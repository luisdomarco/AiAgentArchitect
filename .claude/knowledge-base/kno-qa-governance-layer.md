---
name: kno-qa-governance-layer
description: Comprehensive technical documentation of the Governance, Quality Control (QA), and Cognitive Traceability Framework implemented in AiAgentArchitect. Designed for AI consumption when instantiating new systems.
---

# Governance and QA Framework in Agentic Systems

This document describes **how to technically implement** the architectural mechanisms of Governance, Quality Control (QA), context traceability, and data persistence in complex multi-agent networks.

Any Artificial Intelligence tasked with instantiating, replicating, or scaling new agentic systems **must integrate the following architectural execution blueprint as mandatory**.

---

## 1. Cognitive Traceability: The `<sys-eval>` block

To prevent the inherent laziness of foundational models, attention drift, and quick assumptions, the system implements a **Conditional Chain of Thought (CoT)** mechanism.

### How to implement it?

1. **In Base Rules:** The new system must possess a rule like `rul-strict-compliance.md` that forces the LLM to open an XML tag `<sys-eval>` before emitting any final output. Inside it, the LLM must perform two verbalized checks:
   - _Listing my Hard Constraints:_ Verifies it does not break what is prohibited by the active rules.
   - _Listing my Tasks:_ Verifies it has executed everything it was ordered in its prompt or role.
2. **In the Orchestrator:** The code flow of the Orchestrator (the master agent of the session) must intercept the raw response from the specialist agent, extract via regex or partitioning the string found within `<sys-eval>...</sys-eval>`, and store it transiently in a variable called `reasoning_trace`.

---

## 2. Scope and Storage Definition: `target_dir`

To prevent agentic systems from polluting the repository root with massive logs, persistence is surgically isolated in the first step of the process by establishing an **isolated workspace (sandbox)**.

### How to implement it?

1. **Path Calculation:** The orchestrating Workflow is responsible for computing and creating a `target_dir` variable as soon as it starts (Step 0 or Step 1).
   - _General Domain:_ By default the `target_dir` is usually the process export path, e.g. `exports/[name]/google-antigravity/` in the master framework.
   - _V1 Domain (User Story Agent):_ In business systems, the path must strictly reflect the output hierarchy. In V1, the orchestrating workflow detects and routes its own `target_dir` to:
     - `output/[EPIC-ID]/[US-ID]/` → If the user story belongs to a parent epic.
     - `output/[US-ID]/` → If the user story is standalone.
2. **Scope Distribution:** All subsequent agents, especially those handling temporary persistence (the Context Ledger) and Quality Assurance (QA Auditor), **must receive this `target_dir` variable as an immovable argument** in each invocation so they know where to record their actions.

---

## 3. Temporary Memory and Archiver (Context Ledger)

Multi-agent systems lose context if they depend exclusively on the raw context window of the chat. The **Context Ledger** figure (`ski-context-ledger`) is used to create and read an ephemeral persistence state called `context-ledger.md` within our `target_dir`.

### How to implement it?

1. **Target Directory:** The state file must be created mandatorily at `{target_dir}/context-ledger.md`.
2. **Archiver Strategy in the Orchestrator:** `ski-context-ledger` must not delete or overwrite old executions if the process crashes and the user has to restart the app. When doing `init`, if it locates a previous `context-ledger.md` at that path, it must rename it by inserting a timestamp (e.g. `archive-context-ledger-2026-02-24-10-30-00.md`) and start a virtually blank new one.
3. **Unbreakable Write Flow:** Every time the Orchestrator receives the OK that a Specialist Agent has finished, it is prohibited from advancing without first invoking the Ledger's `write` operation. It must record there simultaneously:
   - The agent's clean _Output_.
   - The pure _`reasoning_trace`_ variable, under a standardized section (e.g. `### Reasoning Trace`).

---

## 4. Checkpoint and QA Orchestration (The "No-Skip")

Iterative advancement in an agentic system must be rigidly conditioned by user validation. This is the architectural barrier ensuring **no one skips the quality review**.

### How to implement it and when does QA intervene?

At the end of each specialist agent's work (Step), the Orchestrator must unconditionally pause and force the following menu on the user:

- A: ✅ Approve and move to the next step
- B: ✏️ Adjust this result
- C: 🔄 Regenerate
- D: ↩️ Go back

**The Option A obligation:**
Only and exclusively when the user types/selects Option `A`, the Orchestrator activates the "QA Cycle".

- If they choose B, C, or D: The logic is interrupted, the specialist is re-invoked to correct and return to the Checkpoint.
- If they choose A: It is assumed that the human local output is acceptable. AND IMMEDIATELY BEFORE jumping to _Step N+1_, the QA routines are invoked in the background presenting the evidence of that phase.

---

## 5. QA Cycle and Rotational Evaluations (QA-Reports)

The Quality Assurance block is designed to audit the LLM against itself. The audit is prohibited from stopping execution unless it finds a destructive failure; its function is to leave an indexable compliance trail and penalize deviations detected in the background.

### How to implement it step by step?

1. **Invocation of the Auditor Agent (`age-spe-auditor`):** After Option A, the Orchestrator notifies the Auditor by passing these exact coordinates:
   - Phase Name (`S1`, `S2`, etc.).
   - The exact _Output_ just generated.
   - The _Reasoning Trace_ taken from the Ledger.
   - The initially computed _`target_dir`_.
2. **Dynamic Reading by the Auditor:** The Auditor must go to disk (`/rules`) and read the strict text of the rules that had to be obeyed in that specific step. **It must read them from disk** (`kno-qa-dynamic-reading`), never relying on its internalized training.
3. **Semantic Verification (`ski-compliance-checker`):** The Auditor crosses the extracted rules with the `reasoning_trace`. It must answer this framework question: _Did the agent reason before acting and contemplate restriction X, or was it deliberately ignored?_ Judgments are evaluated and emitted visually (✅/❌/⚠️).
4. **Rotational Report Storage:**
   - The Auditor is **structurally prohibited from appending** to a megalithic giant QA document. This practice exhausts the token window.
   - The Auditor accesses the `target_dir` variable and programmatically creates the audit subdirectory: `{target_dir}/qa-reports/`.
   - Creates an evaluation file with an exact and unique timestamp: `{target_dir}/qa-reports/qa-report-{yyyy-mm-dd-hh-mm-ss}.md`.
   - Dumps there the Markdown compliance rubric for that particular step.
