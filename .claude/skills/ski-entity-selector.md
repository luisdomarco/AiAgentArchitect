---
name: ski-entity-selector
description: Applies the entity decision tree to determine the correct entity type for each identified responsibility in a process. Use during architecture design (Step 2) to systematically select from all 8 entity types and justify each choice against the decision criteria.
user-invocable: false
---

# Entity Selector Skill

Applies the entity decision tree to select the correct type for each responsibility identified in a process. Avoids intuition-based selection and ensures architectural coherence.

## Input / Output

**Input:**

- Description of a responsibility or capability to model
- Full process context (to evaluate relationships with other entities)

**Output:**

- Recommended entity type with justification
- Signals that confirm the selection
- Alerts if there is ambiguity between two types

---

## Procedure

### 1. Extraction of Structural Metrics

The decision trees, discriminatory matrices by shared attributes, and relational anti-pattern policies no longer reside hardcoded here. You avoid biases by getting the updated "Architecture Component Metrics" from the centralization framework.

> **You must first and mandatorily read the following resource before activating the deductive logic:**
> `../../resources/res-architecture-component-metrics.md`

Extract from there blocks 1 through 4 (Decision Tree, Discriminatory Threshold, Edge Case Resolution, and Prohibited Anti-Patterns) and use them to resolve the structural question.

---

### 5. Selection output

For each analyzed responsibility, deliver:

```
Responsibility: [description]
Selected entity: [TYPE]
Justification: [why this type and not another]
Confirmatory signals:
  - [signal 1]
  - [signal 2]
Alerts: [if there is residual ambiguity or risk of anti-pattern]
```

---

## Examples

**Example 1 — Correct selection of Skill vs Agent**

Responsibility: _"Format the output as structured JSON according to a fixed schema."_

Analysis:

- Does it condition behavior? No.
- Is it static information? No.
- Is it manual/deterministic? No.
- Multiple responsibilities? No.
- Needs own identity and decision? No — always does the same given the input.
- Reusable by multiple agents? Yes.

→ **SKILL** (`ski-format-json-output`)

---

**Example 2 — Detection of required Workflow**

Responsibility: _"Receive an email, classify it, look it up in the CRM, generate a response and send it to the client."_

Analysis:

- Multiple responsibilities? Yes: classify, look up in CRM, generate response, send.
- Transfer of outputs between parts? Yes: classification feeds the lookup, which feeds the generation.

→ **WORKFLOW** + Agent Specialists for each differentiated responsibility.

---

## Error Handling

- **Unresolvable ambiguity:** If after applying the tree and the table the selection is not clear, present both options to the user with their justification and ask them to decide.
- **User proposes an incorrect type:** Explain the anti-pattern it would generate and propose the correct alternative with justification.
