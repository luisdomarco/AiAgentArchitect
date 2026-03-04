---
name: res-architecture-component-metrics
description: Logical trees, Intricacy assignment, and decision matrices for architecture.
tags: [architecture, design, metrics, mapping, blueprint, blueprints]
---

# Architecture Component Metrics

This document centralizes all deductive logic for designing clean systems, including entity selection and intricacy configuration for their guidelines. Consulted by `age-spe-architecture-designer` and its skill `ski-entity-selector`.

## 1. Entity Decision Tree

Apply this sequential tree to decide the base responsibility of any node:

```
What are you modeling?
│
├── Does it condition how other entities behave without executing anything?
│   (restrictions, conventions, quality standards)
│   └── YES → RULE
│
├── Is it static reference information that agents consult?
│   (documentation, examples, domain data, guides)
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

## 2. Discriminatory Threshold by Attributes

| Attribute                     | Workflow | Agent    | Skill | Command | Rule | Knowledge-base |
| ----------------------------- | -------- | -------- | ----- | ------- | ---- | -------------- |
| Executes tasks directly       | No       | Yes      | Yes   | Yes     | No   | No             |
| Coordinates other entities    | Yes      | No       | No    | No      | No   | No             |
| Has own identity and domain   | Yes      | Yes      | No    | No      | No   | No             |
| Can be used standalone        | Yes      | Yes      | No    | Yes     | No   | No             |
| Reusable by multiple agents   | No       | No       | Yes   | No      | Yes  | Yes            |
| Always triggered by the user  | Optional | Optional | No    | Always  | No   | No             |
| Manages flow and checkpoints  | Yes      | No       | No    | No      | No   | No             |
| Conditions behavior of others | No       | No       | No    | No      | Yes  | No             |

## 3. Resolving Common Edge Cases

### Agent vs Skill

- **Agent:** Needs to reason/decide during its execution, has a domain name, or makes sense in isolation.
- **Skill:** Only executes deterministic steps, performs a generic technical function, is repeatable across different agents.

### Command vs Agent

- **Command:** Useful only as a user trigger, is deterministic (acts as a fixed prompt).
- **Agent:** Invokable by a Workflow or another agent, adapts its behavior according to variable context.

### Workflow vs Agent

- **Workflow:** 2+ responsibilities with distinct domains, transfers outputs and delegates tasks.
- **Agent:** 1 responsibility with many internal steps, operates very autonomously.

### Rule vs Specific rules within an Agent

- **Agent:** Applies only locally.
- **Rule:** Applies transversally or conditions 2+ independent entities.

## 4. Prohibited Structural Anti-Patterns

| Anti-pattern                          | Correction                            |
| ------------------------------------- | ------------------------------------- |
| **Agent that invokes another Agent:** | Create an orchestrating Workflow.     |
| **Skill that makes decisions:**       | Upgrade category to Agent Specialist. |
| **Single-entity Workflow:**           | Downgrade to independent Agent.       |
| **Massive fact paragraphs in Agent:** | Decouple to a Knowledge-Base.         |
| **Constraint repeated in n-Agents:**  | Decouple to a transversal Rule.       |

## 5. Intricacy Level Mapping

The Blueprint requires an intricacy assignment to guide its construction for `age-spe-entity-builder`:

| Level     | When it applies                                                       |
| --------- | --------------------------------------------------------------------- |
| `simple`  | One clear task, no complex decisions, no branches                     |
| `medium`  | Several tasks, some decision, basic error handling                    |
| `complex` | Multiple tasks, decision logic, integrations, advanced error handling |

## 6. Blueprint JSON Output (Handoff S2 → S3)

```json
{
  "mode": "express | architect",
  "entities": [
    {
      "type": "workflow | agent | skill | command | rule | knowledge-base",
      "name": "name-in-kebab-case",
      "description": "description for the frontmatter",
      "function": "what this entity does",
      "input": { "description": "", "format": "" },
      "output": { "description": "", "format": "" },
      "relationships": [
        {
          "entity": "",
          "type": "invokes | is-invoked-by | consults | is-conditioned-by",
          "description": ""
        }
      ],
      "is_new": true,
      "reused_from": null,
      "intricacy_level": "simple | medium | complex"
    }
  ],
  "architecture_diagram": "complete Mermaid code | null if Express",
  "creation_order": ["..."],
  "reused_skills": ["..."]
}
```
