---
description: Decision tree, comparative table, and criteria for selecting the correct entity for any responsibility or capability to model.
tags: [entity-selection, decision-tree, architecture]
---

## Table of Contents

- [1. Decision tree](#1-decision-tree)
- [2. Comparative table](#2-comparative-table)
- [3. Criteria per entity](#3-criteria-per-entity)
- [4. Common edge cases](#4-common-edge-cases)
- [5. Anti-patterns](#5-anti-patterns)

---

## 1. Decision tree

```
What are you modeling?
│
├── Does it condition how other entities behave without executing anything?
│   └── YES → RULE
│
├── Is it static reference information that agents consult?
│   └── YES → KNOWLEDGE-BASE
│
├── Is it a single, deterministic action, always triggered manually by the user?
│   (another agent or workflow would never invoke it)
│   └── YES → COMMAND
│
└── Does it execute or coordinate active logic?
    │
    ├── Does it involve multiple differentiated responsibilities or
    │   transfer of outputs between distinct parts?
    │   └── YES → WORKFLOW
    │
    └── Is it a single, bounded responsibility?
        │
        ├── Does it need its own identity, make decisions in its domain,
        │   and make sense to use standalone?
        │   └── YES → AGENT
        │
        └── Is it a reusable technical procedure without its own identity
            or criteria?
            └── YES → SKILL
```

---

## 2. Comparative table

| Attribute                         | Workflow | Agent    | Skill | Command | Rule | Knowledge-base |
| --------------------------------- | -------- | -------- | ----- | ------- | ---- | -------------- |
| Executes tasks directly           | No       | Yes      | Yes   | Yes     | No   | No             |
| Coordinates other entities        | Yes      | No       | No    | No      | No   | No             |
| Has own identity and domain       | Yes      | Yes      | No    | No      | No   | No             |
| Can be used standalone            | Yes      | Yes      | No    | Yes     | No   | No             |
| Reusable by multiple agents       | No       | No       | Yes   | No      | Yes  | Yes            |
| Always triggered by the user      | Optional | Optional | No    | Always  | No   | No             |
| Manages flow and checkpoints      | Yes      | No       | No    | No      | No   | No             |
| Conditions the behavior of others | No       | No       | No    | No      | Yes  | No             |

---

## 3. Criteria per entity

### Workflow

Use it when the process involves multiple responsibilities that must execute in sequence or with branches, passing outputs from one part to the next.

**Key signals:**

- More than one responsibility domain is involved
- There are decisions or branches between parts
- Context needs to be transferred between distinct components
- There are human approval checkpoints
- The process has a start, an orchestrated flow, and a composite final output

**Validation question:** Could it be decomposed into steps with distinct responsible parties?

---

### Agent

Use it when the responsibility is single, bounded, and requires its own criteria to execute.

**Key signals:**

- A single, clear responsibility domain
- Needs to make decisions within its scope
- Can be used standalone or within a Workflow
- Has well-defined input and output

**Validation question:** Could its responsibility be described in one sentence? Does it make sense to invoke it alone?

---

### Skill

Use it when it is a technical or procedural capability that multiple agents might need, without its own identity or criteria.

**Key signals:**

- The same logic could be used in more than one Agent
- It doesn't make decisions: it executes a concrete procedure
- It has no domain context of its own
- It is activated on demand

**Validation question:** Would you find this same logic duplicated in two different Agents?

---

### Command

Use it when it is a concrete, deterministic, frequently used action that the user triggers directly with a keyword.

**Key signals:**

- Always initiated manually by the user
- Always produces the same base behavior
- Makes no sense for another Agent or Workflow to invoke it
- It is equivalent to a saved prompt

**Validation question:** Is this something the user would repeat in exactly the same way many times?

---

### Rule

Use it when you define restrictions or conventions that must condition the behavior of multiple entities without executing anything.

**Key signals:**

- The same directive applies in more than one context
- It is a restriction (never do X) or convention (always do Y this way)
- It produces no output of its own: it conditions others' outputs

**Validation question:** Did you just write the same restriction in three different Agents?

---

### Knowledge-base

Use it when it is static reference information that agents consult to ground their decisions.

**Key signals:**

- Content that doesn't change with each execution
- Agents consult it on demand, don't execute it
- Contains documentation, examples, glossaries, guides, domain data

**Validation question:** Are you stuffing a lot of factual context into an Agent's body for it to "know" it?

---

## 4. Common edge cases

### Agent vs Skill

| Situation                                           | Entity |
| --------------------------------------------------- | ------ |
| Needs to make decisions during execution            | Agent  |
| Only executes a procedure given an input            | Skill  |
| Makes sense to use standalone                       | Agent  |
| Only makes sense inside another Agent or Workflow   | Skill  |
| Has a domain name ("Contract Validator")            | Agent  |
| Is a generic technical capability ("parse_json")    | Skill  |
| The same logic would appear in two different Agents | Skill  |

### Command vs Agent

| Situation                                   | Entity  |
| ------------------------------------------- | ------- |
| Only makes sense as a manual user trigger   | Command |
| Could also be invoked by a Workflow         | Agent   |
| Always produces the same base behavior      | Command |
| Adapts its behavior to the received context | Agent   |
| Is equivalent to a saved prompt             | Command |

### Workflow vs complex Agent

| Situation                                          | Entity   |
| -------------------------------------------------- | -------- |
| Two or more responsibilities with distinct domains | Workflow |
| A single responsibility with many internal steps   | Agent    |
| Needs to transfer outputs between distinct parts   | Workflow |
| Manages human approval checkpoints                 | Workflow |
| Needs to invoke another Agent                      | Workflow |
| Operates autonomously within its domain            | Agent    |

### Rule vs Agent's Specific rules

| Situation                                   | Entity                                     |
| ------------------------------------------- | ------------------------------------------ |
| The restriction applies only to this Agent  | Specific rule in section 10.1 of the Agent |
| The same restriction applies to 2+ entities | Independent Rule referenced in 10.2        |
| It is a global system standard              | Rule with `alwaysApply: true`              |
| It is a contextual restriction              | Rule with `trigger: model_decision`        |

---

## 5. Anti-patterns

| Anti-pattern                        | Signal                                              | Correction                               |
| ----------------------------------- | --------------------------------------------------- | ---------------------------------------- |
| Agent that invokes another Agent    | An Agent references another in its instructions     | Create a Workflow that orchestrates both |
| Skill with its own criteria         | The Skill "decides" how to act according to context | Convert it to Agent Specialist           |
| Single-entity Workflow              | There is only one responsibility                    | It's an Agent, not a Workflow            |
| Factual context in Agent body       | The Agent has paragraphs of data or guides          | Extract to Knowledge-base                |
| Same restriction in multiple Agents | The same rule is repeated in 2+ Agents              | Extract to Rule                          |
| Command invocable by Workflow       | The Command makes sense as a flow step              | Convert it to Agent                      |
