---
description: Conceptual foundation of acceptance criteria in Scrum - definition, the 3C model, format selection (narrative vs. Gherkin), common writing errors, and link to the team's Gherkin convention.
tags: [acceptance-criteria, scrum, bdd, gherkin, user-stories]
---

## Table of Contents

- [1. What Are Acceptance Criteria](#1-what-are-acceptance-criteria)
- [2. The 3C Model](#2-the-3c-model)
- [3. Narrative Format vs. Gherkin](#3-narrative-format-vs-gherkin)
- [4. Common Writing Errors](#4-common-writing-errors)
- [5. Team Convention](#5-team-convention)

---

## 1. What Are Acceptance Criteria

Acceptance criteria are the conditions a product increment must satisfy for a user story to be considered complete. They serve as the shared definition of "done" between the product owner, the development team, and QA.

In Scrum, acceptance criteria fulfill three purposes:

- **Scope boundary:** they prevent scope creep by making explicit what is and is not included in the story.
- **Testability:** each criterion must be verifiable — either it passes or it does not, with no ambiguity.
- **Shared understanding:** they surface assumptions and edge cases before implementation begins, reducing rework.

Acceptance criteria are not test scripts. They describe the expected behavior from the user's perspective, not the technical steps to verify it.

---

## 2. The 3C Model

The 3C model (Card, Conversation, Confirmation) describes how a user story should evolve:

| Stage | Description |
|---|---|
| **Card** | A brief written representation of the story — a placeholder for a conversation, not a complete specification. |
| **Conversation** | The ongoing dialogue between the product owner, developers, and QA that explores the story's intent, constraints, and edge cases. |
| **Confirmation** | The acceptance criteria that emerge from the conversation and formally confirm when the story is done. |

Acceptance criteria belong to the Confirmation stage. They should not be written in isolation by the product owner — they are the output of the Conversation. Writing them before the conversation leads to criteria that capture assumptions rather than shared understanding.

---

## 3. Narrative Format vs. Gherkin

Two formats are commonly used to express acceptance criteria:

**Narrative (Given/When/Then prose):**

> Given [context], when [action], then [outcome].

This format is readable and works well for simple stories with few scenarios. It is less structured and can become ambiguous when scenarios multiply.

**Gherkin (structured scenario format):**

Gherkin uses keywords (`Feature`, `Scenario`, `Given`, `When`, `Then`) to express behavior as concrete, testable examples. It is the preferred format when:

- The story has multiple scenarios covering different paths (happy, unhappy, error).
- The team uses BDD tooling (Cucumber, SpecFlow, Behave) that can parse Gherkin.
- Scenarios need to serve as living documentation for QA and development simultaneously.

**When to choose each:**

| Situation | Recommended format |
|---|---|
| Simple story, 1–2 scenarios | Narrative prose |
| Story with 3+ scenarios or multiple paths | Gherkin |
| Team uses BDD automation | Gherkin |
| Non-technical stakeholders are the primary audience | Narrative prose |

---

## 4. Common Writing Errors

- **Too vague:** "The system should work correctly" — not testable. Criteria must be specific and measurable.
- **Technical implementation detail:** "The API must return a 200 status code" — describes implementation, not user outcome. Criteria should describe observable behavior.
- **Missing edge cases:** writing only the happy path leaves unhappy and error scenarios undiscovered until testing.
- **Written too late:** criteria written after development starts cannot guide implementation decisions.
- **Written in isolation:** criteria written only by the product owner without developer or QA input miss technical constraints and testability gaps.
- **Ambiguous language:** words like "fast", "easy", or "appropriate" are not verifiable. Replace with measurable terms.

---

## 5. Team Convention

When this team uses Gherkin to express acceptance criteria, output must follow the Markdown list format defined in [`rul-acceptance-criteria-generation.md`](../rules/rul-acceptance-criteria-generation.md).

Key points of the team convention:

- Output is always a Markdown list — never a fenced `gherkin` code block.
- `Then` steps describe only outcomes observable by the user or an external system.
- Scenarios are ordered: happy path, then unhappy path, then error path.
- Background is used when the same `Given` repeats across 3 or more scenarios.

For syntax details and anti-patterns, see [`kno-gherkin-syntax-reference.md`](./kno-gherkin-syntax-reference.md).

## Sources

- `📄` Sections 1–4 (definition, role in Scrum, 3C framework, narrative vs. Gherkin formats, common mistakes) — extracted from external references: scrummanager.com and scrum.org/resources.
- `🧠` Section 5 (team convention link to `rul-acceptance-criteria-generation.md`) — inferred from project context; not present literally in source URLs.
