---
name: ski-entity-file-builder
description: Generates complete, correctly formatted instruction files for all 8 entity types (Workflow, Agent, Skill, Command, Rule, Knowledge-base, Resources) per assigned intricacy level. Use in Step 3 to materialize each entity from the architectural blueprint as a deployable file.
---

# Entity File Builder Skill

Generates the complete content of instruction files for each entity type, adapting the depth to the assigned intricacy level and respecting all formatting conventions.

## Input / Output

**Input:**

- Entity type: `workflow | agent-specialist | agent-supervisor | skill | command | rule | knowledge-base`
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

---

### 3. Templates by entity type

The base structures, frontmatters (YAML), and descriptive introductions for each entity type are externalized to optimize cognitive load.

> **You must inspect and copy directly the Baseline Format by reading the auxiliary file:**
> `../../resources/res-entity-formatting-templates.md`

Extract from there the requested structure according to the `Entity type` from the Input, and proceed to fill it dynamically according to the corresponding Intricacy.

---

### 4. Intricacy levels

#### `simple`

- Goals: 2-3 concise objectives.
- Tasks: 3-5 bullets without extensive description.
- Execution Protocol / Workflow Sequence: linear flow, without subsections.
- Specific Rules: 3-5 direct rules.
- Skills: no table if it has none.
- No extended examples.

#### `medium`

- Goals: 3-5 objectives with explicit expected result.
- Tasks: 5-8 bullets with brief description of each.
- Execution Protocol / Workflow Sequence: numbered steps, handling of alternative cases.
- Specific Rules: 5-8 rules with context.
- Skills: complete table with descriptive "When use it" column.
- Examples in Skills when they clarify usage.

#### `complex`

- Goals: 4-6 detailed objectives with success metric.
- Tasks: 8+ bullets with full description.
- Execution Protocol / Workflow Sequence: subsections by stage, error handling, loops, conditions.
- Specific Rules: 8+ rules with specific cases and reasoning.
- Skills: complete table + notes on when NOT to use each one.
- Detailed examples with explicit reasoning.
- Comparative or reference tables where they add clarity.

---

### 5. Cross-reference coherence

Before including any reference to another entity, verify that:

- The name used matches exactly the name in that entity's frontmatter.
- The relative path is correct according to the root folder architecture:

| Type           | Relative path from any entity        |
| -------------- | ------------------------------------ |
| Skill          | `./skills/[skill-name]/SKILL.md`     |
| Agent          | `./workflows/[agent-name].md`        |
| Workflow       | `./workflows/[workflow-name].md`     |
| Rule           | `./rules/[rule-name].md`             |
| Knowledge-base | `./knowledge-base/[kb-name].md`      |
| Command        | `./workflows/[command-name].md`      |
| Resources      | `./resources/res-[resource-name].md` |

---

### 6. Content Structuring and Partitioning (/resources)

If when planning the intricacy level (especially for `complex`) you anticipate a very extensive entity or one that will exceed the recommended limit:

1. Identify dense blocks that could be externalized (e.g. very long prompts, extensive categorization tables, few-shot examples, detailed style policies or guides).
2. Determine which support files to create in the `./resources/` directory to host that raw information.
3. In the main entity, make a direct reference to the support files structuring the information as a relational system. E.g. `See detailed policies in [Security Policies](./resources/res-security-policies.md)`.

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
