---
description: Workflow coordination patterns (linear, checkpoints, decisions, integrations, parallel) and the Context Ledger mechanism for multi-agent state transfer. Read when designing workflows with 2+ agents in sequence that require inter-step context management.
tags: [workflow, patterns, context-ledger, orchestration, multi-agent]
---

## Table of Contents

- [1. Workflow patterns](#1-workflow-patterns)
- [2. Context Management — Context Ledger](#2-context-management--context-ledger)

---

## 1. Workflow patterns

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

## 2. Context Management — Context Ledger

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
