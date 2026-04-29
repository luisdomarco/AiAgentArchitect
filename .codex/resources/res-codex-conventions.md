---
name: res-codex-conventions
description: OpenAI Codex platform reference covering hook event catalog, hooks.json schema, skill discovery paths, subagent invocation patterns, and compilation model. Use when designing automation or understanding Codex platform constraints for generated systems.
tags: [codex, openai, hooks, events, conventions, reference]
---

# OpenAI Codex Platform Conventions

Reference document for Codex-specific platform behavior. For entity formatting and templates, see `res-entity-templates-codex.md`.

---

## 1. Compilation Model

`.codex/` is a **compiled output** generated from `.agents/` (source of truth). It is never edited directly.

```
.agents/ (source of truth)
    │
    ├──→ .claude/  (bidirectional sync — existing)
    │
    └──→ .codex/   (one-way compilation — build-codex.py)
```

**Build command:** `python3 scripts/build-codex.py`

**Rebuild triggers:**
- Manual: run build script directly
- Pre-commit hook: optional, non-blocking (`|| true`)
- Watch mode: triggered by `.agents/` file changes

---

## 2. Codex Hook Events

Events that have direct equivalents between Claude Code and Codex:

| Event | Matcher | Can Block | CC Equivalent |
|---|---|---|---|
| `SessionStart` | `startup`, `resume` | No | `SessionStart` |
| `PreToolUse` | Tool names (`Bash`, etc.) | Yes (exit 2) | `PreToolUse` |
| `PostToolUse` | Tool names | No | `PostToolUse` |
| `UserPromptSubmit` | _(none)_ | Yes | `UserPromptSubmit` |
| `Stop` | _(none)_ | Yes | `Stop` |

### Events without Codex equivalent

These CC events do not have direct Codex equivalents. When generating hooks for a system that uses these events, the hook `.md` documentation is still generated but the `.json` fragment is omitted and a note is added:

| CC Event | Status in Codex | Recommendation |
|---|---|---|
| `SessionEnd` | Not available | Use `Stop` as approximate alternative |
| `InstructionsLoaded` | Not available | Document as observability-only in AGENTS.md |
| `PermissionRequest` | Not available | Use rules (Starlark) for permission control |
| `PermissionDenied` | Not available | No equivalent |
| `PostToolUseFailure` | Not available | Handle in `PostToolUse` with error check |
| `StopFailure` | Not available | No equivalent |
| `Notification` | Not available | No equivalent |
| `SubagentStart` | Not available | No equivalent |
| `SubagentStop` | Not available | No equivalent |
| `TaskCreated` | Not available | No equivalent |
| `TaskCompleted` | Not available | No equivalent |
| `TeammateIdle` | Not available | No equivalent |
| `PreCompact` | Not available | No equivalent |
| `PostCompact` | Not available | No equivalent |
| `WorktreeCreate` | Not available | No equivalent |
| `WorktreeRemove` | Not available | No equivalent |
| `FileChanged` | Not available | No equivalent |
| `CwdChanged` | Not available | No equivalent |
| `ConfigChange` | Not available | No equivalent |
| `Elicitation` | Not available | No equivalent |
| `ElicitationResult` | Not available | No equivalent |

---

## 3. hooks.json Schema

Location: `.codex/hooks.json` (project-scoped) or `~/.codex/hooks.json` (user-scoped).

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<regex-pattern>",
        "hooks": [
          {
            "type": "command | prompt | agent | http",
            "command": "<script-path>",
            "statusMessage": "<optional UI message>",
            "timeout": 600
          }
        ]
      }
    ]
  }
}
```

**Rules:**
- Multiple matcher groups per event; each with an array of hooks
- Matching hooks execute **in parallel** (one cannot prevent others)
- `PreToolUse` can block tool execution: exit code `2` = deny, stdout JSON `{"decision": "deny"}` = deny
- `UserPromptSubmit` can block or modify: stdout JSON `{"text": "modified prompt"}`
- Default timeout: 600 seconds

---

## 4. Skill Discovery

Codex discovers skills from these paths (priority order):

1. `.agents/skills/` (local — also used by GA)
2. `$REPO_ROOT/.agents/skills/` (repo root)
3. `$HOME/.agents/skills/` (user global)
4. `/etc/codex/skills/` (system global)

Since `.codex/skills/` is **not** a default discovery path, generated systems should either:
- Reference skills explicitly in `AGENTS.md`
- Configure skill paths in `config.toml` if supported
- Use the shared `.agents/skills/` path (available in dual-export systems)

For standalone Codex exports (without `.agents/`), skills in `.codex/skills/` must be referenced via AGENTS.md or agent TOML `[[skills.config]]`.

---

## 5. Subagent Invocation

Custom agents (TOML) are invoked as subagents. Key constraints:

| Parameter | Default | Description |
|---|---|---|
| `max_threads` | 6 | Max concurrent subagents |
| `max_depth` | 1 | No nested subagent spawning |
| `job_max_runtime_seconds` | 1800 | 30-minute timeout per subagent |

**Invocation:** Users ask Codex to invoke an agent by name. Within `developer_instructions`, workflows reference other agents by name for orchestration.

**Built-in agents:** `default`, `worker`, `explorer`. Custom agents (from `.codex/agents/`) take precedence over built-ins with the same name.

---

## 6. Rules (Starlark)

Codex supports execution policy rules via Starlark `.rules` files in `~/.codex/rules/`:

```starlark
prefix_rule(
  pattern=["command", "subcommand"],
  decision="allow|prompt|forbidden",
  justification="explanation"
)
```

These are **execution policy** rules (what commands can run), distinct from the behavioral `.md` rules used by the agentic system. Both coexist: `.md` rules guide agent behavior, `.rules` files control command execution permissions.

---

## 7. AGENTS.md Conventions

| Feature | Details |
|---|---|
| **Global scope** | `~/.codex/AGENTS.md` |
| **Project scope** | `{repo-root}/AGENTS.md` |
| **Nested scope** | `{directory}/AGENTS.md` (closer = higher precedence) |
| **Size limit** | 32 KiB combined |
| **Loading** | Rebuilds on every run (no caching) |
| **Override** | `AGENTS.override.md` takes precedence |

AGENTS.md is the Codex equivalent of CLAUDE.md — it provides project-level context, conventions, and references to rules and knowledge bases.
