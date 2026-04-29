---
name: ski-platform-exporter
description: Converts a Google Antigravity export to other platforms (Claude Code, ChatGPT, Claude.ai, Dust, Gemini) by applying the correct mapping and generating the corresponding file structure. For Claude Code, also generates .claude/settings.json with hooks for QA automation. Use post-packaging or on-demand when additional platform exports are requested.
---

# Platform Exporter Skill

Converts a system exported for Google Antigravity to other platforms, applying the necessary transformations according to each platform's conventions.

## Input / Output

**Input:**

- Path of the system in `exports/{name}/` (reads `.agents/` within it)
- Destination platform: `chatgpt`, `claude-ai`, `dust`, `gemini`, `codex`
- System name (extracted from path or provided)

**Note:** Claude Code and Codex exports are generated automatically as part of the default triple-platform structure (`exports/{name}/.claude/` and `exports/{name}/.codex/`). This skill is only needed for application platform exports.

**Output:**

- Files generated in `exports/{name}/{platform}/`
- Summary of exported entities

---

## Procedure

### 1. Validate input

- Check that `exports/{name}/.agents/` exists
- Verify that the destination platform is supported (`chatgpt`, `claude-ai`, `dust`, `gemini`, `codex`)
- If the platform already exists in `exports/{name}/{platform}/`, ask whether to overwrite

---

### 2. Read Antigravity structure

Scan `.agents/` and register all entities found:

```
.agents/
├── workflows/      → list all .md files
├── agents/         → list all .md files
├── skills/         → list all subdirectories (ski-name/)
├── rules/          → list all .md files
├── knowledge-base/ → list all .md files
├── commands/       → list all .md files
├── scripts/        → list all scp-* files
├── hooks/          → list all hok-*.md files
└── process-overview.md
```

---

### 3. Apply mapping according to destination platform

Detailed mapping tables per platform (Claude Code reference, Applications, Codex invocation):

> **`../../resources/res-platform-exporter-mappings.md`**

Read the section for the requested destination platform and apply it.

---

### 4. Execute the conversion

For each entity in the list:

1. Read the source file from `.agents/{type}/{name}`
2. Apply transformations if applicable (none needed for most)
3. Write to the destination path according to the mapping

Maintain the subdirectory structure (e.g. skills maintain their internal folder).

---

### 5. Present summary

```
✅ Export to {platform} complete.
Location: exports/{name}/{platform}/

Exported entities:
- {N} workflows
- {N} agents
- {N} skills
- {N} rules
- {N} knowledge-bases
- {N} commands

[Platform-specific instructions]
```

**Instructions by platform:**

- **Claude Code**: "Open this directory in Claude Code to use the complete system."
- **ChatGPT**: "Upload the .md files to your project in ChatGPT."
- **Claude.ai**: "Create a new project and attach the .md files."
- **Dust / Gemini**: "Upload the files according to the platform's conventions."

---

## Examples

**Example 1 — Export to Claude Code**

Input:

```json
{
  "system": "exports/customer-onboarding/",
  "platform": "claude-code"
}
```

Expected output:

- Directory `exports/customer-onboarding/` with `.claude/` structure
- `CLAUDE.md` generated with system context
- `settings.json` created
- 2 workflows converted to commands in `.claude/commands/`
- 3 agents copied to `.claude/agents/`
- 1 skill copied to `.claude/skills/`
- 2 rules copied in `.claude/rules/` and referenced in `CLAUDE.md`

**Example 2 — Export to ChatGPT**

Input:

```json
{
  "system": "exports/email-classifier/",
  "platform": "chatgpt"
}
```

Expected output:

- Directory `exports/email-classifier/chatgpt/` with folders aligned to the architecture
- 1 agent in `workflows/age-spe-email-classifier.md`
- 2 skills in `skills/ski-xxx/SKILL.md`
- 1 rule in `rules/rul-xxx.md`
- process-overview.md at root

---

## Error Handling

- **System not found**: Verify that `exports/{name}/` exists. If not, list available systems in `exports/` and ask the user to specify correctly.

- **Platform not supported**: Show list of supported platforms: `claude-code`, `chatgpt`, `claude-ai`, `dust`, `gemini`, `codex`.

- **Destination export already exists**: Ask:

  ```
  The export to {platform} already exists at exports/{name}/{platform}/.

  Do you want to overwrite it?
  A) Yes, overwrite
  B) No, cancel
  C) Generate in a different directory ({platform}-v2)
  ```

- **Corrupt or unreadable file**: Notify and skip that file. Continue with the rest. List skipped files in the summary.
