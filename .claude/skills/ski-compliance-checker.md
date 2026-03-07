---
name: ski-compliance-checker
description: Reads the current content of active Rules from disk paths, extracts compliance criteria, and verifies them against the provided phase output. Returns a structured compliance table. Use after any phase checkpoint to power the audit report.
user-invocable: false
allowed-tools: Read Glob
---

# Compliance Checker

## Input / Output

**Input:**

- `rules_content`: array of objects `{ rule_name, content }` with the current content of each Rule read from disk
- `output_to_audit`: the content of the phase output (handoff JSON, entity file, etc.)
- `phase`: identifier of the audited phase (`S1 | S2 | S3-N`)
- `reasoning_trace`: (Optional) The agent's thought log structured in `<sys-eval>`.

**Output:**

- `compliance_table`: array of objects `{ criterion, rule, status, evidence }`
- `summary`: `{ total: N, passed: X, warnings: Y, failed: Z }`

## Procedure

### Step 1 — Criteria extraction

For each Rule in `rules_content`:

1. Identify the `## Hard Constraints` section → mandatory criteria (failure = ❌)
2. Identify the `## Soft Constraints` section → recommended criteria (failure = ⚠️)
3. Extract each criterion as a verifiable condition

### Step 2 — Verification

For each extracted criterion:

1. Search in `output_to_audit` and in `reasoning_trace` for compliance or non-compliance evidence
2. Assign status:
   - `✅` — The output explicitly complies with the criterion with clear evidence. If the criterion required reasoning (Hard Constraint LLM), the `reasoning_trace` contains proof of obedience.
   - `⚠️` — The output partially complies or evidence is ambiguous (Soft Constraint). Or if the output complies but the agent omitted the reasoning dictated by `rul-strict-compliance`.
   - `❌` — The output does not comply with the criterion (Hard Constraint violated) or blatant cognitive negligence.
3. Record the concrete evidence: verbatim quote from the output or trace that justifies the status.

### Step 3 — Table composition

```markdown
| Criterion                        | Rule       | Status     | Evidence                           |
| -------------------------------- | ---------- | ---------- | ---------------------------------- |
| {short description of criterion} | {rul-name} | {✅/⚠️/❌} | {quote or description of evidence} |
```

### Step 4 — Summary generation

```json
{
  "total": N,
  "passed": X,
  "warnings": Y,
  "failed": Z
}
```

## Examples

**Simplified input:**

```
rules_content: [
  { rule_name: "rul-naming-conventions", content: "## Hard Constraints\n- All agents must use prefix age-spe- or age-sup-\n- Names in kebab-case, max. 40 characters..." }
]
output_to_audit: "name: age-architecture-designer\ndescription: ..."
```

**Output:**

```json
{
  "compliance_table": [
    {
      "criterion": "Correct prefix for agent specialist",
      "rule": "rul-naming-conventions",
      "status": "❌",
      "evidence": "The name 'age-architecture-designer' uses 'age-' instead of 'age-spe-'"
    }
  ],
  "summary": { "total": 1, "passed": 0, "warnings": 0, "failed": 1 }
}
```

## Error Handling

- If a Rule has no `## Hard Constraints` or `## Soft Constraints` section: record `⚠️ Rule without verifiable criteria — check format`
- If output_to_audit is empty or malformed: record `❌ Empty or unstructured output — not auditable`
- If compliance cannot be determined with certainty: assign `⚠️` with evidence `"Not determinable with available output"`
