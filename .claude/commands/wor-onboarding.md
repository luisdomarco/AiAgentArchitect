---
name: wor-onboarding
description: First-run guided tour of AiAgentArchitect — a brief 5-screen overview of what the system is, the three operating modes, the layer system, the lifecycle, and the active layers in this install. Then verifies the install and prompts the user for their first action. Auto-invoked on session start when memory/welcome-shown.md is absent. Invocable manually anytime as /wor-onboarding to refresh.
---

# Workflow: Onboarding (root)

## Purpose

Give a new user just enough context to act. Not a tutorial, not documentation — a compass. The user should leave this workflow knowing: (a) what this system does, (b) how to invoke the main flow, (c) what's installed and active on their machine, (d) what the recommended first step is.

## Activation

- **Auto-invocation**: at session start, before any other workflow, if `memory/welcome-shown.md` does not exist.
- **Manual invocation**: `/wor-onboarding` at any time, even after the welcome marker exists. Useful as a refresher or to inspect what layers are active.

## Hard Constraints

- Never modify any file other than `memory/welcome-shown.md` and only in Step 7.
- Never advance past a screen without the user's input — this is interactive, not a monologue.
- Never repeat the entire tour after the marker exists; re-invocation gives a condensed summary instead.
- Always read `config/manifest.yaml` and the active layers before Step 5; never invent state.

## Soft Constraints

- Keep each screen under 8 lines of prose. The user is here to explore, not to read.
- When listing layers, sort alphabetically and show only `enabled: true` ones.
- If something is missing or misconfigured, say so plainly and offer the fix command.

## Workflow Sequence

### Step 0 — Detect mode

Check `memory/welcome-shown.md`:
- If absent → **Full tour mode**. Continue with Step 1.
- If present → **Refresher mode**. Skip to a condensed version: print active layers, current verification status, and the first-step prompt. Skip Step 7 (do not re-write the marker, do not duplicate it).

### Step 1 — Screen 1/5: What this is

Render to the user (verbatim or stylized):

```
AiAgentArchitect — a meta-system for designing and generating agentic systems.

You describe a process or capability you want to agentize. The architect
interviews you, designs the entity blueprint, and produces deployable .md
files for Antigravity, Claude Code, and OpenAI Codex.

Output: a directory of agents, skills, rules, and knowledge-bases that are
immediately runnable in any of the three host platforms.
```

End with: *"Reply 'enter' to continue, or 'skip' to jump to verification."* Wait for input.

### Step 2 — Screen 2/5: Two modes

```
Two modes of operation:

  1) Express      — single entity (an agent, a skill). Fast.
  2) Architect    — full multi-agent system with a blueprint. Standard.

The architect picks the right mode based on your input, but you can
override at the first checkpoint.
```

Wait for input.

### Step 3 — Screen 3/5: The layer system

```
AiAgentArchitect Lite ships with four small layers:

  - context-ledger — append-only trace of each step
  - memory         — cross-session snapshots so you can pause and resume
  - help-router    — /help shows context-aware options
  - onboarding     — this short tour

Layers self-describe via .agents/layers/{layer-id}/MANIFEST.yaml.
```

Wait for input.

### Step 4 — Screen 4/5: Lifecycle

```
A typical session:

  S0  Input enrichment
  S1  Process discovery (interview)
  S2  Architecture design (blueprint)
  S3  Entity implementation (per-entity)
  CLOSE  Packaging

Each step ends in a checkpoint with 4 options (A approve / B adjust /
C regenerate / D go back). You stay in control.
```

Wait for input.

### Step 5 — Screen 5/5: Active layers on this install

Read `config/manifest.yaml`. List `layers_root` entries with `enabled: true`, sorted alphabetically. For each, render one line:

```
  ✓ context-ledger v1.0.0   — Append-only session trace
  ✓ help-router    v0.1.0   — Context-aware /help menus
  ✓ memory         v1.0.0   — Cross-session snapshots
  ✓ onboarding     v0.1.0   — This tour
```

If a layer has `enabled: false`, do not list it. If `manifest.yaml` is missing, render the warning:

```
  ! No manifest.yaml found. Run: bash install.sh
```

Then wait for input.

### Step 6 — Verification

Run a fast self-check (read-only — never modify anything):

1. `config/manifest.yaml` parses as valid YAML and has at least `memory`, `context-ledger` enabled. If not, warn.
2. `.agents/layers/{layer-id}/MANIFEST.yaml` exists for every layer marked enabled in the manifest. If a layer is enabled but its source MANIFEST is missing, warn that the manifest is out of sync.
3. `repository/entities-registry.csv` exists and is non-empty. If not, suggest:

   ```
   Build the registry: python3 .agents/layers/help-router/scripts/build-registry.py
   ```

4. (If `claude-code` is in `manifest.platforms`) `~/.claude/` exists. If not, warn that the platform is configured but the IDE cannot be detected on this machine.
5. (Same check for `codex` ↔ `~/.codex/`.)

Render the result as a checklist:

```
Verification:
  ✓ manifest.yaml valid
  ✓ all enabled layers have source MANIFEST
  ! entities-registry.csv missing → run python3 .agents/layers/help-router/scripts/build-registry.py
  ✓ claude-code IDE detected
  - codex platform configured but ~/.codex/ not found
```

If anything failed, ask: *"Fix now? (Y/n/skip)"*. On Y, run the suggested commands. On n, continue. On skip, continue silently.

### Step 7 — First step prompt

Render:

```
What would you like to do first?

  A) Start a real system: /wor-agentic-architect
  B) Read the docs: open QUICKSTART.md
  C) Explore the README: open README.md
```

Wait for input. Then:
- A → Hand control to `wor-agentic-architect`.
- B → Print: *"Opening QUICKSTART.md in your editor (or check the project root for QUICKSTART.md)."*
- C → Print: *"Opening README.md in your editor."*

### Step 8 — Mark as shown

Only in **Full tour mode** (Step 0 said the marker was absent):

1. Ensure `memory/` exists. Create if not.
2. Write `memory/welcome-shown.md` with this content:

   ```yaml
   ---
   schema_version: 1.0
   first_run_completed_at: <ISO 8601 timestamp>
   aiagent_architect_version: <read from config/manifest.yaml>
   ---

   # Welcome marker

   This file suppresses auto-invocation of wor-onboarding. Delete it to see
   the tour again next session, or run /wor-onboarding manually anytime.
   ```

3. Acknowledge: *"Welcome marker saved to memory/welcome-shown.md. Tour will not auto-run again."*

In **Refresher mode**, do not write or modify the marker.

## Output

No file outputs other than `memory/welcome-shown.md` (Full tour mode only). The user-facing rendered screens are the actual deliverable.

## Error handling

| Situation | Behavior |
| --- | --- |
| `config/manifest.yaml` missing | Skip Step 5. Step 6 emits the install instruction `bash install.sh` and aborts the rest of the tour. |
| `memory/` not writable | Step 8 logs a warning but does not abort; the user will see the tour again on next session. |
| User answers nothing for >5 minutes | Treat as "skip"; advance to the next screen. (Implementations that don't time out can ignore this.) |
| User explicitly cancels | Print *"Tour cancelled. Run /wor-onboarding anytime."* and exit without writing the marker. |
