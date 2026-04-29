---
description: Persistence architecture for agentic entities. Defines the root folder structure, path conventions, and dual-platform Antigravity and Claude Code architecture. Codex available on demand via ski-platform-exporter.
tags: [architecture, file-structure, deployment]
---

## Table of Contents

- [1. Root folder architecture](#1-root-folder-architecture)
- [2. Architecture for applications](#2-architecture-for-applications)
- [3. Export architecture](#3-export-architecture)
- [4. Relative paths between entities](#4-relative-paths-between-entities)

---

## 1. Root folder architecture

The root folder is the **source of truth** for all entities. It is platform-agnostic.

```
(Project Root)
├── .agents/
│   ├── workflows/
│   │   ├── wor-[name].md
│   │   ├── age-spe-[name].md
│   │   ├── age-sup-[name].md
│   │   └── com-[name].md
│   │
│   ├── skills/
│   │   └── ski-[name]/
│   │       └── SKILL.md
│   │
│   ├── rules/
│   │   └── rul-[name].md
│   │
│   ├── knowledge-base/
│   │   └── kno-[name].md
│   │
│   ├── resources/
│   │   └── res-[name].md
│   │
│   ├── scripts/
│   │   └── scp-[name].sh | scp-[name].py (CC) | scp-[name].md (GA)
│   │
│   └── hooks/
│       └── hok-[name].md
│
├── exports/
│   └── [system-name]/
│
└── repository/
    └── [type]-repo.md
```

From this catalog, an export agent distributes entities to their corresponding architectures according to the destination platform.

---

## 2. Architecture for applications

Applies when the destination platform is a chat application: Claude.ai Projects, Gemini, Dust, ChatGPT.

| Entity          | Format on the platform                            |
| --------------- | ------------------------------------------------- |
| Workflows       | Instructions in a single `.md` file               |
| Agents          | Instructions in a single `.md` file               |
| Skills          | Folder structure contained the same as the source |
| Rules           | N `.md` files attached to the project             |
| Knowledge-bases | N `.md` files attached to the project             |
| Commands        | Executed directly in the chat as a prompt         |

---

## 3. Export architecture

Defines how generated systems in `exports/` are structured according to the destination platform.

### Default export: Dual-platform (flat structure)

All generated systems are exported with Google Antigravity and Claude Code structures at the same level. This allows opening the directory directly as a workspace in either platform.

```
exports/{system-name}/
├── .agents/                    ← Google Antigravity (source of truth)
│   ├── workflows/              ← .md files for workflows, agents and commands
│   ├── skills/                 ← ski-name/SKILL.md folders
│   ├── rules/                  ← .md files for rules
│   ├── knowledge-base/         ← .md files (referenced from workflows/agents)
│   ├── resources/              ← .md files for support resources
│   ├── scripts/                ← .md procedural scripts (behavioral)
│   ├── hooks/                  ← .md behavioral hook definitions
│   └── process-overview.md     ← system documentation
├── .claude/                    ← Claude Code (bidirectional sync)
│   ├── knowledge-base/         ← .md files for knowledge base
│   ├── rules/                  ← .md files for rules
│   ├── resources/              ← .md files for support resources
│   ├── skills/                 ← ski-name/SKILL.md folders
│   ├── agents/                 ← .md files for agents (with model, tools, permissionMode)
│   ├── commands/               ← workflows converted to commands (.md)
│   ├── scripts/                ← .sh/.py executable scripts
│   ├── hooks/                  ← .md hook documentation
│   ├── settings.json           ← permissions + hooks configuration for automation
│   └── CLAUDE.md               ← global context + referencing
├── CLAUDE.md                   ← root-level context for Claude Code
├── VERSION                     ← semantic version (e.g. 0.1.0)
├── process-overview.md         ← system documentation
├── context-ledger/             ← cross-session persistence
└── memory/                     ← lightweight session snapshots
```

**Note on paths**: Each platform structure contains independent copies with paths resolved locally. No cross-platform references exist.

**Platform-specific conventions**: CC-specific fields (settings.json, agent frontmatter) are documented in `res-entity-templates-claude-code.md`. Codex-specific formats (TOML agents, hooks.json) are documented in `res-entity-templates-codex.md`.

---

### Optional exports (on demand)

After the dual-platform export, the user can request additional exports using `ski-platform-exporter`, including Codex (`.codex/` + `AGENTS.md`) and application platforms.

---

#### Applications (ChatGPT, Claude.ai, Dust, Gemini)

```
exports/{system-name}/{app-name}/
├── knowledge-base/             ← .md files
├── rules/                      ← .md files
├── skills/                     ← ski-name/SKILL.md folders
├── workflows/                  ← .md files for workflows, agents and commands
├── resources/                  ← .md files
└── process-overview.md         ← system overview
```

**Format**: Individual `.md` files for workflows, agents, rules, knowledge-bases and resources. The user uploads these files manually to the corresponding platform project.

---

### Mapping table: source → platforms

| Entity           | Antigravity Export                  | Claude Code Export                  | Applications Export         |
| ---------------- | ----------------------------------- | ----------------------------------- | --------------------------- |
| Workflow         | `.agents/workflows/wor-xxx.md`      | `.claude/commands/wor-xxx.md`       | `workflows/wor-xxx.md`      |
| Agent            | `.agents/workflows/age-xxx.md`      | `.claude/agents/age-xxx.md`         | `workflows/age-xxx.md`      |
| Command          | `.agents/workflows/com-xxx.md`      | `.claude/commands/com-xxx.md`       | `workflows/com-xxx.md`      |
| Skill            | `.agents/skills/ski-xxx/SKILL.md`   | `.claude/skills/ski-xxx/SKILL.md`   | `skills/ski-xxx/SKILL.md`   |
| Rule             | `.agents/rules/rul-xxx.md`          | `.claude/rules/rul-xxx.md`          | `rules/rul-xxx.md`          |
| Knowledge-base   | `.agents/knowledge-base/kno-xxx.md` | `.claude/knowledge-base/kno-xxx.md` | `knowledge-base/kno-xxx.md` |
| Resources        | `.agents/resources/res-xxx.md`      | `.claude/resources/res-xxx.md`      | `resources/res-xxx.md`      |
| Script           | `.agents/scripts/scp-xxx.md`        | `.claude/scripts/scp-xxx.sh`        | `scripts/scp-xxx.md`        |
| Hook             | `.agents/hooks/hok-xxx.md`          | `.claude/hooks/hok-xxx.md`          | `hooks/hok-xxx.md`          |
| process-overview | `.agents/process-overview.md`       | `process-overview.md`               | `process-overview.md`       |

> **Codex mapping** (on demand via `ski-platform-exporter`): Behavioral entities → `.toml` agents in `.codex/agents/`. Procedural entities → direct copy. Hooks → `.md` + `.json` fragments. See `res-codex-conventions.md`.

---

### Conversion skill: ski-platform-exporter

To generate additional application exports, the system uses `ski-platform-exporter`:

**Input**: path to the system export (`exports/{name}/`) + destination platform

**Output**: files generated in `exports/{name}/{platform}/`

**Supported platforms**: `codex`, `chatgpt`, `claude-ai`, `dust`, `gemini`

**Note**: Claude Code export is generated automatically as part of the default dual-platform export. Codex and application platforms are generated on demand via this skill.

**Invocation**: from the workflow (post-packaging checkpoint) or directly by the user at any time

---

## 4. Relative paths between entities

All cross-reference paths are expressed relative to the architecture root:

| Referenced entity | Relative path                    |
| ----------------- | -------------------------------- |
| Skill             | `./skills/ski-[name]/SKILL.md`   |
| Agent Specialist  | `./workflows/age-spe-[name].md`  |
| Agent Supervisor  | `./workflows/age-sup-[name].md`  |
| Workflow          | `./workflows/wor-[name].md`      |
| Rule              | `./rules/rul-[name].md`          |
| Knowledge-base    | `./knowledge-base/kno-[name].md` |
| Command           | `./workflows/com-[name].md`      |
| Script            | `./scripts/scp-[name].sh` or `./scripts/scp-[name].md` |
| Hook              | `./hooks/hok-[name].md`          |
