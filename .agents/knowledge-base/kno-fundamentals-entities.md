---
description: Definition, purpose, activation, responsibilities, and format specifications of the 6 agentic entities of the system.
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
- [8. Character limits per entity](#8-character-limits-per-entity)
- [9. Workflow patterns](#9-workflow-patterns)

---

## 1. Workflow

**Definition:** Predefined, ordered, and repeatable sequence of steps that automates a complete process from start to finish.

**Objective:** Coordinate the execution of multiple components (Agents, Skills, Rules, Knowledge-base) to complete a process.

**Activation:**

- Manual: explicitly initiated by the user.
- Instructions: invoked by another workflow, agent, skill or command.

**Key attributes:**

| Attribute          | Description                                                        |
| ------------------ | ------------------------------------------------------------------ |
| Knowledge          | Knows the complete process flow                                    |
| Function           | Invokes Agents in sequence                                         |
| Transfer           | Passes outputs of some agents as inputs of others                  |
| Supervision        | Manages checkpoints and human approvals                            |
| Context Management | Persists inter-agent state in `context-ledger.md` (see section 10) |
| Restriction        | **Does not execute tasks directly**, only coordinates              |

**File prefix:** `wor-`
**Structure:** YAML Frontmatter + Markdown Body with sections 1-11.

---

## 2. Agent

**Definition:** Set of instructions with identity, purpose, and specific domain that operates autonomously to perform delimited functions.

**Objective:** Delegate a concrete responsibility to a specialized entity that knows what to do, how to do it, and what to return.

**Activation:**

- Manual: explicitly initiated by the user.
- Instructions: invoked by a workflow, agent, skill or command.

**Key attributes:**

| Attribute    | Description                                      |
| ------------ | ------------------------------------------------ |
| Knowledge    | Knows only its own tasks                         |
| Isolation    | Does not know or depend on other agents          |
| Interface    | Defines clear `input_schema` and `output_schema` |
| Capabilities | Can use assigned Skills                          |
| Invocation   | Can be used standalone or within a Workflow      |

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

**Types:**

| Type              | Description                              | Example                         |
| ----------------- | ---------------------------------------- | ------------------------------- |
| `tool`            | Function or specific API call            | `parse_email`, `validate_input` |
| `workflow`        | Sub-process with multiple internal steps | `complete_onboarding`           |
| `integration`     | Connection with an external system       | `zendesk_create_ticket`         |
| `reasoning`       | Decision or classification logic         | `classify_urgency`              |
| `text-processing` | Text transformation or analysis          | `format_output`, `translate`    |
| `other`           | Other purposes                           | —                               |

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

**Definition:** A directory at the same level as "/workflows" or "/knowledge-base" where other resources are created/stored that are not one of the types considered so far and that are necessary or provide support to different entities or processes.

**File prefix:** `res-`

---

## 8. Character limits per entity

| Entity         | Name (max.) | Description (max.) | Recommended content | Maximum content |
| -------------- | ----------- | ------------------ | ------------------- | --------------- |
| Workflow       | 64          | 250                | <6000               | 12,000          |
| Agent          | 64          | 250                | <3000               | 12,000          |
| Skill          | 64          | 250                | <1500               | 12,000          |
| Command        | 64          | 250                | <1500               | 12,000          |
| Rule           | 64          | 250                | <3000               | 12,000          |
| Knowledge-base | 64          | 250                | <6000               | 12,000          |

---

## 9. Workflow patterns

**Pattern 1 — Linear:**

```
Input → Agent A → Agent B → Agent C → Output
```

**Pattern 2 — With Checkpoints:**

```
Input → Agent A → [Checkpoint] → Agent B → [Checkpoint] → Output
```

**Pattern 3 — With Decisions:**

```
Input → Classifier →
  ├─ Condition A → Agent A → Output
  └─ Condition B → Agent B → Output
```

**Pattern 4 — With Integrations:**

```
Input → Agent A → Integration Agent → External System
                        ↓
                  Agent B → Output
```

**Pattern 5 — Parallel with Consolidation:**

```
Input → Dispatcher →
  ├─ Agent A →
  ├─ Agent B → → Consolidator → Output
  └─ Agent C →
```

---

## 10. Context Management — Context Ledger

In sequential multi-agent flows, the workflow manages context transfer between agents via a **Context Ledger**: a temporary `context-ledger.md` file that persists the output of each step and allows the orchestrator to selectively filter what information passes to the next agent.

### Principle

The **workflow** is the only entity that knows the complete flow and, therefore, the only one that decides **what context flows and where**. Agents do not read or write to the ledger directly — the orchestrator does it for them.

### Flow

```
1. Workflow initializes context-ledger.md
2. Workflow invokes Agent A
3. Workflow writes Agent A's output to the ledger
4. Workflow reads the ledger, filters according to Context Map, and builds the input for Agent B
5. Workflow invokes Agent B with the filtered input
6. Workflow writes Agent B's output to the ledger
7. [Repeats for each following step]
```

### Context Map

Each workflow that uses the pattern must include a **Context Map** section that defines, for each step, which fields from which previous steps' outputs it needs as input:

```markdown
| Destination Step | Consumes from   | Fields / Sections | Mode     |
| ---------------- | --------------- | ----------------- | -------- |
| Step 2           | Step 1 → output | process, diagram  | partial  |
| Step 3           | Step 2 → output | entities, order   | complete |
| Step 3           | Step 1 → output | name, constraints | partial  |
```

- **Mode `complete`**: the full output of the referenced step.
- **Mode `partial`**: only the fields listed in "Fields / Sections".

### When to apply this pattern

- Workflows with **2+ agents in sequence** that need data from previous agents.
- Workflows where context must be **traceable** (auditing, debugging).
- Not necessary in single-agent workflows or in commands.

### Support Skill

To create and operate the ledger, workflows can use the skill `ski-context-ledger` (`./skills/ski-context-ledger/SKILL.md`).
