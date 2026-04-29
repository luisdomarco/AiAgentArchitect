---
name: res-wor-entities-registry
description: Registry of agents, skills, and knowledge-base entities available to wor-agentic-architect. Read on demand when the orchestrator needs to pick which entity to invoke for a step or which knowledge file to consult. Avoids inflating the workflow file with static lookup tables.
tags: [registry, lookup, wor-agentic-architect]
---

## Purpose

`wor-agentic-architect` orchestrates a 3-step pipeline (Discovery → Architecture → Implementation). To stay within the workflow size budget while preserving full discoverability, the catalog of entities the orchestrator can invoke lives here.

The orchestrator reads this file when:

1. It needs to pick which agent to activate at a given step (table 1 — Agents).
2. It needs to invoke a skill conditionally (table 2 — Skills, gated by `active_layers`).
3. It needs to consult a knowledge-base file just-in-time (table 3 — Knowledge-base).

Per `rul-lazy-loading`, the orchestrator does NOT preload these entities — only the ones it actually invokes per step.

---

## 1. Agents

| Agent                           | Route                                | When                                                          |
| ------------------------------- | ------------------------------------ | ------------------------------------------------------------- |
| `age-spe-input-enricher`        | `./age-spe-input-enricher.md`        | Step 0: restructuring and enrichment of the initial input     |
| `age-spe-process-discovery`     | `./age-spe-process-discovery.md`     | Step 1: interview and discovery                               |
| `age-spe-architecture-designer` | `./age-spe-architecture-designer.md` | Step 2: Blueprint design                                      |
| `age-spe-entity-builder`        | `./age-spe-entity-builder.md`        | Step 3: file generation                                       |

---

## 2. Skills

| Skill                   | Route                                      | When                                                                                                                         |
| ----------------------- | ------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------- |
| `ski-platform-exporter` | `../skills/ski-platform-exporter/SKILL.md` | Post-packaging: convert export to other platforms                                                                            |
| `ski-layer-embed`       | `../skills/ski-layer-embed/SKILL.md`       | Post-packaging: embed an active layer (memory, context-ledger, help-router, onboarding) into the generated system            |
| `ski-context-ledger`    | (in context-ledger layer)                  | Start: load-last/init ledger. After each Step: write/read. (Active iff `context-ledger` layer enabled)                       |
| `ski-memory-manager`    | (in memory layer)                          | Start: load-last for quick context. After each CP: save session snapshot. (Active iff `memory` layer enabled)                |
| `ski-help-router`       | (in help-router layer)                     | At any time when user invokes `/help`: render context-aware menu. (Active iff `help-router` layer enabled)                   |

---

## 3. Knowledge base

| Knowledge base            | Route                                          | Description                                                  |
| ------------------------- | ---------------------------------------------- | ------------------------------------------------------------ |
| `kno-entity-selection`    | `../knowledge-base/kno-entity-selection.md`    | Decision tree and edge cases for entity type selection       |
| `kno-entity-types`        | `../knowledge-base/kno-entity-types.md`        | The 10 entity types — semantics and selection criteria       |
| `kno-system-architecture` | `../knowledge-base/kno-system-architecture.md` | Export structure and platform mapping                        |
| `kno-handoff-schemas`     | (in context-ledger layer)                      | Handoff JSON schemas S1→S2 and S2→S3 and metrics object      |
| `kno-workflow-patterns`   | `../knowledge-base/kno-workflow-patterns.md`   | Common workflow patterns                                     |
| `kno-agent-strategies`    | `../knowledge-base/kno-agent-strategies.md`    | Agent strategy patterns                                      |
| `kno-hooks-and-scripts`   | `../knowledge-base/kno-hooks-and-scripts.md`   | Hooks and scripts conventions                                |

---

## Notes

- **Entity discovery vs invocation**: this file is the inventory the orchestrator consults to *decide what to invoke*. Once it picks one, it loads only that file. It does NOT preload all entities listed here.
- **Layers gate availability**: skills tied to optional layers (memory, context-ledger, help-router) only appear in this list as available — the orchestrator must check `active_layers` from `config/manifest.yaml` before invoking them. If the layer is off, skip silently (graceful degradation per `rul-lazy-loading`).
- **Adding a new entity**: when extending the orchestrator's capabilities, add the row here AND ensure the entity file exists at the route. Do NOT add the row to `wor-agentic-architect.md` directly — it belongs in this registry.
