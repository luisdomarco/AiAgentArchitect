# QUICKSTART — AiAgentArchitect Lite

A five-minute walkthrough.

## 1. Install (2 minutes)

```bash
git clone <this-repo> AiAgentArchitect
cd AiAgentArchitect
bash install.sh --yes
```

The wizard accepts the defaults: the four bundled layers (memory, context-ledger, help-router, onboarding) are enabled, and any host platform detected on your machine (`~/.claude/`, `~/.codex/`) is pre-selected.

After install you have:

- `config/manifest.yaml` — what's enabled
- `config/config.user.toml` — your runtime preferences
- `.claude/`, `.codex/` — generated mirrors of `.agents/` (only for platforms you enabled)

## 2. Open in your IDE (30 seconds)

Open the directory in Claude Code (or Antigravity, or load Codex). The IDE picks up `CLAUDE.md` / `AGENTS.md` automatically and you can start typing slash commands.

## 3. First-run tour (1 minute)

```
/wor-onboarding
```

Five short screens explain the system, the operating modes, the layers, the lifecycle, and what's enabled on your install. Press `enter` between screens.

## 4. Your first system (2 minutes)

Pick something small. A Slack bot. An email triager. A daily report generator.

```
/wor-agentic-architect
```

The architect asks 4–6 questions in Express mode (single entity) or runs a fuller interview in Architect mode (multi-entity). After each major step (Discovery, Architecture, Implementation) you hit a checkpoint:

```
A) ✅ Approve and continue
B) ✏️ Adjust this output
C) 🔄 Regenerate
D) ↩️ Go back
```

You stay in control. Approve only when you're happy.

## 5. Output

When you finish (CP-CLOSE), look at:

```
exports/<your-system>/
├── .agents/              ← drop into Antigravity
├── .claude/              ← drop into Claude Code
├── .codex/               ← drop into Codex
├── process-overview.md
└── changelog/2026-04-29-initial-system.md
```

Drop the platform directory into the IDE of your choice. The agents are immediately invocable.

## What to try next

- **`/help`** — context-aware menu of what you can do right now (depends on which checkpoint you're at).
- **Pause and resume** — close your IDE mid-session. Open it again later. Memory will offer to resume.
- **Export to additional platforms** — at CP-CLOSE, the architect offers exports to ChatGPT, Claude.ai, Dust, Gemini.

## Common issues

- **Wizard says "no layers discovered"** — you're running it from the wrong directory. `cd` into the AiAgentArchitect repo root and try again.
- **`/wor-onboarding` doesn't auto-run** — that's by design after the first run. Touch / delete `memory/welcome-shown.md` to see it again, or run `/wor-onboarding` manually.
- **`.codex/` is empty** — only generated if you selected `codex` during install. Re-run `bash install.sh` and pick it.
