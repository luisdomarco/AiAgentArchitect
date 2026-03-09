---
name: res-entity-formatting-templates
description: Core markdown schemas and baseline templates for all 8 AI Agent Architect entity types. Use when the Entity Builder needs to generate a new entity file or when verifying that an existing entity conforms to the expected structure and frontmatter.
tags: [template, formatting, schema, core, entity]
---

# Entity Formatting Templates

The system uses these standardized templates to materialize the different agentic entities. When the Entity Builder generates a file, it must precisely replicate these structures and frontmatters.

---

## 1. Workflow (`wor-[name]`)

```markdown
---
name: wor-[kebab-case-name]
description: [max. 250 characters — objective and mission of the workflow]
---

## 1. Role & Mission

[Who this workflow is and what its main mission is.]

## 2. Context

[What context it operates in. Platform, team, system it belongs to.]

## 3. Goals

- **G1:** [Specific objective with expected result]
- **G2:** [Specific objective with expected result]

## 4. Tasks

- [Main task 1]
- [Main task 2]

## 5. Agents

| **Agent**    | **Route**                   | **When use it**     |
| ------------ | --------------------------- | ------------------- |
| `agent-name` | `./workflows/agent-name.md` | [when to invoke it] |

## 6. Knowledge base

| Knowledge base | **Route**                     | Description        |
| -------------- | ----------------------------- | ------------------ |
| `kb-name`      | `./knowledge-base/kb-name.md` | [what it contains] |

## 7. Workflow Sequence

[Step-by-step description of the complete flow, including when and how to invoke each Agent.]

### Checkpoints

[Points where explicit human approval is required and what options are presented.]

### Error handling

[How to act on failures, contradictions, or unexpected cases.]

### Context Map

Defines what context flows between the Steps/Agents of this workflow (see `kno-fundamentals-entities` §10):

| Destination Step | Consumes from     | Fields / Sections | Mode               |
| ---------------- | ----------------- | ----------------- | ------------------ |
| [step N]         | Step [M] → output | [fields or *]     | [partial/complete] |

> If the workflow has 2+ agents in sequence, use `ski-context-ledger` to persist and filter context. See `kno-handoff-schemas` §4-5.

## 8. Input

[What it receives, from whom, in what format.]

## 9. Output

[What it produces, to whom it goes, in what format.]

## 10. Rules

### 10.1. Specific rules

- [Specific rule for this workflow]

### 10.2. Related rules

| Rule        | **Route**              | Description         |
| ----------- | ---------------------- | ------------------- |
| `rule-name` | `./rules/rule-name.md` | [what it regulates] |

## 11. Definition of success

[Concrete criteria that determine the workflow has worked correctly.]
```

---

## 2. Agent (`age-spe-[name]` | `age-sup-[name]`)

> **Platform note:** The `model` field and optional execution fields are platform-specific. For **Claude Code**: use `model: sonnet | opus | haiku` and optionally `tools`, `disallowedTools`, and `permissionMode`. For **Google Antigravity**: use `model: gemini-2.0-flash | gemini-2.5-pro`; the CC-native fields (`disallowedTools`, `permissionMode`) are injected by `ski-platform-exporter` during CC export.

```markdown
---
name: age-spe-[name] | age-sup-[name]
description: [max. 250 chars — QUÉ hace the agent + CUÁNDO invocarla; third person, keywords for auto-discovery]
model: sonnet | opus | haiku                     # CC: cost/capability control; GA: gemini-2.0-flash | gemini-2.5-pro
tools: [ToolA, ToolB]                            # Optional (CC): whitelist of allowed tools
disallowedTools: [ToolC, ToolD]                  # Optional (CC): blacklist of prohibited tools
permissionMode: default | acceptEdits | plan     # Optional (CC): agent autonomy level
---

## 1. Role & Mission

[Who this agent is, its role and its concrete mission.]

## 2. Context

[What context it operates in. Where its input comes from and where its output goes.]

## 3. Goals

- **G1:** [Objective with expected result]
- **G2:** [Objective with expected result]

## 4. Tasks

- [Task 1]
- [Task 2]

## 5. Skills

| **Skill**    | **Route**                      | **When use it**    |
| ------------ | ------------------------------ | ------------------ |
| `skill-name` | `./skills/skill-name/SKILL.md` | [when to activate] |

## 6. Knowledge base

| Knowledge base | **Route**                     | Description        |
| -------------- | ----------------------------- | ------------------ |
| `kb-name`      | `./knowledge-base/kb-name.md` | [what it contains] |

## 7. Execution Protocol

[How to execute the tasks step by step. Include when to use each Skill and how to apply the Rules.]

## 8. Input

[What it receives, from whom, in what format.]

## 9. Output

[What it produces, exact format.]

## 10. Rules

### 10.1. Specific rules

- [Specific rule for this agent]

### 10.2. Related rules

| Rule        | **Route**              | Description         |
| ----------- | ---------------------- | ------------------- |
| `rule-name` | `./rules/rule-name.md` | [what it regulates] |

## 11. Definition of success

[Concrete success criteria for this agent.]
```

---

## 3. Skill (`ski-[name]/SKILL.md`)

> **Platform note:** The fields `allowed-tools` and `user-invocable` are **Claude Code–native**. For **Google Antigravity**, these fields are injected by `ski-platform-exporter` during CC export. They should be defined in the source entity to document intended capabilities regardless of platform.

> **Structure note:** Skill files use the `ski-[name]/SKILL.md` subdirectory structure in **both** platforms (`.agents/skills/` and `.claude/skills/`). The subdirectory name is the entity identifier; the file is always named `SKILL.md`. Never create a flat `ski-name.md` file on either platform.

```markdown
---
name: ski-[kebab-case-name]
description: [max. 250 chars — QUÉ hace + CUÁNDO usarla; third person, keywords for auto-discovery]
allowed-tools: ToolA ToolB ToolC     # Optional (CC): tools this skill is allowed to use
user-invocable: true | false         # Optional (CC): false = only Claude can invoke it
---

# [Human-readable Skill Name]

[Brief description of what this skill does and what it is for.]

## Input / Output

**Input:**

- [Field 1: type and description]
- [Field 2: type and description]

**Output:**

- [What it produces and in what format]

---

## Procedure

[Concrete, ordered steps to execute the skill.
Use clear numbering. Include conditions if applicable.]

---

## Examples

[Concrete use cases with example input and expected output.
Include reasoning if the level is medium or complex.]

---

## Error Handling

- **[Error type]:** [How to act]
- **[Error type]:** [How to act]
```

---

## 4. Command (`com-[name]`)

```markdown
---
name: com-[kebab-case-name]
description: [max. 250 characters — what it does and when to use it]
---

[Structured system prompt. Use headings and bullets where applicable.
Must be direct and deterministic: the same command always produces the same base behavior.]

## Objective

[What it should do when this command is executed.]

## Behavior

[How it should act. Clear steps or instructions.]

## Expected output

[What it should produce and in what format.]

## Constraints

- [What it should not do]
```

---

## 5. Rule (`rul-[name]`)

```markdown
---
trigger: always_on | manual | model_decision | glob
description: [10-20 words — only if trigger is model_decision]
globs: [list of patterns — only if trigger is glob]
alwaysApply: true | false
tags: [list of tags]
---

## Context

[Why this rule exists. What problem or risk it prevents.]

## Hard Constraints

[What the model MUST NEVER do. Write in negative form.]

- Never [prohibited action]
- Never [prohibited action]

## Soft Constraints

[Preferred styles, conventions, best practices. Write in positive form.]

- Always [preferred behavior]
- Prefer [option A] over [option B]

## Examples

[Code blocks or examples showing incorrect Input vs correct Output where useful.]
```

---

## 6. Knowledge-base (`kno-[name]`)

```markdown
---
description:
  [10-20 words for semantic indexing — what it contains and what it is for]
tags: [list of thematic tags]
---

## Table of Contents

- [Section 1](#section-1)
- [Section 2](#section-2)

## [Section 1]

[Structured content with headings where applicable.]

## [Section 2]

[Structured content.]
```
