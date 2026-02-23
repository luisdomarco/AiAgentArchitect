---
trigger: always_on
description: Defines output format, structure, and constraints for generating acceptance criteria in Gherkin syntax as Markdown lists. Governs scenario ordering, Background and Scenario Outline usage, and language conventions.
alwaysApply: true
tags: [acceptance-criteria, gherkin, output-format, scenarios, bdd]
---

## Context

This rule defines how acceptance criteria in Gherkin syntax must be structured and formatted as output. It ensures that generated criteria are consistent, readable, and aligned with the team's Markdown-list convention — regardless of which user story is being processed. Output is always Markdown with list structure, never a fenced code block.

## Hard Constraints

- Never produce output in any format other than Markdown.
- Never use a fenced code block with `gherkin` — output is a Markdown list structure, not a code block.
- Never include in `Then` steps any validation of internal systems, databases, logs, or processes not observable by the user or an external system.
- Never exceed 8 scenarios per Feature without explicit justification derived from the story scope.
- Never invent data, business rules, or behaviors not present in the user story or provided context.
- Never produce output in a language other than EN-US.

## Soft Constraints

### Grouping structure

- Always include a global block at the start with `Feature` and, if there are preconditions common to all scenarios, a `Background`.
- After the global block, group scenarios by module or product theme when the story spans more than one functional area.
- Each thematic block must have its own scenarios — never mix behaviors from different modules in the same scenario.

### Scenario ordering within each block

Respect this order within each thematic block:

1. **Happy path** — the main flow that results in success when all conditions are correct and the user acts as expected.
2. **Unhappy path** — valid flows that do not result in success due to unmet business conditions: missing permissions, incorrect entity state, business rule that prevents the action.
3. **Error path** — invalid inputs, incorrect data, or exceptional situations that generate a rejection or error message from the system.

### Output format

The output follows this Markdown list structure:

- `- **Feature:** feature title` — first-level bold item.
- `- **Background:**` — first-level bold item, if applicable.
  - Steps as sub-items with 2-space indentation: `  - Given ...`
- `- **Scenario:** descriptive title` — first-level bold item.
  - Steps as sub-items with 2-space indentation.
- Scenario titles: descriptive, specific, and behavior-oriented.
- Steps: short phrases, active voice, domain language.
- Keep 3–5 steps per scenario as a general rule.

### Background and Scenario Outline usage

- Use `Background` when the same `Given` repeats across 3 or more scenarios in the same block — moving it to Background eliminates redundancy.
- Use `Scenario Outline` when the steps are identical and only the input or output data varies, and there are 3 or more combinations.
- Prefer separate scenarios when titles describe qualitatively different situations, even if they share a step.

### Collaborative review

- Before a sprint begins, acceptance criteria should be reviewed jointly by the product owner, developer, and QA to confirm shared understanding and catch missing edge cases.

## Examples

**Correct output (User Login — all 3 paths):**

- **Feature:** User Login

- **Background:**
  - Given a registered user exists

- **Scenario:** Successful login with valid credentials
  - Given the user is on the login page
  - When the user enters valid credentials
  - Then the user is redirected to the dashboard

- **Scenario:** Login blocked for inactive account
  - Given the user account is inactive
  - When the user enters valid credentials
  - Then a message indicates the account is not active

- **Scenario:** Login fails with invalid password
  - Given the user is on the login page
  - When the user enters an incorrect password
  - Then an error message is displayed

**Incorrect format — do not use:**

Using a fenced code block with the `gherkin` language tag is forbidden. Additionally, `Then` steps must never validate internal state (e.g., "the database user record is updated") and scenario titles must be behavior-oriented, not generic (e.g., "Login" is too vague).

## Sources

- `📄` Hard Constraints, Soft Constraints, Scenario ordering, Background/Scenario Outline usage, and the User Login example — extracted from `raw-docs/rul-acceptance-criteria-generation.md`.
- `🧠` Collaborative review section — inferred best practice not present literally in the source document.
