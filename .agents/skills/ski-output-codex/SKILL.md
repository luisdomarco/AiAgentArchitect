---
name: ski-output-codex
description: Converts a generated Google Antigravity entity into its OpenAI Codex equivalent, producing TOML agents for behavioral entities, direct copies for procedural entities, and hook JSON fragments. Use after generating the GA version of each entity in Step 3.
---

# OpenAI Codex Platform Output

Takes a generated GA entity (`.agents/`) and produces the Codex equivalent (`.codex/`), applying all platform-specific transformations.

## Input / Output

**Input:**

- `entity_type`: workflow | agent | command | skill | rule | knowledge-base | resources | script | hook
- `entity_name`: the entity filename (e.g. `age-spe-email-classifier.md`)
- `source_content`: the full content of the generated GA entity
- `export_path`: base export path (e.g. `exports/{name}`)
- `model_ga`: the GA model value from frontmatter (e.g. `gemini-3.1`)

**Output:**

- Entity file(s) written to the correct `.codex/` path
- Hook JSON fragment if entity is a Hook
- Summary of what was generated

---

## Procedure

### 1. Determine transformation type

Read the directory mapping from `../resources/res-entity-templates-codex.md` §3:

| Entity prefix | Transformation | Destination |
|---|---|---|
| `wor-*`, `age-*`, `com-*` | MD → TOML agent | `.codex/agents/` |
| `ski-*` | Direct copy | `.codex/skills/` |
| `rul-*` | Direct copy | `.codex/rules/` |
| `kno-*` | Direct copy | `.codex/knowledge-base/` |
| `res-*` | Direct copy | `.codex/resources/` |
| `scp-*` | MD → executable | `.codex/scripts/` |
| `hok-*` | Copy MD + generate JSON fragment | `.codex/hooks/` |

### 2. Transform content based on entity type

#### For Workflows, Agents, Commands → TOML conversion

Follow the conversion rules in `../resources/res-entity-templates-codex.md` §1:

1. **Parse frontmatter**: Extract `name`, `description`, `model` from YAML frontmatter
2. **Map model**: Apply model mapping from §2:
   - `gemini-3-flash` / `haiku` → `gpt-5.4-mini`, effort `"low"`
   - `gemini-3.1` / `sonnet` → `gpt-5.4`, effort `"medium"`
   - `opus` → `gpt-5.4`, effort `"high"`
3. **Extract body**: Everything after the closing `---` of frontmatter becomes `developer_instructions`
4. **Escape for TOML**: Wrap in `'''` (single-quoted literal). If body contains `'''`, replace with `` ``` ``
5. **Transform agent references**: Replace `./age-spe-*.md` and `../agents/age-spe-*.md` with descriptive subagent invocation text
6. **Parse Skills table**: Extract skill names and generate `[[skills.config]]` entries with `.codex/skills/` paths
7. **Generate nickname**: Convert entity name from kebab-case to Title Case, strip prefix
8. **Set defaults**: `sandbox_mode = true`
9. **Prepend header**: `# AUTO-GENERATED from .agents/ — Do not edit directly.`

**Output file**: `{export_path}/.codex/agents/{entity-name-without-extension}.toml`

#### For Skills

- **Direct copy** to `.codex/skills/ski-[name]/SKILL.md`
- Preserve subdirectory structure

#### For Rules, Knowledge-base, Resources

- **Direct copy** to corresponding `.codex/` directory

#### For Scripts

- Same as Claude Code: extract executable logic from GA `.md` → generate `.sh` or `.py`
- Write to `.codex/scripts/`

#### For Hooks

Generate TWO files:

1. **Documentation**: Copy `.md` to `.codex/hooks/hok-[name].md`
2. **JSON fragment**: Generate `.codex/hooks/hok-[name].json`:

```json
{
  "event": "[from frontmatter event field]",
  "matcher": "[from frontmatter matcher field]",
  "hook": {
    "type": "[from frontmatter type field]",
    "command": ".codex/scripts/scp-[related-script].sh",
    "timeout": 600
  }
}
```

If the hook event has no Codex equivalent (see `../resources/res-codex-conventions.md` §2), generate only the `.md` and skip the `.json` fragment. Add a note in the `.md`:

```
> **Codex note:** This hook event ([event]) has no direct Codex equivalent. The behavioral rule is documented here for reference but cannot be automated via hooks.json.
```

### 3. Write the output file(s)

Write to `{export_path}/.codex/{destination_path}`.

### 4. Return summary

```
Codex output: {entity_name} → .codex/{destination_path}
  Type: [TOML agent | direct copy | executable | hook fragment]
  Transforms: [list, e.g. "MD→TOML", "model mapping", "JSON fragment"]
```

---

## Error Handling

- **Destination file already exists:** Overwrite silently (GA is source of truth).
- **Unknown entity type:** Skip and warn — do not block the pipeline.
- **Model value not in mapping table:** Use `gpt-5.4` with `"medium"` as default, warn.
- **Hook event not supported in Codex:** Generate `.md` only, skip `.json`, add note.
- **TOML escaping failure (body contains `'''`):** Replace with backtick code fences and warn.
