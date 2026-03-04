---
name: res-interview-question-trees
description: Logical question trees, decomposition techniques, and interview blocks for Discovery.
tags: [interview, questions, process, discovery, BPM]
---

# Process Interview Question Trees

This document acts as the "conversational brain" of the process discovery specialist (`age-spe-process-discovery` and its skill `ski-process-interviewer`). It contains all applicable questions organized by depth level.

## Reverse Engineering Technique

When faced with vague or generic descriptions, systematically decompose:

> _"When you say [vague term], do you mean [option A], [option B], or [option C]?"_

| Vague description         | Decomposition                                                                                               |
| ------------------------- | ----------------------------------------------------------------------------------------------------------- |
| "Automate [process]"      | What specific steps does that process have today? Which one takes the most time? Which has the most errors? |
| "Manage [entity]"         | Manage in what sense: create, update, delete, classify, route?                                              |
| "Process [data]"          | What exactly is done with that data? Is it transformed, validated, stored, sent?                            |
| "Improve [area]"          | What specific problem exists in that area today? How is improvement measured?                               |
| "Integrate with [system]" | What information is read from that system? What information is written? How often?                          |

---

## Interview Blocks (Architect Mode)

Apply the blocks in order. Within each block, formulate one question at a time.

### Block 1 — System objective

- What specific problem should this system solve? _(validation: concrete description, not generic)_
- What is the result when it works correctly? What does that success look like?
- How is this done today, without the system? What steps are followed manually?
- What happens if the system fails or doesn't exist? What is the cost or impact?

### Block 2 — Data flow

- Describe the flow step by step. _(suggested format: 1. → 2. → 3.)_
- What INPUT does the system receive to start? What is its format and origin?
- Who or what triggers the process? _(user, event, cron job, webhook, email...)_
- What OUTPUT does it produce when finished? To whom or what system does that output go?

### Block 3 — Flow validation (Complexity)

- Are there decisions or branches? At what points and what conditions each path?
- Are there steps that can fail? What happens when they fail?
- Are there steps that repeat until some condition is met?
- Are there exceptional cases or edge cases the system must handle differently?

### Block 4 — Integrations

- Does the process interact with any external system? _(CRM, ERP, database, API, email, Slack...)_
- For each system: what information is read? What information is written? How often?
- Are credentials or authentication involved?
- Do those systems have usage limitations or relevant rate limits?

### Block 5 — Autonomy and control

- Are there points where a human must review or approve before continuing?
- What decisions should the system never make alone? Why?
- What level of autonomy is expected in day-to-day use?
- Are there irreversible actions in the process? _(sending email, deleting data, making a payment)_

### Block 6 — Additional context

- Is there documentation, examples, or reference data the system should know?
- Are there legal, business, or technical constraints to consider?
- Are there similar already-agentized processes that can be reused or referenced?
- Is there anything important I haven't asked that I should know?

---

## Quick Questionnaire (Express Mode)

If the mode is Express, apply only the following matrix in the fewest possible interactions:

1. **Purpose:** What specific problem does this entity solve?
2. **Input:** What does it receive exactly as input to function?
3. **Output:** What does it produce as output and to whom or what is it delivered?
4. **Behavior:** How should it act in the most common cases?
5. **Constraints:** Is there anything it should never do or any important restriction?
