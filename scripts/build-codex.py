#!/usr/bin/env python3
"""
build-codex.py — Compiles .agents/ (Google Antigravity) → .codex/ (OpenAI Codex)

One-way compilation: .codex/ is a build artifact, never edited directly.
All behavioral entities (wor-*, age-*, com-*) become TOML agents.
All procedural entities (ski-*, rul-*, kno-*, res-*) are direct copies.
Scripts become executables. Hooks produce .md + .json fragments merged into hooks.json.

Usage:
    python3 scripts/build-codex.py                        # Build .codex/ from .agents/
    python3 scripts/build-codex.py --export exports/foo   # Build for an export
    python3 scripts/build-codex.py --validate             # Validate only
    python3 scripts/build-codex.py --clean                # Clean and rebuild

Dependencies: Python 3.10+, stdlib only.
"""

import argparse
import json
import re
import shutil
import sys
from pathlib import Path


# ── Model mapping ────────────────────────────────────────────────────────────

MODEL_MAP = {
    # Gemini (Antigravity-native, source of truth in .agents/)
    "gemini-2.0-flash": ("gpt-5.4-mini", "low"),
    "gemini-2.5-pro": ("gpt-5.4", "medium"),
    "gemini-3-flash": ("gpt-5.4-mini", "low"),
    "gemini-3.1": ("gpt-5.4", "medium"),
    "gemini-3.1-pro": ("gpt-5.4", "high"),
    # Claude (so .codex/ build also works if invoked from a Claude-mapped source)
    "haiku": ("gpt-5.4-mini", "low"),
    "sonnet": ("gpt-5.4", "medium"),
    "opus": ("gpt-5.4", "high"),
}

DEFAULT_MODEL = ("gpt-5.4", "medium")


# ── Frontmatter parsing ─────────────────────────────────────────────────────

def parse_frontmatter(content: str) -> tuple[dict, str]:
    """Parse YAML frontmatter and return (metadata_dict, body_content)."""
    if not content.startswith("---"):
        return {}, content

    end = content.find("---", 3)
    if end == -1:
        return {}, content

    fm_text = content[3:end].strip()
    body = content[end + 3:].strip()

    metadata = {}
    current_key = None
    current_value_lines = []

    for line in fm_text.split("\n"):
        # Simple key: value parsing (handles most YAML frontmatter)
        match = re.match(r"^(\w[\w-]*):\s*(.*)", line)
        if match:
            if current_key:
                metadata[current_key] = "\n".join(current_value_lines).strip()
            current_key = match.group(1)
            current_value_lines = [match.group(2)]
        elif current_key and line.startswith("  "):
            current_value_lines.append(line.strip())

    if current_key:
        metadata[current_key] = "\n".join(current_value_lines).strip()

    return metadata, body


# ── TOML generation ──────────────────────────────────────────────────────────

def escape_toml_literal(text: str) -> str:
    """Escape text for TOML single-quoted literal string (''').

    In TOML literal strings, no escaping is performed.
    The only forbidden sequence is ''' itself.
    """
    return text.replace("'''", "```")


def extract_skills_from_body(body: str) -> list[str]:
    """Extract skill names from a markdown Skills table in the body."""
    skills = []
    # Match patterns like `ski-name` in table rows
    for match in re.finditer(r"`(ski-[\w-]+)`", body):
        skill_name = match.group(1)
        if skill_name not in skills:
            skills.append(skill_name)
    return skills


def name_to_nickname(name: str) -> str:
    """Convert kebab-case entity name to human-readable title.

    Examples:
        age-spe-email-classifier → Email Classifier
        wor-agentic-architect → Agentic Architect
        com-export-system → Export System
    """
    # Strip prefixes
    for prefix in ("wor-", "com-", "age-spe-", "age-sup-"):
        if name.startswith(prefix):
            name = name[len(prefix):]
            break
    return name.replace("-", " ").title()


def generate_toml(metadata: dict, body: str, source_path: str) -> str:
    """Generate TOML agent file content from parsed frontmatter and body."""
    name = metadata.get("name", "")
    description = metadata.get("description", "")
    model_key = metadata.get("model", "sonnet")

    # Clean up model value (remove comments)
    model_key = model_key.split("#")[0].strip()
    # Handle multi-value model fields (e.g. "sonnet | opus | haiku")
    if "|" in model_key:
        model_key = model_key.split("|")[0].strip()

    codex_model, reasoning_effort = MODEL_MAP.get(model_key, DEFAULT_MODEL)
    nickname = name_to_nickname(name)
    skills = extract_skills_from_body(body)

    escaped_body = escape_toml_literal(body)

    lines = [
        f"# AUTO-GENERATED from .agents/ — Do not edit directly.",
        f"# Source: {source_path}",
        f"# Rebuild: python3 scripts/build-codex.py",
        f"",
        f'name = "{name}"',
        f'description = "{description}"',
        f"",
        f"developer_instructions = '''",
        escaped_body,
        f"'''",
        f"",
        f'nickname_candidates = ["{nickname}"]',
        f'model = "{codex_model}"',
        f'model_reasoning_effort = "{reasoning_effort}"',
        f"sandbox_mode = true",
    ]

    for skill in skills:
        lines.extend([
            f"",
            f"[[skills.config]]",
            f'path = ".codex/skills/{skill}"',
            f"enabled = true",
        ])

    return "\n".join(lines) + "\n"


# ── Orphan pruning ──────────────────────────────────────────────────────────

# Files that the build always produces but that aren't tracked per-entity.
# These live at the root of the output directory and must never be pruned.
PROTECTED_OUTPUTS = {"AGENTS.md", "INVENTORY.md", "config.toml", "hooks.json"}


def prune_codex_orphans(output: Path, generated_files: set[Path]) -> int:
    """Remove files in output/ that were not produced by this build run.

    Skips PROTECTED_OUTPUTS at the root and any file whose resolved path is in
    generated_files. After deleting orphan files, removes empty subdirectories.

    Returns the number of orphan files removed.
    """
    if not output.exists():
        return 0

    pruned = 0
    for f in output.rglob("*"):
        if not f.is_file():
            continue
        if f.parent == output and f.name in PROTECTED_OUTPUTS:
            continue
        if f.resolve() not in generated_files:
            f.unlink()
            print(f"  [PRUNE] {f.relative_to(output.parent)}")
            pruned += 1

    # Remove empty subdirectories (deepest first)
    for d in sorted(output.rglob("*"), key=lambda p: -len(p.parts)):
        if d.is_dir() and not any(d.iterdir()):
            d.rmdir()

    if pruned > 0:
        print(f"\nPruned {pruned} orphan file(s) from {output}/")
    return pruned


def find_codex_orphans(output: Path, generated_files: set[Path]) -> list[Path]:
    """Return files in output/ not produced by this build (no deletion). Used by --validate."""
    if not output.exists():
        return []
    orphans: list[Path] = []
    for f in output.rglob("*"):
        if not f.is_file():
            continue
        if f.parent == output and f.name in PROTECTED_OUTPUTS:
            continue
        if f.resolve() not in generated_files:
            orphans.append(f)
    return orphans


# ── Hook fragment generation ────────────────────────────────────────────────

CODEX_SUPPORTED_EVENTS = {
    "SessionStart", "PreToolUse", "PostToolUse",
    "UserPromptSubmit", "Stop",
}


def generate_hook_fragment(metadata: dict) -> dict | None:
    """Generate a hook JSON fragment from hook frontmatter. Returns None if event unsupported."""
    event = metadata.get("event", "")
    if not event or event not in CODEX_SUPPORTED_EVENTS:
        return None

    matcher = metadata.get("matcher", "")
    hook_type = metadata.get("type", "command")

    fragment = {
        "event": event,
        "matcher": matcher,
        "hook": {
            "type": hook_type,
            "timeout": 600,
        },
    }

    return fragment


def merge_hook_fragments(fragments: list[dict]) -> dict:
    """Merge individual hook fragments into a single hooks.json structure."""
    merged = {"hooks": {}}

    for frag in fragments:
        event = frag["event"]
        if event not in merged["hooks"]:
            merged["hooks"][event] = []

        entry = {"hooks": [frag["hook"]]}
        if frag.get("matcher"):
            entry["matcher"] = frag["matcher"]

        merged["hooks"][event].append(entry)

    return merged


# ── AGENTS.md generation ─────────────────────────────────────────────────────

def _group_by_layer(items: list[dict]) -> dict[str, list[dict]]:
    """Group inventory items by their `layer` field. Items without `layer` go to _root."""
    grouped: dict[str, list[dict]] = {}
    for it in items:
        grouped.setdefault(it.get("layer", "_root"), []).append(it)
    return grouped


def _location_for(item_type: str, name: str, layer: str) -> str:
    """Compute the .codex/ path of an entity given its type and (optional) layer."""
    base = f".codex/layers/{layer}" if layer != "_root" else ".codex"
    if item_type == "agent":
        return f"{base}/agents/{name}.toml"
    if item_type == "skill":
        return f"{base}/skills/{name}/SKILL.md"
    if item_type == "rule":
        return f"{base}/rules/{name}.md"
    if item_type == "kb":
        return f"{base}/knowledge-base/{name}.md"
    return base


def generate_agents_md(agents: list[dict], skills: list[dict],
                       rules: list[dict], kbs: list[dict],
                       system_name: str = "") -> str:
    """Generate AGENTS.md content from entity inventories grouped by layer.

    Root-level entities (layer == "_root") render first under the canonical
    headings. Layer-specific entities render under "## Layer: <name>" sub-headings
    so a reader can see at a glance which entities ship with which capability.
    """
    lines = [f"# {system_name or 'System'}", ""]

    agents_by = _group_by_layer(agents)
    skills_by = _group_by_layer(skills)
    rules_by = _group_by_layer(rules)
    kbs_by = _group_by_layer(kbs)

    # ── Root-level entities ──────────────────────────────────────────────
    if agents_by.get("_root"):
        lines.extend(["## Agents (root)", "",
                      "| Agent | Description | Invoke with |",
                      "|---|---|---|"])
        for a in agents_by["_root"]:
            name = a["name"]
            desc = a.get("description", "")
            invoke = ("Invoked as subagent by workflows"
                      if name.startswith("age-")
                      else f"Ask Codex to invoke `{name}`")
            lines.append(f"| `{name}` | {desc} | {invoke} |")
        lines.append("")

    if skills_by.get("_root"):
        lines.extend(["## Skills (root)", "",
                      "| Skill | Location | Description |",
                      "|---|---|---|"])
        for s in skills_by["_root"]:
            lines.append(
                f"| `{s['name']}` | `{_location_for('skill', s['name'], '_root')}` | {s.get('description', '')} |")
        lines.append("")

    if rules_by.get("_root"):
        lines.extend(["## Rules (root)", "",
                      "Rules are loaded from `.codex/rules/`:"])
        for r in rules_by["_root"]:
            lines.append(f"- `{r['name']}` — {r.get('description', '')}")
        lines.append("")

    if kbs_by.get("_root"):
        lines.extend(["## Knowledge Base (root)", ""])
        for k in kbs_by["_root"]:
            lines.append(
                f"- `{k['name']}` — {k.get('description', '')} "
                f"(`{_location_for('kb', k['name'], '_root')}`)")
        lines.append("")

    # ── Layer-specific entities ──────────────────────────────────────────
    all_layers = sorted(
        set(agents_by) | set(skills_by) | set(rules_by) | set(kbs_by)
    )
    layer_ids = [l for l in all_layers if l != "_root"]

    if layer_ids:
        lines.extend(["## Layers", "",
                      "Modular capabilities embedded under `.codex/layers/{layer-id}/`. "
                      "Each layer mirrors the root structure (agents/, skills/, rules/, ...)."])
        lines.append("")
        for layer_id in layer_ids:
            lines.append(f"### Layer: {layer_id}")
            lines.append("")
            agents_l = agents_by.get(layer_id, [])
            skills_l = skills_by.get(layer_id, [])
            rules_l = rules_by.get(layer_id, [])
            kbs_l = kbs_by.get(layer_id, [])

            counts = []
            if agents_l: counts.append(f"{len(agents_l)} agent(s)")
            if skills_l: counts.append(f"{len(skills_l)} skill(s)")
            if rules_l: counts.append(f"{len(rules_l)} rule(s)")
            if kbs_l: counts.append(f"{len(kbs_l)} knowledge-base(s)")
            lines.append(f"Provides: {', '.join(counts) if counts else '(none)'}")
            lines.append("")

            if agents_l:
                lines.append("Agents:")
                for a in agents_l:
                    lines.append(f"- `{a['name']}` — {a.get('description', '')}")
                lines.append("")
            if skills_l:
                lines.append("Skills:")
                for s in skills_l:
                    lines.append(f"- `{s['name']}` — `{_location_for('skill', s['name'], layer_id)}`")
                lines.append("")
            if rules_l:
                lines.append("Rules:")
                for r in rules_l:
                    lines.append(f"- `{r['name']}` — {r.get('description', '')}")
                lines.append("")
            if kbs_l:
                lines.append("Knowledge Base:")
                for k in kbs_l:
                    lines.append(f"- `{k['name']}` — `{_location_for('kb', k['name'], layer_id)}`")
                lines.append("")

    # Note: the directory structure section is provided by the AGENTS.md template;
    # we don't duplicate it here since this content is embedded into the template.

    return "\n".join(lines) + "\n"


# ── Main build logic ────────────────────────────────────────────────────────

def process_source_dir(
    source: Path,
    output: Path,
    *,
    layer_label: str = "",
    inventories: dict | None = None,
    hook_fragments: list | None = None,
    stats: dict | None = None,
    generated_files: set[Path] | None = None,
    validate_only: bool = False,
) -> int:
    """Process a single source directory tree (root .agents/ or one .agents/layers/{X}/).

    Iterates all entity subdirectories (workflows, skills, rules, knowledge-base,
    resources, scripts, hooks), parses frontmatter, generates TOML for behavioral
    entities, and direct-copies the rest to the corresponding output subdirectory.

    layer_label is a non-empty string ("qa", "memory", ...) when processing a layer,
    or "" when processing the root .agents/ directory. It is only used for log prefix.

    Mutates the shared inventories/hook_fragments/stats/generated_files containers
    so the caller can aggregate across root and all layers. generated_files records
    every dest path written (or that would be written, in validate mode) — used by
    prune_codex_orphans / find_codex_orphans.

    Returns the number of errors encountered.
    """
    errors = 0
    label = f"[{layer_label}] " if layer_label else ""
    if inventories is None:
        inventories = {"agents": [], "skills": [], "rules": [], "kbs": []}
    if hook_fragments is None:
        hook_fragments = []
    if stats is None:
        stats = {"agents": 0, "skills": 0, "rules": 0, "kb": 0,
                 "resources": 0, "scripts": 0, "hooks": 0}
    if generated_files is None:
        generated_files = set()

    # ── Behavioral entities → TOML ───────────────────────────────────────
    workflows_dir = source / "workflows"
    if workflows_dir.exists():
        for md_file in sorted(workflows_dir.glob("*.md")):
            name = md_file.stem
            content = md_file.read_text(encoding="utf-8")
            metadata, body = parse_frontmatter(content)

            if not metadata.get("name"):
                metadata["name"] = name

            toml_content = generate_toml(
                metadata, body,
                source_path=str(md_file.relative_to(source.parent))
            )

            dest = output / "agents" / f"{name}.toml"
            inventories["agents"].append({
                "name": metadata["name"],
                "description": metadata.get("description", ""),
                "layer": layer_label or "_root",
            })

            if not validate_only:
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_text(toml_content, encoding="utf-8")
            generated_files.add(dest.resolve())

            stats["agents"] += 1
            print(f"  [TOML] {label}{md_file.name} → {output.name}/agents/{name}.toml")

    # ── Skills → Direct copy ─────────────────────────────────────────────
    skills_dir = source / "skills"
    if skills_dir.exists():
        for skill_dir in sorted(skills_dir.iterdir()):
            if not skill_dir.is_dir() or not skill_dir.name.startswith("ski-"):
                continue
            skill_md = skill_dir / "SKILL.md"
            if not skill_md.exists():
                print(f"  [WARN] {label}No SKILL.md in {skill_dir.name}/", file=sys.stderr)
                continue

            content = skill_md.read_text(encoding="utf-8")
            metadata, _ = parse_frontmatter(content)

            inventories["skills"].append({
                "name": metadata.get("name", skill_dir.name),
                "description": metadata.get("description", ""),
                "layer": layer_label or "_root",
            })

            dest = output / "skills" / skill_dir.name / "SKILL.md"
            if not validate_only:
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_text(content, encoding="utf-8")
            generated_files.add(dest.resolve())

            stats["skills"] += 1
            print(f"  [COPY] {label}skills/{skill_dir.name}/SKILL.md")

    # ── Rules → Direct copy ──────────────────────────────────────────────
    rules_dir = source / "rules"
    if rules_dir.exists():
        for rule_file in sorted(rules_dir.glob("rul-*.md")):
            content = rule_file.read_text(encoding="utf-8")
            metadata, _ = parse_frontmatter(content)

            inventories["rules"].append({
                "name": metadata.get("name", rule_file.stem),
                "description": metadata.get("description", ""),
                "layer": layer_label or "_root",
            })

            dest = output / "rules" / rule_file.name
            if not validate_only:
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_text(content, encoding="utf-8")
            generated_files.add(dest.resolve())

            stats["rules"] += 1
            print(f"  [COPY] {label}rules/{rule_file.name}")

    # ── Knowledge-base → Direct copy ─────────────────────────────────────
    kb_dir = source / "knowledge-base"
    if kb_dir.exists():
        for kb_file in sorted(kb_dir.glob("kno-*.md")):
            content = kb_file.read_text(encoding="utf-8")
            metadata, _ = parse_frontmatter(content)

            inventories["kbs"].append({
                "name": metadata.get("name", kb_file.stem),
                "description": metadata.get("description", ""),
                "layer": layer_label or "_root",
            })

            dest = output / "knowledge-base" / kb_file.name
            if not validate_only:
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_text(content, encoding="utf-8")
            generated_files.add(dest.resolve())

            stats["kb"] += 1
            print(f"  [COPY] {label}knowledge-base/{kb_file.name}")

    # ── Resources → Direct copy ──────────────────────────────────────────
    res_dir = source / "resources"
    if res_dir.exists():
        for res_file in sorted(res_dir.glob("res-*.md")):
            dest = output / "resources" / res_file.name
            if not validate_only:
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_text(
                    res_file.read_text(encoding="utf-8"), encoding="utf-8")
            generated_files.add(dest.resolve())

            stats["resources"] += 1
            print(f"  [COPY] {label}resources/{res_file.name}")

    # ── Scripts → Copy (already executable or convert) ────────────────────
    scripts_dir = source / "scripts"
    if scripts_dir.exists():
        for script_file in sorted(scripts_dir.glob("scp-*")):
            dest = output / "scripts" / script_file.name
            if not validate_only:
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(script_file, dest)
            generated_files.add(dest.resolve())

            stats["scripts"] += 1
            print(f"  [COPY] {label}scripts/{script_file.name}")

    # ── Hooks → Copy .md + generate .json fragment ───────────────────────
    hooks_dir = source / "hooks"
    if hooks_dir.exists():
        for hook_file in sorted(hooks_dir.glob("hok-*.md")):
            content = hook_file.read_text(encoding="utf-8")
            metadata, _ = parse_frontmatter(content)

            dest_md = output / "hooks" / hook_file.name
            if not validate_only:
                dest_md.parent.mkdir(parents=True, exist_ok=True)
                dest_md.write_text(content, encoding="utf-8")
            generated_files.add(dest_md.resolve())

            fragment = generate_hook_fragment(metadata)
            if fragment:
                json_name = hook_file.stem + ".json"
                dest_json = output / "hooks" / json_name
                if not validate_only:
                    dest_json.write_text(
                        json.dumps(fragment, indent=2) + "\n",
                        encoding="utf-8")
                generated_files.add(dest_json.resolve())
                hook_fragments.append(fragment)
                print(f"  [HOOK] {label}hooks/{hook_file.name} + {json_name}")
            else:
                event = metadata.get("event", "unknown")
                print(f"  [HOOK] {label}hooks/{hook_file.name} (event '{event}' — no Codex equivalent, .md only)")

            stats["hooks"] += 1

    return errors


def build(source: Path, output: Path, validate_only: bool = False,
          prune: bool = False) -> bool:
    """Build .codex/ from .agents/ source. Includes root and every .agents/layers/{X}/.

    When `prune=True`, removes any file in `output/` not produced by this build run
    (orphans from renamed/deleted entities). When `validate_only=True`, instead
    reports orphans and treats their presence as a validation failure.

    Returns True on success.
    """
    if not source.exists():
        print(f"Error: source directory '{source}' does not exist.", file=sys.stderr)
        return False

    inventories = {"agents": [], "skills": [], "rules": [], "kbs": []}
    hook_fragments: list = []
    stats = {"agents": 0, "skills": 0, "rules": 0, "kb": 0,
             "resources": 0, "scripts": 0, "hooks": 0}
    generated_files: set[Path] = set()
    errors = 0

    # ── Process root .agents/ → .codex/ ──────────────────────────────────
    print(f"-- Processing root: {source} → {output}")
    errors += process_source_dir(
        source, output,
        layer_label="",
        inventories=inventories, hook_fragments=hook_fragments,
        stats=stats, generated_files=generated_files, validate_only=validate_only,
    )

    # ── Process every .agents/layers/{X}/ → .codex/layers/{X}/ ───────────
    layers_root = source / "layers"
    if layers_root.exists():
        for layer_dir in sorted(layers_root.iterdir()):
            if not layer_dir.is_dir() or layer_dir.name.startswith("_"):
                continue
            layer_id = layer_dir.name
            layer_output = output / "layers" / layer_id
            print(f"-- Processing layer: {layer_dir} → {layer_output}")
            errors += process_source_dir(
                layer_dir, layer_output,
                layer_label=layer_id,
                inventories=inventories, hook_fragments=hook_fragments,
                stats=stats, generated_files=generated_files, validate_only=validate_only,
            )

    # ── Merge hook fragments → hooks.json (root level only) ──────────────
    merged_hooks = merge_hook_fragments(hook_fragments)
    hooks_json_path = output / "hooks.json"
    if not validate_only:
        hooks_json_path.parent.mkdir(parents=True, exist_ok=True)
        hooks_json_path.write_text(
            json.dumps(merged_hooks, indent=2) + "\n", encoding="utf-8")
    # hooks.json is a PROTECTED_OUTPUT — no need to add to generated_files,
    # but doing so makes the orphan check trivially correct.
    generated_files.add(hooks_json_path.resolve())
    print(f"  [MERGE] hooks.json ({len(hook_fragments)} fragments)")

    try:
        json.dumps(merged_hooks)
    except (TypeError, ValueError) as e:
        print(f"  [ERROR] Invalid hooks.json: {e}", file=sys.stderr)
        errors += 1

    # ── Generate config.toml (root level) ────────────────────────────────
    config_path = output / "config.toml"
    if not validate_only:
        config_path.write_text(
            "[agents]\n"
            "max_threads = 6\n"
            "max_depth = 1\n"
            "job_max_runtime_seconds = 1800\n",
            encoding="utf-8")
    generated_files.add(config_path.resolve())

    # ── Inventory section for AGENTS.md ──────────────────────────────────
    # We do NOT write AGENTS.md directly; build-context-roots.py owns the file.
    # We compute the inventory section here and write it to a sidecar file that
    # build-context-roots.py reads when filling its {{INVENTORY}} placeholder.
    system_name = source.parent.name
    if system_name in (".", ""):
        system_name = "AiAgentArchitect"

    agents_md_inventory = generate_agents_md(
        inventories["agents"], inventories["skills"],
        inventories["rules"], inventories["kbs"],
        system_name=system_name)

    sidecar = output / "INVENTORY.md"
    if not validate_only:
        sidecar.parent.mkdir(parents=True, exist_ok=True)
        sidecar.write_text(agents_md_inventory, encoding="utf-8")
        # Then invoke build-context-roots.py so AGENTS.md picks up the fresh inventory.
        try:
            from subprocess import run as _run
            project_root = source.parent if source.parent.name not in ("", ".") else Path(".")
            script = project_root / "scripts" / "build-context-roots.py"
            if script.exists():
                _run([sys.executable, str(script), "--quiet"], check=False)
        except Exception as e:
            print(f"  [WARN] Could not invoke build-context-roots.py: {e}", file=sys.stderr)
    generated_files.add(sidecar.resolve())

    # ── Summary ──────────────────────────────────────────────────────────
    print()
    total = sum(stats.values())
    mode = "Validated" if validate_only else "Built"
    print(f"{mode} .codex/ — {total} entities:")
    print(f"  Agents (TOML): {stats['agents']}")
    print(f"  Skills:        {stats['skills']}")
    print(f"  Rules:         {stats['rules']}")
    print(f"  Knowledge-base:{stats['kb']}")
    print(f"  Resources:     {stats['resources']}")
    print(f"  Scripts:       {stats['scripts']}")
    print(f"  Hooks:         {stats['hooks']}")

    layers_seen = sorted(set(item["layer"] for item in inventories["agents"] + inventories["skills"] + inventories["rules"] + inventories["kbs"]) - {"_root"})
    if layers_seen:
        print(f"  Layers:        {', '.join(layers_seen)}")

    # ── Prune or report orphans ──────────────────────────────────────────
    if validate_only:
        orphans = find_codex_orphans(output, generated_files)
        if orphans:
            print(f"\n⚠️  {len(orphans)} orphan file(s) in {output}/:")
            for o in orphans:
                print(f"   {o.relative_to(output.parent)}")
            print(f"\nRun: python3 scripts/build-codex.py --prune")
            errors += 1
    elif prune:
        prune_codex_orphans(output, generated_files)

    if errors:
        print(f"\n{errors} error(s) detected.", file=sys.stderr)
    else:
        print("\nNo errors.")

    return errors == 0


# ── CLI ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Compile .agents/ (Google Antigravity) → .codex/ (OpenAI Codex)")
    parser.add_argument(
        "--source", type=Path, default=Path(".agents"),
        help="Source .agents/ directory (default: .agents/)")
    parser.add_argument(
        "--output", type=Path, default=Path(".codex"),
        help="Output .codex/ directory (default: .codex/)")
    parser.add_argument(
        "--export", type=Path, default=None,
        help="Build for an export directory (e.g. exports/my-system)")
    parser.add_argument(
        "--validate", action="store_true",
        help="Only validate, don't generate files")
    parser.add_argument(
        "--clean", action="store_true",
        help="Remove output directory before building (destructive opt-in)")
    parser.add_argument(
        "--prune", action="store_true",
        help="After building, remove .codex/ files that were not produced by this build "
             "(orphans from renamed or deleted entities)")

    args = parser.parse_args()

    # Handle --export shortcut
    if args.export:
        args.source = args.export / ".agents"
        args.output = args.export / ".codex"

        # (v3) Respect the subsystem's `platforms` list. Skip if 'codex' is not
        # active. At the root (no --export), this check is a no-op.
        if not _subsystem_has_platform(args.export, "codex"):
            print(f"Skipping .codex/ build — 'codex' not in platforms of {args.export}/config/manifest.yaml")
            sys.exit(0)

    print(f"Source: {args.source}")
    print(f"Output: {args.output}")
    print()

    if args.clean and args.output.exists():
        print(f"Cleaning {args.output}/...")
        shutil.rmtree(args.output)
        print()

    if not args.validate:
        args.output.mkdir(parents=True, exist_ok=True)

    success = build(args.source, args.output,
                    validate_only=args.validate, prune=args.prune)
    sys.exit(0 if success else 1)


def _subsystem_has_platform(export_dir: Path, platform: str) -> bool:
    """Return True if the subsystem's manifest.yaml lists `platform` in its
    `platforms` list. Returns True (permissive) if no manifest exists or it
    cannot be parsed — preserving backward-compatibility with pre-v3 exports.
    """
    manifest = export_dir / "config" / "manifest.yaml"
    if not manifest.exists():
        return True
    try:
        # Light YAML parse: avoid importing PyYAML (not always available).
        # The manifest is structured: look for "platforms:" block, then list items.
        in_platforms = False
        for line in manifest.read_text(encoding="utf-8").splitlines():
            stripped = line.rstrip()
            if stripped == "platforms:" or stripped.startswith("platforms:"):
                in_platforms = True
                continue
            if in_platforms:
                if stripped.startswith("  - ") or stripped.startswith("- "):
                    item = stripped.lstrip().lstrip("-").strip().strip("'\"")
                    if item == platform:
                        return True
                elif stripped and not stripped.startswith(" ") and not stripped.startswith("#"):
                    # End of platforms block
                    break
        return False
    except Exception:
        return True  # parse error → permissive


if __name__ == "__main__":
    main()
