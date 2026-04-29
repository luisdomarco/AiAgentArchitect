---
name: res-agent-strategies-templates
description: Templates and formats consumed by advisor-pattern agents — Escalation Report (executor → advisor), Advisor Resolution Plan (advisor → executor), and the advisor-incidents/ directory format (INDEX.md + ADV-NNN.md). Loaded only when an executor escalates or when the advisor reads incident history. Decoupled from kno-agent-strategies to keep the knowledge file focused on strategies, not output formats.
tags: [advisor, escalation, templates, incident-learning]
---

## When to load this file

- An executor agent escalates to an advisor (steps 1–6 of the Escalation protocol in `kno-agent-strategies` §2.4): the workflow loads §1 (Escalation Report) and §2 (Resolution Plan) templates.
- An advisor consults `advisor-incidents/` for precedent (step 4): the workflow loads §3 (incident-learning format).
- The Optimizer (CP-CLOSE) reads incident patterns: it loads §3 only.

If no escalation occurs in a session, this file is never read. Per `rul-lazy-loading`.

---

## 1. Escalation Report

**Direction**: Executor → Workflow → Advisor

```markdown
## Escalation Report
- **Agent:** age-spe-{executor-name}
- **Signal:** repeated-failure | circular-loop | declared-uncertainty | unexpected-complexity | architectural-decision
- **Context:** [what the agent was trying to do]
- **Attempts:** [what was tried and why it failed]
- **Options seen:** [alternatives the agent identifies but can't choose between]
```

The executor MUST emit a chat-visible announcement before sending this report:
> _"He detectado un problema: [brief description]. Escalando al advisor `age-spe-advisor[-{domain}]` para obtener un plan de resolución."_

---

## 2. Advisor Resolution Plan

**Direction**: Advisor → Workflow → Executor

```markdown
## Advisor Resolution Plan
- **Advisor:** age-spe-advisor[-{domain}]
- **Diagnosis:** [root cause analysis]
- **Plan:**
  1. [step 1]
  2. [step 2]
  3. [step N]
- **Rationale:** [why this approach]
```

After delivering, the workflow emits a chat-visible summary:
> _"El advisor ha proporcionado un plan de resolución. Resumen: [summary]. Continuando ejecución."_

---

## 3. Incident learning — `advisor-incidents/` directory

Every resolved escalation is persisted in `advisor-incidents/` at the export root (external to `.agents/`/`.claude/`, alongside `context-ledger/` and `memory/`). This is **runtime data**, not system definition — it grows with use and can be carried to new deployments or discarded.

### 3.1 Directory structure

```
{system-root}/
  advisor-incidents/
    INDEX.md          ← table index (advisor reads first)
    ADV-001.md        ← individual incident detail
    ADV-002.md
```

### 3.2 INDEX.md format

```markdown
# Advisor Incidents Index

| ID | Date | Executor | Advisor | Signal | Problem | Solution |
|---|---|---|---|---|---|---|
| [ADV-001](ADV-001.md) | 2026-04-11 | age-spe-backend-dev | age-spe-advisor | repeated-failure | API auth token refresh loop | Switch to OAuth2 client_credentials flow |
```

### 3.3 Individual incident file (`ADV-NNN.md`)

```markdown
# ADV-NNN — [short problem title]

- **Date:** YYYY-MM-DD
- **Executor:** age-spe-{name}
- **Advisor:** age-spe-advisor[-{domain}]
- **Signal:** [signal type]

## Problem
[full context of what was happening and what failed]

## Analysis
[advisor's root cause diagnosis]

## Solution
[plan that was applied and its outcome]

## Learning
[concise instruction: what to do if this problem recurs — actionable without re-escalating]

## Prevention
[suggested system change to avoid recurrence, if applicable]
```

### 3.4 Read points

- **Advisor at escalation step 4**: reads INDEX.md first, then the relevant `ADV-NNN.md` if a matching incident exists; uses its Learning/Solution as starting point.
- **Workflow at escalation step 8**: appends new incident (new `ADV-NNN.md` + INDEX.md row).
- **Optimizer at CP-CLOSE**: reads INDEX.md only, looks for repeated patterns, proposes system improvements (per `rul-audit-behavior`).
