---
name: res-architect-execution-phases
description: Structural detail of the orchestrator's execution phases, endpoints, and QA flow.
tags: [workflow, routing, phases, orchestration, S1, S2, S3]
---

# Architect Execution Phases

This document details the operational logic and interaction loops that the main orchestrator (`wor-agentic-architect`) executes throughout discovery, architecture, and human/QA generation.

## Metrics tracking

Maintain the metrics object `{ "regenerations", "iterations" }` per Step (see `kno-handoff-schemas` §3). Increment on regenerations (option C) or iterations (option B). Pass to the Evaluator along with each phase context.

---

## Step 0 — Input Structuring & Enrichment

**Activates:** `age-spe-input-enricher` receiving the raw or partial format input. Structures and infers initial gaps by proposing improvements to validate the idea before heavy discovery.

**Checkpoint S0:** A) ✅ Approve base structure → Step 1 · B) ✏️ Adjust this result · C) 🔄 Regenerate using a different approach · D) ↩️ Go back

**Context Ledger:** After validating Checkpoint S0, execute `ski-context-ledger` operation `write` with step=0, agent=`age-spe-input-enricher`, output=Summary of the structured input.

> `/skip-qa S0` skips QA for this preparatory phase.

---

## Step 1 — Process Discovery

**Activates:** `age-spe-process-discovery` with the mode and initial description. The agent conducts the complete interview and returns the S1→S2 handoff (schema in `kno-handoff-schemas` §1).

**Context Ledger:** After obtaining the S1 handoff JSON, execute `ski-context-ledger` operation `write` with step=1, agent=`age-spe-process-discovery`, output=S1 JSON.

**Checkpoint S1:** A) ✅ Approve → Step 2 · B) ✏️ Edit summary · C) 🔄 Regenerate · D) ↩️ Go back

**Automatic QA after approval:**

1. `age-spe-auditor` — Reads active Rules + S1 JSON from disk → produces compliance table.
2. `age-spe-evaluator` — Scores S1. Creates `qa-report.md` at the root of the generated system (`{export-path}/qa-report.md`) with [Audit S1] + [Score S1].

- Display: `🔍 QA S1 — {N} criteria | ✅ {X} / ⚠️ {Y} / ❌ {Z} — Score: {X.X}/10 ({level})`
- If there are alerts: bullet with the most critical criterion.

> `/skip-qa S1` skips the QA cycle for this phase.

---

## Step 2 — Architecture Design

**Context Ledger (read):** Before invoking the agent, execute `ski-context-ledger` operation `read` with step_destination=2 and the workflow's Context Map. This extracts the complete S1 JSON from the ledger.

**Activates:** `age-spe-architecture-designer` with the context filtered by the ledger. The agent designs the Blueprint and returns the S2→S3 handoff (schema in `kno-handoff-schemas` §2).

**Context Ledger (write):** After obtaining the S2 handoff JSON, execute `ski-context-ledger` operation `write` with step=2, agent=`age-spe-architecture-designer`, output=S2 JSON.

**Checkpoint S2:** A) ✅ Approve Blueprint → Step 3 · B) ✏️ Adjust entity · C) 🔄 Redesign architecture · D) ↩️ Return to S1

**Automatic QA after approval:**

1. `age-spe-auditor` — Reads active Rules + Blueprint from disk → compliance table.
2. `age-spe-evaluator` — Scores S2. Adds [Audit S2] + [Score S2] to `qa-report.md`.

- Display: `🔍 QA S2 — {N} criteria | ✅ {X} / ⚠️ {Y} / ❌ {Z} — Score: {X.X}/10`

> `/skip-qa S2` skips the QA cycle for this phase.

---

## Step 3 — Entity Implementation

**Context Ledger (read):** Before invoking the agent, execute `ski-context-ledger` operation `read` with step_destination=3 and the workflow's Context Map. This extracts: complete S2 JSON + partial fields from S1 (`process.name`, `process.constraints`, `diagram_as_is`).

**Activates:** `age-spe-entity-builder` with the context filtered by the ledger. The agent generates entities one by one.

**Context Ledger (write):** After final approval of all entities and `process-overview.md`, execute `ski-context-ledger` operation `write` with step=3, agent=`age-spe-entity-builder`, output=list of generated files.

**Per-entity checkpoint:** A) ✅ Approve → next entity · B) ✏️ Adjust · C) 🔄 Regenerate · D) ↩️ Return to Blueprint

**Automatic Audit after each approval:**

- **Normal batches (≤ 7 entities):** `age-spe-auditor` on the newly generated file. Adds [Audit S3-{name}] to `qa-report.md`. Presents summary on screen (max. 5 lines).
- **Large batches (> 7 entities):** To not interrupt the user, `age-spe-auditor` acts in **silent background** mode accumulating the [Audit] on disk without requesting blocking confirmation or emitting a screen summary (unless there is a critical ❌).

After all entities are complete, the agent generates `process-overview.md`.

**Closing checkpoint:** A) ✅ Approve → final packaging · B) ✏️ Adjust process-overview · C) 🔄 Return to S3 · D) ↩️ Return to Blueprint

**Global QA after approval:**

1. `age-spe-evaluator` — S3 Score: average of individual audits. Metrics = cumulative sum of S3.
2. `age-spe-evaluator` — Weighted global score (S1×25% + S2×35% + S3×40%). Adds [Global Evaluation] to `qa-report.md` and entry to `qa-meta-report.md`.
3. `age-spe-optimizer` — Reads `qa-report.md` from disk. Uses `ski-pattern-analyzer`. Adds [Optimization Proposals] to `qa-report.md`.

- Display: `📊 Score: {X.X}/10 — {level} | S1:{X.X} S2:{X.X} S3:{X.X} | 🔧 {N} proposals (see qa-report.md)`
