---
trigger: always_on
alwaysApply: true
tags: [qa, audit, evaluation, optimization]
---

## Context

This rule defines the behavior of the QA cycle (Audit + Evaluation + Optimization) as a transversal layer of the system. The QA Layer runs automatically after each approved checkpoint, without requiring the user to activate it. Its goal is to ensure the system continuously self-evaluates and accumulates knowledge to improve.

The QA Layer is external to the creative process: it observes, measures, and proposes, but never modifies or makes decisions on behalf of the user.

## Hard Constraints

- The QA Layer activates **after** the user approves a checkpoint, never before or instead of it.
- The Auditor (`age-spe-auditor`) and the Evaluator (`age-spe-evaluator`) **do not modify any file** of the audited system.
- The Optimizer (`age-spe-optimizer`) **does not automatically apply any proposal** — every modification requires an explicit user decision.
- The `qa-report.md` is always updated in **append** mode — it is never overwritten and no previous blocks are deleted. **This update must be written to disk immediately** at the moment of the audit, not at the end of the process.
- The Auditor **always reads entity files and Rules from disk** at the time of the audit, never from in-memory versions.
- AFTER WRITING THE REPORT TO DISK: The Auditor or Evaluator **must always emit a chat-visible summary to the user** of at most 5 lines. The QA cycle is not silent; the user must know what has been evaluated.

## Soft Constraints

- If a phase score is `< 4.0` (Critical), the orchestrator may optionally notify the user with a warning before continuing to the next step.
- The QA cycle in CP-S3-N (per entity) may be limited to the Auditor only (without the Evaluator) if the number of entities is > 7, to avoid extending the process.
- If the user explicitly rejects the QA (`/skip-qa`), the cycle may be skipped for that phase, but the omission is recorded in `qa-report.md`.

## Automatic Activation

| Event             | Activate                       | Output                                        |
| ----------------- | ------------------------------ | --------------------------------------------- |
| CP-S0 approved    | Auditor (S0) → Evaluator (S0)  | Block [Audit S0] + [Score S0] in qa-report.md |
| CP-S1 approved    | Auditor (S1) → Evaluator (S1)  | Block [Audit S1] + [Score S1] in qa-report.md |
| CP-S2 approved    | Auditor (S2) → Evaluator (S2)  | Block [Audit S2] + [Score S2] in qa-report.md |
| CP-S3-N approved  | Auditor (entity N)             | Block [Audit S3-{entity}] in qa-report.md     |
| CP-CLOSE approved | Evaluator (global) → Optimizer | Global Scorecard + Proposals in qa-report.md  |

## On-demand Re-audit

The user may trigger at any time:

```
/re-audit [entity | phase | system]
```

Valid examples:

- `/re-audit rul-naming-conventions` → re-audits that specific file
- `/re-audit S2` → re-audits the entire S2 phase with current content
- `/re-audit system` → re-audits all generated entities

The re-audit appends a block `## [Re-audit — {target} — {timestamp}]` to the end of `qa-report.md`. It never overwrites previous audits.

## Voluntary Omission

The user may skip QA for a phase with:

```
/skip-qa [phase]
```

This records in `qa-report.md`:

```markdown
## [QA Skipped — {phase}] — {timestamp}

_The user skipped the QA cycle for this phase._
```

## Agent Responsibilities

| Agent               | Can                                                       | Cannot                                        |
| ------------------- | --------------------------------------------------------- | --------------------------------------------- |
| `age-spe-auditor`   | Read files, report compliance                             | Modify, suggest content improvements          |
| `age-spe-evaluator` | Calculate scores, write to qa-report.md                   | Modify entities, issue qualitative judgements |
| `age-spe-optimizer` | Propose improvements with concrete target and description | Apply changes, modify any file                |
