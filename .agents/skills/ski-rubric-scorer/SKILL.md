---
name: ski-rubric-scorer
description: Applies a weighted rubric (Completeness 30%, Quality 30%, Compliance 25%, Efficiency 15%) to score a process phase from 0-10 per dimension. Uses audit results and metrics as input, returns a structured scorecard.
---

# Rubric Scorer

## Input / Output

**Input:**

- `phase`: phase identifier (`S1 | S2 | S3 | global`)
- `compliance_summary`: `{ total, passed, warnings, failed }` from the Audit
- `phase_output`: the output generated in the phase (handoff JSON or entity)
- `metrics`: `{ regenerations: N, iterations: N }`
- `criteria_config`: weight configuration from `kno-evaluation-criteria` (optional, uses defaults if not provided)

**Output:**

- `scorecard`: array of `{ dimension, score, weight, partial }`
- `total_score`: number between 0-10
- `level`: `Excellent | Good | Improvable | Critical`
- `interpretation`: 1-2 context sentences

## Procedure

### Step 1 — Completeness Scoring (weight: 30%)

Verify that the output contains all required elements for the phase:

| Phase  | Required elements                                                                              |
| ------ | ---------------------------------------------------------------------------------------------- |
| S1     | process.name, process.objective, process.steps, process.trigger, process.input, process.output |
| S2     | entities (non-empty array), creation_order, architecture_diagram                               |
| S3     | file with all sections of the format for its entity type                                       |
| global | process-overview.md with all its sections                                                      |

Scoring: `(present_elements / required_elements) × 10`

### Step 2 — Quality Scoring (weight: 30%)

Evaluate whether the content is specific vs. generic. Signals of high quality:

- Descriptions of >50 words with real process context
- Goals with concrete action verbs (not generic "manage", "ensure")
- Tasks with specific steps, not generic bullets
- Examples in Skills that correspond to the real context

Signals of low quality:

- Unfilled placeholders (`[description]`, `[name]`)
- Single-line descriptions in `complex` entities
- Literal repetition of the objective as the description

Scoring: `0`=all generic, `5`=half specific, `10`=all specific and contextualized

### Step 3 — Compliance Scoring (weight: 25%)

Directly from the Audit Report:

```
compliance_score = (passed / total) × 10
```

If there are `❌` (Hard Constraints): additional penalty of -1 point per failure.

### Step 4 — Efficiency Scoring (weight: 15%)

| Regenerations | Score |
| ------------- | ----- |
| 0             | 10    |
| 1             | 8     |
| 2             | 6     |
| 3             | 4     |
| >3            | 2     |

### Step 5 — Weighted total score

```
total_score = (completeness × 0.30) + (quality × 0.30) + (compliance × 0.25) + (efficiency × 0.15)
```

Levels:

- `≥ 8.0` → **Excellent**
- `6.0 – 7.9` → **Good**
- `4.0 – 5.9` → **Improvable**
- `< 4.0` → **Critical**

### Step 6 — Interpretation

Generate 1-2 sentences explaining the result in an actionable way:

- If score is high: what worked well
- If score is low: which dimension dragged the result the most and why

## Examples

**Input:**

```json
{
  "phase": "S1",
  "compliance_summary": { "total": 5, "passed": 4, "warnings": 1, "failed": 0 },
  "metrics": { "regenerations": 1, "iterations": 3 },
  "phase_output": { "process": { "name": "...", "objective": "...", "steps": [...] } }
}
```

**Output:**

```json
{
  "scorecard": [
    {
      "dimension": "Completeness",
      "score": 9.0,
      "weight": "30%",
      "partial": 2.7
    },
    { "dimension": "Quality", "score": 7.5, "weight": "30%", "partial": 2.25 },
    {
      "dimension": "Compliance",
      "score": 8.0,
      "weight": "25%",
      "partial": 2.0
    },
    { "dimension": "Efficiency", "score": 8.0, "weight": "15%", "partial": 1.2 }
  ],
  "total_score": 8.15,
  "level": "Excellent",
  "interpretation": "The Discovery captured all key process elements. The content quality is solid although it could be more specific in describing decisions."
}
```

## Error Handling

- If `compliance_summary` is empty: use `{ total: 1, passed: 0, warnings: 0, failed: 1 }` and record note in interpretation
- If `criteria_config` is not provided: use default weights (30/30/25/15)
- If the phase output does not allow evaluating Completeness: assign score 5 with note "Partial output — approximate evaluation"
