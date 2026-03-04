---
name: res-system-packaging-logic
description: Strict packaging, export, and error checkpoint policies.
tags: [export, packaging, checkpoint, error, handler]
---

# System Packaging Logic

This document contains the decision branches to execute when the Architect orchestrates system closure and injects peripheral layers.

## Final Packaging

Generate files in `exports/{system-name}/google-antigravity/.agents/` (see `kno-system-architecture` §3). Structure: `workflows/`, `skills/`, `rules/`, `knowledge-base/`, `resources/`, `process-overview.md`.

Display export summary with number of entities generated per type.

**Post-packaging checkpoint:**
A) ✅ Finalize · B) 📦 Export to Claude Code · C) 📦 Export to app (ChatGPT/Claude.ai/Dust/Gemini) · D) 📦 Multiple formats

If B/C/D: activate `ski-platform-exporter` with the system and destination platform → generates in `exports/{name}/{platform}/`. Allow multiple iterations.

**QA embed question:**
A) ✅ Yes, embed QA Layer (3 agents + 3 skills + 1 rule + 1 knowledge-base) · B) ⏭️ No, finalize

If A: activate `ski-qa-embed` with `system_path`, `system_name`, `workflow_path` and `existing_rules`. The skill creates the QA files, initializes a blank `qa-report.md`, and inserts hooks into the system's workflow.

## Checkpoint Routing Table

| ID       | Moment                    | Automatic QA                   |
| -------- | ------------------------- | ------------------------------ |
| CP-S1    | Step 1 close              | Auditor + Evaluator (S1)       |
| CP-S2    | Step 2 close              | Auditor + Evaluator (S2)       |
| CP-S3-N  | Each entity in Step 3     | Auditor (entity N)             |
| CP-CLOSE | process-overview approval | Evaluator (global) + Optimizer |

## Active Error Management

- **Incomplete handoff JSON:** request the responsible agent to complete it before continuing to the next Step.
- **Ambiguous checkpoint response:** always explicitly ask what to change before acting.
- **Inconsistency between entities:** pause and notify the user before allowing graphical continuity.

> **Important:** The handoff JSON is the only context transfer mechanism between Steps. Each agent receives the JSON from the previous Step and delivers its own back to the main pipeline.
