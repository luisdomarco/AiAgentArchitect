#!/usr/bin/env python3
"""
AiAgentArchitect — Entities Registry builder.

Scans `.agents/` (including `.agents/layers/{layer-id}/`) for entity files,
parses YAML frontmatter, and writes `repository/entities-registry.csv`.

This CSV is consumed by `ski-help-router` (and other discoverability skills)
to render context-aware menus and surface relevant entities.

Output columns:
  entity_id, type, layer, description, file_path

Where:
  entity_id   — the value of `name:` in the frontmatter (or filename stem if absent)
  type        — inferred from prefix: wor- → workflow, age-spe- → agent, ski- → skill, etc.
  layer       — `_root` for entities in .agents/{workflows,skills,...}/ directly;
                otherwise the directory name under .agents/layers/ (e.g. `qa`, `memory`)
  description — first line of the `description:` field, trimmed
  file_path   — relative to project root, for click-through

Usage:
  python3 .agents/layers/help-router/scripts/build-registry.py
  python3 .agents/layers/help-router/scripts/build-registry.py --root /path/to/project
  python3 .agents/layers/help-router/scripts/build-registry.py --quiet
"""

from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path

PREFIX_TO_TYPE = {
    "wor-": "workflow",
    "age-spe-": "agent-specialist",
    "age-sup-": "agent-supervisor",
    "com-": "command",
    "ski-": "skill",
    "rul-": "rule",
    "kno-": "knowledge-base",
    "res-": "resource",
    "scp-": "script",
    "hok-": "hook",
}

ENTITY_DIRS = (
    "workflows",
    "agents",  # claude-code style; not used in .agents/ but harmless
    "skills",
    "rules",
    "knowledge-base",
    "resources",
    "scripts",
    "hooks",
    "commands",  # claude-code style
)


def infer_type(stem: str) -> str:
    for prefix, t in PREFIX_TO_TYPE.items():
        if stem.startswith(prefix):
            return t
    return "unknown"


def parse_frontmatter(text: str) -> dict | None:
    """Return a dict of YAML frontmatter fields, or None if malformed/missing.

    Permissive: accepts both `key: value` and `key: "quoted value"`. Handles
    multi-line `description: |` blocks. Stops at the closing `---` or first
    blank line outside the frontmatter.
    """
    if not text.startswith("---"):
        return None
    lines = text.splitlines()
    if len(lines) < 2:
        return None
    end = None
    for i, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            end = i
            break
    if end is None:
        return None

    fields: dict[str, str] = {}
    current_key: str | None = None
    block_lines: list[str] = []
    in_block = False
    for raw in lines[1:end]:
        if in_block:
            if raw.startswith(" ") or raw.startswith("\t"):
                block_lines.append(raw.lstrip())
                continue
            else:
                fields[current_key] = " ".join(block_lines).strip()
                in_block = False
                current_key = None
                block_lines = []
        m = re.match(r"^([A-Za-z0-9_\-]+):\s*(.*)$", raw)
        if not m:
            continue
        key, value = m.group(1), m.group(2).strip()
        if value in ("|", ">"):
            in_block = True
            current_key = key
            block_lines = []
        else:
            value = value.strip().strip('"').strip("'")
            fields[key] = value
    if in_block and current_key is not None:
        fields[current_key] = " ".join(block_lines).strip()
    return fields


def find_entity_files(agents_root: Path) -> list[Path]:
    """Yield entity files under .agents/, including .agents/layers/."""
    candidates: list[Path] = []
    for entity_dir in ENTITY_DIRS:
        for p in agents_root.glob(f"{entity_dir}/*"):
            if p.is_file() and p.suffix == ".md":
                candidates.append(p)
            elif p.is_dir() and (p / "SKILL.md").exists():
                candidates.append(p / "SKILL.md")
    layers_dir = agents_root / "layers"
    if layers_dir.exists():
        for layer_path in layers_dir.iterdir():
            if not layer_path.is_dir() or layer_path.name.startswith("_"):
                continue
            for entity_dir in ENTITY_DIRS:
                for p in (layer_path / entity_dir).glob("*"):
                    if p.is_file() and p.suffix == ".md":
                        candidates.append(p)
                    elif p.is_dir() and (p / "SKILL.md").exists():
                        candidates.append(p / "SKILL.md")
    return candidates


def layer_for(file_path: Path, agents_root: Path) -> str:
    rel = file_path.relative_to(agents_root)
    parts = rel.parts
    if parts and parts[0] == "layers" and len(parts) > 1:
        return parts[1]
    return "_root"


def entity_id_for(file_path: Path, fields: dict | None) -> str:
    if fields and fields.get("name"):
        return fields["name"]
    if file_path.name == "SKILL.md":
        return file_path.parent.name
    return file_path.stem


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[4],
        help="Project root containing .agents/ and repository/",
    )
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args()

    agents_root = args.root / ".agents"
    if not agents_root.exists():
        sys.stderr.write(f"ERROR: {agents_root} not found.\n")
        return 1

    repo_dir = args.root / "repository"
    repo_dir.mkdir(parents=True, exist_ok=True)
    out = repo_dir / "entities-registry.csv"

    rows: list[dict[str, str]] = []
    for file_path in find_entity_files(agents_root):
        try:
            text = file_path.read_text(encoding="utf-8")
        except OSError as e:
            if not args.quiet:
                sys.stderr.write(f"WARN: skipping {file_path}: {e}\n")
            continue

        fields = parse_frontmatter(text)
        eid = entity_id_for(file_path, fields)
        etype = infer_type(eid)
        elayer = layer_for(file_path, agents_root)
        edesc = (fields or {}).get("description", "").strip()
        # Truncate to first sentence or 200 chars for CSV readability.
        first_sentence = re.split(r"(?<=[.!?])\s", edesc, maxsplit=1)[0]
        edesc_short = (first_sentence or edesc)[:200].strip()
        rel = file_path.relative_to(args.root)

        rows.append(
            {
                "entity_id": eid,
                "type": etype,
                "layer": elayer,
                "description": edesc_short,
                "file_path": str(rel),
            }
        )

    rows.sort(key=lambda r: (r["layer"], r["type"], r["entity_id"]))

    with out.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(
            f, fieldnames=["entity_id", "type", "layer", "description", "file_path"]
        )
        writer.writeheader()
        writer.writerows(rows)

    if not args.quiet:
        sys.stdout.write(
            f"Wrote {len(rows)} entities to {out.relative_to(args.root)}\n"
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
