# AiAgentArchitect

> Build production-ready multi-agent systems in three structured steps.

Designing agentic systems is hard: vague requirements, no standard structure, and every implementation looks different. AiAgentArchitect solves this with a guided pipeline — from raw idea to ready-to-deploy `.md` files — using a strict entity-based architecture and built-in QA scoring.

---

## How It Works

AiAgentArchitect operates through a 3-step pipeline:

**Step 1 — Process Discovery**
A specialist agent interviews you using BPM/BPA techniques. It reverse-engineers vague requests, detects hidden complexity, and produces an AS-IS diagram and a structured handoff to Step 2.

**Step 2 — Architecture Design**
An architecture agent translates the discovered process into a Blueprint: the right entities, correct responsibilities, assigned intricacy levels, and a To-Be diagram.

**Step 3 — Entity Implementation**
An entity builder materializes the Blueprint into correctly formatted `.md` files, placed in the output directory and ready to use.

---

## What You Get

Every generated system follows this structure:

```text
exports/{system-name}/google-antigravity/
└── .agents/
    ├── workflows/          # Orchestrators + specialist agents
    ├── skills/             # Reusable capability packages
    ├── rules/              # Guardrails and compliance rules
    ├── knowledge-base/     # Static documentation consulted on demand
    ├── resources/          # Templates and support logic
    └── process-overview.md # Full system documentation
```

**Example: `assistant-documentation-generator`** — generated entirely by AiAgentArchitect:

- 5 specialist agents (content analyzer, doc builder, auditor, evaluator, optimizer)
- 4 skills, 4 rules, 3 knowledge-base files, 1 resource
- Built-in QA Layer (Auditor + Evaluator + Optimizer)
- Exported to both Google Antigravity and Claude Code

---

## Entity Architecture

Every system is built from 6 atomic entity types:

| Entity           | Prefix     | Role                                               |
| :--------------- | :--------- | :------------------------------------------------- |
| Workflow         | `wor-`     | Orchestrator — coordinates agents and steps        |
| Agent Specialist | `age-spe-` | Executes a specific domain of responsibility       |
| Agent Supervisor | `age-sup-` | Reviews or validates output from other agents      |
| Skill            | `ski-`     | Reusable capability package (tool, API, protocol)  |
| Rule             | `rul-`     | Constraint that guarantees quality and consistency |
| Knowledge-base   | `kno-`     | Static context consulted on demand                 |

---

## Getting Started

### Prerequisites

- [Google Antigravity](https://antigravity.dev) — reads `.agents/` structure
- [Claude Code](https://claude.ai/code) — reads `.claude/` structure (auto-synced)
- `fswatch` (optional, for real-time sync): `brew install fswatch`

### Invocation

**Google Antigravity** — type the slash command in the chat:

```
/wor-agentic-architect
```

**Claude Code** — same slash command from the command palette:

```
/wor-agentic-architect
```

Both platforms run the same workflow. Antigravity reads `.agents/`, Claude Code reads `.claude/`, synced automatically.

### Tip: skip the interview

Pre-fill a template before starting to skip most questions:

```
exports/template/%Master - Docs/template-input-architect.md   ← full systems
exports/template/%Master - Docs/template-input-express.md     ← single entities
```

**→ Full usage guide, stage walkthrough, and checkpoint reference: [USAGE.md](USAGE.md)**

---

## Project Structure

AiAgentArchitect uses a **dual-system architecture**: every entity lives in both `.agents/` (Google Antigravity format) and `.claude/` (Claude Code format), kept in sync automatically via a git pre-commit hook.

```text
.agents/          ← Source of truth (Google Antigravity)
.claude/          ← Auto-synced mirror (Claude Code)
exports/          ← Output directory for generated systems
  └── template/  ← Starter template for new systems
scripts/          ← sync-dual.sh and utilities
```

See [DUAL-SYSTEM.md](DUAL-SYSTEM.md) for full sync documentation.

---

## Built-in QA System

Every session runs a three-role quality cycle automatically — no setup required.

- **Auditor** — verifies rule compliance after each approved checkpoint. Reads rules from disk at audit time. Never modifies anything.
- **Evaluator** — scores each phase on four dimensions: Completeness, Quality, Compliance, and Efficiency. Produces a weighted scorecard at process close.
- **Optimizer** — reads the complete audit and score history, detects recurring patterns, and generates prioritized improvement proposals. Never applies them automatically.

QA output is appended to a single `qa-report.md` at the root of the generated system. The cycle is non-blocking: it never stops execution, only accumulates evidence.

**→ Full QA specification: [QA-SYSTEM.md](QA-SYSTEM.md)**

---

## Documentation

- [Entity Fundamentals](.agents/knowledge-base/kno-fundamentals-entities.md)
- [System Architecture](.agents/knowledge-base/kno-system-architecture.md)
- [Handoff Schemas](.agents/knowledge-base/kno-handoff-schemas.md)
- [Dual System Sync](DUAL-SYSTEM.md)
- [QA System](QA-SYSTEM.md)

---

## Feedback & Suggestions

Have an idea or found something to improve? Open an [issue](https://github.com/luisdomarco/AiAgentArchitect/issues).
