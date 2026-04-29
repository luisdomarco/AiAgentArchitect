# AiAgentArchitect Lite — System Overview

> Public preview of AiAgentArchitect. A single-project meta-system for designing and generating agentic systems across Antigravity, Claude Code, and OpenAI Codex.

This file is the entry-point overview consumed by the orchestrator at session start (per `rul-lazy-loading`). It lists every entity available, with one line of description each. Individual entity files are loaded only when actually needed.

## How to start

- **Antigravity:** `wor-agentic-architect`
- **Claude Code:** `/wor-agentic-architect`
- For context-aware help: `/help`

## Workflows & Agents

| Entity | Path | Role |
|---|---|---|
| `wor-agentic-architect` | `.agents/workflows/wor-agentic-architect.md` | Main orchestrator. Discovery → Architecture → Implementation in 3 steps. |
| `age-spe-input-enricher` | `.agents/workflows/age-spe-input-enricher.md` | Step 0: structures and enriches the raw input. |
| `age-spe-process-discovery` | `.agents/workflows/age-spe-process-discovery.md` | Step 1: conducts the BPM/BPA interview, returns the S1 handoff. |
| `age-spe-architecture-designer` | `.agents/workflows/age-spe-architecture-designer.md` | Step 2: designs the entity Blueprint. |
| `age-spe-entity-builder` | `.agents/workflows/age-spe-entity-builder.md` | Step 3: generates the entity files one by one. |

## Skills

| Skill | Path | Use |
|---|---|---|
| `ski-process-interviewer` | `.agents/skills/ski-process-interviewer/SKILL.md` | BPM-style structured interview technique. |
| `ski-entity-selector` | `.agents/skills/ski-entity-selector/SKILL.md` | Decision tree to pick entity types from a description. |
| `ski-entity-file-builder` | `.agents/skills/ski-entity-file-builder/SKILL.md` | Generates entity files per type and intricacy level. |
| `ski-diagram-generator` | `.agents/skills/ski-diagram-generator/SKILL.md` | Generates Mermaid diagrams (AS-IS, blueprint). |
| `ski-output-claude-code` | `.agents/skills/ski-output-claude-code/SKILL.md` | Maps generated entities to Claude Code conventions. |
| `ski-output-codex` | `.agents/skills/ski-output-codex/SKILL.md` | Maps generated entities to OpenAI Codex conventions. |
| `ski-platform-exporter` | `.agents/skills/ski-platform-exporter/SKILL.md` | Generates platform-specific outputs (ChatGPT, Claude.ai, Dust, Gemini). |
| `ski-layer-embed` | `.agents/skills/ski-layer-embed/SKILL.md` | Embeds an active layer into a generated subsystem. |

## Rules

| Rule | Path | Purpose |
|---|---|---|
| `rul-checkpoint-behavior` | `.agents/rules/rul-checkpoint-behavior.md` | Standard 4-option checkpoint format and validation. |
| `rul-interview-standards` | `.agents/rules/rul-interview-standards.md` | Interview protocol and response quality standards. |
| `rul-naming-conventions` | `.agents/rules/rul-naming-conventions.md` | Entity prefixes, kebab-case, character limits. |
| `rul-strict-compliance` | `.agents/rules/rul-strict-compliance.md` | Mandatory `<sys-eval>` self-check before every output. |
| `rul-lazy-loading` | `.agents/rules/rul-lazy-loading.md` | Just-in-time loading of knowledge-base and resources. |
| `rul-scope-boundaries` | `.agents/rules/rul-scope-boundaries.md` | Strict read boundaries between root and exports. |

## Knowledge base

| Entry | Path | Use |
|---|---|---|
| `kno-entity-types` | `.agents/knowledge-base/kno-entity-types.md` | The 10 entity types — semantics and selection. |
| `kno-entity-selection` | `.agents/knowledge-base/kno-entity-selection.md` | Decision tree and edge cases for picking entities. |
| `kno-system-architecture` | `.agents/knowledge-base/kno-system-architecture.md` | Generated system structure and platform mapping. |
| `kno-workflow-patterns` | `.agents/knowledge-base/kno-workflow-patterns.md` | Common workflow patterns. |
| `kno-agent-strategies` | `.agents/knowledge-base/kno-agent-strategies.md` | Agent strategy patterns (specialist, supervisor). |
| `kno-hooks-and-scripts` | `.agents/knowledge-base/kno-hooks-and-scripts.md` | Hooks and scripts conventions. |

## Active layers (4)

The Lite edition ships with 4 layers, all enabled by default:

| Layer | Manifest | Provides |
|---|---|---|
| `context-ledger` | `.agents/layers/context-ledger/MANIFEST.yaml` | `ski-context-ledger`, `kno-handoff-schemas` — append-only session trace. |
| `memory` | `.agents/layers/memory/MANIFEST.yaml` | `ski-memory-manager` — cross-session lightweight snapshots. |
| `help-router` | `.agents/layers/help-router/MANIFEST.yaml` | `ski-help-router` — context-aware `/help` menus. |
| `onboarding` | `.agents/layers/onboarding/MANIFEST.yaml` | `wor-onboarding` — first-run guided tour. |

## Cross-session persistence

- `memory/` — small (1-2 KB) snapshots per session per project, used for resume.
- `context-ledger/` — append-only full ledger of each step's input/output/reasoning trace.

## Reading strategy

When working on AiAgentArchitect Lite itself:

1. Always read this `system-overview.md` first — it is the index.
2. Read individual entity files only when the workflow logic indicates it (e.g. read `kno-entity-selection.md` only when the architecture designer is picking entity types).
3. Per `rul-scope-boundaries`, never read inside `exports/` from this scope (except `exports/template/` for structural reference).
