---
description: Claude Code hook events catalog, handler types, settings.json structure, Google Antigravity behavioral equivalents, script conventions, and hook-script relationship patterns. Use when designing automation for generated systems.
tags: [hooks, scripts, automation, claude-code, antigravity, events]
---

## Table of Contents

- [1. Overview](#1-overview)
- [2. Claude Code hook events (26)](#2-claude-code-hook-events)
- [3. Hook handler types](#3-hook-handler-types)
- [4. Settings.json hook structure](#4-settingsjson-hook-structure)
- [5. Subagent-level hooks](#5-subagent-level-hooks)
- [6. Google Antigravity behavioral equivalents](#6-google-antigravity-behavioral-equivalents)
- [7. Script conventions](#7-script-conventions)
- [8. Hook + Script relationship patterns](#8-hook--script-relationship-patterns)
- [9. Common use cases](#9-common-use-cases)

> **Detailed reference:** Handler output schemas, environment variables, blocking behavior matrix, and exit codes → [res-hook-events-reference](../resources/res-hook-events-reference.md).

---

## 1. Overview

Hooks and Scripts are automation primitives for generated agentic systems. They work together: a **Hook** is an event-driven trigger that fires when a system event occurs, and a **Script** is an executable procedure that performs the actual action.

**Platform mapping:**

| Concept | Claude Code | Google Antigravity | OpenAI Codex |
| --- | --- | --- | --- |
| Hook | Entry in `settings.json` under `hooks` key | Behavioral `.md` file in `hooks/` that instructs agents to act on triggers | `.json` fragment in `hooks/` merged into `hooks.json` |
| Script | Executable file (`.sh`/`.py`) in `scripts/` | Procedural `.md` document in `scripts/` describing the logic declaratively | Executable file (`.sh`/`.py`) same as CC |

> **Codex hook conventions:** For the full Codex hook event catalog, hooks.json schema, and compilation model, see `res-codex-conventions.md`.

---

## 2. Claude Code hook events

Complete catalog of 26 events with matchers, blocking behavior, and output schemas:

> **Full event catalog:** See `../resources/res-hook-events-reference.md` — authoritative reference for all 26 events, handler output schemas, environment variables, blocking behavior matrix, and exit codes.

---

## 3. Hook handler types

Each hook specifies a handler type that determines what action is taken:

| Type | Description | Use when |
| --- | --- | --- |
| `command` | Executes a shell command or script. Receives event JSON on stdin. Exit code 0 = success, 2 = blocking error. | Running validation scripts, linting, file operations, external tool invocations |
| `prompt` | Single LLM call for evaluation. `$ARGUMENTS` placeholder receives event JSON. | Lightweight checks that need contextual understanding (e.g., "does this write affect QA files?") |
| `agent` | Spawns a subagent with tool access (up to 50 tool turns). `$ARGUMENTS` placeholder. | Complex automated tasks that require reasoning and multiple tool calls |
| `http` | POST to an HTTP endpoint with event payload as JSON body. | Webhooks, external service notifications, CI/CD triggers |

Additional properties (`async`, `timeout`, `if`, `once`, `shell`, `statusMessage`, `headers`, `allowedEnvVars`, `model`), output schemas, and exit code behavior are documented in [res-hook-events-reference](../resources/res-hook-events-reference.md).

---

## 4. Settings.json hook structure

Hooks are configured in `.claude/settings.json` (or `settings.local.json`) under the `hooks` key:

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<tool-name-or-pattern>",
        "hooks": [
          { "type": "command", "command": "./scripts/scp-example.sh" }
        ]
      }
    ]
  }
}
```

**Key rules:** Each event contains an array of matcher groups, each with an array of hooks. Matching hooks execute in parallel. Supports `"async": true` for non-blocking execution. Timeout configurable (default 10 min).

---

## 5. Subagent-level hooks

Claude Code supports hooks in agent frontmatter. These hooks only run while that specific subagent is active:

```yaml
---
name: age-spe-code-reviewer
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/scp-validate-command.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/scp-run-linter.sh"
---
```

**Project-level hooks for subagent lifecycle:**

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "age-spe-data-processor",
        "hooks": [
          { "type": "command", "command": "./scripts/scp-setup-env.sh" }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          { "type": "command", "command": "./scripts/scp-cleanup.sh" }
        ]
      }
    ]
  }
}
```

Subagent-level hooks are cleaned up automatically when the subagent finishes.

---

## 6. Google Antigravity behavioral equivalents

GA does not support native hooks. Equivalent automation uses:

- **Behavioral hook files** (`hooks/hok-*.md`): Describe trigger conditions and expected agent behavior. Agents read at runtime.
- **Procedural script files** (`scripts/scp-*.md`): Step-by-step instruction documents agents follow when trigger is met.

GA hooks use a `Trigger → Action → Enforcement` structure referencing the rules and workflows that enforce them.

---

## 7. Script conventions

### File naming

- Claude Code: `scripts/scp-[name].sh` or `scripts/scp-[name].py`
- Google Antigravity: `scripts/scp-[name].md`

### Language selection

| Language | Use when |
| --- | --- |
| Bash (`.sh`) | File operations, git commands, simple validations, CLI tool invocations |
| Python (`.py`) | Complex logic, JSON/YAML parsing, API calls, data processing |

### Script structure (Claude Code)

Scripts invoked by hooks receive event JSON on stdin and must:
- Exit with code `0` for success
- Exit with code `2` for blocking errors (stderr is shown to user)
- Other exit codes are treated as non-blocking errors

### Script structure (Google Antigravity)

Procedural `.md` documents follow the same template as other entities but describe the procedure in natural language with numbered steps.

---

## 8. Hook + Script relationship patterns

### Pattern 1: Hook triggers Script (most common)

```
Event (PreToolUse:Bash) → Hook (hok-validate-command) → Script (scp-validate-bash.sh)
```

The hook is the trigger configuration; the script is the action. This is the default pattern.

> **Note:** The previous example used `hok-memory-auto-save` (Stop → ski-memory-manager), which was deprecated in April 2026 due to a feedback loop caused by `type: "prompt"` on Stop events. Lifecycle persistence is now orchestrator-driven, not hook-driven.

### Pattern 2: Standalone Hook (no script)

```
Event (PreToolUse:Write) → Hook (hok-validate-naming) → prompt type handler
```

When the action is a simple LLM evaluation, no external script is needed. The hook uses `type: "prompt"` directly.

### Pattern 3: Standalone Script (no hook)

```
User or Command → Script (scp-deploy.sh)
```

Scripts that are invoked manually or by Commands, not triggered by system events.

### Pattern 4: Hook triggers Agent

```
Event (SessionStart:resume) → Hook (hok-restore-context) → agent type handler
```

When the action requires multi-step reasoning and tool use, the hook spawns a subagent.

---

## 9. Common use cases

> Lookup table of 16 common hook/script use cases (event → script → pattern):
> **`../resources/res-hooks-use-cases.md`**
