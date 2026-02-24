---
description: Complete Gherkin syntax reference covering keywords, step roles, Background, Scenario Outline, quality criteria, and anti-patterns for writing well-formed acceptance criteria.
tags: [gherkin, acceptance-criteria, syntax, bdd, testing]
---

## Table of Contents

- [1. Primary Keywords](#1-primary-keywords)
- [2. Step Keywords](#2-step-keywords)
- [3. Background](#3-background)
- [4. Scenario Outline](#4-scenario-outline)
- [5. Step Arguments](#5-step-arguments)
- [6. Quality Criteria](#6-quality-criteria)
- [7. Scenario Outline vs. Separate Scenarios](#7-scenario-outline-vs-separate-scenarios)
- [8. Anti-patterns](#8-anti-patterns)
- [9. Team Convention Note](#9-team-convention-note)

---

> **Team convention:** In this team, Gherkin output is expressed as a Markdown list — never as a fenced code block. When generating or reviewing acceptance criteria, apply [`rul-acceptance-criteria-generation.md`](../rules/rul-acceptance-criteria-generation.md).

---

## 1. Primary Keywords

Gherkin uses special keywords to give structure to specifications. The working language is EN-US. Each non-blank line must begin with a Gherkin keyword or be a free-text description under `Feature`, `Background`, `Scenario`, or `Rule`.

| Keyword | Purpose |
|---|---|
| `Feature` | Groups related scenarios under one functionality. Only one per file. |
| `Rule` | Groups scenarios that illustrate the same business rule (Gherkin v6+). |
| `Scenario` / `Example` | Defines a concrete case with steps. They are synonyms. |
| `Background` | Defines common steps executed before each scenario in the block. |
| `Scenario Outline` / `Scenario Template` | Runs the same scenario with multiple data combinations. |
| `Examples` / `Scenarios` | Data table for a `Scenario Outline`. |

---

## 2. Step Keywords

Steps describe behavior in three phases:

| Keyword | Role | Usage |
|---|---|---|
| `Given` | Context | Initial state of the system or user before the action. |
| `When` | Action | The event or action executed by the user or system. |
| `Then` | Result | The observable expected outcome. Only visible outcomes — never internal validations. |
| `And` | Continuation | Extends the previous step of the same type. |
| `But` | Contrast | Introduces an exception or negative condition within a block. |

**Critical rule:** `Then` must describe only outcomes observable by the user or an external system. Never database validations, logs, or internal states.

---

## 3. Background

`Background` defines steps executed before each scenario in the `Feature` or `Rule` it belongs to. It eliminates repeated context.

**When to use it:** when the same `Given` repeats across 3 or more scenarios in the same block.

**Tips for a good Background:**

- Keep it short — maximum 4 lines. If it grows, the reader loses context.
- Include only what the reader needs to remember to understand the scenarios.
- Use domain language, not technical language: `Given a registered user exists` instead of `Given user ID 42 exists in the database`.
- Do not use Background for complex states that are not relevant to the business outcome.

---

## 4. Scenario Outline

Allows running the same scenario with multiple value combinations, avoiding duplication. Parameters are delimited with `< >` and resolved with the `Examples` table.

**When to use it:** when steps are identical and only input or output data varies, and there are 3 or more combinations.

See [res-gherkin-output-examples.md](../resources/res-gherkin-output-examples.md) for a Markdown-list formatted Scenario Outline example.

---

## 5. Step Arguments

Step arguments allow passing complex data to a step. These are reference concepts for understanding Gherkin specifications written by other tools or teams.

- **Doc Strings** — multiline text blocks delimited by `"""`, used to pass a text body to a step.
- **Data Tables** — inline tables delimited by `|`, used to pass structured data sets to a step.

Note: the team's Markdown list output format does not use Doc Strings or Data Tables inline. This section exists for reading comprehension of external Gherkin files.

---

## 6. Quality Criteria

A syntactically valid scenario can still be a poorly written scenario. Criteria to evaluate quality:

- **Adequate granularity:** each scenario covers exactly one behavior. If the title requires "and" to describe itself, it probably needs to be split.
- **Domain language:** steps use business vocabulary, not implementation vocabulary. `the user submits the form` is correct; `the POST request is sent` is not.
- **Atomic steps:** avoid chaining multiple actions in a single step with "and". Use the `And` Gherkin keyword to separate steps, not the conjunction in the text.
- **Given describes state, not action:** `Given the cart has 3 items` is correct; `Given the user added 3 items to the cart` describes an action, not a state.
- **Then describes outcome, not process:** `Then the confirmation email is sent` is observable; `Then the system triggers the email service` is not.
- **3–5 steps per scenario** as a general rule. More steps indicate the scenario covers too much or that steps are not well abstracted.

---

## 7. Scenario Outline vs. Separate Scenarios

| Use `Scenario Outline` when... | Use separate `Scenario` when... |
|---|---|
| Steps are identical and only input/output data changes. | Scenarios have different steps, even if they share context. |
| There are 3 or more data combinations for the same flow. | There are 2 variations with descriptive names that add clarity separately. |
| The Examples table makes the behavior more readable at a glance. | Each case's context or result requires its own explanation in the title. |

**Practical rule:** if separate scenario titles would be nearly identical except for one value, use `Scenario Outline`. If titles describe qualitatively different situations, keep them separate.

---

## 8. Anti-patterns

| Anti-pattern | Problem | Correction |
|---|---|---|
| `Then the database is updated` | Validates internal state, not observable outcome. | `Then the user sees a confirmation message` |
| `Given the user clicks the login button` | `Given` describes an action, not a state. | `Given the user is on the login page` |
| `When the user fills the form and clicks submit` | Multiple actions in one step. | Split into `When` + `And`. |
| Scenario with 10+ steps | Covers too much or steps are too granular. | Split into scenarios or abstract common steps to Background. |
| All scenarios are happy path | Does not cover edge cases or errors. | Explicitly add unhappy path and error path. |
| Same `Given` copied to every scenario | Unnecessary redundancy. | Move to `Background`. |

---

## 9. Team Convention Note

This document describes canonical Gherkin syntax. When generating acceptance criteria for this team, output must follow the Markdown list format defined in [`rul-acceptance-criteria-generation.md`](../rules/rul-acceptance-criteria-generation.md). Fenced `gherkin` blocks are never used in team output.

## Sources

- `📄` Sections 1–8 (keywords, step roles, Background, Scenario Outline, step arguments, quality criteria, when to use Outline vs. separate, anti-patterns) — extracted from `raw-docs/kno-gherkin-syntax.md`.
- `📄` Supplementary examples for step arguments (Doc Strings, Data Tables, Background at Rule level) — extracted from `raw-docs/gherkin-syntax.md`.
- `🧠` Section 9 (Team Convention Note linking to `rul-acceptance-criteria-generation.md`) — inferred from project context; not present in source documents.
