---
description: Model composition strategies for optimizing cost and performance by combining different model tiers (frontier, standard, fast) within agent architectures. Consulted during Step 2 when designing entity blueprints and during Step 3 for model assignment.
tags: [strategies, model-composition, cost-optimization, architecture]
---

## Table of Contents

- [1. Overview](#1-overview)
- [2. Strategy Catalog](#2-strategy-catalog)
  - [2.4 Advisor](#24-advisor-inverted-orchestrator) — Communication structures, Incident learning, Multi-advisor criteria
- [3. Selection Guide](#3-selection-guide)
- [4. Integration with Architecture](#4-integration-with-architecture)

---

## 1. Overview

Three model tiers (platform-agnostic):

| Tier | CC (model / effort) | GA | Codex |
|---|---|---|---|
| **frontier** | `opus` / `max` | `gemini-3.1` | `gpt-5.4` / effort `"high"` |
| **standard** | `sonnet` / `high` | `gemini-3.1` | `gpt-5.4` / effort `"medium"` |
| **fast** | `haiku` / `low` | `gemini-3-flash` | `gpt-5.4-mini` / effort `"low"` |

**CC effort defaults:**

- `opus`: always `max` — frontier reasoning at full depth.
- `sonnet`: `high` by default; `medium` only when the task is evidently routine (no decisions, no generation, mechanical transformation).
- `haiku`: always `low` — fast tier for trivial tasks.

Strategies are **orthogonal to workflow patterns**. A system can use Advisor strategy within a Linear, Parallel, or any other workflow pattern from `kno-workflow-patterns`.

The Architecture Designer recommends a strategy at **system level** in Step 2. The Entity Builder applies it in Step 3 via model assignment.

---

## 2. Strategy Catalog

### 2.1 Single Model

```
Agent A ──┐
Agent B ──┤  (no model specified — user configures at session level)
Agent C ──┘
```

- **Do not** specify `model` in entity frontmatter. Users configure at session/platform level.
- When to use: systems with 1-3 agents, uniform complexity, or user wants full control over model selection.
- Trade-off: simplest to configure, no cost optimization. All agents run at the same tier.

### 2.2 Tiered Assignment (DEFAULT)

```
complex agents  ──→  frontier (opus/max)
medium agents   ──→  standard (sonnet/high)
simple agents   ──→  fast     (haiku/low)
```

- Map intricacy level directly to model tier.
- **Fast tier is reserved** for tasks meeting ALL criteria: no decisions, no creative generation, well-defined I/O (format validation, direct copy, simple binary classification).
- When to use: multi-agent systems with varied complexity. Most common case.
- Trade-off: good cost/quality balance, straightforward to apply from intricacy levels.

### 2.3 Orchestrator-Worker

```
                ┌─→ Worker A (standard/fast)
Orchestrator ───┼─→ Worker B (standard/fast)
 (frontier)     └─→ Worker C (standard/fast)
```

- Frontier model as orchestrator: decomposes tasks, plans, coordinates.
- Standard/fast models execute individual sub-tasks.
- When to use: task decomposition is complex but sub-task execution is formulaic.
- Trade-off: strong planning quality, but orchestrator cost is constant regardless of sub-task simplicity.

### 2.4 Advisor (Inverted Orchestrator)

**Single advisor (default):**

```
Executor (standard) ──→ tools, execution, iteration
       │
       │  escalation signal detected
       ▼
Workflow ──→ Advisor (frontier/max) ──→ solution plan
       │
       ▼
Executor resumes with plan
```

**Multi-advisor (domain-diverse systems):**

```
Executor-A (standard) ──→ tools, execution
       │
       │  escalation (domain: security)
       ▼
Workflow ──→ Advisor-Security (frontier/max) ──→ plan
       │
       ▼
Executor-A resumes

Executor-B (standard) ──→ tools, execution
       │
       │  escalation (domain: data)
       ▼
Workflow ──→ Advisor-Data (frontier/max) ──→ plan
       │
       ▼
Executor-B resumes
```

A standard-tier agent drives execution end-to-end. When it detects an escalation signal, the **workflow** activates a frontier-tier advisor agent (opus/max). The advisor analyzes the problem and returns a solution plan. The executor resumes with that plan.

**Escalation signals** (embedded in executor instructions):

| Signal | Description |
|---|---|
| Repeated failure | Same tool call fails 2+ times consecutively |
| Circular loop | Re-attempts an approach that already failed |
| Declared uncertainty | Executor recognizes it is unsure of the approach |
| Unexpected complexity | Discovers unanticipated dependencies or scope |
| Architectural decision | Faces choice between multiple valid approaches |

**Escalation protocol** (orchestrated by workflow):

1. Executor detects signal, stops, and emits a chat-visible announcement: _"He detectado un problema: [brief description]. Escalando al advisor `age-spe-advisor[-{domain}]` para obtener un plan de resolución."_
2. Executor reports to workflow using the **Escalation Report** format (see Communication structures below).
3. Workflow identifies the target advisor: in single-advisor mode, activates `age-spe-advisor`. In multi-advisor mode, matches the executor's `escalation_domain` to the corresponding `age-spe-advisor-{domain}`.
4. Advisor reads `advisor-incidents/INDEX.md` to check for precedent. If a matching incident exists, reads the specific `ADV-NNN.md` and uses its Learning/Solution as starting point. If no match, analyzes from scratch.
5. Advisor returns a **Resolution Plan** (see Communication structures below): plan, correction, or stop signal.
6. Workflow passes the plan back to the executor and emits a chat-visible summary: _"El advisor ha proporcionado un plan de resolución. Resumen: [summary]. Continuando ejecución."_
7. Executor resumes execution following the plan.
8. Workflow appends the resolved incident to `advisor-incidents/` (new `ADV-NNN.md` file + INDEX.md row). See Incident learning below.

#### Communication structures and incident learning

The exact templates (Escalation Report, Advisor Resolution Plan) and the `advisor-incidents/` directory format (INDEX.md + ADV-NNN.md) live in **`../resources/res-agent-strategies-templates.md`**. Loaded only when an escalation occurs or when the advisor consults incident history. Per `rul-lazy-loading`.

#### Implementation entities

- **Single advisor:** `age-spe-advisor` — frontier tier (opus/max), domain-agnostic. Analyzes problems and returns actionable plans. Never executes tools or produces user-facing output directly.
- **Multi-advisor:** `age-spe-advisor-{domain}` per knowledge domain — each frontier tier (opus/max), scoped to its domain expertise. Domain label is a short kebab-case identifier (e.g., `security`, `data`, `ux`).
- Executor agents: standard tier (sonnet/high), with escalation instructions in their markdown. Each executor has an `escalation_domain` field (multi-advisor) matching its assigned advisor.
- Workflow: orchestrates executor-advisor routing and incident persistence. The executor never invokes an advisor directly.

#### Multi-advisor selection criteria

Use multi-advisor when ALL of the following hold:

- System has 3+ executor agents
- Executors span 2+ distinct knowledge domains
- At least 2 executors share each domain (no single-agent domains)

Otherwise, use a single `age-spe-advisor`. When in doubt, prefer single advisor — it is simpler and sufficient for most systems.

**Benchmark reference (Anthropic):** +2.7pp SWE-bench Multilingual over standard solo, -11.9% cost per task.

- When to use: routine execution with occasional hard decisions. Single advisor: all agents escalate to one advisor. Multi-advisor: each domain cluster escalates to its domain-specific advisor.
- Trade-off: near-frontier quality at fraction of cost, adds latency only on escalation. Multi-advisor adds domain expertise at the cost of more frontier-tier entities.

### 2.5 Evaluator-Gate

```
Generator (fast) ──→ output ──→ Evaluator (standard/frontier)
                                    │
                         ┌──────────┼──────────┐
                      accept     revise      reject
```

- Fast model generates output; stronger model evaluates and decides: accept, reject, or request revision.
- When to use: high-volume generation requiring quality assurance.
- Trade-off: quality control without frontier-tier generation cost. Adds evaluation latency per output.

### Addendum — Advanced Patterns

**Ensemble/Voting** (multiple models generate, consensus selects) and **Speculative Execution** (cheap model pre-generates, frontier validates) exist but are typically overkill for most agentic systems. Consider only for mission-critical outputs where cost is secondary to correctness.

---

## 3. Selection Guide

| System characteristic | Recommended strategy |
|---|---|
| Single agent or command | Single Model |
| Multi-agent, varied complexity | Tiered Assignment |
| Complex planning + routine execution | Orchestrator-Worker |
| Routine execution + occasional hard decisions | Advisor |
| High-volume generation + quality requirements | Evaluator-Gate |

---

## 4. Integration with Architecture

Strategy is recorded in the Blueprint at system level:

```
MODEL STRATEGY
───────────────
Strategy: [name]
Rationale: [why this strategy fits this system]
Tier mapping: [e.g. complex→frontier, medium→standard, simple→fast]
```

If strategy = `advisor` (single), the Blueprint also includes:

```
Advisor: age-spe-advisor (frontier / max)
Escalation signals: [applicable signals from §2.4]
```

If strategy = `advisor` (multi), the Blueprint includes:

```
Advisors:
  - age-spe-advisor-{domain1} (frontier / max) — domain: {domain1}
  - age-spe-advisor-{domain2} (frontier / max) — domain: {domain2}
Escalation signals: [applicable signals from §2.4]
Domain routing:
  - {executor-1, executor-2} → {domain1}
  - {executor-3, executor-4} → {domain2}
```

Passed to Entity Builder via the optional `model_strategy` field in the S2→S3 handoff JSON. When multi-advisor, the `advisor_config` uses the `advisors` array format (see `res-architecture-component-metrics` §6).
