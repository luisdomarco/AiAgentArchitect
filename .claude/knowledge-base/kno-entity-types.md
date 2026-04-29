---
description: "Definition, purpose, activation, responsibilities, and format specifications of the 9 entity types: Workflow, Agent (Specialist / Supervisor), Skill, Command, Rule, Knowledge-base, Resources, Script, and Hook."
tags: [entities, fundamentals, architecture]
---

## Table of Contents

- [1. Workflow](#1-workflow)
- [2. Agent](#2-agent)
- [3. Skill](#3-skill)
- [4. Command](#4-command)
- [5. Rule](#5-rule)
- [6. Knowledge-base](#6-knowledge-base)
- [7. Resources](#7-resources)
- [8. Script](#8-script)
- [9. Hook](#9-hook)
- [10. Character limits per entity](#10-character-limits-per-entity)

> **Workflow patterns and Context Ledger:** See `kno-workflow-patterns.md`.

---

## 1. Workflow

**Definition:** Predefined, ordered, and repeatable sequence of steps that automates a complete process from start to finish.

**Objective:** Coordinate the execution of multiple components (Agents, Skills, Rules, Knowledge-base) to complete a process.

**Activation:** Manual (by user) or invoked by another workflow, agent, skill, or command.

**Key constraint:** Does not execute tasks directly — only coordinates. Persists inter-agent state via context-ledger (see `kno-workflow-patterns.md`).

**File prefix:** `wor-`
**Structure:** YAML Frontmatter + Markdown Body with sections 1-11.

---

## 2. Agent

**Definition:** Set of instructions with identity, purpose, and specific domain that operates autonomously to perform delimited functions.

**Objective:** Delegate a concrete responsibility to a specialized entity that knows what to do, how to do it, and what to return.

**Activation:** Manual (by user) or invoked by a workflow, agent, skill, or command.

**Key constraints:** Knows only its own tasks; does not depend on other agents; defines clear input/output schemas.

**Roles:**

- **Supervisor (`age-sup-`):** Quality supervision or output validation.
- **Specialist (`age-spe-`):** Execution of specific domain functions.

**Structure:** YAML Frontmatter + Markdown Body with sections 1-11.

---

## 3. Skill

**Definition:** Specialized and reusable knowledge package that gives an agent concrete capabilities for a specific task.

**Objective:** Extend an agent's capabilities in a modular and on-demand way, without overloading its context with knowledge that may not be needed in all executions.

**Activation:**

- Automatic: activated by the agent when it detects the task requires it.
- Instructions: invoked by a workflow, agent or command.

**Characteristics:**

- Reusable by multiple different agents.
- No dependencies on a specific agent.
- Loaded only when relevant to the current task.

**Types:** `tool` (API call/function), `workflow` (sub-process), `integration` (external system), `reasoning` (classification/decision), `text-processing` (transformation/analysis), `other`.

**Folder structure:**

```
ski-[name]/
├── SKILL.md          (required)
├── scripts/          (optional)
├── resources/        (optional)
└── examples/         (optional)
```

**Prefix:** `ski-` (in the folder name, not the file name)

---

## 4. Command

**Definition:** Direct and predefined instruction that triggers a concrete action or procedure immediately and deterministically.

**Objective:** Execute saved procedures quickly and precisely, reducing friction in frequent tasks.

**Activation:** Manual — always invoked by the user via keyword or predefined shortcut.

**Characteristics:**

- Deterministic execution: the same Command always produces the same base behavior.
- Can invoke Agents or Skills.
- Does not require the user to write instructions each time.
- Oriented towards atomic or frequently used tasks.
- Similar to a saved prompt.

**Difference from Workflow:** A Command is a single or few-step action. A Workflow is a complete multi-agent process. A Command can be a step within a Workflow, but not the other way around.

**File prefix:** `com-`
**Structure:** YAML Frontmatter + Markdown Body (structured system prompt).

---

## 5. Rule

**Definition:** Set of guidelines, directives, or restrictions that condition the behavior of Workflows, Agents, Skills, or Commands.

**Objective:** Ensure consistency, quality, and adherence to standards in all executions.

**Characteristics:**

- Does not execute tasks, only defines how they must be executed.
- Can be global (applies to everything) or specific (applies to a context).
- It is the most passive component: guides without acting.

**Activation modes:**

| Mode             | Description                                             |
| ---------------- | ------------------------------------------------------- |
| `always_on`      | Always applies, in any context                          |
| `manual`         | Explicitly activated by direct mention                  |
| `model_decision` | The model evaluates whether it applies based on context |
| `glob`           | Applies to files matching a pattern                     |

**File prefix:** `rul-`
**Structure:** YAML Frontmatter (`trigger`, `description`, `globs`, `alwaysApply`, `tags`) + Markdown Body.

---

## 6. Knowledge-base

**Definition:** Repository of reference information that agents consult to ground their decisions and outputs.

**Objective:** Provide factual context, domain data, examples, or documentation without incorporating that knowledge directly into each agent's instructions.

**Characteristics:**

- Does not execute or coordinate: it is static consultable content.
- Can contain: technical documentation, style guides, reference data, examples, glossaries.
- Agents consult it on demand.
- Decouples domain knowledge from agent logic.

**File prefix:** `kno-`
**Structure:** YAML Frontmatter (`description`, `tags`) + Markdown Body with table of contents.

---

## 7. Resources

**Definition:** Support documents that extend the content of other entities when a single entity file would exceed its recommended size limit. Resources break down complex specifications, large tables, examples, templates, or reference data into dedicated files that are referenced from the main entity.

**Objective:** Prevent entity files from becoming monolithic, keeping main entities concise and focused while offloading detailed supporting content to dedicated resource files.

**Characteristics:**

- Does not execute or coordinate: it is static reference content, like Knowledge-base.
- Always referenced from another entity (never standalone).
- Preferred over embedding large content directly in a workflow, agent, or knowledge-base file.
- Can contain: detailed templates, decision trees, raw data tables, long examples, execution manuals.

**When to create a Resource:**

- When a workflow, agent, or knowledge-base file approaches its recommended character limit.
- When a section of content is too detailed to inline without burying the main instructions.
- When the same reference content is needed by more than one entity (favors reuse).

**File prefix:** `res-`
**Structure:** YAML Frontmatter (`name`, `description`, `tags`) + Markdown Body (free format, organized with headings).

---

## 8. Script

**Definition:** Executable procedure that performs a concrete automated task. In Claude Code, it is an actual runnable file (`.sh`, `.py`). In Google Antigravity, it is a procedural instruction document describing what the script should do.

**Objective:** Encapsulate automated tasks (linting, validation, deployment, data processing) as standalone executable units that can be invoked by hooks, commands, or manually.

**Activation:** By a Hook (event-driven), by a Command (user-triggered), or manually from the terminal.

**Platform behavior:** Claude Code → `.sh`/`.py` executable in `scripts/`. Google Antigravity → `.md` procedural instruction document in `scripts/`. Format differs between platforms — never edit Codex scripts directly (compiled by `build-codex.py`).

**File prefix:** `scp-`
**Structure:** YAML Frontmatter + executable code (CC) or procedural Markdown (GA).

---

## 9. Hook

**Definition:** Event-driven trigger that fires automated actions when a specific system event occurs. In Claude Code, it is a configuration entry in `settings.json`. In Google Antigravity, it is a behavioral instruction file that tells agents when and how to act.

**Objective:** Provide event-driven automation — trigger QA on file write, validate naming on entity creation, restore context on session start, enforce constraints before tool execution.

**Activation:** Automatic — triggered by system events. Never manually invoked. Does not execute logic directly — delegates to scripts (`command` type), LLM evaluations (`prompt`), subagents (`agent`), or HTTP endpoints (`http`).

**Platform behavior:** Claude Code → entry in `settings.json` under `hooks` key + documentation in `hooks/hok-*.md`. Google Antigravity → behavioral `.md` file in `hooks/`. A hook often references a script (hook = trigger, script = action).

**File prefix:** `hok-`
**Structure:** YAML Frontmatter + Markdown body + `settings.json` entry (CC only).

For hook events catalog, handler types, and configuration reference: `kno-hooks-and-scripts.md`.

---

## 10. Character limits per entity

| Entity         | Name (max.) | Description (max.) | Recommended content | Maximum content |
| -------------- | ----------- | ------------------ | ------------------- | --------------- |
| Workflow       | 64          | 250                | <6,000              | 12,000          |
| Agent          | 64          | 250                | <3,000              | 12,000          |
| Skill          | 64          | 250                | <1,500              | 12,000          |
| Command        | 64          | 250                | <1,500              | 12,000          |
| Rule           | 64          | 250                | <3,000              | 12,000          |
| Knowledge-base | 64          | 250                | <6,000              | 12,000          |
| Resources      | 64          | 250                | <6,000              | 12,000          |
| Script         | 64          | 250                | <1,500              | 12,000          |
| Hook           | 64          | 250                | <1,500              | 12,000          |
