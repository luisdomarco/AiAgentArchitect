---
name: res-architecture-designer-protocol
description: Output format specifications for age-spe-architecture-designer Step 6 (Blueprint presentation) and Step 7 (Architecture diagram). Loaded just-in-time when the agent reaches the presentation step. Decoupled from the agent file to keep it lean while preserving full presentation fidelity.
tags: [architecture-designer, blueprint, diagram, output-format]
---

## Purpose

Step 2 (Architecture Design) of `wor-agentic-architect` ends with the agent presenting a Blueprint to the user. The Blueprint has a strict format that must be reproduced exactly across sessions and modes. This resource externalizes that format from the agent file.

**When to load**: in Step 6 (Blueprint generation) of the Architect Mode flow, after Steps 1–5 (decomposition, entity selection, relationships, intricacy, model strategy) have determined the content.

---

## 1. Blueprint output template (Step 6)

**Pre-step — Entity count verification**: Before presenting the Blueprint, count the rows in the entity table and verify the total matches the count stated in the agent's reasoning. If there is a discrepancy, correct the count before proceeding.

Present the complete Blueprint to the user using this exact template:

```
ARCHITECTURAL BLUEPRINT

Process: [name]

PROPOSED ENTITIES ([N] total)
─────────────────────────────────

[TYPE] `entity-name` — level: simple|medium|complex
Function: [what it does]
Input: [what it receives]
Output: [what it produces]
Relationships: [with which other entities it interacts and how]
New or reused?: New | Reused from [name]

[repeat for each entity]

MODEL STRATEGY
───────────────
Strategy: [single-model | tiered-assignment | orchestrator-worker | advisor | evaluator-gate]
Rationale: [why this strategy fits this system]
Tier mapping: [e.g. complex→frontier, medium→standard, simple→fast]

[If strategy = advisor (single):]
Advisor: age-spe-advisor (frontier / max)
Escalation signals: [applicable signals from kno-agent-strategies §2.4]

[If strategy = advisor (multi):]
Advisors:
  - age-spe-advisor-{domain1} (frontier / max) — domain: {domain1}
  - age-spe-advisor-{domain2} (frontier / max) — domain: {domain2}
Escalation signals: [applicable signals from kno-agent-strategies §2.4]
Domain routing:
  - {executor-1, executor-2} → {domain1}
  - {executor-3, executor-4} → {domain2}

CREATION ORDER
─────────────────
1. entity-name-1 (reason)
2. entity-name-2 (reason)
...

REUSED SKILLS
───────────────────
- [name] → used by [entity-X] and [entity-Y]
```

---

## 2. Architecture diagram (Step 7, Architect Mode only)

Activate `ski-diagram-generator` to generate the architecture diagram in Mermaid. The diagram MUST show:

- All entities as nodes with their type (use distinct shapes/colors per type if the renderer supports it).
- Relationships between entities as labeled arrows (Invokes / Consults / Conditions).
- External systems as differentiated nodes (e.g., dashed border or different color).
- The main data flow (left-to-right or top-to-bottom; pick one and be consistent).

The diagram is presented immediately after the Blueprint text block as a visual summary. It is NOT a substitute for the Blueprint — both must be present.

---

## 3. Notes on Express Mode

Express Mode does NOT use this resource. It uses a simpler proposal format defined in the agent file (§7.3 Express Mode), single entity, no diagram, no model strategy.

This resource applies only to Architect Mode.
