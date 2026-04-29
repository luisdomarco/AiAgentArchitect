---
name: res-platform-output-structure
description: Defines the directory structure, required files, and conventions for each platform output (Google Antigravity, Claude Code, optional platforms). Read during the packaging phase to verify correct output structure and guide additional exports.
tags: [platform, output, structure, packaging]
---

## Dual-Platform Default Structure

Every generated system produces two platform outputs at the same level inside `exports/{system-name}/`:

```
exports/{system-name}/
├── .agents/                    ← Google Antigravity (source of truth)
│   ├── workflows/
│   ├── skills/
│   ├── rules/
│   ├── knowledge-base/
│   ├── resources/
│   ├── scripts/
│   └── hooks/
├── .claude/                    ← Claude Code (bidirectional sync from .agents/)
│   ├── commands/
│   ├── agents/
│   ├── skills/
│   ├── rules/
│   ├── knowledge-base/
│   ├── resources/
│   ├── scripts/
│   └── hooks/
├── context-ledger/             ← Full session ledger files
├── memory/                     ← Lightweight session summaries
├── changelog/                  ← Version history entries
├── CLAUDE.md                   ← Claude Code root context
├── process-overview.md         ← System documentation
└── VERSION                     ← Semantic version (e.g. 0.1.0)
```

---

## Required Files per Platform

### Google Antigravity (`.agents/`)

- Entity files following `rul-naming-conventions` prefixes and folder structure
- No special root-level files required beyond `process-overview.md`

### Claude Code (`.claude/`)

| File | Description |
| ---- | ----------- |
| `CLAUDE.md` | Root-level context: system description, workflow invocation commands, active rules listing, scope boundaries |
| `.claude/settings.json` | Hook configuration for behavioral hooks (when the system includes hook entities) |

**Folder mapping from `.agents/`:**

| `.agents/` path | `.claude/` path |
| --------------- | --------------- |
| `workflows/wor-*.md` | `commands/wor-*.md` |
| `workflows/age-*.md` | `agents/age-*.md` |
| `workflows/com-*.md` | `commands/com-*.md` |
| `skills/ski-*/SKILL.md` | `skills/ski-*/SKILL.md` |
| `rules/rul-*.md` | `rules/rul-*.md` |
| `knowledge-base/kno-*.md` | `knowledge-base/kno-*.md` |
| `resources/res-*.md` | `resources/res-*.md` |
| `scripts/scp-*.md` | `scripts/scp-*.sh` or `scripts/scp-*.py` |
| `hooks/hok-*.md` | `hooks/hok-*.md` + entries in `settings.json` |

### OpenAI Codex (`.codex/`) — On Demand

Generated via `ski-platform-exporter` or `python3 scripts/build-codex.py --export exports/{name}`. Not included in the default export.

| File | Description |
| ---- | ----------- |
| `AGENTS.md` | Root-level context equivalent to `CLAUDE.md` for Codex |
| `config.toml` | Global Codex configuration |
| `hooks.json` | Merged hook configuration from all `hok-*.json` fragments |

**Entity type mapping:**

| Source type | Codex output |
| ----------- | ------------ |
| Behavioral (wor-*, age-*, com-*) | TOML agent definition in `.codex/agents/` |
| Procedural (ski-*, rul-*, kno-*, res-*) | Direct copy |
| Scripts | Executable copy |
| Hooks | `.md` copy + `.json` fragment → merged into `hooks.json` |

---

## Application Platform Exports (Optional)

Additional exports to application platforms (ChatGPT, Claude.ai, Dust, Gemini) are generated on demand via `ski-platform-exporter`. These go to `exports/{name}/{platform}/` with a flat structure:

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

All entities are copied as `.md` files without platform-specific transformations.

---

## Session Persistence Directories

Generated systems include cross-session state directories at their export root:

| Directory | Purpose | Git |
| --------- | ------- | --- |
| `context-ledger/` | Full session ledger files (`YYYY-MM-DD-HH-MM-{project}.md`) | Excluded |
| `memory/` | Lightweight session summaries (~1-2KB) for fast startup | Excluded |
| `changelog/` | Version history entries, one `.md` per iteration | Included |
