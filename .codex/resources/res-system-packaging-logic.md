---
name: res-system-packaging-logic
description: Strict packaging, export, and error checkpoint policies for the Lite edition.
tags: [export, packaging, checkpoint, error, handler]
---

# System Packaging Logic (Lite)

This document contains the decision branches to execute when the Architect orchestrates system closure and offers additional platform exports.

## Mandatory Pre-CP-CLOSE Checklist

Execute the following offer **before presenting CP-CLOSE** to the user:

### 1. Additional application exports — `ski-platform-exporter`

Note: Google Antigravity (`.agents/`) and Claude Code (`.claude/`) are generated automatically as part of the default dual-platform export. This step offers exports to additional platforms including Codex and application platforms.

Present:
> "The system is ready in Google Antigravity and Claude Code formats. Do you want to export to an additional platform?
> A) OpenAI Codex · B) ChatGPT · C) Claude.ai · D) Dust · E) Gemini · F) No, skip"

If A–E: invoke `ski-platform-exporter` with `system_path` and selected platform. Return to this checklist after each export.

### 2. Present CP-CLOSE

Only after the offer has been made (and optionally executed), present the standard CP-CLOSE checkpoint.

---

## Final Packaging

Generate files in `exports/{system-name}/.agents/` (GA) and `exports/{system-name}/.claude/` (CC) simultaneously (see `kno-system-architecture` §3). Structure per platform follows the mapping table. **Generate `.codex/` only if `codex` is in `target_platforms`** (per `target_platforms` captured at CP-S0).

**Automation directories:** If the system includes Script or Hook entities, create `scripts/` and `hooks/` directories in both platform structures. CC hooks require `settings.json` entries.

**Persistence directories:** Always create `context-ledger/` and `memory/` at the root of `exports/{system-name}/` (when those layers are active). These directories enable cross-session persistence for the generated system's own workflows. Any workflow generated within the system that uses `ski-context-ledger` must reference `ledger_dir=context-ledger/` (at the system root), not a path inside `.agents/` or `.claude/`.

**System overview:** Generate a `system-overview.md` at the root of `exports/{system-name}/` containing: system purpose (from process-overview.md), entity inventory table (all generated entities with name, type, description, when to use), cross-session persistence note (context-ledger/ and memory/), and a reading strategy instructing the AI to read this file first and individual entities on demand.

**Scope boundaries rule:** Generate `rul-scope-boundaries.md` in the system's rules directory (both platforms if dual export). Content: Hard Constraint — when working on this system, never read files outside its directory; Soft Constraint — prefer reading system-overview.md before individual entity files.

**Write subsystem manifest:** Generate `exports/{system-name}/config/manifest.yaml` from the parent's `templates/manifest.yaml.tpl` using these fields:

- `aiagent_architect_version` — copy from parent's `config/manifest.yaml`. Immutable provenance: the parent version under which this subsystem was first generated.
- `generated_at` — ISO 8601 timestamp now.
- `project_name` — from session start.
- `mode` — `"architect"` or `"express"`.
- `platforms` — the validated `target_platforms` list (e.g. `["antigravity", "claude-code"]` or `["antigravity", "claude-code", "codex"]`).
- `layers_root` — list of layers actually embedded in this subsystem. For each: `name`, `version`, `embedded_at`.

This manifest is the source of truth for the sync scripts (`sync-dual.sh --target`, `build-codex.py --export`) when they operate on this subsystem.

Display export summary with number of entities generated per type.

**Sync invocation for subsystems:** The user (or CI) invokes the parent's scripts targeting the subsystem's directory:

```
bash scripts/sync-dual.sh --target exports/{system-name} --agents-to-claude --prune
python3 scripts/build-codex.py --export exports/{system-name} --prune
```

Each script reads `exports/{system-name}/config/manifest.yaml` and skips its output if the corresponding platform is not in `platforms`.

**Post-packaging checkpoint:**
A) ✅ Finalize · B) 📦 Export to additional platform · C) ↩️ Adjust process-overview

If B: activate `ski-platform-exporter` with the system and destination platform → generates in `exports/{name}/{platform}/`. Allow multiple iterations.

## Active Error Management

- **Incomplete handoff JSON:** request the responsible agent to complete it before continuing to the next Step.
- **Ambiguous checkpoint response:** always explicitly ask what to change before acting.
- **Inconsistency between entities:** pause and notify the user before allowing graphical continuity.

> **Important:** The handoff JSON is the only context transfer mechanism between Steps. Each agent receives the JSON from the previous Step and delivers its own back to the main pipeline.
