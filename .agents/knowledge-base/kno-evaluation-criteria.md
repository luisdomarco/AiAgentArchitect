---
description: Criteria, weights and evaluation thresholds for the QA Layer. Defines the scoring rubric per dimension and per entity type, phase weights for the global scorecard, and quality level thresholds.
tags: [qa, evaluation, rubric, scoring]
---

## Table of Contents

1. General rubric (per dimension)
2. Adjustments per entity type (S3)
3. Phase weights for the global scorecard
4. Quality level thresholds
5. Penalties and bonuses

---

## Documentation

### 1. General rubric (per dimension)

The standard rubric applies to all phases. Four dimensions with weighted scores:

| Dimension        | Weight | What it measures                                                        |
| ---------------- | ------ | ----------------------------------------------------------------------- |
| **Completeness** | 30%    | Does the output contain all required elements for its phase?            |
| **Quality**      | 30%    | Is the content specific and contextualized, not generic or placeholder? |
| **Compliance**   | 25%    | Did the output pass the Audit without ⚠️ alerts or ❌ failures?         |
| **Efficiency**   | 15%    | How many regenerations/iterations did the process require?              |

**Total score = (Completeness × 0.30) + (Quality × 0.30) + (Compliance × 0.25) + (Efficiency × 0.15)**

---

### 2. Adjustments per entity type (S3)

In S3 (Entity Implementation), Completeness verifies that all required sections of the entity type are present and non-empty:

| Type                          | Required sections for Completeness                                                                                         |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Workflow (`wor-`)             | Role & Mission, Context, Goals, Tasks, Agents, Workflow Sequence, Checkpoints, Input, Output, Rules, Definition of success |
| Agent Specialist (`age-spe-`) | Role & Mission, Context, Goals, Tasks, Skills, Execution Protocol, Input, Output, Rules, Definition of success             |
| Skill (`ski-`)                | Input/Output, Procedure, Examples, Error Handling                                                                          |
| Rule (`rul-`)                 | Context, Hard Constraints, Soft Constraints                                                                                |
| Knowledge-base (`kno-`)       | Table of Contents, Documentation (≥2 subsections)                                                                          |
| Command (`com-`)              | System prompt with at least 3 structured instructions                                                                      |

For Quality in S3, signals of high quality:

- Descriptions of >40 words with real process context (not type description)
- Goals with explicit expected results, not just intention verbs
- Execution Protocol with branches and error handling (for `complex`)
- Examples in Skills that reflect the real use case of the system

---

### 3. Phase weights for the global scorecard

The global scorecard weights the three process phases:

| Phase                      | Weight | Justification                                                             |
| -------------------------- | ------ | ------------------------------------------------------------------------- |
| S1 — Process Discovery     | 25%    | Sets the foundation, but errors here are usually detected and fixed in S2 |
| S2 — Architecture Design   | 35%    | Defines the complete structure; errors here carry over to S3              |
| S3 — Entity Implementation | 40%    | This is the actual final output. Errors here directly affect usability    |

**Global score = (Score S1 × 0.25) + (Score S2 × 0.35) + (Score S3 × 0.40)**

If the process used Express Mode (without formal S2), redistribute: S1=35%, S3=65%.

---

### 4. Quality level thresholds

| Score     | Level          | Interpretation                                                      |
| --------- | -------------- | ------------------------------------------------------------------- |
| ≥ 8.0     | **Excellent**  | The process was solid. Few or no urgent improvements.               |
| 6.0 – 7.9 | **Good**       | Functional result with non-critical improvement opportunities.      |
| 4.0 – 5.9 | **Improvable** | There are problematic patterns worth addressing.                    |
| < 4.0     | **Critical**   | The process has structural failures. The Optimizer issues an alert. |

---

### 5. Penalties and bonuses

**Automatic penalties:**

- ❌ Hard Constraint violated in Audit: -1.0 point in Compliance score per failure
- Unfilled placeholders (`[description]`, `[name]`) detected: -0.5 in Quality per each
- More than 3 regenerations on the same S3 entity: Efficiency = 1.0 (does not penalize Completeness or Quality)

**Bonuses:**

- No automatic bonuses — the maximum score is 10 without extras
- In the interpretation text, the Evaluator may highlight notable positive aspects

---

### 6. Efficiency Scoring — reference table

| Regenerations in the phase | Efficiency Score |
| -------------------------- | ---------------- |
| 0                          | 10.0             |
| 1                          | 8.0              |
| 2                          | 6.0              |
| 3                          | 4.0              |
| 4                          | 2.0              |
| ≥ 5                        | 1.0              |

Adjustment iterations (checkpoint option B, without regenerating from scratch) count as 0.3 each, added to the regeneration score.
