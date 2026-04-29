---
name: ski-context-ledger
description: Manages shared context state between agents by initializing, writing, filtering, and retrieving session ledger files in a context-ledger/ directory. Use when transferring structured data between Step agents, resuming a previous session, or when an agent needs to access validated outputs from a previous phase.
type: workflow
---

## Description

Reusable skill that provides the necessary operations to manage context ledger files within a `context-ledger/` directory. Each workflow session creates its own ledger file (named with timestamp and project), enabling multi-session history and fast retrieval of previous context.

The ledger persists the output of each step and allows the orchestrator to selectively filter what information passes to the next agent.

**The workflow decides what flows; this skill executes the mechanics.**

## Input / Output

**Input (common to all operations):** `system`, `workflow`, `ledger_dir`, `project_name`, `step`, `agent`, `status`, `input`, `output`, `reasoning_trace`, `step_destination`, `context_map` — varies by operation (see below).

**Output:** Created or updated ledger file (for `init`/`write`), a filtered context block ready for injection (for `read`), or the content of the most recent session ledger (for `load-last`).

## Operations

### `init` — Initialize a new session ledger

Creates a new session ledger file in the `ledger_dir/` directory. Each session gets its own file, named with timestamp and project name.

**Input:**

| Field        | Description                                                                    |
| ------------ | ------------------------------------------------------------------------------ |
| system       | Name of the running system                                                     |
| workflow     | Name of the workflow invoking it                                               |
| ledger_dir   | Path to the context-ledger directory (e.g. `context-ledger/`)                  |
| project_name | Name of the project (e.g. `agsy-product-manager-aramis`)                       |
| target_dir   | (Optional) Path to the export/working directory — stored in frontmatter only   |
| mode         | (Optional) `architect` or `express` — stored in frontmatter only               |

**Output:** File `{ledger_dir}/{YYYY-MM-DD-HH-MM}-{project_name}.md` created with frontmatter:

```markdown
---
schema_version: 1.1
system: {system}
workflow: {workflow}
project_name: {project_name}
target_dir: {target_dir}
mode: {mode}
created: {ISO timestamp}
last_updated: {ISO timestamp}
---

<!-- Context Ledger — append-only. Do not overwrite previous blocks. -->
```

The orchestrator must retain the generated file path internally for subsequent `write` and `read` calls.

**Schema version note (v3 — 4.3.1):** `schema_version: 1.1` distinguishes v3 ledgers (with `Metrics` blocks per step and delta tracking) from v2 baseline (absent or 1.0). When `load-last` reads a file without `schema_version`, treat it as v1.0 — no `Metrics` blocks, no delta tracking. Subsequent `write` calls migrate the frontmatter on first append.

### `write` (re-audit, v3 — 4.3.3 — delta tracking)

When the orchestrator re-audits a phase that was already audited, do not write a complete duplicate block. Instead emit a delta:

```markdown
## [Step 2 — re-audit] (delta vs. previous audit)

### Changes
- +2 criteria evaluated (rul-X.criterion-3, rul-X.criterion-4)
- -1 ⚠️ (was: "missing field 'process_name'", now: ✅)
- regenerated: false
- reasoning_trace: <sys-eval>...</sys-eval>

### Metadata
- Timestamp: {ISO}
- Step: 2
- Previous audit: line {N} of this file
```

Compute the delta by comparing the new audit block against the most recent matching block in the ledger. Only the differences (+criteria, -⚠️/❌, status changes) are recorded. The full new state is reconstructable by replaying the chain of deltas.

### `read` (pre-flight Context Map validation, v3 — 4.3.4)

Before invoking Step N with a Context Map, validate that every step referenced in the map either:
- Exists in the current ledger (was already executed), OR
- Is the current step itself (will execute now), OR
- Has been declared as a future step in the workflow definition (legitimate forward reference).

If any step in the Context Map references a step that is neither past nor declared future, abort with:

```
Pre-flight Context Map error: Step {N} references "Step {M} output" but Step {M} is not present in the ledger and not declared in the workflow. Likely typo in the Context Map definition.
```

This catches Context Map drift errors at workflow start instead of at runtime when Step N actually executes.

**When:** At the start of the workflow execution, before invoking the first agent.

---

### `write` — Record a step's output

Adds a block to the current session's ledger file with the input received and output produced by an agent. **Always in append mode**, never overwrites previous blocks. Also updates the `last_updated` field in the frontmatter.

**Input:**

| Field           | Description                                                                          |
| --------------- | ------------------------------------------------------------------------------------ |
| ledger_file     | Full path to the current session's ledger file (obtained from `init`)                |
| step            | Step number or identifier (0, 1, 2, 3... or `S0`, `S1`, etc.)                       |
| agent           | Name of the agent that executed the step                                             |
| status          | `completed` / `in_progress` / `pending`                                              |
| input           | Summary of the input the agent received                                              |
| output          | Output produced by the agent (JSON, text, file reference)                            |
| reasoning_trace | (Optional) The `<sys-eval>` thought block generated by the agent before its response |

**Output:** Block appended to the ledger file:

```markdown
---

<!-- separator -->

## [Step {step}] — {agent} — {status}

### Input received

{input}

### Reasoning Trace

{reasoning_trace} *(Added only if it exists in the input)*

### Generated output

{output}

### Metadata

- Timestamp: {ISO}
- Step: {step} of {total}
```

**When:** Immediately after an agent completes its execution and before invoking the next one.

---

### `read` — Read and filter context

Reads the current session's ledger and extracts the relevant context for a destination step according to the **Context Map** defined in the workflow.

**Input:**

| Field            | Description                                                            |
| ---------------- | ---------------------------------------------------------------------- |
| ledger_file      | Full path to the current session's ledger file                         |
| step_destination | Number of the step that will receive the context                       |
| context_map      | Array of rules: `[{ "from_step": N, "fields": [...], "mode": "..." }]` |

**Logic:**

1. Read the file at `ledger_file`.
2. For each rule in the `context_map`:
   - If `mode` = `complete`: extract the entire `### Generated output` block (and `### Reasoning Trace` if it exists) from the referenced step.
   - If `mode` = `partial`: extract only the fields listed in `fields` from the output of the referenced step.
3. Compose the filtered context as a unified block.

**Output:** Filtered context ready to be injected as input for the next agent.

**When:** Before invoking each agent (except the first one, which receives direct input).

---

### `load-last` — Load the most recent ledger for a project

Scans the `ledger_dir/` directory for files matching the project name and returns the most recent one. Used at workflow startup to check for existing session context and enable resumption.

**Input:**

| Field        | Description                                                       |
| ------------ | ----------------------------------------------------------------- |
| ledger_dir   | Path to the context-ledger directory (e.g. `context-ledger/`)     |
| project_name | Name of the project to search for                                 |

**Logic:**

1. List all files in `{ledger_dir}/`.
2. Filter files whose name ends with `-{project_name}.md`.
3. Sort by timestamp prefix (descending) — the filename format `YYYY-MM-DD-HH-MM-` guarantees lexicographic = chronological order.
4. Return the content of the first (most recent) match.

**Output:** Full content of the most recent ledger file for the project, or empty with message `"No previous context ledger found for project '{project_name}'"`.

**When:** At workflow startup, before deciding whether to create a new session or resume.

## Procedure

Use operations in this order per workflow run:

1. `load-last` — at workflow start, check for existing sessions
2. `init` — create a new session ledger (if starting fresh or a new session on an existing project)
3. `write` — after each agent completes and checkpoint is approved
4. `read` — before each subsequent agent to inject filtered context

## Usage notes

- The workflow is responsible for defining the **Context Map** in its own structure. This skill only executes it.
- If the ledger file does not exist when attempting `write` or `read`, emit an error and notify the workflow.
- Ledger files are maintained after workflow execution — they are never deleted. They serve as traceability records.
- In flows with human checkpoint, the `write` must execute **after** the checkpoint approval, not before.
- The `ledger_dir` is typically `context-ledger/` at the project root, accessible by both Google Antigravity and Claude Code implementations.
- Multiple sessions for the same project are expected — each creates a new file with a unique timestamp.

## Backwards Compatibility

For workflows that still pass `target_dir` without `ledger_dir`:
- Treat `target_dir` as the ledger directory.
- Create the file as `{target_dir}/context-ledger.md` (legacy single-file mode).
- `load-last` is not available in legacy mode.

This ensures existing generated systems continue to work until they are migrated.

## Error Handling

- **`write` or `read` called without prior `init`:** Emit error `"No active ledger file — run init first"` and halt.
- **`context_map` references a step not yet in the ledger:** Return empty block with warning `"Step {N} not found in ledger"`.
- **Ledger file is corrupt or unreadable:** Notify the workflow orchestrator and suggest running `init` to reset.
- **`load-last` finds no matching files:** Return empty with informational message (not an error — new projects won't have history).
- **`ledger_dir` does not exist:** Emit error `"Directory {ledger_dir} not found"` and halt.
