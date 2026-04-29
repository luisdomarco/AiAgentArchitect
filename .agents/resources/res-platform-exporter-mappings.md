---
name: res-platform-exporter-mappings
description: Platform-specific mapping tables for ski-platform-exporter. Defines how Google Antigravity entities are converted for each destination platform (Claude Code, ChatGPT, Claude.ai, Dust, Gemini, Codex). Read by ski-platform-exporter during export execution.
tags: [platform, exporter, mappings, conversion, claude-code, codex, chatgpt]
---

## Purpose

This resource contains the per-platform mapping detail used by `ski-platform-exporter`. It defines directory structures, entity transformations, and special file generation rules for each supported destination platform.

**Note:** Claude Code and Codex are generated automatically as part of the default triple-platform structure. This skill is only needed for additional application platform exports.

---

## Platform: Claude Code (Reference Only)

> The Claude Code structure is generated automatically at `exports/{name}/.claude/` during the default triple-platform packaging. This mapping is documented here for reference only — it is **NOT** invoked via `ski-platform-exporter`.

**Destination:** `exports/{name}/.claude/`

**Entity mapping:**

| `.agents/` source | `.claude/` destination |
| ----------------- | ---------------------- |
| `workflows/wor-*.md` | `commands/wor-*.md` |
| `workflows/age-*.md` | `agents/age-*.md` |
| `workflows/com-*.md` | `commands/com-*.md` |
| `skills/ski-*/SKILL.md` | `skills/ski-*/SKILL.md` |
| `rules/rul-*.md` | `rules/rul-*.md` |
| `knowledge-base/kno-*.md` | `knowledge-base/kno-*.md` |
| `resources/res-*.md` | `resources/res-*.md` |
| `scripts/scp-*.md` | `scripts/scp-*.sh` or `scripts/scp-*.py` |
| `hooks/hok-*.md` | `hooks/hok-*.md` + entries in `settings.json` |

**Special files generated:**
- `CLAUDE.md` — system context, workflow invocation, active rules listing
- `.claude/settings.json` — hook configuration for automation

---

## Platform: Application Platforms (ChatGPT, Claude.ai, Dust, Gemini)

**Destination:** `exports/{name}/{platform}/`

**Directory structure:**

```
exports/{name}/{platform}/
├── knowledge-base/
├── rules/
├── skills/
├── workflows/
├── resources/
├── scripts/
├── hooks/
└── process-overview.md
```

**Entity mapping (all platforms):**

| `.agents/` source | Destination | Transformation |
| ----------------- | ----------- | -------------- |
| `workflows/wor-*.md` | `workflows/` | Copy `.md` directly |
| `workflows/age-*.md` | `workflows/` | Copy `.md` directly |
| `workflows/com-*.md` | `workflows/` | Copy `.md` directly |
| `skills/ski-*/` | `skills/ski-*/` | Copy entire folder with all content intact |
| `rules/rul-*.md` | `rules/` | Copy `.md` directly |
| `knowledge-base/kno-*.md` | `knowledge-base/` | Copy `.md` directly |
| `resources/res-*.md` | `resources/` | Copy `.md` directly |
| `scripts/scp-*.md` | `scripts/` | Copy `.md` — apps use procedural docs |
| `hooks/hok-*.md` | `hooks/` | Copy `.md` — apps use behavioral docs |
| `process-overview.md` | root | Copy directly |

**Notes per platform:**
- **ChatGPT**: Upload `.md` files to the project in ChatGPT.
- **Claude.ai**: Create a new project and attach the `.md` files.
- **Dust / Gemini**: Upload files according to the platform's conventions.

---

## Platform: Codex (OpenAI)

**Invocation:** Run `python3 scripts/build-codex.py --export exports/{name}`.

The build script handles all Codex-specific transformations automatically. This skill only needs to trigger the script.

**What the build script does:**

| Source | Codex output |
| ------ | ------------ |
| Behavioral entities (`wor-*`, `com-*`, `age-*`) | TOML agent definitions in `.codex/agents/` |
| Procedural entities (`ski-*`, `rul-*`, `kno-*`, `res-*`) | Direct copy to corresponding folder |
| Scripts | Executable copy to `.codex/scripts/` |
| Hooks | `.md` copy + `.json` fragment → merged into `hooks.json` |
| — | `AGENTS.md` generated at export root |
| — | `config.toml` generated at export root |

For manual or fine-grained control, see `res-entity-templates-codex.md` and `res-codex-conventions.md`.
