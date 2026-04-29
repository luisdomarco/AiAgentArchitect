---
name: res-hooks-use-cases
description: Common hook and script use case patterns for generated agentic systems. Maps use cases to hook events, scripts, and handler patterns. Read when designing hook or script entities to find the appropriate event and pattern for a given automation need.
tags: [hooks, scripts, use-cases, automation, patterns]
---

## Purpose

This resource provides a lookup table of common hook and script use cases. Consult it when designing automation for a generated system to find the standard approach for a given need.

**When to read:** When creating Hook (`hok-*`) or Script (`scp-*`) entities, or when the architecture designer is determining which hook event matches a given automation requirement.

---

## Common Use Cases

| Use Case | Hook Event | Script | Pattern |
| --- | --- | --- | --- |
| QA trigger after entity file creation | `PostToolUse:Write` | `scp-qa-validate.sh` | Hook → Script |
| Naming validation before write | `PreToolUse:Write` | `scp-validate-naming.sh` | Hook → Script |
| Session context restoration | `SessionStart:resume` | `scp-restore-context.sh` | Hook → Script |
| Session cleanup and persistence | `SessionEnd` | `scp-session-cleanup.sh` | Hook → Script |
| Linting on file change | `FileChanged:*.md` | `scp-lint-entities.sh` | Hook → Script |
| Environment setup on startup | `SessionStart:startup` | `scp-setup-env.sh` | Hook → Script |
| Prevent writes to protected files | `PreToolUse:Write` | _(none)_ | Standalone Hook (prompt) |
| Cleanup after subagent finishes | `SubagentStop` | `scp-cleanup.sh` | Hook → Script |
| Block dangerous prompts | `UserPromptSubmit` | `scp-prompt-filter.sh` | Hook → Script |
| Auto-approve safe tool calls | `PermissionRequest:Bash` | _(none)_ | Standalone Hook (command) |
| Track API errors | `StopFailure` | `scp-log-api-errors.sh` | Hook → Script |
| Enforce task completion criteria | `TaskCompleted` | `scp-verify-tests.sh` | Hook → Script |
| Save state before compaction | `PreCompact` | `scp-save-context.sh` | Hook → Script |
| Auto-answer MCP server prompts | `Elicitation` | _(none)_ | Standalone Hook (command) |
| Audit rule/instruction loading | `InstructionsLoaded` | `scp-audit-log.sh` | Hook → Script |
| Deployment automation | _(manual)_ | `scp-deploy.sh` | Standalone Script |

---

## Handler Pattern Reference

| Pattern | When to use |
| --- | --- |
| **Hook → Script** | The hook fires on an event and delegates execution to an external script. Most common pattern. |
| **Standalone Hook (prompt)** | The action is a simple LLM evaluation with no external side effects. Use `type: "prompt"` handler. |
| **Standalone Hook (command)** | A simple shell one-liner suffices. Use `type: "command"` handler inline. |
| **Standalone Script** | Invoked manually by the user or a Command entity, not triggered by a system event. |
| **Hook → Agent** | The action requires multi-step reasoning and tool use. Use `type: "agent"` handler. |

For handler configuration details (exit codes, async, timeout, output schemas), see `res-hook-events-reference.md`.
