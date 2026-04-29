# Install with Claude Code

A guided install path for users who prefer running everything from inside Claude Code.

## Prerequisites

- Claude Code installed (`~/.claude/` exists).
- Node 20+, Python 3.10+, Git available on `PATH`.

## Steps

### 1. Clone

In your terminal:

```bash
git clone <this-repo> AiAgentArchitect
cd AiAgentArchitect
```

### 2. Open in Claude Code

```
code AiAgentArchitect/
```

(Or open the folder via the Claude Code IDE manually.)

### 3. Run install from inside Claude Code

In the Claude Code chat, ask:

```
Run bash install.sh --yes
```

This bootstraps the dependencies, runs the wizard with safe defaults, and writes:

- `config/manifest.yaml` — what's enabled
- `config/config.user.toml` — your runtime preferences
- `.claude/` — generated mirror (you'll see new files appear)
- `.codex/` — only if you enabled Codex
- `CLAUDE.md`, `AGENTS.md` — context roots from templates

### 4. Reload Claude Code

Reload the IDE so it picks up the freshly generated `CLAUDE.md` and the entities in `.claude/`.

### 5. First-run tour

```
/wor-onboarding
```

Five screens explain what's installed and where to go next.

### 6. Build your first system

```
/wor-agentic-architect
```

Pick a small process. The architect interviews you, designs the blueprint, and generates entity files. Output lands in `exports/<your-system>/`.

## Customizing the install

To re-run with custom layer selection:

```bash
bash install.sh
```

Drop the `--yes` flag and the wizard becomes interactive — you can deselect bundled layers or change platforms.

## Troubleshooting

- **`/wor-agentic-architect` not found**: The IDE didn't pick up `.claude/`. Reload the workspace or check that `.claude/commands/wor-agentic-architect.md` exists.
- **Wizard fails with "no layers discovered"**: You ran the wizard from outside the repo. `cd` into the repo root and try again.
- **Sync says "no .agents/ found"**: Same — must run from repo root.

## What you get when done

```
AiAgentArchitect/
├── .agents/                ← source of truth
├── .claude/                ← mirror (active in your IDE)
├── .codex/                 ← compiled Codex output (if enabled)
├── config/
│   ├── manifest.yaml
│   ├── config.base.toml
│   └── config.user.toml
├── exports/                ← where your generated systems land
├── memory/                 ← session snapshots
└── context-ledger/         ← session traces
```

You're set. Run `/help` anytime to see context-aware options.
