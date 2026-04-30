# AiAgentArchitect — Lite

> **Build production-ready multi-agent systems in three structured steps.**

Designing agentic systems is hard: vague requirements, no standard structure, and every implementation looks different. AiAgentArchitect solves this with a guided pipeline — from raw idea to ready-to-deploy `.md` files — using a strict entity-based architecture.

**AiAgentArchitect** is a guided meta-system that interviews you, designs the architecture, and generates ready-to-deploy agent files — for **Google Antigravity**, **Claude Code**, and **OpenAI Codex** — from a single source of truth.

[rookiespath.com](https://rookiespath.com/)

---

## How it works

Three structured steps. Zero blank-page paralysis.

### Step 1 — Discovery

A specialist agent interviews you using BPM/BPA techniques. It asks the right questions, reverse-engineers vague descriptions, detects hidden complexity, and produces an AS-IS diagram plus a validated process definition.

> *You: "I want to automate customer support."*
> *AiAgentArchitect: "What triggers the process? What does a resolved ticket look like? What happens when Zendesk doesn't respond?"*

### Step 2 — Architecture

An architecture agent turns your process definition into a Blueprint: the right entity types, correct responsibilities, assigned complexity levels, and a To-Be diagram — all reviewed and validated before a single file is written.

### Step 3 — Implementation

An entity builder materializes the Blueprint into correctly formatted `.md` files (and `.toml` for Codex), placed in the output directory and ready to deploy. No copy-pasting. No reformatting. No guessing what structure each platform expects.

---

## What you get

A complete agentic system in `exports/{your-system-name}/`, ready for three platforms simultaneously:

```text
exports/{system-name}/
├── .agents/                        # Google Antigravity (source of truth)
│   ├── workflows/                  # Orchestrators + specialist agents
│   ├── skills/                     # Reusable capability packages
│   ├── rules/                      # Guardrails and compliance rules
│   ├── knowledge-base/             # Static documentation consulted on demand
│   ├── resources/                  # Templates and support logic
│   ├── scripts/                    # Procedural scripts
│   └── hooks/                      # Behavioral hook definitions
├── .claude/                        # Claude Code (auto-synced mirror)
│   ├── commands/                   # Workflows converted to commands
│   ├── agents/                     # Specialist agents
│   ├── skills/, rules/, ...        # Direct copies
│   ├── scripts/                    # Executable scripts (.sh/.py)
│   └── settings.json               # Permissions + hooks configuration
├── .codex/                         # OpenAI Codex (compiled from .agents/)
│   ├── agents/                     # TOML agent definitions
│   ├── skills/, rules/, ...        # Direct copies
│   ├── hooks/                      # Hook docs + JSON fragments
│   ├── hooks.json                  # Merged hook configuration
│   └── config.toml                 # Codex configuration
├── CLAUDE.md                       # Root-level context for Claude Code
├── AGENTS.md                       # Root-level context for OpenAI Codex
├── VERSION                         # Semantic version (e.g. 0.1.0)
├── system-overview.md              # Entity inventory + reading strategy
├── process-overview.md             # Full system documentation
├── changelog/                      # Version history entries
├── context-ledger/                 # Session records (resumable)
└── memory/                         # Lightweight session snapshots
```

### Three platforms. One source.

| Platform | Directory | Sync model |
|----------|-----------|------------|
| **Google Antigravity** | `.agents/` | Source of truth — always edit here |
| **Claude Code** | `.claude/` | Bidirectional sync via `sync-dual.sh` |
| **OpenAI Codex** | `.codex/` | One-way compilation via `build-codex.py` |

Switch platforms later. Nothing in the source changes.

---

## Lite vs Full

AiAgentArchitect ships in two editions. **Lite** is the open public preview. **Full** adds production capabilities on top of the same core.

| Layer | Lite | Full | What it adds |
|---|:---:|:---:|---|
| `context-ledger` | ✅ | ✅ | Append-only session trace; clean state transfer between agents |
| `memory` | ✅ | ✅ | Cross-session snapshots — resume any project where you left off |
| `help-router` | ✅ | ✅ | Context-aware `/help` menus based on current phase and project state |
| `onboarding` | ✅ | ✅ | Guided 5-screen first-run tour |
| `qa` | — | ✅ | Auditor + Evaluator + Optimizer cycle after every checkpoint |
| `adversarial-review` | — | ✅ | Cynic + Boundary-Walker reviewers that challenge your design |
| `compression` | — | ✅ | Lossless compression of long docs into token-efficient distillates |
| `cross-project-aggregator` | — | ✅ | Macro analysis across multiple generated systems |
| `elicitation-methods` | — | ✅ | Refinement techniques: Socratic, pre-mortem, red-team, 5-whys, inversion, … |
| `mcp` | — | ✅ | Bridge to Model Context Protocol servers |
| `methods-registry` | — | ✅ | Registry of reusable techniques discoverable by keyword |
| `state-tracking` | — | ✅ | Frontmatter on every artifact for filesystem-verified resume |
| `telemetry` | — | ✅ | Local aggregation of token usage, cache hit rate, latency |
| `templates` | — | ✅ | Versioned Markdown templates for consistent human-facing outputs |

The four Lite layers are enough to run the complete Discovery → Architecture → Implementation flow end-to-end across all three host platforms.

---

## Two operating modes

| Mode | When to use | Output |
|------|-------------|--------|
| **Express** | One agent or skill, fast | Single file or small directory |
| **Architect** | Full multi-agent system with Blueprint and diagrams | Multi-entity system with Memory and Context Ledger embedded |

> A third mode — **Iterate** (PATCH / REFACTOR / EVOLVE on existing systems) — is available in the Full edition.

---

## Entity architecture

Every generated system is built from the same 10 entity types, with the same naming conventions, across all three platforms.

The prefix system (`wor-`, `age-spe-`, `ski-`, `com-`, …) is a deliberate UX decision — not just a naming convention:

- **Invocability** — in Claude Code and Antigravity, prefixes map directly to slash commands. `/wor-` triggers a workflow, `/com-` triggers a command. You don't need to remember what something is called — the prefix tells you how to invoke it.
- **Self-documentation** — a file named `age-spe-email-classifier.md` tells you its type (specialist agent), its platform behavior, and its purpose before you open it.
- **Platform abstraction** — the same prefix vocabulary works on all three platforms. We then arrange the files into the directory structure each one expects (`.claude/commands/` for `wor-`/`com-`, `.claude/agents/` for `age-`, `.codex/agents/` as TOML, `.agents/workflows/` flat as the source of truth, …). You author once; we render the layout each platform expects. One source, three renderings, no rewrite.

| Type | Prefix | Role |
|------|--------|------|
| Workflow | `wor-` | Orchestrates steps and agents |
| Agent Specialist | `age-spe-` | Executes a specific domain of responsibility |
| Agent Supervisor | `age-sup-` | Reviews or validates output from other agents |
| Skill | `ski-` | Reusable capability package (tool, API, protocol) |
| Command | `com-` | Saved procedure for frequent tasks |
| Rule | `rul-` | Constraint that guarantees quality and consistency |
| Knowledge-base | `kno-` | Static context, loaded on demand |
| Resources | `res-` | Support documents extending other entities |
| Script | `scp-` | Executable automated procedure |
| Hook | `hok-` | Event-driven trigger for automated actions |

→ Full entity catalog — definitions, format specs, activation rules, character limits: [**kno-entity-types.md**](.agents/knowledge-base/kno-entity-types.md)

---

## Get started in 1 minute

Four paths — pick the one that fits.

**Requirements:** Git · Node.js 20+ · Python 3.10+ (the bootstrap script offers to install missing pieces).

### 1. Clone + wizard

```bash
git clone https://github.com/luisdomarco/AiAgentArchitect.git
cd AiAgentArchitect
bash install.sh
```

The wizard detects which host platforms you already have (`~/.claude/`, `~/.codex/`) and pre-selects them.

### 2. Bash bootstrap (one-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/luisdomarco/AiAgentArchitect/main/install.sh | bash -s -- --yes
```

Auto-installs Node/Python deps if missing, then runs the wizard with safe defaults.

### 3. npx

```bash
npx aiagent-architect-lite install
```

### 4. CI / non-interactive

```bash
bash install.sh --yes --layers=memory,context-ledger,help-router,onboarding --platforms=antigravity,claude-code --lang=en
```

### Bonus: let Claude Code do it

Open Claude Code, paste a 6-line prompt referencing [INSTALL-WITH-CLAUDE.md](INSTALL-WITH-CLAUDE.md), and Claude walks the whole sequence end to end with checkpoints at every decision.

→ Full walkthrough with prerequisites, the wizard, and post-install verification: [**QUICKSTART.md**](QUICKSTART.md)

After install:

```
/wor-onboarding         ← 5-screen guided tour (auto-fires first time)
/wor-agentic-architect  ← start designing a system
/help                   ← context-aware options at any moment
```

---

## Documentation

| Document | What's in it |
|----------|-------------|
| [QUICKSTART.md](QUICKSTART.md) | Install to first generated system in 5 minutes |
| [USAGE.md](USAGE.md) | Full usage guide, modes, the 3-step flow, layers |
| [INSTALL-WITH-CLAUDE.md](INSTALL-WITH-CLAUDE.md) | Hand the install over to Claude Code — one prompt, end to end |
| [TRIPLE-SYSTEM.md](TRIPLE-SYSTEM.md) | `.agents/` ↔ `.claude/` ↔ `.codex/` sync model |
| [system-overview.md](system-overview.md) | Entity inventory shipped with this Lite edition |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to report bugs and suggest changes |
| [CHANGELOG.md](CHANGELOG.md) | Version history |

---

lite v0.1.0 · 4 layers · triple-platform · wizard installer · [CHANGELOG.md](CHANGELOG.md)

---

MIT · [Issues](https://github.com/luisdomarco/AiAgentArchitect/issues) · [CONTRIBUTING.md](CONTRIBUTING.md)
