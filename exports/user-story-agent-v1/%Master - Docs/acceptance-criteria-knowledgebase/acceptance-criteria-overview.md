---
description: Index and summary for the acceptance-criteria documentation set. Covers Gherkin syntax reference, output format rules, conceptual fundamentals, annotated examples, and business context template.
tags: [overview, acceptance-criteria, gherkin, bdd, index]
---

# Acceptance Criteria Documentation — Project Overview

## Objective

This documentation set provides a complete reference for writing, formatting, and reviewing acceptance criteria in Gherkin syntax using the team's Markdown list convention. It covers the canonical Gherkin syntax, the team's output format rule, conceptual foundations, annotated examples, and a reusable business context template.

---

## Table of Contents

| # | File | Type | Description |
|---|---|---|---|
| 1 | [rul-acceptance-criteria-generation.md](./rules/rul-acceptance-criteria-generation.md) | Rule | Defines the output format constraints: Markdown list structure, scenario ordering (happy/unhappy/error), Background and Scenario Outline usage, and EN-US language requirement. |
| 2 | [kno-gherkin-syntax-reference.md](./knowledge-base/kno-gherkin-syntax-reference.md) | Knowledge-Base | Complete Gherkin syntax reference: primary keywords, step keywords, Background, Scenario Outline, quality criteria, and anti-pattern correction table. |
| 3 | [kno-acceptance-criteria-fundamentals.md](./knowledge-base/kno-acceptance-criteria-fundamentals.md) | Knowledge-Base | Conceptual foundation: definition of acceptance criteria in Scrum, the 3C model, when to use narrative vs. Gherkin format, and common writing errors. |
| 4 | [res-gherkin-output-examples.md](./resources/res-gherkin-output-examples.md) | Resource | Annotated examples in Markdown list format: User Login (all 3 paths), Scenario Outline, Background at Rule level, e-commerce domain example, and anti-pattern corrections. |
| 5 | [kno-business-context.md](./knowledge-base/kno-business-context.md) | Knowledge-Base | Structured template for capturing product context: roles, domain glossary, functional modules, business constraints, and edge cases. Fill before generating criteria for a new project. |

---

## How to Use This Set

1. **Before writing acceptance criteria for a new story:** Fill in `kno-business-context.md` with the product's roles, glossary, modules, and constraints.
2. **When generating criteria:** Follow `rul-acceptance-criteria-generation.md` strictly — Markdown list format, correct ordering, and EN-US language.
3. **When reviewing criteria quality:** Use `kno-gherkin-syntax-reference.md` as the checklist for quality criteria and anti-patterns.
4. **When onboarding new team members:** Start with `kno-acceptance-criteria-fundamentals.md` for conceptual grounding, then move to the rule and syntax reference.
5. **For concrete format examples:** Refer to `res-gherkin-output-examples.md` to see all patterns applied in practice.

---

## Source Attribution

| Document | Primary Source |
|---|---|
| `rul-acceptance-criteria-generation.md` | `raw-docs/rul-acceptance-criteria-generation.md` (direct extraction and faithful expansion) |
| `kno-gherkin-syntax-reference.md` | `raw-docs/kno-gherkin-syntax.md` (direct extraction with team convention note added) |
| `kno-acceptance-criteria-fundamentals.md` | External reference URLs on Scrum acceptance criteria (conceptual enrichment) |
| `res-gherkin-output-examples.md` | `raw-docs/rul-acceptance-criteria-generation.md` + `raw-docs/kno-gherkin-syntax.md` + inferred e-commerce domain example |
| `kno-business-context.md` | System inference (raw-doc source was empty — structured template generated) |

---

Generated: 2026-02-22
