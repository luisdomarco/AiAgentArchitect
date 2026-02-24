# Framework: Acceptance Criteria Writing Patterns

This document defines the systematic patterns an AI must follow when drafting acceptance criteria (AC) for features that involve **permissions**, **field states**, **calculations**, and **user actions**. It is designed to be consumed as a system prompt or context injection.

---

## Core Principle

Every acceptance criterion must cover **not just the happy path**, but the full behavioral matrix derived from the combination of axes that govern the scenario. Before drafting ACs for any feature, identify which axes apply and generate scenarios for every meaningful combination.

---

## Axis 1 — Permission Model

### 1A. Simple binary permission (has / does not have)

When a feature is gated by a single permission:

| State | Expected behavior |
|-------|-------------------|
| Permission = Yes | Feature is visible and operable |
| Permission = No / Empty | Feature is hidden. No partial visibility. |

**Rule:** Always write both scenarios, even when the "No" case seems obvious.

---

### 1B. Hierarchical permissions (View → Edit)

When a section has a View permission that is prerequisite for Edit:

| View | Edit | Expected behavior |
|------|------|-------------------|
| No | No | Section is hidden |
| No | Yes | Section is hidden (Edit is irrelevant without View) |
| Yes | No | Section is visible, all fields are disabled (read-only) |
| Yes | Yes | Section is visible and fully editable (happy path) |

**Rule:** Always write the `View=No + Edit=Yes` scenario explicitly. It is a real configuration that can occur in production and must not behave differently from `View=No + Edit=No`.

---

### 1C. Tiered permissions with a gate + sub-actions (List → Create / Edit / Remove)

When access to a section requires a "List" (or equivalent gate) permission, and sub-actions have their own independent permissions:

| List | Create | Edit | Remove | Expected behavior |
|------|--------|------|--------|-------------------|
| No | Any | Any | Any | Section is hidden. Sub-permissions are irrelevant. |
| Yes | No | No | No | Section visible, items listed. No action controls shown. |
| Yes | Yes | No | No | Section visible. Can add. Cannot edit or remove. |
| Yes | No | Yes | No | Section visible. Can edit existing. Cannot add or remove. |
| Yes | No | No | Yes | Section visible. Can remove. Cannot add or edit. |
| Yes | Yes | Yes | Yes | Full access (happy path) |
| Yes | Partial mix | Partial mix | Partial mix | Only controls for granted sub-permissions are visible/enabled |

**Rule:** Each sub-permission must independently control its own UI control (button, action, field). The absence of one sub-permission must not block unrelated sub-permissions. Always include a "List=Yes but all sub-permissions=No" scenario.

---

### 1D. Scope-based permissions (Owner / Yes / No / Empty)

When permissions have a scope qualifier (e.g., Owner = only own records, Yes = all records):

| Permission | Expected behavior |
|------------|-------------------|
| No / Empty | Section hidden or action blocked |
| Owner | Visible/operable only for own records |
| Yes | Visible/operable for all records |

**Rule:** Write scenarios for each scope level if the feature supports multi-user or multi-record contexts.

---

## Axis 2 — Field / Data State

When a feature depends on data that may or may not exist, cover all states:

| State | Definition | Expected behavior |
|-------|------------|-------------------|
| Empty / Never filled | No value has ever been saved | Fields show placeholder or blank. Calculations that depend on them are skipped. |
| Partially filled | Some required fields have values, others do not | Document which partial combinations block vs. allow calculations. Each field dependency must be explicit. |
| Fully filled | All required fields have values | Full calculation and display. |
| Modified (dirty) | Existing value changed in the current session but not yet saved | UI reflects the new value. Saving propagates the change. Discarding reverts to original. |
| Saved | Modified value confirmed | Persisted to the appropriate storage level (simulation, customer profile, etc.). |

**Rule:** Always document where data is stored (e.g., customer profile vs. simulation level) and the propagation direction (who writes to whom on save).

---

## Axis 3 — Calculation / Formula Result

When a feature computes a value from inputs:

| Input completeness | Expected behavior |
|--------------------|-------------------|
| All required inputs present and valid | Formula runs. Result displayed. Dependent indicators updated. |
| One or more required inputs missing | Formula does not run. Result field is empty or shows a placeholder. No indicators. |
| Input modified after initial calculation | Formula recalculates immediately. All dependent fields and indicators update. |
| Input cleared after calculation | Result field is cleared. Dependent indicators are removed. |

**Rule:** Be explicit about which fields are "required" for the formula. If the formula has optional components (e.g., co-owner data), define what happens when those optional parts are absent vs. present.

---

## Axis 4 — Real-time Reactivity

When a feature supports real-time or instant recalculation:

| Trigger | Expected behavior |
|---------|-------------------|
| Any parameter change | Recalculation occurs immediately, without page refresh |
| Rule/configuration change that removes applicable terms | Previously shown terms disappear. UI updates to reflect new set. |
| Rule/configuration change that results in zero matching terms | Empty state is shown with an explanatory message. No empty columns or orphaned rows. |
| Parameter change that makes a previously invalid configuration valid | New results appear immediately. |

**Rule:** Always include a "no matching results" scenario. It is frequently omitted and frequently broken.

---

## Axis 5 — Visual Feedback / Affordability Indicators

When UI provides visual signals based on calculated thresholds:

| Condition | Expected behavior |
|-----------|-------------------|
| Value within acceptable threshold | Positive or neutral indicator (or no indicator) |
| Value exceeds threshold | Warning or negative visual indicator |
| Threshold not calculable (missing inputs) | No indicator shown. Neither positive nor negative. |
| Threshold changes due to input update | Indicator updates immediately to reflect new threshold |

**Rule:** Explicitly define what "no indicator" looks like (blank, hidden element, neutral color) so it is not confused with a bug.

---

## Axis 6 — Data Persistence & Propagation

When data can be stored at multiple levels (e.g., customer profile and simulation):

| Action | Expected behavior |
|--------|-------------------|
| Open simulation with pre-existing customer data | Data is pre-filled from customer profile |
| Open simulation with no existing customer data | Fields are empty, no pre-fill |
| Modify data in simulation and save | Changes propagate to customer profile |
| Modify data in simulation and discard | Changes do not propagate. Original customer profile data is preserved. |
| Customer profile updated externally after simulation is open | Define whether the simulation refreshes or not (typically: it does not until re-opened) |

**Rule:** Always document propagation direction explicitly: "simulation → customer profile on save" or "customer profile → simulation on open". Do not assume this is obvious.

---

## Axis 7 — Selective Actions (Send, Compare, Export)

When a user can select a subset of items for an action:

| Selection | Expected behavior |
|-----------|-------------------|
| 0 items selected | Action button is disabled or not available |
| 1 item selected | Action runs with single-item output |
| N items selected (homogeneous) | Action runs, output reflects all N |
| N items selected (heterogeneous mix, e.g. different simulations, different insurance states) | Output correctly reflects each item's own configuration |
| Combination: whole simulation + specific terms from another | Output merges both without duplication or conflict |
| Filtered selection (e.g., only terms with insurance) | Only matching terms included. Excluded terms are not present in output. |

**Rule:** Write a scenario for the most complex mixed-selection case that the feature supports. If the feature has not defined behavior for it, flag it as a gap before writing ACs.

---

## Structural Template for Scenarios

Use this template for every scenario. Never skip the `Then` clauses for negative outcomes.

```gherkin
- **Scenario:** [Short descriptive title]
  - Given [precondition: permission state, data state, system state]
  - And [additional precondition if needed]
  - When [user action or system event]
  - Then [primary expected outcome]
  - And [secondary outcome: UI update, recalculation, propagation, indicator]
  - And [tertiary outcome if relevant]
```

For **unhappy paths**, replace `Then` with the blocking or hidden behavior:

```gherkin
  - Then [feature/section/action] is [hidden / disabled / blocked]
  - And no [calculation / indicator / propagation] occurs
```

---

## Scenario Grouping Convention

Group scenarios under their Feature. Within each Feature, order scenarios as:

1. **Happy path** (full permissions, full data, expected result)
2. **Partial access** (some permissions, some data — document each meaningful partial combination)
3. **Denied access** (no permissions, hidden)
4. **Edge / boundary cases** (missing data, no matching rules, dirty state, etc.)

---

## Pre-drafting Checklist

Before writing ACs for any feature, answer these questions:

1. **Does this feature have permissions?**
   - Is it a simple binary, a View→Edit hierarchy, or a List→Sub-action tier?
   - Are there scope qualifiers (Owner, Yes, No)?

2. **Does this feature depend on field data?**
   - Which fields are required vs. optional for the feature to function?
   - What happens if required fields are partially filled?
   - Where is data stored and in which direction does it propagate on save/discard?

3. **Does this feature compute a value?**
   - What inputs are required?
   - What triggers recalculation?
   - What is the behavior when inputs are missing or cleared?

4. **Does this feature show visual feedback?**
   - What are the threshold conditions?
   - What does "no indicator" look like?

5. **Does this feature support real-time updates?**
   - What is the "no matching results" state?
   - Is there a loading/transition state?

6. **Does this feature allow selective actions?**
   - What is the minimum and maximum selection?
   - What is the most complex heterogeneous selection case?
   - What happens with 0 items selected?

7. **Are there gaps in the spec?**
   - If a combination of axes produces a state that is not defined in the user story, flag it explicitly as "UNDEFINED — requires clarification" rather than inventing behavior.

---

## Anti-patterns to Avoid

| Anti-pattern | Correct approach |
|-------------|-----------------|
| Only writing happy path | Always write denied/partial/edge scenarios |
| Writing `View=No + Edit=Yes` as identical to `View=No + Edit=No` without a scenario | Write it explicitly even if behavior is identical — it is a real configuration |
| Assuming "partial data" behaves like "no data" | Define partial state behavior for every formula or calculation |
| Omitting the "no matching results" state for real-time features | Always include it |
| Describing propagation direction vaguely ("data is saved") | Always specify source and destination explicitly |
| Writing a scenario for "can select N items" without defining the heterogeneous mix case | Always include the most complex selection scenario the feature supports |
| Using "etc." or "and so on" in a Then clause | Every Then clause must be fully explicit |
