---
name: res-architect-execution-phases
description: Structural detail of the orchestrator's execution phases, endpoints, and persistence flow.
tags: [workflow, routing, phases, orchestration, S1, S2, S3]
---

# Architect Execution Phases (Lite)

This document details the operational logic and interaction loops that the main orchestrator (`wor-agentic-architect`) executes throughout discovery, architecture, and entity generation in the **Lite** edition (single-project, no QA, no iteration).

---

## Session Start

1. **Load system overview:** Read `system-overview.md` from project root for global entity context. This replaces reading individual entity files until they are actually needed during execution.
2. **Detect template:** Check `%Master - Docs/template-input-architect.md` or `template-input-express.md`. If filled, use as initial context and mention it to the user.
3. **Detect mode:** Ask _"What do you want to create? A) Complete process → Architect Mode · B) Concrete entity → Express Mode"_. Infer from complexity if the user describes directly. Confirm: _"I'll work in [X] Mode. Correct?"_
4. **Identify project:** Ask or infer the system name. Define `project_name` (e.g. `email-classifier`).
5. **Validate uniqueness of `project_name`:**
   - Check whether `exports/{project_name}/` already exists.
   - **If it exists:** offer:
     - `A) Variant with timestamp suffix (suggested: {project_name}-{YYYYMMDD-HHMM})`
     - `B) Pick a different name (ask user)`
   - **If it does not exist:** continue.
   - Always confirm the suggestion in option A with the user before adopting it.
6. **Session Initialization:**
   - **6a. Load memory first** (lightweight): if `memory` layer active, invoke `ski-memory-manager` (`load-last`) with `memory_dir=memory/` and `project_name`.
   - **6b. If memory found:** Present summary — _"I found a previous session from [date]. Last checkpoint: [CP]. A) Resume · B) New session · C) New project."_ On A: use memory snapshot; only load full context-ledger if user explicitly requests it. On B/C: proceed as new.
   - **6c. If no memory found:** Proceed as a new project.
7. **Calculate `target_dir`:** Define internal variable, default `exports/{system-name}/`.
8. **Initialize persistence (parallel, conditional on layer activation):**
   - If `context-ledger` layer active → `ski-context-ledger` operation `init` with system name, workflow, `ledger_dir=context-ledger/`, `project_name`. Ledger file created in `context-ledger/` at project root, NOT inside `exports/`.
   - If `memory` layer active → `ski-memory-manager` (`save`) with `memory_dir=memory/`, `project_name`, `status=in-progress`, current session timestamp.

---

## Step 0 — Input Structuring & Enrichment

**Activates:** `age-spe-input-enricher` receiving the raw or partial format input. Structures and infers initial gaps by proposing improvements to validate the idea before heavy discovery.

**CP-S0:** A) ✅ Approve base structure → Step 1 · B) ✏️ Adjust this result · C) 🔄 Regenerate using a different approach · D) ↩️ Go back

**After CP-S0 approval:**
1. **Capture `target_platforms`:** Extract from validated output. Default: `["antigravity", "claude-code"]`. Codex available as opt-in via `ski-platform-exporter`. Propagate unchanged through S1, S2, S3 handoffs.
2. **Context Ledger (if active):** `ski-context-ledger` write with step=0, agent=`age-spe-input-enricher`, output=structured input including `target_platforms`.
3. **Memory (if active):** `ski-memory-manager` save with `last_checkpoint=CP-S0`, `status=in-progress`.
4. **Preliminary sketch (Architect Mode only):** Invoke `ski-diagram-generator` type `flow` with S0 structured input. Present: _"Rough sketch — refined after Discovery."_ Do not wait for approval; proceed to Step 1.

---

## Step 1 — Process Discovery

**Activates:** `age-spe-process-discovery` with the mode and initial description. The agent conducts the complete interview and returns the S1→S2 handoff (schema in `kno-handoff-schemas` §1).

**Context Ledger (if active):** After obtaining the S1 handoff JSON, execute `ski-context-ledger` operation `write` with step=1, agent=`age-spe-process-discovery`, output=S1 JSON.

**Checkpoint S1:** A) ✅ Approve → Step 2 · B) ✏️ Edit summary · C) 🔄 Regenerate · D) ↩️ Go back

---

## Step 2 — Architecture Design

**Context Ledger (read, if active):** Before invoking the agent, execute `ski-context-ledger` operation `read` with step_destination=2 and the workflow's Context Map. This extracts the complete S1 JSON from the ledger.

**Activates:** `age-spe-architecture-designer` with the context filtered by the ledger. The agent designs the Blueprint and returns the S2→S3 handoff (schema in `kno-handoff-schemas` §2).

**Context Ledger (write, if active):** After obtaining the S2 handoff JSON, execute `ski-context-ledger` operation `write` with step=2, agent=`age-spe-architecture-designer`, output=S2 JSON.

**Checkpoint S2:** A) ✅ Approve Blueprint → Step 3 · B) ✏️ Adjust entity · C) 🔄 Redesign architecture · D) ↩️ Return to S1

---

## Step 3 — Entity Implementation

**Context Ledger (read, if active):** Before invoking the agent, execute `ski-context-ledger` operation `read` with step_destination=3 and the workflow's Context Map. This extracts: complete S2 JSON + partial fields from S1 (`process.name`, `process.constraints`, `diagram_as_is`).

**Activates:** `age-spe-entity-builder` with the context filtered by the ledger. The agent generates entities one by one.

**Context Ledger (write, if active):** After final approval of all entities and `process-overview.md`, execute `ski-context-ledger` operation `write` with step=3, agent=`age-spe-entity-builder`, output=list of generated files.

**Per-entity checkpoint:** A) ✅ Approve → next entity · B) ✏️ Adjust · C) 🔄 Regenerate · D) ↩️ Return to Blueprint

After all entities are complete, the agent generates `process-overview.md`.

**Closing checkpoint:** A) ✅ Approve → final packaging · B) ✏️ Adjust process-overview · C) 🔄 Return to S3 · D) ↩️ Return to Blueprint

---

## Context Map

| Destination Step | Consumed from   | Fields / Sections                                       | Mode     |
| ---------------- | --------------- | ------------------------------------------------------- | -------- |
| Step 1           | Step 0 → output | `*` (Restructured and validated raw input)              | complete |
| Step 2           | Step 1 → output | `*` (Complete S1 handoff JSON)                          | complete |
| Step 3           | Step 2 → output | `*` (Complete S2 handoff JSON)                          | complete |
| Step 3           | Step 1 → output | `process.name`, `process.constraints`, `diagram_as_is`  | partial  |

---

## Reasoning Trace

When any specialist agent finishes (S0–S3), extract the `<sys-eval>` tag content from its response and pass it as `reasoning_trace` to `ski-context-ledger` write for the active `ledger_file` (only if `context-ledger` layer is active).

**If `<sys-eval>` is missing:** record `reasoning_trace = "MISSING"`. Per `rul-strict-compliance`, all agents are expected to emit `<sys-eval>` before their final output. Never leave `reasoning_trace` empty or omit it when context-ledger is active.

---

## Per-CP Persistence Checklist

Execute after EVERY checkpoint approval, without exception, in this order: (1) `ski-context-ledger` write (if active) → (2) `ski-memory-manager` save (if active).

| After CP | Context Ledger (ski-context-ledger write)      | Memory (ski-memory-manager save)                          |
| -------- | ---------------------------------------------- | --------------------------------------------------------- |
| CP-S0    | ✅ handled in Step 0 above                     | `last_checkpoint=CP-S0, steps_completed.S0`               |
| CP-S1    | write S1 output + reasoning_trace              | `last_checkpoint=CP-S1, steps_completed.S1`               |
| CP-S2    | write S2 output + reasoning_trace              | `last_checkpoint=CP-S2, steps_completed.S2`               |
| CP-S3-N  | write entity N output + reasoning_trace        | `last_checkpoint=CP-S3-{entity}, steps_completed.S3`      |
| CP-CLOSE | write final state                              | `last_checkpoint=CP-CLOSE, status=completed`              |
