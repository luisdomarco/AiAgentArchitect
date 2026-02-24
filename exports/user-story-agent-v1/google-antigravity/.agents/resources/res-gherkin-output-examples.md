---
name: res-gherkin-output-examples
description: Annotated Gherkin acceptance criteria examples in Markdown list format, covering all scenario paths, Scenario Outline, Background at Rule level, e-commerce domain example, and anti-pattern corrections.
tags: [gherkin, examples, acceptance-criteria, bdd, markdown-list]
---

All examples in this document use the team's Markdown list format. Fenced `gherkin` blocks are never used in team output. See [`rul-acceptance-criteria-generation.md`](../rules/rul-acceptance-criteria-generation.md) for format rules.

---

## 1. User Login — Background + All 3 Paths

This example demonstrates a Feature with a Background and all three scenario paths: happy, unhappy, and error.

- **Feature:** User Login

- **Background:**
  - Given a registered user exists

- **Scenario:** Successful login with valid credentials
  - Given the user is on the login page
  - When the user enters valid credentials
  - Then the user is redirected to the dashboard
  - And the session is active

- **Scenario:** Login blocked for inactive account
  - Given the user account is inactive
  - When the user enters valid credentials
  - Then a message indicates the account is not active
  - And the user remains on the login page

- **Scenario:** Login fails with invalid password
  - Given the user is on the login page
  - When the user enters an incorrect password
  - Then an error message is displayed
  - And the password field is cleared

- **Scenario:** Login fails after 5 consecutive failed attempts
  - Given the user has failed to log in 4 times
  - When the user enters an incorrect password again
  - Then the account is locked
  - And a notification is sent to the registered email

---

## 2. Scenario Outline in Markdown List Format

This example shows how to express a Scenario Outline as a Markdown list. Parameters are shown in angle brackets and an Examples table follows.

- **Feature:** Discount Application

- **Scenario Outline:** Discount applied based on user tier
  - Given the user has tier \< tier \>
  - When the user adds a product to the cart
  - Then a discount of \< discount \> is applied to the total

  | tier     | discount |
  |----------|----------|
  | silver   | 5%       |
  | gold     | 10%      |
  | platinum | 15%      |

---

## 3. Background at Rule Level (Gherkin v6)

In Gherkin v6, a `Rule` keyword groups scenarios that illustrate the same business rule. A `Background` can be scoped to a `Rule` block instead of the entire `Feature`.

- **Feature:** Inventory Management

- **Rule:** Stock cannot go below zero

  - **Background:**
    - Given the product has 1 unit in stock

  - **Scenario:** Purchase fails when stock is zero after reservation
    - When a customer attempts to purchase 2 units
    - Then the purchase is rejected
    - And a low-stock warning is displayed

  - **Scenario:** Purchase succeeds when exact stock is available
    - When a customer attempts to purchase 1 unit
    - Then the purchase is confirmed
    - And the stock level shows 0 units

---

## 4. E-commerce Domain Example — Business Language vs. Implementation

This example contrasts correct domain language with implementation-leaning language.

**Correct (domain language):**

- **Feature:** Order Checkout

- **Background:**
  - Given a registered customer with items in the cart

- **Scenario:** Successful checkout with valid payment
  - Given the customer is on the checkout page
  - When the customer submits a valid payment method
  - Then the order is confirmed
  - And the customer receives an order confirmation email

- **Scenario:** Checkout fails when payment is declined
  - Given the customer is on the checkout page
  - When the customer submits a declined payment method
  - Then the order is not placed
  - And the customer sees a payment failure message

**Incorrect (implementation language — do not use):**

- **Scenario:** Checkout updates the orders table
  - Given the user has items in the cart
  - When the POST request to /api/orders is sent
  - Then the HTTP response code is 201
  - And the orders table has a new row

Reason this is incorrect: steps describe HTTP mechanics and database state rather than observable business outcomes.

---

## 5. Anti-pattern Corrections

The following table shows the 5 most critical anti-patterns and their corrections in Markdown list format.

| # | Anti-pattern | Problem | Corrected Scenario Step |
|---|---|---|---|
| 1 | `Then the database is updated` | Validates internal state, not observable outcome. | `Then the user sees a confirmation message` |
| 2 | `Given the user clicks the login button` | `Given` describes an action, not an initial state. | `Given the user is on the login page` |
| 3 | `When the user fills the form and clicks submit` | Two actions chained in one step with "and". | Split: `When the user fills in the form` + `And the user clicks submit` |
| 4 | Scenario with 10+ steps | Covers too much behavior in one scenario. | Divide into focused scenarios; move shared setup to Background. |
| 5 | All scenarios are happy path only | Critical edge cases are undiscovered until QA or production. | Add explicit unhappy path and error path scenarios. |

## Sources

- `📄` Sections 1–4 (User Login example with 3 paths, Scenario Outline, Background at Rule level, Doc Strings and Data Tables examples) — adapted from `raw-docs/rul-acceptance-criteria-generation.md` and `raw-docs/kno-gherkin-syntax.md`.
- `🧠` Section 4 e-commerce domain example (Shopping Cart Add Item) — inferred domain example not present in source documents; added to illustrate domain language vs. implementation language.
- `🧠` Section 5 anti-pattern corrections table — synthesized from anti-patterns listed in `raw-docs/kno-gherkin-syntax.md`; the correction column format is an inferred enrichment.
