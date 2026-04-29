---
name: ski-memory-manager
description: Manages lightweight persistent memory files for cross-session project context. Use when a workflow needs to save or retrieve a condensed summary of previous work on a project to enable fast startup without re-reading full context ledgers.
type: workflow
---

## Description

Reusable skill that provides operations to manage the `memory/` directory of a project. Memory files are condensed summaries (~1-2KB) that allow a workflow orchestrator to quickly orient itself when resuming work on an existing project, without consuming the tokens required by a full context ledger.

**The memory file is a quick-start summary; the context ledger is the full record.**

## Input / Output

**Input (common):** `memory_dir`, `project_name` — varies by operation (see below).

**Output:** Created or updated memory file (for `save`) or a memory content block ready for injection (for `load-last`).

## Operations

### `save` — Write or update a session memory file

Creates or updates a condensed memory file for the current session. If a file with the same session timestamp already exists, it overwrites it. Otherwise, creates a new file.

**Input:**

| Field                  | Description                                                                          |
| ---------------------- | ------------------------------------------------------------------------------------ |
| memory_dir             | Path to the memory directory (default: `memory/`)                                    |
| project_name           | Name of the project (e.g. `agsy-product-manager-aramis`)                             |
| session_timestamp      | Timestamp of the current session in `YYYY-MM-DD-HH-MM` format                       |
| mode                   | `architect` or `express`                                                             |
| status                 | `in-progress` / `completed` / `paused` (see status semantics below)                  |
| last_checkpoint        | ID of the last approved checkpoint (e.g. `CP-S2`, `CP-CLOSE`)                        |
| checkpoints_approved   | List of all approved checkpoints so far                                              |
| checkpoint_decisions   | (v3 — 4.2.2) Object: which option (A/B/C/D) the user picked at each checkpoint + optional note. See structure below. |
| target_dir             | Path to the export directory for this project                                        |
| session_summary        | 2-3 line description of what was designed/generated in this session                  |
| steps_completed        | Object with step summaries: `{ "S0": "...", "S1": "...", ... }`                      |
| active_state           | What is pending, open questions, next steps                                          |
| key_decisions          | List of key design decisions made                                                    |
| last_session_at        | (v3 — 4.2.4) ISO 8601 timestamp of when this session started. Computed automatically. |

**Output:** File `{memory_dir}/{session_timestamp}-{project_name}.md` created with structure:

```markdown
---
schema_version: 1.1
project-name: {project_name}
session: {session_timestamp}
mode: {mode}
status: {status}
last-checkpoint: {last_checkpoint}
checkpoints-approved: [{checkpoints_approved}]
checkpoint_decisions:
  CP-S0: { option: A, note: "Approved as-is" }
  CP-S1: { option: B, note: "Adjusted: added 2 triggers" }
  CP-S2: { option: C, regenerated_count: 1 }
target-dir: {target_dir}
last_session_at: 2026-04-25T10:00:00Z
---

## Session summary
{session_summary}

## Steps completed
- S0: {steps_completed.S0}
- S1: {steps_completed.S1}
...

## Active state
{active_state}

## Key decisions
- {key_decisions[0]}
- {key_decisions[1]}
...
```

**Schema version note (v3 — 4.2.1):** The `schema_version` field distinguishes v3 Memory snapshots (1.1) from v2 baseline (absent or 1.0). When `load-last` reads a file without `schema_version`, treat it as v1.0 and silently migrate fields on the next `save` (back-compat).

**Status semantics:**

| Status | Meaning | Visible in load-last? |
|---|---|---|
| `in-progress` | Active session, mid-workflow | Yes |
| `paused` | Temporarily stopped, plans to resume soon | Yes |
| `completed` | Workflow reached CP-CLOSE, no pending work | Yes |

**When:** After each checkpoint approval and at session close.

---

### `load-last` — Load the most recent memory for a project

Scans the memory directory for files matching the project name and returns the most recent one.

**Input:**

| Field        | Description                                                      |
| ------------ | ---------------------------------------------------------------- |
| memory_dir   | Path to the memory directory (default: `memory/`)                |
| project_name | Name of the project to search for                                |

**Logic:**

1. List all files in `{memory_dir}/`.
2. Filter files whose name ends with `-{project_name}.md`.
3. Sort by timestamp prefix (descending) — the filename format `YYYY-MM-DD-HH-MM-` guarantees lexicographic = chronological order.
4. Read the content of the first (most recent) match.
5. **Compute time-since-last-session:** read `last_session_at` from the loaded Memory; compute `time_since_last_session_hours = now - last_session_at`. Surface as part of the load output:
   - `"Resuming `foo-system` (last touched 3 days ago, status: in-progress at CP-S2)"`.
6. Return the content of the most recent memory file.

**Output:** Full content of the most recent memory file, or empty with message `"No previous memory found for project '{project_name}'"`. When v3 verification triggers, also include a one-line summary of the resolution.

**When:** At workflow startup, before initializing a new session, to check for existing project context.

## Procedure

Use operations in this order per workflow run:

1. `load-last` — at workflow start, check for existing context
2. `save` — after each checkpoint approval (update in-progress state)
3. `save` — at workflow close (final state with status=`completed`)

## Usage notes

- The workflow is responsible for composing the memory content. This skill only handles the file mechanics.
- Memory files are designed to be small (~1-2KB). Do NOT dump the full context ledger into memory — use concise summaries.
- If `memory_dir` does not exist, emit an error and notify the workflow.
- Memory files are never deleted — they accumulate as a historical record of sessions.
- Multiple sessions for the same project are expected (different timestamps).

## Error Handling

- **`save` called with missing `memory_dir`:** Emit error `"memory directory not found at {memory_dir}"` and halt.
- **`load-last` finds no matching files:** Return empty with informational message (not an error — new projects won't have memory).
- **Corrupted or unreadable file:** Skip it and try the next most recent. If all fail, return empty with warning.
