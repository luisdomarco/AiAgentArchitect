# AiAgentArchitect — Lite

> **Public preview** of AiAgentArchitect: a meta-system that interviews you about a process or capability and produces deployable agent files for **Google Antigravity**, **Claude Code**, and **OpenAI Codex** in one run.

You describe a workflow you want to agentize. The architect interviews you, designs the entity blueprint, and generates `.md` (and `.toml` for Codex) files that drop into the host platform of your choice — instantly runnable.

This is the **Lite** edition. It ships with the core 3-step workflow (Discovery → Architecture → Implementation) plus four small support layers (memory, context-ledger, help-router, onboarding). The full edition adds QA auditing, multi-project iteration, adversarial review, MCP, telemetry, and other power-user capabilities.

---

## What you get

When you finish a session, you have a directory like:

```
exports/<your-system>/
├── .agents/                ← Antigravity entities (.md)
├── .claude/                ← Claude Code mirror
├── .codex/                 ← Codex compiled output (TOML agents + hooks.json)
├── process-overview.md     ← What was built and why
└── changelog/              ← First-version entry
```

You drop that directory into your IDE / workspace and the agents work immediately.

## Requirements

- Git
- Node.js 20+
- Python 3.10+

The bootstrap script will check these and offer to install missing pieces.

## Install

```bash
git clone <this-repo> AiAgentArchitect
cd AiAgentArchitect
bash install.sh
```

The wizard will detect which host platforms you already have (`~/.claude/`, `~/.codex/`) and pre-select them. Accept the defaults to get up and running fastest.

For a non-interactive install:

```bash
bash install.sh --yes
```

## First run

In Claude Code:

```
/wor-onboarding
```

(The first session auto-invokes onboarding once.)

Then to design your first system:

```
/wor-agentic-architect
```

Or, in Antigravity, simply ask: `wor-agentic-architect`.

For a context-aware menu of options at any time: `/help`.

## Try it: a 3-minute demo

```
You: /wor-agentic-architect
[architect] What do you want to create? A) Complete process · B) Single entity?
You: A — a Slack bot that summarizes a channel's daily activity at 5 PM
[architect] System name? Suggested: slack-daily-summary
You: looks good
[architect goes through Step 0 → Step 1 → Step 2 → Step 3, asking questions
and showing you the blueprint and entity drafts at each checkpoint]
```

After CP-CLOSE you have `exports/slack-daily-summary/` with everything wired up.

## What's in the Lite edition

- `wor-agentic-architect` — the orchestrator
- 4 specialist agents (`age-spe-input-enricher`, `process-discovery`, `architecture-designer`, `entity-builder`)
- 8 reusable skills
- 6 rules (interview, naming, checkpoints, lazy-loading, scope, strict-compliance)
- 6 knowledge-base files
- 4 layers (memory, context-ledger, help-router, onboarding)
- 3-platform output (Antigravity, Claude Code, Codex)

## What's not in Lite

The Lite edition deliberately omits:

- **QA layer** — Auditor / Evaluator / Optimizer cycle that scores every checkpoint and proposes improvements.
- **Multi-project iteration** — `/com-iterate-system`, `/com-publish-system`, `/com-clone-system`, `/com-export-system`, `/com-abandon-project`.
- **Layer management commands** — `/com-layer-list`, `/com-layer-enable`, etc. (Lite ships with a fixed set.)
- **Adversarial review** — cynic + boundary-walker agents that challenge your design.
- **Refinement methods** — Socratic, pre-mortem, red-team, first-principles, 5-whys, inversion, devils-advocate.
- **Compression**, **MCP bridge**, **Telemetry**, **Methods Registry**, **State-tracking**, **Templates layer**, **Cross-project aggregator**.

If you find yourself wanting these, the full edition is available upstream.

## Documentation

- [QUICKSTART.md](QUICKSTART.md) — five-minute walkthrough.
- [USAGE.md](USAGE.md) — modes, the 3-step flow, layers, host platforms.
- [INSTALL-WITH-CLAUDE.md](INSTALL-WITH-CLAUDE.md) — guided install via Claude Code.
- [TRIPLE-SYSTEM.md](TRIPLE-SYSTEM.md) — how `.agents/` ↔ `.claude/` ↔ `.codex/` work together.
- [system-overview.md](system-overview.md) — entity inventory.

## License

See [LICENSE](LICENSE).
