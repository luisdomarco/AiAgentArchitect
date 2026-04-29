---
name: ski-help-router
description: Renders a context-aware menu of next actions based on the current project phase, Memory state, and active layers. Reads repository/entities-registry.csv and menus.csv to compose options, filtering out any that require a layer not currently enabled. Use when the user invokes /help, asks "what can I do now?", or seems lost during a workflow phase.
---

# Help Router

Renders the right menu for the right moment. Adapted to the AiAgentArchitect layer model and the 3-platform output structure.

## Input

- `context_hint`: optional string identifying the context the caller wants help for. If absent, the skill infers the context from Memory + filesystem state.
- `verbose`: optional boolean. When true, also explain why each option is shown or filtered.

## Output

A markdown block to render in chat:

```
You're at: <inferred or hinted context>

What you can do now:
  A) <option label> — <one-line description>
  B) <option label> — <one-line description>
  ...

Run `/help --verbose` for filter rationale.
```

## Procedure

### Step 1 — Determine context

If `context_hint` is provided, use it directly. Otherwise:

1. Read `config/manifest.yaml` to discover which layers are active.
2. If the Memory layer is active, find the most recent file in `memory/` matching the current project. Extract `last_checkpoint`, `status`, `mode`.
3. Map state → context:
   - No memory file present → `root-no-project`
   - `last_checkpoint = CP-S0` and `status = in-progress` → `cp-s0-pending`
   - Same pattern for CP-S1, CP-S2, CP-S3-N, CP-CLOSE
   - `status = paused` → `paused-resumable`
   - `status = completed` → `completed-options`
4. If state is ambiguous, fall back to `mid-step`.

### Step 2 — Look up the context menu

Read `menus.csv` (sibling file in this skill directory). Find the row where `context` matches the inferred context. Each row contains pipe-separated options of the form `label|description|action|layer_required`.

If no row matches, fall back to the `default` row.

### Step 3 — Filter options by active layers

For each option:
- If `layer_required` is empty, include the option.
- If `layer_required` is non-empty, include the option only if that layer is `enabled: true` in `config/manifest.yaml`.

### Step 4 — Append entity-discovery options (if registry available)

If `repository/entities-registry.csv` exists, surface the top 3 most-relevant entities for the current context (e.g. at CP-S2 surface `ski-entity-selector`, `ski-diagram-generator`). The skill uses simple heuristics: matches on entity description against the context label.

If the registry does not exist, append a single option:

```
*) Build the entities registry — `python3 .agents/layers/help-router/scripts/build-registry.py`
```

### Step 5 — Render menu

Compose a markdown block as in the Output section above. Letter the options A, B, C, ... Use `*)` for utility / housekeeping options. Keep each option to one line.

When `verbose` is true, append a section:

```
Filtered out:
  - <option> — requires layer `<layer-id>` (not active)
  - ...
```

## Error handling

- `manifest.yaml` missing → show the error and direct the user to run `node scripts/install.mjs` or `bash install.sh`.
- `menus.csv` malformed → show the parser error and offer to fall back to a hard-coded minimal menu (`Run /wor-agentic-architect`, `See README.md`).
- All other I/O errors → log and degrade to the minimal menu.

## Notes on context inference

The skill reads but never writes Memory or the ledger. It only reads them. The orchestrator owns mutation of those files; this skill is purely advisory.
