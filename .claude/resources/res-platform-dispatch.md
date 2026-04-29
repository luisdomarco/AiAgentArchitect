---
name: res-platform-dispatch
description: Lazy-loading dispatch table for platform-specific resources. Maps each target platform to its template resource, output skill, and conventions resource. Read by age-spe-entity-builder once at session start to determine which resources to load based on target_platforms from the S0 handoff.
tags: [platform, dispatch, lazy-loading, templates]
---

## Purpose

This resource enables lazy-loading of platform-specific knowledge. Instead of loading all platform templates at the start of every session, the entity builder reads only the resources corresponding to the platforms selected in Step 0 (`target_platforms` field in the S0 handoff JSON).

**When to read this file:** At the beginning of Step 3 (entity generation), before generating the first entity. Read it once, then follow the dispatch table for the session's `target_platforms`.

---

## Dispatch Table

| Platform ID    | Template Resource                           | Output Skill                                | Conventions Resource         |
| -------------- | ------------------------------------------- | ------------------------------------------- | ---------------------------- |
| `antigravity`  | `res-entity-templates-behavioral.md` (behavioral entities) or `res-entity-templates-support.md` (support entities) | _(none — GA is the source of truth)_        | _(none)_                     |
| `claude-code`  | `res-entity-templates-claude-code.md`       | `ski-output-claude-code`                    | _(none)_                     |
| `codex`        | `res-entity-templates-codex.md`             | `ski-output-codex`                          | `res-codex-conventions.md`   |

> **Note:** `codex` is opt-in for exports (not included in the default `target_platforms`). It can be generated on demand via `ski-platform-exporter` or by explicitly adding `"codex"` to `target_platforms` at Step 0.

---

## Lazy-Loading Protocol

### At the start of Step 3

1. Read `target_platforms` from the S2 handoff JSON (propagated from S0).
2. Load template resources only for active platforms:
   - `antigravity` is always active (source of truth) — load the appropriate behavioral or support template as needed per entity type.
   - For each additional platform in `target_platforms`: read its template resource listed above.
3. Do **not** read template resources for platforms not in `target_platforms`.

### Per-entity output cycle

After generating each GA entity, invoke output skills only for platforms in `target_platforms`:

```
if "claude-code" in target_platforms → invoke ski-output-claude-code
if "codex" in target_platforms → invoke ski-output-codex
```

Skills not in `target_platforms` are never invoked.

---

## Entity Type → Template File Mapping (Antigravity)

| Entity category | Entity types                      | Template resource                         |
| --------------- | --------------------------------- | ----------------------------------------- |
| Behavioral      | `wor-`, `age-spe-`, `age-sup-`, `com-` | `res-entity-templates-behavioral.md` |
| Support         | `ski-`, `rul-`, `kno-`, `res-`, `scp-`, `hok-` | `res-entity-templates-support.md` |

---

## Adding a New Platform

To add support for a new platform (e.g., `gemini`):

1. Add a row to the Dispatch Table above.
2. Create a new `res-entity-templates-{platform}.md` resource file with its template specifications.
3. Create a new `ski-output-{platform}` skill with its conversion logic.
4. No changes needed in any behavioral agent — the dispatch table is the single extension point.
