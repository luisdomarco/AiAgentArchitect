#!/usr/bin/env python3
"""
AiAgentArchitect — build-context-roots.py

Renders root context files for the host platforms by combining a template with the
`context_root_inject.content` declared by every layer that is enabled in
`config/manifest.yaml`.

Inputs:
  - templates/CLAUDE.md.tpl, templates/AGENTS.md.tpl
  - config/manifest.yaml         (which layers are enabled at root)
  - .agents/layers/{X}/MANIFEST.yaml (per-platform context_root_inject)

Outputs:
  - CLAUDE.md, AGENTS.md         at the project root

Replacement marker:
  - {{ACTIVE_LAYERS}}            replaced with concatenated layer sections
  - {{INVENTORY}}                left as a placeholder comment (filled by build-codex.py)

Zero Python deps: hand-parses the YAML subset our MANIFESTs use.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Optional


# ---------------------------------------------------------------------------
# Minimal hand-parser for our YAML subset
# ---------------------------------------------------------------------------

def read_indented_block(lines: list[str], start: int, base_indent: int) -> tuple[str, int]:
    """Read a `key: |` block starting from line `start+1`. Return (joined_text, end_index).

    Lines belong to the block if their indent is strictly greater than base_indent
    or if they are blank. Stops at the first non-blank line with indent <= base_indent.
    """
    out: list[str] = []
    i = start + 1
    while i < len(lines):
        line = lines[i].rstrip("\n")
        stripped = line.lstrip(" ")
        indent = len(line) - len(stripped)
        if not stripped:
            out.append("")
            i += 1
            continue
        if indent <= base_indent:
            break
        out.append(stripped)
        i += 1
    return "\n".join(out).rstrip(), i


def get_description(text: str) -> str:
    """Extract `description:` from top-level MANIFEST. Supports single-line only."""
    m = re.search(r"^description:\s*(.+?)$", text, re.MULTILINE)
    if not m:
        return ""
    return m.group(1).strip().strip('"').strip("'")


def extract_context_root_inject(text: str, platform: str) -> Optional[dict]:
    """Find platform_targets.{platform}.context_root_inject in MANIFEST.

    Returns a dict {file, section, content} or None if absent / null / not declared.
    Hand-parses the indented YAML block.
    """
    lines = text.splitlines()

    # Find platform_targets:
    pt_idx = None
    for i, line in enumerate(lines):
        if re.match(r"^platform_targets:\s*$", line):
            pt_idx = i
            break
    if pt_idx is None:
        return None

    # Within platform_targets, find {platform}: at indent 2
    plat_idx = None
    for i in range(pt_idx + 1, len(lines)):
        line = lines[i]
        if re.match(r"^[a-zA-Z]", line):
            return None  # left platform_targets block
        m = re.match(r"^  ([\w\-]+):\s*$", line)
        if m and m.group(1) == platform:
            plat_idx = i
            break
    if plat_idx is None:
        return None

    # Within {platform}, find context_root_inject at indent 4
    cri_idx = None
    for i in range(plat_idx + 1, len(lines)):
        line = lines[i]
        stripped = line.lstrip(" ")
        indent = len(line) - len(stripped)
        if not stripped:
            continue
        if indent <= 2:
            return None  # left this platform's block
        m = re.match(r"^    context_root_inject:\s*(.*)$", line)
        if m:
            tail = m.group(1).strip()
            if tail in ("null", "~"):
                return None
            cri_idx = i
            break
    if cri_idx is None:
        return None

    # Parse fields under context_root_inject (indent 6)
    info: dict = {}
    i = cri_idx + 1
    while i < len(lines):
        line = lines[i]
        stripped = line.lstrip(" ")
        indent = len(line) - len(stripped)
        if not stripped:
            i += 1
            continue
        if indent <= 4:
            break
        m = re.match(r"^      ([\w\-]+):\s*(.*)$", line)
        if not m:
            i += 1
            continue
        key, val = m.group(1), m.group(2).strip()
        if val in ("|", ">"):
            block_text, end = read_indented_block(lines, i, 6)
            info[key] = block_text
            i = end
        elif val:
            info[key] = val.strip('"').strip("'")
            i += 1
        else:
            i += 1
    return info if info else None


# ---------------------------------------------------------------------------
# Manifest reader (config/manifest.yaml)
# ---------------------------------------------------------------------------

def list_enabled_root_layers(manifest_text: str) -> list[str]:
    """Parse layers_root from config/manifest.yaml, return list of layer ids with enabled: true."""
    lines = manifest_text.splitlines()
    in_layers_root = False
    enabled: list[str] = []
    current_layer: Optional[str] = None
    for line in lines:
        if re.match(r"^layers_root:\s*$", line):
            in_layers_root = True
            continue
        if in_layers_root:
            if re.match(r"^[a-zA-Z]", line):
                in_layers_root = False
                continue
            m_layer_inline = re.match(r"^  ([\w\-]+):\s*\{([^}]*)\}\s*$", line)
            if m_layer_inline:
                lid = m_layer_inline.group(1)
                inline = m_layer_inline.group(2)
                if "enabled: true" in inline or "enabled:true" in inline:
                    enabled.append(lid)
                current_layer = None
                continue
            m_layer = re.match(r"^  ([\w\-]+):\s*$", line)
            if m_layer:
                current_layer = m_layer.group(1)
                continue
            if current_layer is not None:
                m_enabled = re.match(r"^    enabled:\s*(true|false)\s*$", line)
                if m_enabled and m_enabled.group(1) == "true":
                    enabled.append(current_layer)
                    current_layer = None
    return enabled


# ---------------------------------------------------------------------------
# Render
# ---------------------------------------------------------------------------

def render_layer_section(layer_id: str, description: str, inject: Optional[dict]) -> str:
    """Render a single layer's section for a context root file.

    Always uses `### {layer_id}` as the heading (we are already under the parent
    `## Active Layers` heading, so the layer id is enough). The MANIFEST `section`
    field is preserved as metadata in MANIFEST.yaml but ignored here to avoid
    redundancy ("Active Layers — QA" under "Active Layers" reads like noise).
    """
    if not inject:
        return ""
    content = inject.get("content", description).rstrip()
    return f"### {layer_id}\n\n{content}\n"


def build_active_layers_block(layers_root: Path, enabled: list[str], platform: str) -> str:
    """Concatenate context_root_inject sections of every enabled layer for a platform."""
    chunks: list[str] = []
    for lid in enabled:
        manifest = layers_root / lid / "MANIFEST.yaml"
        if not manifest.exists():
            continue
        text = manifest.read_text(encoding="utf-8")
        desc = get_description(text)
        inject = extract_context_root_inject(text, platform)
        if not inject:
            chunks.append(f"### {lid}\n\n*No context-root injection declared for `{platform}`. Description: {desc}*\n")
            continue
        chunks.append(render_layer_section(lid, desc, inject))

    if not chunks:
        return "## Active Layers\n\n*(no layers active in root)*\n"
    return "## Active Layers\n\n" + "\n".join(chunks)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def render_context_root(
    template_path: Path,
    output_path: Path,
    layers_block: str,
    *,
    inventory_sidecar: Optional[Path] = None,
) -> None:
    """Render a single context root file from its template.

    If `inventory_sidecar` exists (typically `.codex/INVENTORY.md` written by
    build-codex.py), its contents replace the {{INVENTORY}} placeholder.
    Otherwise the placeholder is replaced with a hint comment.
    """
    if not template_path.exists():
        sys.stderr.write(f"WARN: template not found: {template_path}; skipping {output_path.name}\n")
        return

    template = template_path.read_text(encoding="utf-8")
    rendered = template.replace("{{ACTIVE_LAYERS}}", layers_block)

    if inventory_sidecar and inventory_sidecar.exists():
        inventory_text = inventory_sidecar.read_text(encoding="utf-8").rstrip()
        rendered = rendered.replace("{{INVENTORY}}", inventory_text)
    else:
        rendered = rendered.replace(
            "{{INVENTORY}}",
            "<!-- INVENTORY: run `python3 scripts/build-codex.py` to fill -->",
        )

    output_path.write_text(rendered, encoding="utf-8")
    print(f"  wrote {output_path}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="Project root containing config/, templates/, .agents/",
    )
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args()

    config = args.root / "config" / "manifest.yaml"
    layers_root = args.root / ".agents" / "layers"
    templates_dir = args.root / "templates"

    if not config.exists():
        sys.stderr.write(f"ERROR: {config} not found. Run install.sh first.\n")
        return 1
    if not layers_root.exists():
        sys.stderr.write(f"ERROR: {layers_root} not found.\n")
        return 1

    enabled = list_enabled_root_layers(config.read_text(encoding="utf-8"))
    if not args.quiet:
        print(f"Enabled root layers: {', '.join(enabled) if enabled else '(none)'}")

    render_context_root(
        templates_dir / "CLAUDE.md.tpl",
        args.root / "CLAUDE.md",
        build_active_layers_block(layers_root, enabled, "claude_code"),
    )

    render_context_root(
        templates_dir / "AGENTS.md.tpl",
        args.root / "AGENTS.md",
        build_active_layers_block(layers_root, enabled, "codex"),
        inventory_sidecar=args.root / ".codex" / "INVENTORY.md",
    )

    return 0


if __name__ == "__main__":
    sys.exit(main())
