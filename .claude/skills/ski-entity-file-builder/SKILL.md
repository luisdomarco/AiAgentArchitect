---
name: ski-entity-file-builder
description: Generates complete, correctly formatted instruction files for all 10 entity types (Workflow, Agent, Skill, Command, Rule, Knowledge-base, Resources, Script, Hook) per assigned intricacy level. Use in Step 3 to materialize each entity from the architectural blueprint as a deployable file.
---

# Entity File Builder Skill

Generates the complete content of instruction files for each entity type, adapting the depth to the assigned intricacy level and respecting all formatting conventions.

## Input / Output

**Input:**

- Entity type: `workflow | agent-specialist | agent-supervisor | skill | command | rule | knowledge-base | script | hook`
- Intricacy level: `simple | medium | complex`
- Entity data from handoff JSON (name, description, function, input, output, relationships)
- List of entities already created in the session (for correct cross-references)

**Output:**

- Complete `.md` file with YAML frontmatter and Markdown body, ready to download

---

## Procedure

### 1. Pre-generation: mandatory verifications

Before writing the file, verify:

- The name follows the kebab-case convention with the correct prefix for its type.
- The frontmatter description does not exceed 250 characters.
- Cross-reference paths use the correct relative format.
- The intricacy level determines the content density (see section 4).
- The expected size and density: if the projected content approaches or exceeds the recommended character limit for the entity type (<6000 Workflow/KB, <3000 Agent/Rule, <1500 Skill/Command), prepare to partition it by creating documents in the `/resources` directory and referencing them.

---

### 2. Naming conventions by type

| Type             | Prefix     | Example                       |
| ---------------- | ---------- | ----------------------------- |
| Workflow         | `wor-`     | `wor-customer-onboarding.md`  |
| Agent Specialist | `age-spe-` | `age-spe-email-classifier.md` |
| Agent Supervisor | `age-sup-` | `age-sup-output-validator.md` |
| Skill            | `ski-`     | `ski-format-output/SKILL.md`  |
| Command          | `com-`     | `com-quick-translate.md`      |
| Rule             | `rul-`     | `rul-output-standards.md`     |
| Knowledge-base   | `kno-`     | `kno-brand-guidelines.md`     |
| Resources        | `res-`     | `res-security-policies.md`    |
| Script           | `scp-`     | `scp-lint-check.sh`           |
| Hook             | `hok-`     | `hok-validate-on-save.md`     |

---

### 3. Templates by entity type

Templates are split by entity category to minimize context load:

- **Behavioral entities** (`wor-`, `age-spe-`, `age-sup-`, `com-`): read `../../resources/res-entity-templates-behavioral.md`
- **Support entities** (`ski-`, `rul-`, `kno-`, `res-`, `scp-`, `hok-`): read `../../resources/res-entity-templates-support.md`

Extract the structure for the requested entity type and fill it dynamically per the assigned intricacy level.

---

### 4. Intricacy levels and cross-reference rules

Full specifications for all three intricacy levels (`simple`, `medium`, `complex`), cross-reference path conventions, consistency rules, content partitioning, and pre-validation checklist:

> **`../../resources/res-entity-builder-protocol.md`**

> **Platform output:** This skill generates GA (`.agents/`) entities only. Platform-specific output (CC, Codex) is handled by `ski-output-claude-code` and `ski-output-codex` respectively. Skills use the `ski-[name]/SKILL.md` subdirectory structure on all platforms — never create flat `ski-name.md` files.

---

### 5. Content Structuring and Partitioning (/resources)

If when planning the intricacy level (especially for `complex`) you anticipate a very extensive entity or one that will exceed the recommended limit:

1. Identify dense blocks that could be externalized (e.g. very long prompts, extensive categorization tables, few-shot examples, detailed style policies or guides).
2. Determine which support files to create in the `./resources/` directory to host that raw information.
3. In the main entity, make a direct reference to the support files structuring the information as a relational system. E.g. `See detailed policies in [Security Policies](./resources/res-security-policies.md)`.

---

### 6. Pre-presentation validation

After generating the entity content and before returning it, run this automated checklist:

1. **Frontmatter:** `name` and `description` are present; `description` ≤ 250 chars.
2. **Cross-references:** Each path in Skills/KB/Rules tables points to an entity that exists or is planned in `creation_order`.
3. **Character count:** If the entity exceeds the recommended limit for its type, flag it with a suggestion to partition into `resources/`.
4. **Template conformance:** All required sections for the entity type are present and non-empty.
5. **Naming:** Correct prefix for the entity type and kebab-case format.

Emit a summary line at the end of the generated entity:

```
Pre-validation: ✅ frontmatter | ✅ cross-refs | ✅ size (2847/3000) | ✅ sections | ✅ naming
```

If any check fails, use `⚠️` and describe the issue. Do not suppress failures.

---

### 7. Universal compliance requirement for generated agents

**Universal requirement (all intricacy levels):** Every generated agent (type `age-spe-*` or `age-sup-*`) MUST include in its Execution Protocol:

> "Before presenting your output, emit a `<sys-eval>` block per `rul-strict-compliance`."

Every agent's Related rules table MUST include `rul-strict-compliance`. This ensures all generated systems produce traceable outputs.

---

## Examples

**Example — Generation of Agent Specialist at simple level**

Input:

```json
{
  "type": "agent-specialist",
  "name": "age-spe-email-classifier",
  "function": "Classify incoming emails into predefined categories",
  "intricacy_level": "simple"
}
```

Expected output: Agent with Goals (2), Tasks (4), linear Execution Protocol (5-6 steps), Specific Rules (3), without Skills or KB if not needed.

---

## Error Handling

- **Name does not follow convention:** Automatically correct and notify the user.
- **Description exceeds 250 characters:** Summarize while maintaining the essential meaning.
- **Reference to entity not yet created:** Include the reference with the correct path and indicate in a comment that entity will be created later.
- **Inconsistency detected with the Blueprint:** Pause, notify the user, and ask for clarification before continuing.
