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
├── Is it an event-driven trigger that fires automated actions
│   when a system event occurs? (file change, tool use, session start)
│   └── YES → HOOK
│
├── Is it an executable automated procedure? (linting, validation,
│   deployment, data processing — runs headlessly as a script)
│   └── YES → SCRIPT
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

| Attribute                         | Workflow | Agent    | Skill | Command | Rule | Knowledge-base | Script | Hook       |
| --------------------------------- | -------- | -------- | ----- | ------- | ---- | -------------- | ------ | ---------- |
| Executes tasks directly           | No       | Yes      | Yes   | Yes     | No   | No             | Yes    | No         |
| Coordinates other entities        | Yes      | No       | No    | No      | No   | No             | No     | No         |
| Has own identity and domain       | Yes      | Yes      | No    | No      | No   | No             | No     | No         |
| Can be used standalone            | Yes      | Yes      | No    | Yes     | No   | No             | Yes    | Yes        |
| Reusable by multiple agents       | No       | No       | Yes   | No      | Yes  | Yes            | Yes    | Yes        |
| Always triggered by the user      | Optional | Optional | No    | Always  | No   | No             | No     | No         |
| Manages flow and checkpoints      | Yes      | No       | No    | No      | No   | No             | No     | No         |
| Conditions the behavior of others | No       | No       | No    | No      | Yes  | No             | No     | Yes        |
| Event-driven                      | No       | No       | No    | No      | No   | No             | No     | Yes        |

---

## 3. Criteria per entity

> Detailed per-entity criteria (key signals, validation questions) for all 8 types are in `../resources/res-entity-selection-criteria.md`. Read it when there is doubt about a specific entity type after consulting §1 and §2 above.

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

### Script vs Skill

| Situation                                                   | Entity |
| ----------------------------------------------------------- | ------ |
| Runs as an actual executable file (`.sh`, `.py`)            | Script |
| Augments an agent's reasoning with knowledge                | Skill  |
| Produces side-effects (file changes, external calls)        | Script |
| Is a knowledge package loaded on demand by an agent         | Skill  |
| Can run headlessly without any agent                        | Script |
| Only makes sense inside another Agent or Workflow           | Skill  |

### Hook vs Rule

| Situation                                                     | Entity |
| ------------------------------------------------------------- | ------ |
| Fires automatically on a system event (file change, tool use) | Hook   |
| Constrains how agents behave without executing anything       | Rule   |
| Delegates to a script or prompt for action                    | Hook   |
| Defines restrictions or conventions (never do X, always do Y) | Rule   |
| Needs event matchers and handler configuration                | Hook   |
| Is read by agents as a passive behavioral guide               | Rule   |

### Script vs Command

| Situation                                            | Entity  |
| ---------------------------------------------------- | ------- |
| Runs headlessly, often triggered by a hook           | Script  |
| Requires user interaction or manual invocation only   | Command |
| Is an automated procedure (validation, deployment)   | Script  |
| Is a saved prompt equivalent for user convenience     | Command |
| Could be invoked by a hook or another script         | Script  |
| Makes no sense for another entity to invoke it       | Command |

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
| Rule that executes scripts          | A Rule references external scripts or commands      | Create a Hook + Script pair              |
| Hook with complex business logic    | The Hook contains multi-step logic inline           | Extract logic to a Script, keep Hook thin |
