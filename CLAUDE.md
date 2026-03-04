# AiAgentArchitect

System for designing and generating complete agentic systems.

## How it Works

Run the main workflow to start a design session:

**From Google Antigravity:**

```
wor-agentic-architect
```

**From Claude Code:**

```
/wor-agentic-architect
```

## Project Structure

This project maintains **two implementations of the same agentic system**, each optimized for its platform:

### 1. Google Antigravity (`.agents/`)

Original structure for Google Antigravity:

- `.agents/`
  - `workflows/` — Workflows (`wor-*`) and Agents (`age-spe-*`)
  - `skills/` — Skills with subdirectory structure (`ski-*/SKILL.md`)
  - `rules/` — Rules (`rul-*`)
  - `knowledge-base/` — Knowledge base (`kno-*`)
  - `resources/` — Reference resources (`res-*`)

### 2. Claude Code (`.claude/`)

Structure adapted for Claude Code:

- `.claude/`
  - `commands/` — Main workflows (`wor-*`)
  - `agents/` — Specialized agents (`age-spe-*`)
  - `skills/` — Skills with flat structure (`ski-*.md`)
  - `rules/` — Rules (`rul-*`)
  - `knowledge-base/` — Knowledge base (`kno-*`)
  - `resources/` — Reference resources (`res-*`)
  - `settings.local.json` — Permission configuration

**Key differences between `.agents/` and `.claude/`:**

- Workflows and Agents separated: `workflows/` → `commands/` (workflows) + `agents/` (agents)
- Flattened skills: `skills/ski-*/SKILL.md` → `skills/ski-*.md`
- References automatically adjusted per context

### 3. Generated Systems (`exports/`)

Output directory for generated systems:

- `exports/`
  - `template/` — base to copy and rename
  - `{system-name}/google-antigravity/` — default export
  - `{system-name}/{platform}/` — optional exports

## Active Rules

The following rules apply in both implementations (`.agents/` and `.claude/`):

- **`rul-naming-conventions`** — Prefixes and naming conventions for entities
- **`rul-checkpoint-behavior`** — Checkpoint format and structured validations
- **`rul-interview-standards`** — Interview protocol (one question at a time, no assumptions)
- **`rul-audit-behavior`** — QA Layer: audit cycle activation and responsibilities

## Synchronization

Both implementations must remain in sync. Changes in one structure must be replicated in the other, adjusting paths accordingly:

- `.agents/workflows/` ↔ `.claude/commands/` + `.claude/agents/`
- `.agents/skills/ski-*/SKILL.md` ↔ `.claude/skills/ski-*.md`
