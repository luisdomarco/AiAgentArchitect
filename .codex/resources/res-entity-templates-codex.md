---
name: res-entity-templates-codex
description: OpenAI Codex platform-specific entity templates, TOML agent format, AGENTS.md generation rules, hook fragment JSON schema, and model mapping. Use when generating entity files for the .codex/ export structure.
tags: [template, codex, openai, platform, formatting, toml]
---

# OpenAI Codex Entity Templates

Platform-specific additions and transformations for OpenAI Codex (`.codex/`). These supplement the core GA templates in `res-entity-templates-behavioral.md` (behavioral entities) and `res-entity-templates-support.md` (support entities).

---

## 1. TOML Agent Format

All behavioral entities (Workflows `wor-*`, Commands `com-*`, Agents `age-*`) are converted to TOML custom agent files in `.codex/agents/`:

```toml
# AUTO-GENERATED from .agents/ — Do not edit directly.
# Source: .agents/workflows/[source-file].md
# Rebuild: python3 scripts/build-codex.py

name = "[entity-name]"
description = "[max 250 chars — from frontmatter description]"

developer_instructions = '''
[Full markdown body content extracted from the .md source file.
Includes all sections: Role & Mission, Context, Goals, Tasks,
Execution Protocol / Workflow Sequence, Rules, Definition of success.
Single-quoted TOML literal string to avoid escaping issues.]
'''

nickname_candidates = ["[Human Readable Name]"]
model = "gpt-5.4"
model_reasoning_effort = "medium"
sandbox_mode = true

[[skills.config]]
path = ".codex/skills/ski-[name]"
enabled = true
```

### Conversion rules

1. **Frontmatter** `name` → TOML `name` (preserve exact value)
2. **Frontmatter** `description` → TOML `description`
3. **Frontmatter** `model` → mapped via model table (§2)
4. **Markdown body** (everything after frontmatter `---`) → TOML `developer_instructions` wrapped in `'''` (single-quoted literal)
5. **Skills table** in the markdown → `[[skills.config]]` entries with paths adjusted to `.codex/skills/`
6. **Agent references** in the body: replace `./age-spe-*.md` / `../agents/age-spe-*.md` with Codex subagent invocation description
7. **`nickname_candidates`**: derive from entity name — convert `kebab-case` to `Title Case`, remove prefix (`wor-`, `age-spe-`, `com-`)
8. **`sandbox_mode`**: always `true` by default
9. Prepend `# AUTO-GENERATED` comment header

### Escaping

Use `'''` (single-quoted TOML literal strings) for `developer_instructions`. This avoids all escaping issues since single-quoted literals in TOML treat backslashes and quotes as literal characters. The only character that cannot appear is `'''` itself — if the source markdown contains `'''`, replace with `` ``` `` (backtick code fence).

---

## 2. Model Mapping

| GA Model | CC Model | Codex Model | Codex Reasoning Effort |
|---|---|---|---|
| `gemini-3-flash` | `haiku` | `gpt-5.4-mini` | `"low"` |
| `gemini-3.1` | `sonnet` | `gpt-5.4` | `"medium"` |
| _(none)_ | `opus` | `gpt-5.4` | `"high"` |

---

## 3. Directory Mapping (GA → Codex)

| Entity | GA path | Codex path | Transformation |
|---|---|---|---|
| Workflow | `workflows/wor-*.md` | `agents/wor-*.toml` | MD → TOML |
| Agent | `workflows/age-*.md` | `agents/age-*.toml` | MD → TOML |
| Command | `workflows/com-*.md` | `agents/com-*.toml` | MD → TOML |
| Skill | `skills/ski-*/SKILL.md` | `skills/ski-*/SKILL.md` | Direct copy |
| Rule | `rules/rul-*.md` | `rules/rul-*.md` | Direct copy |
| Knowledge-base | `knowledge-base/kno-*.md` | `knowledge-base/kno-*.md` | Direct copy |
| Resources | `resources/res-*.md` | `resources/res-*.md` | Direct copy |
| Script | `scripts/scp-*.md` | `scripts/scp-*.sh` or `.py` | MD → executable |
| Hook | `hooks/hok-*.md` | `hooks/hok-*.md` + `hok-*.json` | Copy + JSON fragment |

---

## 4. Hook Fragment JSON Format

Each Hook entity produces an individual JSON fragment file in `.codex/hooks/`:

```json
{
  "event": "[EventName]",
  "matcher": "[tool-name-or-pattern]",
  "hook": {
    "type": "command",
    "command": ".codex/scripts/scp-[name].sh",
    "timeout": 600
  }
}
```

Handler types: `command`, `prompt`, `agent`, `http`.

The build script (`build-codex.py`) merges all fragments into `.codex/hooks.json`:

```json
{
  "hooks": {
    "[EventName]": [
      {
        "matcher": "[pattern]",
        "hooks": [
          { "type": "command", "command": "...", "timeout": 600 }
        ]
      }
    ]
  }
}
```

---

## 5. AGENTS.md Template

Generated at the export root (`exports/{name}/AGENTS.md`):

```markdown
# [System Name]

[System description — from process-overview.md]

## Agents

| Agent | Description | Invoke with |
|---|---|---|
| `wor-[name]` | [description] | Ask Codex to invoke `wor-[name]` |
| `age-spe-[name]` | [description] | Invoked as subagent by workflows |
| `com-[name]` | [description] | Ask Codex to invoke `com-[name]` |

## Skills

| Skill | Location | Description |
|---|---|---|
| `ski-[name]` | `.codex/skills/ski-[name]/SKILL.md` | [description] |

## Rules

Rules are loaded from `.codex/rules/`:
- `rul-[name]` — [description]

## Knowledge Base

- `kno-[name]` — [description] (`.codex/knowledge-base/kno-[name].md`)

## Structure

\`\`\`
.codex/
├── agents/           ← TOML agent definitions
├── skills/           ← skill subdirectories (SKILL.md)
├── rules/            ← behavioral rules (.md)
├── knowledge-base/   ← reference knowledge (.md)
├── resources/        ← support resources (.md)
├── scripts/          ← executable scripts (.sh/.py)
├── hooks/            ← hook docs (.md) + fragments (.json)
├── hooks.json        ← merged hook config
└── config.toml       ← Codex configuration
\`\`\`
```

---

## 6. config.toml Template

```toml
[agents]
max_threads = 6
max_depth = 1
job_max_runtime_seconds = 1800
```

---

## 7. Codex-exclusive Files (not in GA or CC)

| File | Purpose |
|---|---|
| `.codex/agents/*.toml` | Custom agent definitions (compiled from .md) |
| `.codex/hooks/*.json` | Individual hook config fragments |
| `.codex/hooks.json` | Merged hook configuration |
| `.codex/config.toml` | Codex global configuration |
| `AGENTS.md` (root) | Project guidance for Codex |
