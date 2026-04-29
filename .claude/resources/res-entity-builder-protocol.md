---
name: res-entity-builder-protocol
description: Detailed generation protocol for ski-entity-file-builder and age-spe-entity-builder. Defines intricacy levels, cross-reference path conventions, content partitioning rules, and pre-presentation validation checklist. Read once at the start of Step 3 entity generation.
tags: [entity-builder, protocol, intricacy, cross-references, validation]
---

## Purpose

This resource externalizes the operational detail of the entity generation protocol, allowing `ski-entity-file-builder` and `age-spe-entity-builder` to remain lean while preserving full fidelity of the generation rules.

**When to read:** Once at the beginning of Step 3 (entity generation), before generating the first entity.

---

## 1. Intricacy Levels

The intricacy level determines the content density of generated entities. Apply it consistently across all sections.

### `simple`

- Goals: 2-3 concise objectives.
- Tasks: 3-5 bullets without extensive description.
- Execution Protocol / Workflow Sequence: linear flow, without subsections.
- Specific Rules: 3-5 direct rules.
- Skills: no table if it has none.
- No extended examples.

### `medium`

- Goals: 3-5 objectives with explicit expected result.
- Tasks: 5-8 bullets with brief description of each.
- Execution Protocol / Workflow Sequence: numbered steps, handling of alternative cases.
- Specific Rules: 5-8 rules with context.
- Skills: complete table with descriptive "When use it" column.
- Examples in Skills when they clarify usage.

### `complex`

- Goals: 4-6 detailed objectives with success metric.
- Tasks: 8+ bullets with full description.
- Execution Protocol / Workflow Sequence: subsections by stage, error handling, loops, conditions.
- Specific Rules: 8+ rules with specific cases and reasoning.
- Skills: complete table + notes on when NOT to use each one.
- Detailed examples with explicit reasoning.
- Comparative or reference tables where they add clarity.

---

## 2. Cross-Reference Path Conventions

Before including any reference to another entity in a generated file, verify the name and path.

**Paths relative from `.agents/` root:**

| Entity type    | Relative path                             |
| -------------- | ----------------------------------------- |
| Skill          | `../skills/[skill-name]/SKILL.md`         |
| Agent          | `./[agent-name].md`                       |
| Workflow       | `./[workflow-name].md`                    |
| Rule           | `../rules/[rule-name].md`                 |
| Knowledge-base | `../knowledge-base/[kb-name].md`          |
| Command        | `./[command-name].md`                     |
| Resources      | `../resources/res-[resource-name].md`     |
| Script         | `../scripts/scp-[name].sh` or `../scripts/scp-[name].md` |
| Hook           | `../hooks/hok-[name].md`                  |

**Paths relative from entity root (used inside entity body cross-refs):**

| Entity type    | Relative path                             |
| -------------- | ----------------------------------------- |
| Skill          | `./skills/[skill-name]/SKILL.md`          |
| Agent          | `./workflows/[agent-name].md`             |
| Workflow       | `./workflows/[workflow-name].md`          |
| Rule           | `./rules/[rule-name].md`                  |
| Knowledge-base | `./knowledge-base/[kb-name].md`           |
| Command        | `./workflows/[command-name].md`           |
| Resources      | `./resources/res-[resource-name].md`      |
| Script         | `./scripts/scp-[name].sh` or `./scripts/scp-[name].md` |
| Hook           | `./hooks/hok-[name].md`                   |

**Skills use the `ski-[name]/SKILL.md` subdirectory structure on all platforms — never create flat `ski-name.md` files.**

---

## 3. Consistency During Generation

Maintain an internal record of already approved entities during the generation session:

- **Names:** Use exactly the same name (kebab-case with prefix) in all cross-references. The frontmatter `name` must match the filename exactly.
- **Reused Skills:** If a Skill was already created or is reused, reference it with the correct path in all Agents that use it.
- **Context Ledger:** If the generated workflow has 2+ agents in sequence, include the **Context Map** section and register `ski-context-ledger` in its Skills table. If the target system doesn't include `ski-context-ledger`, generate it as an additional entity.
- **Platform output:** Hook entities are handled by the platform output skills. `ski-output-claude-code` generates `settings.json` entries. `ski-output-codex` generates `.json` hook fragments. Only generate the GA `.md` file.

---

## 4. Content Partitioning into `/resources`

If when planning the intricacy level (especially for `complex`) the projected content approaches or exceeds the recommended character limit:

1. Identify dense blocks that could be externalized (e.g. very long prompts, extensive categorization tables, few-shot examples, detailed style policies or guides).
2. Determine which support files to create in the `./resources/` directory to host that raw information.
3. In the main entity, make a direct reference to the support files structuring the information as a relational system. E.g. `See detailed policies in [Security Policies](./resources/res-security-policies.md)`.

**Character limits reference:**

| Entity type | Recommended | Maximum |
| ----------- | ----------- | ------- |
| Workflow    | < 6,000     | 12,000  |
| Agent       | < 3,000     | 12,000  |
| Skill       | < 1,500     | 12,000  |
| Command     | < 1,500     | 12,000  |
| Rule        | < 3,000     | 12,000  |
| Knowledge-base | < 6,000  | 12,000  |
| Resources   | < 6,000     | 12,000  |
| Script      | < 1,500     | 12,000  |
| Hook        | < 1,500     | 12,000  |

---

## 5. Pre-Presentation Validation Checklist

After generating the entity content and before returning it, run this checklist:

1. **Frontmatter:** `name` and `description` are present; `description` ≤ 250 chars.
2. **Cross-references:** Each path in Skills/KB/Rules tables points to an entity that exists or is planned in `creation_order`.
3. **Character count:** If the entity exceeds the recommended limit for its type, flag it with a suggestion to partition into `resources/`.
4. **Template conformance:** All required sections for the entity type are present and non-empty.
5. **Naming:** Correct prefix for the entity type and kebab-case format.
6. **Intricacy conformance:** Content density matches the assigned intricacy level (§1 above).
7. **sys-eval compliance:** Every generated agent includes `<sys-eval>` in its Execution Protocol and `rul-strict-compliance` in its Related Rules table.

Emit a summary line at the end of the generated entity:

```
Pre-validation: ✅ frontmatter | ✅ cross-refs | ✅ size (2847/3000) | ✅ sections | ✅ naming
```

If any check fails, use `⚠️` and describe the issue. Do not suppress failures.

---

## 6. Generating process-overview.md

**Before generating process-overview.md, ask the user:**

```
Do you want to add the QA system (Auditor, Evaluator, Optimizer) to the system we are creating?
This adds 3 agents + 3 skills + 1 rule + 1 knowledge-base that automatically evaluate
the system after each checkpoint.

A) ✅ Yes, include QA Layer
B) ⏭️  No, continue without QA
```

If **A**: activate `ski-qa-embed` with the current system. The skill creates QA files and adds them to the Blueprint. Register QA entities to include them in the `process-overview.md` inventory.

If **B**: continue directly to `process-overview.md`.

After all entities are complete (with or without QA), generate `process-overview.md` with these sections: **Process description** (2-4 paragraphs), **Flow diagram** (Mermaid), **Entity architecture** (Inventory table + Relationships prose + Architecture Mermaid diagram), **Success criteria**. Use `ski-diagram-generator` for diagrams.

Present with a final checkpoint:

```
Closing document generated.

How do you want to continue?
A) ✅ Approve and close the process
B) ✏️  Adjust the closing document
C) 🔄 Return to Step 3 to adjust an entity
```

---

## 7. Universal Compliance Requirement for Generated Agents

**All intricacy levels:** Every generated agent (`age-spe-*` or `age-sup-*`) MUST include in its Execution Protocol:

> "Before presenting your output, emit a `<sys-eval>` block per `rul-strict-compliance`."

Every agent's Related Rules table MUST include `rul-strict-compliance`. This ensures all generated systems produce traceable outputs.

---

## 8. Model & Effort Selection (Claude Code)

After all entities are approved (all CP-S3-N checkpoints passed) and **before** generating `process-overview.md`, if `"claude-code"` is in `target_platforms`:

1. **Read `model_strategy` from S2 handoff** (if present). If absent, default to `tiered-assignment`.

2. **Strategy-specific behavior:**
   - `single-model`: Do not populate `model` field in any entity. Present a note: _"Strategy is Single Model. No model specified in entity files; configure at session/platform level."_ Skip the rest of this section.
   - `tiered-assignment` (default): Use the role table below to set model per agent.
   - `advisor`: Same as `tiered-assignment` for executor agents. Ensure all advisor entities (`age-spe-advisor` or `age-spe-advisor-{domain}`) have `opus` / `max`. Add a "Role" column with values "executor" or "advisor" (or "advisor ({domain})" in multi-advisor mode).
   - `orchestrator-worker`: Workflow/orchestrator entities get frontier tier (`opus`/`max`), worker agents get `sonnet`/`high` or `haiku`/`low`.
   - `evaluator-gate`: Generator agents get `haiku`/`low`, evaluator agents get `sonnet`/`high` or `opus`/`max`.

3. Collect all agent entities (`age-spe-*`, `age-sup-*`) from the generation plan. For each agent, determine a recommended CC `model` and `effort` based on its role:

   | Agent Role | Model | Effort | Rationale |
   |---|---|---|---|
   | Analysis, architecture, complex design | `opus` | `max` | Deepest reasoning, complex trade-offs |
   | Advisor (strategy = advisor) | `opus` | `max` | Must provide highest quality analysis |
   | Code review, security audit, QA audit | `opus` | `high` | Nuanced judgment, thorough verification |
   | Implementation, coding, scaffolding | `sonnet` | `high` | Fast code gen with thorough thinking |
   | UI/UX, component implementation, design decisions | `opus` | `max` | Design architecture requires frontier reasoning |
   | Testing, validation | `sonnet` | `medium` | Formulaic but needs some reasoning |
   | DevOps, git, deployment | `sonnet` | `medium` | Mechanical operations |
   | QA scoring, structured evaluation | `sonnet` | `medium` | Structured calculation |
   | Trivial tasks (validation, copy, routing) | `haiku` | `low` | Only when task has no decisions, no creative generation, well-defined I/O |

   **Effort defaults:**
   - `opus`: always `max` — frontier reasoning at full depth.
   - `sonnet`: `high` by default; `medium` only when the task is evidently routine (no decisions, mechanical transformation).
   - `haiku`: always `low` — reserved for trivially simple tasks.

   **Valid values:**
   - `model`: `opus` (most capable), `sonnet` (balanced), `haiku` (fastest/cheapest)
   - `effort`: `max` (absolute maximum, opus/sonnet only), `high` (default), `medium` (balanced), `low` (most efficient)

4. Present the selection table to the user:

   ```
   MODEL & EFFORT SELECTION (Claude Code)

   Strategy: [strategy name from S2 handoff, or "tiered-assignment" if not specified]

   These agents support model and effort configuration in Claude Code.
   Model controls capability/cost; effort controls reasoning depth.

   | # | Agent | Role | Model | Effort |
   |---|---|---|---|---|
   | 1 | `age-spe-{name}` | {role summary} | {model} | {effort} |
   | 2 | `age-spe-{name}` | {role summary} | {model} | {effort} |
   | ... | ... | ... | ... | ... |

   How do you want to proceed?
   A) ✅ Accept all recommendations
   B) ✏️ Change specific agents (e.g. "2→opus/high, 5→haiku/low")
   C) ⏭️ Skip — keep default mapping, no effort field
   ```

5. **If A:** Update `model` and `effort` fields in each CC agent file under `.claude/agents/`.
6. **If B:** Apply user-specified overrides, then update the CC agent files.
7. **If C:** No changes — the default GA→CC model mapping remains, no `effort` field added.

After this step, present a confirmation summary of the final assignments (unless skipped).

If strategy = `advisor`, add a note below the confirmation:
> _"Executor agents include escalation instructions to invoke the advisor when they detect difficulty signals (see `kno-agent-strategies` §2.4). Communication uses the Escalation Report and Resolution Plan formats defined in that section."_

If multi-advisor, also add:
> _"Domain routing: each executor's `escalation_domain` determines which advisor receives the escalation. See the Domain routing table in the Blueprint."_

**Patch Mode:** When iterating on an existing system, this step is available on demand. The user can request `/model-select` to re-run model and effort selection for all agents, or specify individual agents to update.

---

## 9. Advisor Incidents Scaffolding

When strategy = `advisor`, after the model & effort selection is confirmed (or skipped), create the `advisor-incidents/` directory at the export root with an empty `INDEX.md`:

1. Create directory `exports/{name}/advisor-incidents/`.
2. Write `exports/{name}/advisor-incidents/INDEX.md` with the base structure:

```markdown
# Advisor Incidents Index

Resolved escalations are logged here by the workflow after each advisor intervention.
The advisor consults this index before analyzing new escalations to leverage prior solutions.

| ID | Date | Executor | Advisor | Signal | Problem | Solution |
|---|---|---|---|---|---|---|
```

3. Reference `advisor-incidents/` in `process-overview.md` under a "Runtime Data" or "Operational Directories" section, alongside `context-ledger/` and `memory/`.
