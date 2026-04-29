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

## Active Layers

### context-ledger

- **Context Ledger active**. Trace at `context-ledger/YYYY-MM-DD-HH-MM-{project}.md`.
- Each step records input + reasoning trace + output + metadata.
- Handoff JSON schemas in `kno-handoff-schemas`.

### memory

- **Memory Layer active**. Snapshots at `memory/YYYY-MM-DD-HH-MM-{project}.md`.
- The orchestrator invokes `ski-memory-manager save` after each checkpoint and `load-last` at session start.

### help-router

- **Help Router active** (degradation: invocation by name). Codex does not support custom slash commands; invoke `/ski-help-router` directly to see context-aware menus.

### onboarding

- **Onboarding active**. On first invocation, run `/wor-onboarding` for a brief tour and next-step prompt. Codex does not auto-detect missing markers; the user must invoke explicitly.


## Inventory

For the live entity inventory (agents, skills, rules, knowledge-base, grouped by layer), see the auto-generated section below produced by `scripts/build-codex.py`. If you need to refresh after editing entities:

```
python3 scripts/build-codex.py
```

This rebuilds `.codex/` and re-renders the inventory.

# AiAgentArchitect

## Agents (root)

| Agent | Description | Invoke with |
|---|---|---|
| `age-spe-architecture-designer` | Analyzes a discovered process definition and designs the optimal entity architecture by selecting entity types from the decision tree, mapping existing skills, and generating the blueprint with a Mermaid diagram. Use at Step 2 after the S1 handoff JSON is validated and ready for architectural translation. | Invoked as subagent by workflows |
| `age-spe-entity-builder` | Generates individual instruction files for each entity in the architectural blueprint, following exact format specifications per entity type and intricacy level, validating each with the user before continuing. Use at Step 3 after the S2 handoff JSON is approved to materialize the designed architecture as deployable files. | Invoked as subagent by workflows |
| `age-spe-input-enricher` | Receives the user's raw or partial input, analyzes it for completeness, structures it into a validated format, and proposes enrichments to fill detected gaps. Use at Step 0 before Discovery begins, whenever the initial user input is ambiguous, incomplete, or in free-form natural language. | Invoked as subagent by workflows |
| `age-spe-process-discovery` | Interviews the user to fully discover and document a process or entity to be agentized, applying BPM/BPA techniques, structured questioning, and inverse engineering. Use at Step 1 to transform enriched input into a validated process definition with handoff JSON and AS-IS diagram (Architect mode). | Invoked as subagent by workflows |
| `wor-agentic-architect` | Orchestrates the complete design and generation of agentic systems through 3 steps (Discovery, Architecture, Implementation) in Express or Architect mode. Use when a user wants to create a new agentic system from scratch, design a multi-agent workflow, or generate entity files for Google Antigravity, Claude Code, or OpenAI Codex platforms. | Ask Codex to invoke `wor-agentic-architect` |

## Skills (root)

| Skill | Location | Description |
|---|---|---|
| `ski-diagram-generator` | `.codex/skills/ski-diagram-generator/SKILL.md` | Generates Mermaid diagrams for process flows, AS-IS states, and entity architectures. Use whenever a visual representation of a process or architecture is needed for validation or documentation, such as at Step 1 (AS-IS) and Step 2 (architecture blueprint). |
| `ski-entity-file-builder` | `.codex/skills/ski-entity-file-builder/SKILL.md` | Generates complete, correctly formatted instruction files for all 10 entity types (Workflow, Agent, Skill, Command, Rule, Knowledge-base, Resources, Script, Hook) per assigned intricacy level. Use in Step 3 to materialize each entity from the architectural blueprint as a deployable file. |
| `ski-entity-selector` | `.codex/skills/ski-entity-selector/SKILL.md` | Applies the entity decision tree to determine the correct entity type for each identified responsibility in a process. Use during architecture design (Step 2) to systematically select from all 10 entity types and justify each choice against the decision criteria. |
| `ski-layer-embed` | `.codex/skills/ski-layer-embed/SKILL.md` | Embeds, unembeds or updates a modular layer into a destination system (root or subsystem) by reading its MANIFEST.yaml, copying entities to the correct platform directories, injecting context-root sections (CLAUDE.md/AGENTS.md), wiring hooks (settings.json), updating the destination's manifest, and resolving dependencies. Use when activating, deactivating or upgrading any layer (qa, memory, context-ledger, mcp, help-router, onboarding, etc.) on AiAgentArchitect itself or on any generated subsystem. |
| `ski-output-claude-code` | `.codex/skills/ski-output-claude-code/SKILL.md` | Converts a generated Google Antigravity entity into its Claude Code equivalent, applying directory mapping, path transformations, CC-specific frontmatter injection, and settings.json hook entry generation. Use after generating the GA version of each entity in Step 3. |
| `ski-output-codex` | `.codex/skills/ski-output-codex/SKILL.md` | Converts a generated Google Antigravity entity into its OpenAI Codex equivalent, producing TOML agents for behavioral entities, direct copies for procedural entities, and hook JSON fragments. Use after generating the GA version of each entity in Step 3. |
| `ski-platform-exporter` | `.codex/skills/ski-platform-exporter/SKILL.md` | Converts a Google Antigravity export to other platforms (Claude Code, ChatGPT, Claude.ai, Dust, Gemini) by applying the correct mapping and generating the corresponding file structure. For Claude Code, also generates .claude/settings.json with hooks for QA automation. Use post-packaging or on-demand when additional platform exports are requested. |
| `ski-process-interviewer` | `.codex/skills/ski-process-interviewer/SKILL.md` | Structured interview technique for process discovery using BPM/BPA methods, inverse engineering on vague descriptions, and organized question blocks. Use when age-spe-process-discovery needs to elicit complete, unambiguous process information from the user through a structured dialogue. |

## Rules (root)

Rules are loaded from `.codex/rules/`:
- `rul-checkpoint-behavior` — 
- `rul-interview-standards` — 
- `rul-lazy-loading` — Establishes the lazy-loading principle for AiAgentArchitect — every entity reads only what it needs at the moment it needs it. The session boot path stays minimal; per-step reads are gated by an explicit condition (active layer, target_platforms, current step). Violations balloon token consumption and slow session startup. Auditors flag any boot-time read above the allowlist or any preventive load of knowledge-base/resources files.
- `rul-naming-conventions` — 
- `rul-scope-boundaries` — 
- `rul-strict-compliance` — 

## Knowledge Base (root)

- `kno-agent-strategies` — Model composition strategies for optimizing cost and performance by combining different model tiers (frontier, standard, fast) within agent architectures. Consulted during Step 2 when designing entity blueprints and during Step 3 for model assignment. (`.codex/knowledge-base/kno-agent-strategies.md`)
- `kno-entity-selection` — Decision tree, comparative table, and criteria for selecting the correct entity for any responsibility or capability to model. (`.codex/knowledge-base/kno-entity-selection.md`)
- `kno-entity-types` — "Definition, purpose, activation, responsibilities, and format specifications of the 9 entity types: Workflow, Agent (Specialist / Supervisor), Skill, Command, Rule, Knowledge-base, Resources, Script, and Hook." (`.codex/knowledge-base/kno-entity-types.md`)
- `kno-hooks-and-scripts` — Claude Code hook events catalog, handler types, settings.json structure, Google Antigravity behavioral equivalents, script conventions, and hook-script relationship patterns. Use when designing automation for generated systems. (`.codex/knowledge-base/kno-hooks-and-scripts.md`)
- `kno-system-architecture` — Persistence architecture for agentic entities. Defines the root folder structure, path conventions, and dual-platform Antigravity and Claude Code architecture. Codex available on demand via ski-platform-exporter. (`.codex/knowledge-base/kno-system-architecture.md`)
- `kno-workflow-patterns` — Workflow coordination patterns (linear, checkpoints, decisions, integrations, parallel) and the Context Ledger mechanism for multi-agent state transfer. Read when designing workflows with 2+ agents in sequence that require inter-step context management. (`.codex/knowledge-base/kno-workflow-patterns.md`)

## Layers

Modular capabilities embedded under `.codex/layers/{layer-id}/`. Each layer mirrors the root structure (agents/, skills/, rules/, ...).

### Layer: context-ledger

Provides: 1 skill(s), 1 knowledge-base(s)

Skills:
- `ski-context-ledger` — `.codex/layers/context-ledger/skills/ski-context-ledger/SKILL.md`

Knowledge Base:
- `kno-handoff-schemas` — `.codex/layers/context-ledger/knowledge-base/kno-handoff-schemas.md`

### Layer: help-router

Provides: 1 skill(s)

Skills:
- `ski-help-router` — `.codex/layers/help-router/skills/ski-help-router/SKILL.md`

### Layer: memory

Provides: 1 skill(s)

Skills:
- `ski-memory-manager` — `.codex/layers/memory/skills/ski-memory-manager/SKILL.md`

### Layer: onboarding

Provides: 1 agent(s)

Agents:
- `wor-onboarding` — First-run guided tour of AiAgentArchitect — a brief 5-screen overview of what the system is, the three operating modes, the layer system, the lifecycle, and the active layers in this install. Then verifies the install and prompts the user for their first action. Auto-invoked on session start when memory/welcome-shown.md is absent. Invocable manually anytime as /wor-onboarding to refresh.

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
