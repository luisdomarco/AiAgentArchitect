---
name: ski-pattern-analyzer
description: Analyzes Audit and Score blocks in qa-report.md to detect recurring failure and success patterns across phases and entities. Returns structured pattern data and prioritized improvement targets. Use at CP-CLOSE to power the Optimizer.
---

# Pattern Analyzer

## Input / Output

**Input:**

- `qa_report_content`: complete content of `qa-report.md`
- `meta_report_content`: content of `qa-meta-report.md` (optional, for historical data)

**Output:**

- `failure_patterns`: array of `{ criterion, occurrences, affected_phases, score_impact }`
- `success_patterns`: array of `{ criterion, occurrences, phases }`
- `efficiency_issues`: `{ phase, regenerations }` for phases with regenerations > 1
- `dimension_trends`: `{ dimension, average_score }` per dimension
- `priority_targets`: ordered array of `{ target_entity, problem_description, priority }`

## Procedure

### Step 1 — Block extraction

Parse the `qa-report.md` and identify:

- All `## [Audit {phase}]` blocks → extract the compliance table
- All `### Score {phase}` blocks → extract scores per dimension
- `## [Re-audit — {entity} — {timestamp}]` blocks → treat them as additional audits

If `meta_report_content` exists, extract historical entries from previous sessions.

### Step 2 — Failure analysis

For each criterion with status ⚠️ or ❌:

1. Count in how many phases/entities that criterion appeared with failure
2. Identify which Rule is associated
3. Estimate impact on the score (⚠️ = medium impact, ❌ = high impact)

Order by: `occurrences × score_impact` (descending)

### Step 3 — Score analysis by dimension

Calculate the average of each dimension across all phases:

```
dimension_trend = {
  Completeness: average(all Completeness scores),
  Quality: average(all Quality scores),
  Compliance: average(all Compliance scores),
  Efficiency: average(all Efficiency scores)
}
```

Dimensions with average < 6.0 → high improvement priority.

### Step 4 — Efficiency analysis

For each phase, extract the number of regenerations from the Score block metrics.
Phases with regenerations > 1 → generate entry in `efficiency_issues`.

### Step 5 — Success analysis

For each criterion with status ✅ **in all phases where it was verified**:

1. Register it as a success pattern
2. Identify which Rule or design makes it consistent

### Step 6 — priority_targets generation

For each failure pattern, map to the system entity that should be modified:

| Failure type                                    | Probable target                 |
| ----------------------------------------------- | ------------------------------- |
| Criterion from rul-naming-conventions           | `rul-naming-conventions`        |
| Poorly formed checkpoint                        | `rul-checkpoint-behavior`       |
| Interview with multiple questions               | `rul-interview-standards`       |
| Incorrect entity format                         | `ski-entity-file-builder`       |
| Incomplete Blueprint / excess S2 regenerations  | `age-spe-architecture-designer` |
| Incomplete Discovery / missing trigger or steps | `age-spe-process-discovery`     |
| Low Completeness score                          | entity with most ⚠️ in S3       |

Order `priority_targets` by `occurrences × score_impact` → highest first.

## Examples

**Input (excerpt from qa-report.md):**

```
## [Audit S1] — 2026-02-20T21:25:14
| rul-naming-conventions | ✅ | ... |
| rul-checkpoint-behavior | ⚠️ | Missing option D |

## [Audit S3-age-spe-example]
| rul-naming-conventions | ❌ | Prefix 'agent-' instead of 'age-spe-' |
| rul-checkpoint-behavior | ✅ | ... |
```

**Output:**

```json
{
  "failure_patterns": [
    {
      "criterion": "Checkpoint with 4 options (rul-checkpoint-behavior)",
      "occurrences": 2,
      "affected_phases": ["S1", "S2"],
      "score_impact": "medium"
    },
    {
      "criterion": "Correct prefix in agent specialists (rul-naming-conventions)",
      "occurrences": 1,
      "affected_phases": ["S3"],
      "score_impact": "high"
    }
  ],
  "success_patterns": [
    {
      "criterion": "One question at a time (rul-interview-standards)",
      "occurrences": 3,
      "phases": ["S1"]
    }
  ],
  "priority_targets": [
    {
      "target_entity": "rul-checkpoint-behavior",
      "problem_description": "Missing option D in 2 of 3 phases",
      "priority": "high"
    },
    {
      "target_entity": "rul-naming-conventions",
      "problem_description": "❌ incorrect prefix in S3",
      "priority": "high"
    }
  ]
}
```

## Error Handling

- If `qa-report.md` has no Audit blocks: return `{ failure_patterns: [], success_patterns: [], priority_targets: [] }` with note "Insufficient data for analysis"
- If there is only one block (one checkpoint): partial analysis with explicit note
- If there are Re-audit blocks: include them in the analysis but mark them as `type: "re-audit"` to distinguish them
