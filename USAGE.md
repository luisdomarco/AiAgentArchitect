# USAGE — AiAgentArchitect Lite

How the system works once you've installed it.

## Modes

The orchestrator detects mode from your input or asks at session start.

**Express Mode** — for a single entity (one agent, one skill). Minimal friction. Three to five questions, one or two checkpoints. Good for one-shot small components.

**Architect Mode** — for a complete process or multi-entity system. Full BPM-style interview, an AS-IS diagram, an entity Blueprint, per-entity generation. Standard for anything beyond a single agent.

Mode can escalate from Express → Architect if the orchestrator detects more complexity than initially declared. It cannot reverse.

## The 3-step flow

Every session goes through the same three steps with checkpoints between them.

| Step | Agent | What happens |
|---|---|---|
| Step 0 | `age-spe-input-enricher` | Restructures and enriches your raw input. Surfaces gaps. |
| Step 1 | `age-spe-process-discovery` | Conducts the interview. Returns the S1 handoff (process description, triggers, integrations, constraints). In Architect Mode, also produces an AS-IS Mermaid diagram. |
| Step 2 | `age-spe-architecture-designer` | Designs the entity Blueprint (which agents, skills, rules, knowledge-base entries). In Architect Mode, also produces an architecture diagram. |
| Step 3 | `age-spe-entity-builder` | Generates the entity `.md` files one by one, with a checkpoint per entity. Closes with `process-overview.md` and CP-CLOSE. |

Each checkpoint offers four options: **A** approve and continue, **B** adjust, **C** regenerate, **D** go back. CP-CLOSE finalizes the session.

## Active layers

Lite ships with 4 layers, all enabled by default:

- **`context-ledger`** — Every step's input, reasoning trace (`<sys-eval>`), and output is appended to `context-ledger/<timestamp>-<project>.md`. This is the audit trail of what happened.
- **`memory`** — A small (~1-2 KB) snapshot per session per project, written to `memory/<timestamp>-<project>.md` after every approved checkpoint. Lets you pause and resume across sessions.
- **`help-router`** — `/help` renders a context-aware menu of next actions based on your current checkpoint and active project.
- **`onboarding`** — On first run (no `memory/welcome-shown.md`), `wor-onboarding` runs a brief 5-screen tour and verifies your install.

## Host platforms

The system writes to up to three platforms in parallel:

- **`.agents/`** — Google Antigravity (source of truth).
- **`.claude/`** — Claude Code mirror, generated from `.agents/` via `bash scripts/sync-dual.sh`.
- **`.codex/`** — OpenAI Codex compiled output, generated via `python3 scripts/build-codex.py`.

You pick which platforms to enable during install. `.agents/` is always the source of truth — every other platform is regenerated from it.

## Re-running install

To change your platform or layer selection:

```bash
bash install.sh
```

The wizard re-runs interactively. Pre-existing config files are overwritten (manifest, user config, generated context roots).

## Synchronization

After editing entities by hand in `.agents/`:

```bash
bash scripts/sync-dual.sh --agents-to-claude --prune
python3 scripts/build-codex.py
```

These are idempotent — re-run safely.

## Pause and resume

Close your IDE mid-session. The Memory layer persists a snapshot after every approved checkpoint. When you reopen and start typing, the orchestrator detects the recent snapshot and offers:

```
I found a previous session from [date]. Last checkpoint: CP-S2.
A) Resume · B) New session · C) New project
```

Pick A to continue exactly where you left off.

## What this Lite edition cannot do

- **No QA cycle**: there is no Auditor/Evaluator/Optimizer scoring your output after each checkpoint. The architect produces good output, but you're the only reviewer.
- **No iteration**: once a system is in `exports/`, you can't re-enter it via `/com-iterate-system`. Re-run the architect to make a new one (or edit by hand).
- **No multi-project**: every system is single-project (`embedded`). No `clones-registry.md`, no `/com-clone-system`.
- **No layer management commands**: layers are fixed in Lite. Re-run install to change.
- **No adversarial review, no refinement methods, no compression, no MCP, no telemetry**: see the full edition for any of these.
