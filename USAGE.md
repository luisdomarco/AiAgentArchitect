# Using AiAgentArchitect

This guide covers how to invoke the workflow, choose the right mode, and understand each stage of the pipeline.

---

## Invocation

### Google Antigravity

The `.agents/` folder is picked up automatically when you open this project in Google Antigravity. To start the workflow, type the following slash command in the chat:

```
/wor-agentic-architect
```

This loads `.agents/workflows/wor-agentic-architect.md` and begins the session.

### Claude Code

The `.claude/` folder is read automatically by Claude Code. The slash command is identical:

```
/wor-agentic-architect
```

This loads `.claude/commands/wor-agentic-architect.md` — a synced copy of the same workflow adapted to Claude Code's path conventions.

> Both platforms run the same logic. The only difference is the file structure they read from.

---

## Pre-filling a Template (optional)

To skip the initial questions and jump straight to architecture, fill in one of the templates in:

```
exports/template/%Master - Docs/
├── template-input-architect.md   ← for full multi-agent systems
└── template-input-express.md     ← for single entities
```

The workflow detects these files at session start and uses them as initial context.

---

## Modes

Choose your mode at the first prompt. The workflow asks:

> _"What do you want to create? A) Complete process → Architect Mode · B) Concrete entity → Express Mode"_

| Mode          | When to use                                   | Produces                                                     |
| :------------ | :-------------------------------------------- | :----------------------------------------------------------- |
| **Express**   | A single entity with a clear responsibility   | One entity file, minimal friction                            |
| **Architect** | A full multi-agent system with multiple steps | Full Blueprint + AS-IS and To-Be diagrams + all entity files |

**Escalation:** If Express reveals more complexity than expected, the system recommends switching to Architect. The reverse (downgrade) is not allowed.

---

## Pipeline Stages

### Session Start

The workflow detects your mode, sets the output path (`exports/{system-name}/google-antigravity/`), and initializes the Context Ledger for inter-agent state management.

---

### Step 0 — Input Structuring (CP-S0)

**Agent:** `age-spe-input-enricher`

Takes your raw description and structures it into a formal draft: title, objective, inputs, outputs, constraints, and edge cases. Inferred fields are marked `[PROPOSED]`.

**You review and approve (CP-S0) before anything is designed.**

---

### Step 1 — Process Discovery (CP-S1)

**Agent:** `age-spe-process-discovery`

Conducts a structured interview using BPM/BPA techniques. Asks one question at a time. Detects hidden complexity and gaps you haven't considered.

In **Architect Mode**, produces an AS-IS diagram in Mermaid before closing.

Delivers a structured handoff JSON to Step 2.

**You review and approve (CP-S1). QA runs automatically after approval (Auditor + Evaluator).**

---

### Step 2 — Architecture Design (CP-S2)

**Agent:** `age-spe-architecture-designer`

Translates the discovered process into a Blueprint: entity types, responsibilities, relationships, intricacy levels. Reuses existing skills when possible.

In **Architect Mode**, generates a To-Be architecture diagram.

**You review the Blueprint and approve (CP-S2). QA runs automatically (Auditor + Evaluator).**

---

### Step 3 — Entity Implementation (CP-S3-N)

**Agent:** `age-spe-entity-builder`

Generates entity files one by one in the order defined by the Blueprint, placing them in `exports/{system-name}/google-antigravity/.agents/`. Each file respects format specs and character limits.

**You approve each entity before the next one is generated (CP-S3-N). QA audits each file on approval.**

After all entities: generates `process-overview.md` (the system's documentation). You approve this (CP-CLOSE).

---

### Closing — Global QA + Packaging

After CP-CLOSE:

1. **Evaluator** calculates the weighted global score (S1×25% + S2×35% + S3×40%) and writes the final scorecard to `qa-report.md`.
2. **Optimizer** reads the full `qa-report.md`, detects patterns, and adds prioritized improvement proposals.
3. **Packaging checkpoint** — choose output formats:
   - A) Finalize (Google Antigravity only)
   - B/C/D) Export to Claude Code, ChatGPT, Claude.ai, Dust, or Gemini
4. **QA Embed question** — optionally inject the QA Layer (Auditor + Evaluator + Optimizer) into the generated system itself.

---

## Checkpoint Reference

| Checkpoint | Triggered after     | What happens on approval (A)                  |
| :--------- | :------------------ | :-------------------------------------------- |
| CP-S0      | Input enrichment    | QA optional (`/skip-qa S0`) → Step 1          |
| CP-S1      | Discovery interview | QA (Auditor + Evaluator) → Step 2             |
| CP-S2      | Blueprint design    | QA (Auditor + Evaluator) → Step 3             |
| CP-S3-N    | Each entity file    | QA (Auditor) → next entity                    |
| CP-CLOSE   | process-overview.md | Global QA (Evaluator + Optimizer) → packaging |

Every checkpoint has four options: **A) Approve · B) Adjust · C) Regenerate · D) Go back**

---

## QA Commands

These can be issued at any point during the session:

```
/re-audit {entity-name}   →  Re-audit a specific entity file
/re-audit S2              →  Re-audit an entire phase
/re-audit system          →  Re-audit the complete system
/skip-qa S1               →  Skip QA for a specific phase
```

QA results accumulate in `qa-report.md` (append-only) in the generated system's root. Historical scores across sessions are recorded in `qa-meta-report.md`.

---

## Output Location

```
exports/{system-name}/google-antigravity/
└── .agents/
    ├── workflows/
    ├── skills/
    ├── rules/
    ├── knowledge-base/
    ├── resources/
    └── process-overview.md
```

Additional platform exports (if requested) are placed in:

```
exports/{system-name}/{platform}/
```
