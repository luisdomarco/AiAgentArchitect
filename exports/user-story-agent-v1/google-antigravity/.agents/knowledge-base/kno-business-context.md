---
description: Structured template for capturing the business context of a product or project. Defines product purpose, user roles, domain glossary, functional modules, business constraints, and known edge cases.
tags: [business-context, product, domain, glossary, roles, modules]
---

## Table of Contents

- [1. Product Overview](#1-product-overview)
- [2. Functional Description](#2-functional-description)
- [3. Users and Roles](#3-users-and-roles)
- [4. Domain Glossary](#4-domain-glossary)
- [5. Functional Modules](#5-functional-modules)
- [6. Known Business Constraints](#6-known-business-constraints)
- [7. Frequent Edge Cases](#7-frequent-edge-cases)

---

> **Note:** This document is a structured template. Replace each placeholder value with the actual information for your product or project before using this file as context for acceptance criteria generation.

---

## 1. Product Overview

| Field | Value |
|---|---|
| **Product name** | _[Enter product name]_ |
| **Product type** | _[e.g., web application, mobile app, internal tool, API]_ |
| **Current version** | _[e.g., v1.0, MVP, beta]_ |
| **Primary objective** | _[One sentence describing the core problem the product solves]_ |

---

## 2. Functional Description

_[2–4 sentences describing what the product does, who it serves, and what value it delivers. Focus on business outcomes, not technical implementation.]_

Example: "The product allows operations teams to track real-time inventory across multiple warehouses. It provides automated alerts when stock levels fall below configured thresholds and integrates with the purchasing system to trigger restocking orders."

---

## 3. Users and Roles

| Role | Description | Key permissions or limitations |
|---|---|---|
| _[Role 1]_ | _[Who this person is and what they do]_ | _[What they can or cannot do in the system]_ |
| _[Role 2]_ | _[Who this person is and what they do]_ | _[What they can or cannot do in the system]_ |
| _[Role 3]_ | _[Who this person is and what they do]_ | _[What they can or cannot do in the system]_ |

---

## 4. Domain Glossary

List terms specific to this business domain that must be used consistently in acceptance criteria and user stories.

| Term | Definition |
|---|---|
| _[Term 1]_ | _[Business definition — not technical implementation]_ |
| _[Term 2]_ | _[Business definition — not technical implementation]_ |
| _[Term 3]_ | _[Business definition — not technical implementation]_ |

---

## 5. Functional Modules

List the main functional areas of the product. These correspond to the grouping structure used in Gherkin `Feature` and `Rule` blocks.

| Module | Description | Key behaviors |
|---|---|---|
| _[Module 1]_ | _[What this module handles]_ | _[2–3 key behaviors in this module]_ |
| _[Module 2]_ | _[What this module handles]_ | _[2–3 key behaviors in this module]_ |
| _[Module 3]_ | _[What this module handles]_ | _[2–3 key behaviors in this module]_ |

---

## 6. Known Business Constraints

List rules, policies, or external regulations that constrain how the product must behave. These feed directly into unhappy path and error path scenarios.

- _[Constraint 1 — e.g., "Users cannot delete records that have been invoiced."]_
- _[Constraint 2 — e.g., "Discounts cannot exceed 30% without manager approval."]_
- _[Constraint 3 — e.g., "All transactions must comply with GDPR data retention policy."]_

---

## 7. Frequent Edge Cases

List recurring edge cases that have appeared in previous sprints or that the product owner anticipates. These should be covered explicitly in acceptance criteria.

- _[Edge case 1 — e.g., "User attempts an action while their session has expired."]_
- _[Edge case 2 — e.g., "Two users attempt to modify the same record simultaneously."]_
- _[Edge case 3 — e.g., "Input field receives a value at the exact boundary limit."]_

## Sources

- `🧠` All sections (Domain Overview, Key Entities, Business Rules, Glossary, Modules, Constraints, Edge Cases) — fully inferred structure. The source file `raw-docs/kno-business-context.md` was empty; this file provides a ready-to-fill template.
