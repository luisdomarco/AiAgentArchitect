---
name: ski-output-claude-code
description: Converts a generated Google Antigravity entity into its Claude Code equivalent, applying directory mapping, path transformations, CC-specific frontmatter injection, and settings.json hook entry generation. Use after generating the GA version of each entity in Step 3.
---

# Claude Code Platform Output

Takes a generated GA entity (`.agents/`) and produces the Claude Code equivalent (`.claude/`), applying all platform-specific transformations.

## Input / Output

**Input:**

- `entity_type`: workflow | agent | command | skill | rule | knowledge-base | resources | script | hook
- `entity_name`: the entity filename (e.g. `age-spe-email-classifier.md`)
- `source_content`: the full content of the generated GA entity
- `export_path`: base export path (e.g. `exports/{name}`)
- `model_ga`: the GA model value from frontmatter (e.g. `gemini-3.1`)
- `settings_json`: current state of the system's `settings.json` (for hook appending)

**Output:**

- Entity file written to the correct `.claude/` path
- Updated `settings.json` if entity is a Hook
- Summary of what was generated

---

## Procedure

### 1. Determine destination path

Read the directory mapping from `../resources/res-entity-templates-claude-code.md` §5:

| Entity type | GA source path | CC destination path |
|---|---|---|
| Workflow (`wor-*`) | `.agents/workflows/` | `.claude/commands/` |
| Agent (`age-*`) | `.agents/workflows/` | `.claude/agents/` |
| Command (`com-*`) | `.agents/workflows/` | `.claude/commands/` |
| Skill (`ski-*`) | `.agents/skills/ski-*/` | `.claude/skills/ski-*/` |
| Rule (`rul-*`) | `.agents/rules/` | `.claude/rules/` |
| Knowledge-base (`kno-*`) | `.agents/knowledge-base/` | `.claude/knowledge-base/` |
| Resources (`res-*`) | `.agents/resources/` | `.claude/resources/` |
| Script (`scp-*`) | `.agents/scripts/` | `.claude/scripts/` |
| Hook (`hok-*`) | `.agents/hooks/` | `.claude/hooks/` |

### 2. Transform content based on entity type

#### For Workflows, Agents, Commands (behavioral entities)

**Path transformations:**
- Replace `./age-spe-` with `../agents/age-spe-` in all references
- Replace `./age-sup-` with `../agents/age-sup-` in all references

**Frontmatter injection (Agents only):**
- Map `model` value using default mapping: `gemini-3-flash` → `haiku`, `gemini-3.1` → `sonnet`. Valid CC values: `opus`, `sonnet`, `haiku`. Note: `model` and `effort` defaults may be overridden later by the user in §7.5 Model & Effort Selection of the entity builder.
- Add `effort` field if specified (valid values: `max`, `high`, `medium`, `low`). `max` is only available on opus and sonnet. Controls reasoning depth.
- Add CC-specific fields if specified in the handoff JSON: `tools`, `disallowedTools`, `permissionMode`

**Protection:** Do NOT transform paths inside:
- Code blocks documenting architecture of generated systems
- Generic templates/placeholders with `[name]` brackets
- Paths that already use `../agents/` format

#### For Skills

- **Direct copy** — content is identical on both platforms
- Verify subdirectory structure: `ski-[name]/SKILL.md` (never flat file)

#### For Rules, Knowledge-base, Resources

- **Direct copy** — content is identical on both platforms

#### For Scripts

- GA format: `.md` procedural document
- CC format: `.sh` or `.py` executable
- Extract the executable logic from the GA `.md` and generate the corresponding script file
- Preserve the same frontmatter in a companion documentation file if needed

#### For Hooks

- **Copy** the `.md` documentation file to `.claude/hooks/`
- **Generate** the `settings.json` hook entry:
  1. Read `event` and `matcher` from the hook frontmatter
  2. Read `platform_behavior.claude_code` for the entry structure
  3. Append to the `hooks` key in `settings.json`, grouped by event type

### 3. Write the output file

Write the transformed content to `{export_path}/.claude/{destination_path}`.

### 4. Return summary

```
CC output: {entity_name} → .claude/{destination_path}
  Transforms: [list of transforms applied, e.g. "path transforms", "model mapping", "settings.json hook"]
```

---

## Error Handling

- **Destination file already exists:** Overwrite silently (the GA version is the source of truth).
- **Unknown entity type:** Skip and warn — do not block the pipeline.
- **Model value not in mapping table:** Use `sonnet` as default and warn.
- **Hook without event field in frontmatter:** Skip settings.json entry and warn.
