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
├── Is it an event-driven trigger that fires automated actions
│   when a system event occurs? (file change, tool use, session start)
│   └── YES → HOOK
│
├── Is it an executable automated procedure? (linting, validation,
│   deployment, data processing — runs headlessly as a script)
│   └── YES → SCRIPT
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

| Attribute                     | Workflow | Agent    | Skill | Command | Rule | Knowledge-base | Script | Hook       |
| ----------------------------- | -------- | -------- | ----- | ------- | ---- | -------------- | ------ | ---------- |
| Executes tasks directly       | No       | Yes      | Yes   | Yes     | No   | No             | Yes    | No         |
| Coordinates other entities    | Yes      | No       | No    | No      | No   | No             | No     | No         |
| Has own identity and domain   | Yes      | Yes      | No    | No      | No   | No             | No     | No         |
| Can be used standalone        | Yes      | Yes      | No    | Yes     | No   | No             | Yes    | Yes        |
| Reusable by multiple agents   | No       | No       | Yes   | No      | Yes  | Yes            | Yes    | Yes        |
| Always triggered by the user  | Optional | Optional | No    | Always  | No   | No             | No     | No         |
| Manages flow and checkpoints  | Yes      | No       | No    | No      | No   | No             | No     | No         |
| Conditions behavior of others | No       | No       | No    | No      | Yes  | No             | No     | Yes        |
| Event-driven                  | No       | No       | No    | No      | No   | No             | No     | Yes        |

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

### Script vs Skill

- **Script:** Actual executable procedure (`.sh`/`.py`), produces side-effects, runs headlessly.
- **Skill:** Knowledge package that augments agent capabilities, no side-effects of its own, loaded on demand.

### Hook vs Rule

- **Hook:** Event-driven trigger that fires automated actions on system events, delegates to scripts or prompts.
- **Rule:** Passive behavioral constraint that agents read and follow, never executes anything.

### Script vs Command

- **Script:** Automated procedure, often triggered by hooks, runs headlessly.
- **Command:** User-triggered saved prompt, requires manual invocation, interactive.

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
| **Rule that executes scripts:**       | Create a Hook + Script pair.          |
| **Hook with complex business logic:** | Extract logic to Script, keep Hook thin. |

## 5. Intricacy Level Mapping

The Blueprint requires an intricacy assignment to guide its construction for `age-spe-entity-builder`:

| Level     | When it applies                                                       |
| --------- | --------------------------------------------------------------------- |
| `simple`  | One clear task, no complex decisions, no branches                     |
| `medium`  | Several tasks, some decision, basic error handling                    |
| `complex` | Multiple tasks, decision logic, integrations, advanced error handling |

### 5.1. Measurable Intricacy Criteria

The architecture designer MUST count and declare the following metrics to justify each intricacy level assignment:

| Metric              | `simple`  | `medium` | `complex` |
| ------------------- | --------- | -------- | --------- |
| Responsibilities    | 1-2       | 3-5      | 6+        |
| External integrations | 0-1     | 1-2      | 3+        |
| Decision branches   | 0-1       | 2-3      | 4+        |

**Usage:** When assigning intricacy in the Blueprint, state the counts:

```
`age-spe-ticket-router` — level: medium
  Justification: 3 responsibilities, 1 integration (Zendesk API), 2 decision branches
```

The Auditor can verify these counts against the actual entity content.

## 6. Blueprint JSON Output (Handoff S2 → S3)

```json
{
  "mode": "express | architect",
  "model_strategy": {
    "strategy": "single-model | tiered-assignment | advisor | orchestrator-worker | evaluator-gate",
    "tier_mapping": { "complex": "frontier", "medium": "standard", "simple": "fast" },
    "advisor_config": {
      "advisor_entity": "age-spe-advisor",
      "advisors": null,
      "escalation_signals": []
    },
    "rationale": ""
  },
  "entities": [
    {
      "type": "workflow | agent | skill | command | rule | knowledge-base | script | hook",
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

**Notes on `model_strategy`:** Optional field. If absent, Entity Builder defaults to `tiered-assignment`. The `advisor_config` sub-object is only present when `strategy` = `advisor`. See `kno-agent-strategies` for strategy definitions and selection guide.

**`advisor_config` formats:**

- **Single advisor** (default): `advisors` is `null` or absent. The `advisor_entity` field names the single advisor (`age-spe-advisor`).
- **Multi-advisor**: `advisors` is an array. Each entry maps a domain-specific advisor to its assigned executors. When `advisors` is non-null, the `advisor_entity` field is ignored (kept for backward compatibility).

Multi-advisor example:

```json
"advisor_config": {
  "advisor_entity": "age-spe-advisor",
  "advisors": [
    { "entity": "age-spe-advisor-security", "domain": "security", "executors": ["age-spe-backend-dev", "age-spe-infra-dev"] },
    { "entity": "age-spe-advisor-data", "domain": "data", "executors": ["age-spe-data-engineer", "age-spe-etl-builder"] }
  ],
  "escalation_signals": ["repeated-failure", "circular-loop", "declared-uncertainty", "unexpected-complexity", "architectural-decision"]
}
```
