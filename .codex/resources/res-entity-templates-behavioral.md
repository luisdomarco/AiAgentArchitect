---
name: res-entity-templates-behavioral
description: Baseline markdown templates and frontmatter schemas for behavioral entity types (Workflow, Agent, Command). Read when generating or validating wor-*, age-spe-*, age-sup-*, or com-* entities. Complements res-entity-templates-support.md for procedural entities.
tags: [template, formatting, schema, behavioral, workflow, agent, command]
---

# Behavioral Entity Templates

Standardized templates for entities that execute or coordinate active logic. When the Entity Builder generates a behavioral entity, it must precisely replicate these structures and frontmatters.

> **Platform-specific templates:** For Claude Code–specific fields and conventions, see `res-entity-templates-claude-code.md`. For OpenAI Codex–specific formats (TOML agents), see `res-entity-templates-codex.md`.
> **Support entity templates:** (Skill, Rule, Knowledge-base, Script, Hook) are in `res-entity-templates-support.md`.

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

Defines what context flows between the Steps/Agents of this workflow (see `kno-workflow-patterns` §2):

| Destination Step | Consumes from     | Fields / Sections | Mode               |
| ---------------- | ----------------- | ----------------- | ------------------ |
| [step N]         | Step [M] → output | [fields or *]     | [partial/complete] |

> If the workflow has 2+ agents in sequence, use `ski-context-ledger` to persist and filter context.

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

> **Platform note:** The `model` field is platform-specific. For GA: `gemini-3-flash | gemini-3.1`. Platform-specific fields (CC: `tools`, `disallowedTools`, `permissionMode`; Codex: TOML format) are documented in their respective `res-entity-templates-*` resources.

```markdown
---
name: age-spe-[name] | age-sup-[name]
description: [max. 250 chars — WHAT the agent does + WHEN to invoke it; third person, keywords for auto-discovery]
model: gemini-3-flash | gemini-3.1               # GA model; mapped per platform
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

**Mandatory compliance step:** Before any checkpoint or final output, the agent MUST emit a `<sys-eval>` block per `rul-strict-compliance`. This applies regardless of intricacy level.

## 8. Input

[What it receives, from whom, in what format.]

## 9. Output

[What it produces, exact format.]

## 10. Rules

### 10.1. Specific rules

- [Specific rule for this agent]

### 10.2. Related rules

**Mandatory for all agents:** Every agent MUST include `rul-strict-compliance` in this table.

| Rule                    | **Route**                          | Description                                           |
| ----------------------- | ---------------------------------- | ----------------------------------------------------- |
| `rul-strict-compliance` | `./rules/rul-strict-compliance.md` | Mandatory self-evaluation before any definitive output |
| `rule-name`             | `./rules/rule-name.md`             | [what it regulates]                                   |

## 11. Definition of success

[Concrete success criteria for this agent.]
```

---

## 3. Command (`com-[name]`)

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
