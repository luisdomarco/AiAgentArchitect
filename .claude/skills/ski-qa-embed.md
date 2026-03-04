---
name: ski-qa-embed
description: Transversal skill that takes a freshly generated system path and embeds the QA Layer (3 agents + 3 skills + 1 rule + 1 knowledge-base) into it. Parametrizes templates from kno-qa-layer-template with the target system's name and rules. Also inserts QA hooks into the target system's workflow and initializes a blank qa-report.md. Use after the packaging step when the user opts to embed QA in the new system.
---

# QA Embed

## Input / Output

**Input:**

- `system_path`: base path of the destination system, e.g. `exports/my-system/google-antigravity/.agents/`
- `system_name`: name of the system (e.g. `my-system`)
- `workflow_path`: path of the main workflow of the destination system (e.g. `./workflows/wor-my-name.md`)
- `existing_rules`: list of Rule paths from the destination system (e.g. `["./rules/rul-my-rule.md"]`)

**Output:**

- Files created in `system_path/workflows/` (3 parametrized QA agents)
- Files created in `system_path/skills/` (3 QA skills)
- File created in `system_path/rules/rul-audit-behavior.md`
- File created in `system_path/knowledge-base/kno-qa-dynamic-reading.md`
- Destination system workflow modified with QA hooks
- `system_path/qa-report.md` initialized blank with frontmatter
- Confirmation message with inventory of what was created

## Procedure

### Step 1 — Reading templates

Read the universal raw templates resource for embedding: `../../resources/res-qa-layer-raw-templates.md` and extract the needed templates:

- `age-spe-auditor` (base template)
- `age-spe-evaluator` (base template)
- `age-spe-optimizer` (base template)
- `ski-compliance-checker` (base template)
- `ski-rubric-scorer` (base template)
- `ski-pattern-analyzer` (base template)
- `rul-audit-behavior` (base template)
- `kno-qa-dynamic-reading` (base template)
- `rul-strict-compliance` (new base template)
- `ski-context-ledger` (new base template)

### Step 2 — Parametrization

For each template, replace the parametrization tokens:

- `{SYSTEM_NAME}` → value of `system_name`
- `{WORKFLOW_PATH}` → value of `workflow_path`
- `{EXISTING_RULES}` → formatted list of `existing_rules`
- `{SYSTEM_PATH}` → value of `system_path`

The QA agents already know how to audit the destination system's Rules because they receive the list in each activation.

### Step 3 — File creation

Create the files at the correct paths within `system_path`:

```
{system_path}/
├── workflows/
│   ├── age-spe-auditor.md        ← parametrized
│   ├── age-spe-evaluator.md      ← parametrized
│   └── age-spe-optimizer.md      ← parametrized
├── skills/
│   ├── ski-compliance-checker/
│   │   └── SKILL.md
│   ├── ski-rubric-scorer/
│   │   └── SKILL.md
│   ├── ski-pattern-analyzer/
│   │   └── SKILL.md
│   └── ski-context-ledger/
│       └── SKILL.md
├── rules/
│   ├── rul-audit-behavior.md     ← parametrized
│   └── rul-strict-compliance.md  ← parametrized
└── knowledge-base/
    └── kno-qa-dynamic-reading.md ← parametrized
```

### Step 4 — Modification of destination workflow

Read the main workflow of the destination system (`workflow_path`). Add at the end of the Workflow Sequence section (or at the beginning of the final packaging) the QA hooks block, including the imperative instruction for the orchestrator to calculate and ask for the destination path:

```markdown
### Session Initialization (Step 0)

Mandatory: At the start of the flow, before invoking the first sub-agent, the main Workflow MUST ask the user: `"In which directory do you want to generate the reports and outputs for this process? (e.g. output/process-xyz/)"`. Once the user responds, the orchestrator will store that response in the internal variable `target_dir` and use it to initialize the Context Ledger and inject it into all QA modules.

### QA Layer — Automatic activation

After each approved checkpoint, activate the corresponding QA cycle, always sending the `target_dir` and the `reasoning_trace` extracted from the Ledger:

| Checkpoint            | Activate                                                                 |
| --------------------- | ------------------------------------------------------------------------ |
| CP-S1 (or equivalent) | `age-spe-auditor` → `age-spe-evaluator` (pointing to current target_dir) |
| CP-S2 (or equivalent) | `age-spe-auditor` → `age-spe-evaluator` (pointing to current target_dir) |
| CP per entity         | `age-spe-auditor` (pointing to current target_dir)                       |
| CP-CLOSE              | `age-spe-evaluator` (global) → `age-spe-optimizer`                       |

For manual re-audits use: `/re-audit [entity | phase | system]`

Active system rules being audited: {EXISTING_RULES}
```

### Step 5 — Update of destination system process-overview.md

If `{system_path}/../process-overview.md` exists, add the QA Layer to the entity inventory and architecture diagram.

### Step 6 — Confirmation message

```
✅ QA Layer embedded in {system_name}

Added entities:
- 3 agents: age-spe-auditor, age-spe-evaluator, age-spe-optimizer
- 4 skills: ski-compliance-checker, ski-rubric-scorer, ski-pattern-analyzer, ski-context-ledger
- 2 rules: rul-audit-behavior, rul-strict-compliance
- 1 knowledge-base: kno-qa-dynamic-reading

The {system_name} orchestrator has been configured to ask for its target_dir interactively and audit itself in rotational silos.
```

## Error Handling

- If `system_path` does not exist: error — `"The destination system does not exist at the indicated path"`
- If `age-spe-auditor.md` already exists at the destination: ask `"A QA Layer already exists in this system. Overwrite? A) Yes / B) No"`
- If the destination workflow has no identifiable Workflow Sequence section: add the block at the end of the file with an explanatory note
- If `existing_rules` is empty: embed with warning `"No active Rules detected — the Auditor will use only the QA Layer rules"`
