---
name: res-entity-templates-claude-code
description: Claude Code platform-specific entity templates, frontmatter fields, settings.json hook configuration, and CLAUDE.md generation rules. Use when generating entity files for the .claude/ export structure.
tags: [template, claude-code, platform, formatting]
---

# Claude Code Entity Templates

Platform-specific additions and transformations for Claude Code (`.claude/`). These supplement the core GA templates in `res-entity-templates-behavioral.md` (behavioral entities) and `res-entity-templates-support.md` (support entities).

---

## 1. Agent Frontmatter (CC-specific fields)

Claude Code agents receive additional frontmatter fields beyond the base GA template:

```yaml
model: sonnet | opus | haiku                     # Cost/capability control
effort: max | high | medium | low                 # Reasoning depth — max only on opus/sonnet
tools: [ToolA, ToolB]                            # Optional: whitelist of allowed tools
disallowedTools: [ToolC, ToolD]                  # Optional: blacklist of prohibited tools
permissionMode: default | acceptEdits | plan     # Optional: agent autonomy level
```

These fields are added to the agent frontmatter when generating the `.claude/agents/` version. The `.agents/` (GA) version uses `model: gemini-3-flash | gemini-3.1` and does not include `tools`, `disallowedTools`, or `permissionMode`.

### Model mapping (GA → CC)

Default mapping applied during initial generation by `ski-output-claude-code`:

| GA Model | CC Model | CC Effort Default |
|---|---|---|
| `gemini-3-flash` | `haiku` | `low` |
| `gemini-3.1` | `sonnet` | `high` |

**Effort defaults:** `opus` always gets `max`, `sonnet` gets `high` (or `medium` for evidently routine tasks), `haiku` always gets `low`.

After all entities are generated, §7.5 of the entity builder presents a **Model & Effort Selection** step where the user can override any agent's model and effort based on the agent's role and the selected model strategy (see `kno-agent-strategies`). The user may also skip this step to keep the defaults above.

---

## 2. Skill Frontmatter (CC-specific fields)

```yaml
allowed-tools: ToolA ToolB ToolC     # Optional: tools this skill is allowed to use
user-invocable: true | false         # Optional: false = only Claude can invoke it
```

These fields are defined in the source entity to document intended capabilities. For GA, they are informational only — actual enforcement happens only in Claude Code.

---

## 3. Script Format (CC)

Claude Code scripts are **executable files** (`.sh` or `.py`) in `.claude/scripts/`:

- File extension: `.sh` for bash, `.py` for Python
- Must have execute permissions
- Receive event JSON on stdin when invoked by hooks
- Exit codes: `0` = success, `2` = blocking error, other = non-blocking error

GA scripts are `.md` procedural documents describing the same logic declaratively.

---

## 4. Hook — settings.json Entry

For each Hook entity, Claude Code requires a corresponding entry in `.claude/settings.json` under the `hooks` key:

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<tool-name-or-pattern>",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/scripts/scp-[name].sh",
            "timeout": 600
          }
        ]
      }
    ]
  }
}
```

Handler types: `command`, `prompt`, `agent`, `http`.

When generating a Hook entity for CC, produce BOTH the `.md` documentation file AND the `settings.json` entry. Append new hook entries to the existing `hooks` object, grouped by event type.

---

## 5. Directory Mapping (GA → CC)

| Entity | GA path | CC path |
|---|---|---|
| Workflow | `workflows/wor-*.md` | `commands/wor-*.md` |
| Agent | `workflows/age-*.md` | `agents/age-*.md` |
| Command | `workflows/com-*.md` | `commands/com-*.md` |
| Skill | `skills/ski-*/SKILL.md` | `skills/ski-*/SKILL.md` |
| Rule | `rules/rul-*.md` | `rules/rul-*.md` |
| Knowledge-base | `knowledge-base/kno-*.md` | `knowledge-base/kno-*.md` |
| Resources | `resources/res-*.md` | `resources/res-*.md` |
| Script | `scripts/scp-*.md` | `scripts/scp-*.sh` or `.py` |
| Hook | `hooks/hok-*.md` | `hooks/hok-*.md` + `settings.json` |

---

## 6. Path Transformations

References to agents change between platforms:

| Reference | In `.agents/` | In `.claude/` |
|---|---|---|
| Agent from workflow | `./age-spe-*.md` | `../agents/age-spe-*.md` |
| Supervisor from workflow | `./age-sup-*.md` | `../agents/age-sup-*.md` |

All other paths (skills, rules, KB, resources, scripts, hooks) remain identical.

---

## 7. CLAUDE.md Template

Generated at the export root (`exports/{name}/CLAUDE.md`):

```markdown
# [System Name]

[System description — from process-overview.md]

## Active Rules

- **`rul-[name]`** — path: `.claude/rules/rul-[name].md`

## Knowledge Base

- **`kno-[name]`** — path: `.claude/knowledge-base/kno-[name].md`

## Structure

\`\`\`
.claude/
├── commands/         ← workflows and commands
├── agents/           ← specialist and supervisor agents
├── skills/           ← skill subdirectories
├── rules/            ← behavioral rules
├── knowledge-base/   ← reference knowledge
├── resources/        ← support resources
├── scripts/          ← executable scripts
├── hooks/            ← hook documentation
└── settings.json     ← permissions + hooks
\`\`\`
```

---

## 8. CC-exclusive Files (not synced)

| File | Purpose |
|---|---|
| `.claude/settings.json` | Permissions + hook automation |
| `.claude/settings.local.json` | Local permission overrides |
| `.claude/plans/` | Implementation plans |
