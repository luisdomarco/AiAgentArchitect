# AiAgentArchitect Lite

> **Lite edition** — Public preview of AiAgentArchitect for designing and generating agentic systems across Antigravity, Claude Code, and OpenAI Codex.
>
> This file is **auto-generated** by `scripts/build-context-roots.py` from `templates/AGENTS.md.tpl` and the `context_root_inject.content` of every layer enabled in `config/manifest.yaml`. Edit the template, not this file. Re-generate with `python3 scripts/build-context-roots.py` (also runs automatically after `python3 scripts/build-codex.py`).

## Codex usage

This system targets **OpenAI Codex** as one of three host platforms (Antigravity, Claude Code, Codex). Codex receives a compiled output at `.codex/` produced by `python3 scripts/build-codex.py`.

- TOML agents at `.codex/agents/` and `.codex/layers/{layer-id}/agents/`.
- Skills at `.codex/skills/` and `.codex/layers/{layer-id}/skills/`.
- Rules, knowledge-base, resources are direct copies under their canonical subdirectories.
- Hooks are emitted as JSON fragments and merged into `.codex/hooks.json`. Codex does **not** support live hooks the way Claude Code does; layer behaviors that require hooks degrade to manual invocation.
- Configuration: `.codex/config.toml`.

To invoke any agent or command, ask Codex by its `name` (e.g. `wor-agentic-architect`, `/help`).

## Active session behavior

**On every interaction, before responding, check this:**

1. Look for the latest snapshot in `memory/` matching the active project (most recent `*.md` by mtime).
2. If a snapshot exists with `status: in-progress` and `last_checkpoint` set, the user is mid-workflow. Treat any non-slash user message as continuation:
   - Read the snapshot to recover `mode`, `last_checkpoint`, and `target_platforms`.
   - Resume from the corresponding Step / CP per `res-architect-execution-phases`.
   - Do not require the user to invoke `wor-agentic-architect` again. Explicit invocation remains available.
3. If the user message is unrelated to the workflow (meta-question, off-topic), answer directly and ask whether to resume.

Codex has no live hook runtime, so this is your only mechanism for continuity. Respect it.

## Bundled layers

AiAgentArchitect Lite ships with four small layers: `context-ledger`, `memory`, `help-router`, `onboarding`. All enabled by default.

{{ACTIVE_LAYERS}}

## Inventory

For the live entity inventory (agents, skills, rules, knowledge-base, grouped by layer), see the auto-generated section below produced by `scripts/build-codex.py`. If you need to refresh after editing entities:

```
python3 scripts/build-codex.py
```

This rebuilds `.codex/` and re-renders the inventory.

{{INVENTORY}}

## Structure

```
.codex/
├── agents/           ← TOML agent definitions (root)
├── skills/           ← skill subdirectories (SKILL.md)
├── rules/            ← behavioral rules (.md)
├── knowledge-base/   ← reference knowledge (.md)
├── resources/        ← support resources (.md)
├── scripts/          ← executable scripts (.sh/.py)
├── hooks/            ← hook docs (.md) + fragments (.json)
├── hooks.json        ← merged hook config
├── config.toml       ← Codex configuration
└── layers/
    └── {layer-id}/   ← same subdirectories as root, scoped to one layer
```
