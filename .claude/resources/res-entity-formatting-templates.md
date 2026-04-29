---
name: res-entity-formatting-templates
description: "RETIRED — Replaced by res-entity-templates-behavioral.md (Workflow, Agent, Command) and res-entity-templates-support.md (Skill, Rule, KB, Script, Hook). Do not reference this file."
tags: [retired, deprecated]
---

> **RETIRED:** This file has been split into:
> - `res-entity-templates-behavioral.md` — Workflow, Agent, Command templates
> - `res-entity-templates-support.md` — Skill, Rule, Knowledge-base, Resource, Script, Hook templates
>
> Update all references to use those files instead.

# Entity Formatting Templates

The system uses these standardized templates to materialize the different agentic entities. When the Entity Builder generates a file, it must precisely replicate these structures and frontmatters.

> **Platform-specific templates:** For Claude Code–specific fields and conventions, see `res-entity-templates-claude-code.md`. For OpenAI Codex–specific formats (TOML agents, hooks.json), see `res-entity-templates-codex.md`.

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

Defines what context flows between the Steps/Agents of this workflow (see `kno-workflow-patterns` for context coordination patterns and `kno-handoff-schemas` for the schemas):

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

> **Platform note:** The `model` field is platform-specific. For GA: `gemini-3-flash | gemini-3.1`. Platform-specific fields (CC: `tools`, `disallowedTools`, `permissionMode`; Codex: TOML format) are documented in their respective `res-entity-templates-*` resources.

```markdown
---
name: age-spe-[name] | age-sup-[name]
description: [max. 250 chars — QUÉ hace the agent + CUÁNDO invocarla; third person, keywords for auto-discovery]
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

| Rule                    | **Route**                         | Description                                           |
| ----------------------- | --------------------------------- | ----------------------------------------------------- |
| `rul-strict-compliance` | `./rules/rul-strict-compliance.md` | Mandatory self-evaluation before any definitive output |
| `rule-name`             | `./rules/rule-name.md`            | [what it regulates]                                   |

## 11. Definition of success

[Concrete success criteria for this agent.]
```

---

## 3. Skill (`ski-[name]/SKILL.md`)

> **Structure note:** Skill files use the `ski-[name]/SKILL.md` subdirectory structure on **all** platforms. The subdirectory name is the entity identifier; the file is always named `SKILL.md`. Never create a flat `ski-name.md` file. CC-specific fields (`allowed-tools`, `user-invocable`) are documented in `res-entity-templates-claude-code.md`.

```markdown
---
name: ski-[kebab-case-name]
description: [max. 250 chars — QUÉ hace + CUÁNDO usarla; third person, keywords for auto-discovery]
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

---

## 7. Script (`scp-[name]`)

> **Platform note:** Scripts have different formats per platform. GA: `.md` procedural document. CC and Codex: `.sh`/`.py` executables. Details in `res-entity-templates-claude-code.md` and `res-entity-templates-codex.md`.

```markdown
---
name: scp-[kebab-case-name]
description: [max. 250 chars — what it does + when to use it]
platform: claude-code | google-antigravity
language: bash | python
triggers: [list of hooks or commands that invoke this script]
---

# [Human-readable Script Name]

[Brief description of what this script does.]

## Purpose

[What problem it solves and why it exists.]

## Usage

[How to invoke: command line, hook reference, or manual trigger.]

## Parameters

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| [param] | [type] | [yes/no] | [what it controls] |

## Behavior

[Step-by-step description of what the script does.
For CC: actual executable code.
For GA: procedural instructions describing the equivalent logic.]

## Error Handling

- **[Error case]:** [How to handle it]

## Dependencies

- [External tool or system required]
```

---

## 8. Hook (`hok-[name]`)

> **Platform note:** Hook `.md` documentation is identical on all platforms. CC additionally requires a `settings.json` entry (see `res-entity-templates-claude-code.md` §4). Codex requires a JSON fragment file (see `res-entity-templates-codex.md` §4). GA uses the `.md` as a behavioral instruction that agents read at runtime.

```markdown
---
name: hok-[kebab-case-name]
description: [max. 250 chars — what it does + when it fires]
event: [SessionStart | SessionEnd | InstructionsLoaded | UserPromptSubmit | PreToolUse | PermissionRequest | PermissionDenied | PostToolUse | PostToolUseFailure | Stop | StopFailure | Notification | SubagentStart | SubagentStop | TaskCreated | TaskCompleted | TeammateIdle | PreCompact | PostCompact | WorktreeCreate | WorktreeRemove | FileChanged | CwdChanged | ConfigChange | Elicitation | ElicitationResult]
matcher: [tool name, file pattern, or session type — if applicable]
type: command | prompt | agent | http
platform_behavior:
  google_antigravity: [brief description of behavioral rule equivalent]
  claude_code: [brief description of settings.json entry]
  codex: [brief description of hooks.json fragment — or "N/A" if event unsupported]
---

# [Human-readable Hook Name]

[Brief description of what this hook does and when it fires.]

## Event Trigger

[Which system event triggers this hook and what conditions must be met.]

## Matcher

[What tools, files, or patterns this hook matches against. "None" if the event has no matcher.]

## Action

### Claude Code

[The exact settings.json entry structure for this hook.]

### Google Antigravity

[The behavioral rule equivalent — how agents should behave as if this hook existed.]

### OpenAI Codex

[The hooks.json fragment for this hook, or "N/A — event not supported in Codex" if the event has no equivalent.]

## Related Scripts

| Script | Route | Purpose |
| --- | --- | --- |
| `scp-[name]` | `./scripts/scp-[name].sh` | [what it executes] |

## Error Handling

- **[Error case]:** [How to handle it]
```
