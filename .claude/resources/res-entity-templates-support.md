---
name: res-entity-templates-support
description: Baseline markdown templates and frontmatter schemas for support entity types (Skill, Rule, Knowledge-base, Script, Hook). Read when generating or validating ski-*, rul-*, kno-*, res-*, scp-*, or hok-* entities. Complements res-entity-templates-behavioral.md for orchestration entities.
tags: [template, formatting, schema, support, skill, rule, knowledge-base, script, hook]
---

# Support Entity Templates

Standardized templates for entities that provide passive knowledge, rules, procedures, or automation triggers. When the Entity Builder generates a support entity, it must precisely replicate these structures and frontmatters.

> **Behavioral entity templates:** (Workflow, Agent, Command) are in `res-entity-templates-behavioral.md`.
> **Platform-specific overrides:** For Claude Code fields, see `res-entity-templates-claude-code.md`. For Codex formats, see `res-entity-templates-codex.md`.

---

## 1. Skill (`ski-[name]/SKILL.md`)

> **Structure note:** Skill files use the `ski-[name]/SKILL.md` subdirectory structure on **all** platforms. The subdirectory name is the entity identifier; the file is always named `SKILL.md`. Never create a flat `ski-name.md` file. CC-specific fields (`allowed-tools`, `user-invocable`) are documented in `res-entity-templates-claude-code.md`.

```markdown
---
name: ski-[kebab-case-name]
description: [max. 250 chars — WHAT it does + WHEN to use it; third person, keywords for auto-discovery]
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

## 2. Rule (`rul-[name]`)

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

## 3. Knowledge-base (`kno-[name]`)

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

## 4. Script (`scp-[name]`)

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

## 5. Hook (`hok-[name]`)

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
