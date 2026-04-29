---
name: res-hook-events-reference
description: Detailed Claude Code hook reference — handler properties, output schemas, environment variables, and blocking behavior matrix. Use when generating hook entity files or settings.json entries for exported systems.
---

# Hook Events Detailed Reference

Companion to `kno-hooks-and-scripts`. This resource contains the technical detail needed when generating hook configurations.

---

## 1. Handler additional properties

Beyond the base `type`/`command`/`prompt`/`url` fields, handlers support:

| Property | Type | Applies to | Description |
| --- | --- | --- | --- |
| `async` | boolean | `command` | Run in background without blocking (`true` = fire-and-forget) |
| `timeout` | number (s) | all | Max execution time (default: 600 for command, 30 for prompt/http) |
| `if` | string | `command` | Permission rule filter (e.g., `"Bash(git *)"`) — hook only fires if rule matches |
| `once` | boolean | skills | Run hook only once per session (useful for skill-level hooks) |
| `shell` | string | `command` | Shell to use (`"bash"`, `"powershell"`) |
| `statusMessage` | string | `command` | Custom message shown during execution |
| `headers` | object | `http` | HTTP headers; supports env var interpolation (`"$MY_TOKEN"`) |
| `allowedEnvVars` | string[] | `http` | Allowlist of env vars that can be interpolated in headers |
| `model` | string | `prompt` | Model override for prompt evaluation |

---

## 2. Handler output schemas

### PreToolUse output

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow | deny | ask | defer",
    "permissionDecisionReason": "explanation",
    "updatedInput": { "modified": "tool input" },
    "additionalContext": "context injected for Claude"
  }
}
```

- `defer`: only valid in non-interactive mode (`-p` flag)
- `updatedInput`: modifies tool parameters before execution
- Decision precedence: `deny` > `defer` > `ask` > `allow`

### PermissionRequest output

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow | deny",
      "updatedInput": { "modified": "tool input" },
      "updatedPermissions": [],
      "message": "reason for deny",
      "interrupt": false
    }
  }
}
```

- `interrupt: true`: blocks Claude with feedback message
- `updatedPermissions`: can echo back `permission_suggestions` from input

### PostToolUse output

```json
{
  "decision": "block",
  "reason": "explanation",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "context for Claude",
    "updatedMCPToolOutput": "replacement value for MCP tools"
  }
}
```

- Tool already executed — `decision: "block"` provides feedback, not prevention
- `updatedMCPToolOutput`: replaces the original MCP tool response

### Stop / SubagentStop output

```json
{
  "decision": "block",
  "reason": "Continue processing — task not complete",
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "context to continue with"
  }
}
```

### TaskCreated / TaskCompleted / TeammateIdle output

```json
{
  "continue": false,
  "stopReason": "Custom stop reason"
}
```

- Exit code 2: sends stderr as feedback to model (model retries)
- `continue: false`: stops teammate entirely

### Common output fields (all handlers)

| Field | Type | Description |
| --- | --- | --- |
| `continue` | boolean | If `false`, stops Claude entirely (default: `true`) |
| `stopReason` | string | Message shown when `continue: false` |
| `suppressOutput` | boolean | Hides stdout from verbose mode |
| `systemMessage` | string | Warning shown to user |

---

## 3. Environment variables

Variables available to hook handlers:

| Variable | Available in | Description |
| --- | --- | --- |
| `CLAUDE_PROJECT_DIR` | All hooks | Project root directory path |
| `CLAUDE_ENV_FILE` | `SessionStart`, `CwdChanged`, `FileChanged` | Write `export VAR=value` lines to persist env vars for subsequent Bash commands |
| `CLAUDE_PLUGIN_ROOT` | Plugin hooks | Plugin installation directory |
| `CLAUDE_PLUGIN_DATA` | Plugin hooks | Plugin persistent data directory |
| `CLAUDE_CODE_REMOTE` | All hooks | Set to `"true"` when running in remote web environment |

---

## 4. Blocking behavior matrix

Which events can block execution and how:

| Event | Can Block | Mechanism |
| --- | --- | --- |
| `SessionStart` | No | — |
| `SessionEnd` | No | — |
| `InstructionsLoaded` | No | — |
| `UserPromptSubmit` | **Yes** | Exit code 2 or `decision: "block"` + `reason` |
| `PreToolUse` | **Yes** | `permissionDecision: "deny"` or exit code 2 |
| `PermissionRequest` | **Yes** | `decision.behavior: "deny"` or `interrupt: true` |
| `PermissionDenied` | No | Can allow `retry: true` |
| `PostToolUse` | No | Feedback via `decision: "block"` (tool already ran) |
| `PostToolUseFailure` | No | — |
| `Stop` | **Yes** | Exit code 2 or `decision: "block"` (forces continuation) |
| `StopFailure` | No | Output ignored |
| `Notification` | No | — |
| `SubagentStart` | No | — |
| `SubagentStop` | **Yes** | Same as `Stop` |
| `TaskCreated` | **Yes** | Exit code 2 (feedback) or `continue: false` (stops teammate) |
| `TaskCompleted` | **Yes** | Exit code 2 (feedback) or `continue: false` (stops teammate) |
| `TeammateIdle` | **Yes** | Exit code 2 (continues) or `continue: false` (stops) |
| `PreCompact` | No | — |
| `PostCompact` | No | — |
| `WorktreeCreate` | **Yes** | Non-zero exit fails creation |
| `WorktreeRemove` | No | — |
| `FileChanged` | No | — |
| `CwdChanged` | No | — |
| `ConfigChange` | **Yes** | Exit code 2 or `decision: "block"` (except `policy_settings`) |
| `Elicitation` | **Yes** | Exit code 2 denies; or `action: "decline"/"cancel"` |
| `ElicitationResult` | **Yes** | Exit code 2 blocks response; or override `action`/`content` |

---

## 5. Common input fields (all events)

Every hook receives these fields on stdin:

| Field | Description |
| --- | --- |
| `session_id` | Session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `hook_event_name` | Name of the firing event |
| `permission_mode` | Current mode: `default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions` |
| `agent_id` | (Subagent only) Unique subagent identifier |
| `agent_type` | (Subagent/--agent only) Agent type name |

---

## 6. Exit code behavior

| Code | Meaning | Behavior |
| --- | --- | --- |
| 0 | Success | Parse JSON output; hidden unless verbose mode |
| 2 | Blocking error | Event-specific block behavior; stderr shown to user/model |
| Other | Non-blocking error | stderr shown in verbose mode; execution continues |

---

## 7. Execution rules

- **Parallel execution:** All matching hooks for an event run in parallel
- **Deduplication:** Command hooks by command string; HTTP hooks by URL
- **JSON output cap:** 10,000 characters; excess saved to file
- **Matcher precedence:** PreToolUse > PermissionRequest when both match same tool
