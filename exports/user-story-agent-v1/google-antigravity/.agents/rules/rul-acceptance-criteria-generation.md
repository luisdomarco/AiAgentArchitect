---
trigger: always_on
description: Define formato, estructura y restricciones estrcitas para la salida de criterios de aceptación en Markdown list.
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

- Siempre incluir un bloque global al inicio con `Feature` y `Background` (si hay precondiciones comunes).
- Siempre agrupar scenarios por módulo o tema de producto cuando la historia abarca varias áreas.
- Siempre respetar este orden dentro de los bloques temáticos: 1) Happy path, 2) Unhappy path, 3) Error path.
- Siempre usar esta estructura de lista Markdown (con viñetas de lista, espacios e indentación strictos):
  - `- **Feature:** `
  - `- **Background:** ` (si aplica) con sub-items indentados dos espacios: `  - Given`
  - `- **Scenario:** ` con sub-items indentados dos espacios: `  - Given`, `  - When`, `  - Then`
- Siempre utilizar `Background` si el mismo `Given` se repite en 3 o más escenarios del bloque.
- Siempre utilizar `Scenario Outline` si los pasos son idénticos variando solo datos, con 3 o más combinaciones.
- Siempre preferir escenarios separados cuando describen cualitativamente diferentes situaciones.

## Examples

**Correct output (User Login — all 3 paths):**

```markdown
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
```

**Incorrect format:**
Usar un bloque de código `gherkin` está prohibido, la salida debe ser la lista plana Markdown.
