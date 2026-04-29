---
name: ski-layer-embed
description: Embeds, unembeds or updates a modular layer into a destination system (root or subsystem) by reading its MANIFEST.yaml, copying entities to the correct platform directories, injecting context-root sections (CLAUDE.md/AGENTS.md), wiring hooks (settings.json), updating the destination's manifest, and resolving dependencies. Use when activating, deactivating or upgrading any layer (qa, memory, context-ledger, mcp, help-router, onboarding, etc.) on AiAgentArchitect itself or on any generated subsystem.
---

# Layer Embed

Generic layer-management skill. Generalizes the legacy `ski-qa-embed` for any layer declared in `.agents/layers/{layer-id}/MANIFEST.yaml`.

## Input

- `operation`: `embed` | `unembed` | `update`
- `layer_id`: identifier of the layer (e.g. `qa`, `memory`, `help-router`)
- `destination`: absolute or relative path to the target system root (e.g. `.` for root, `exports/foo-system` for a subsystem)
- `platforms`: subset of `[antigravity, claude_code, codex]` declared in the destination's `config/manifest.yaml`. If omitted, use all platforms enabled in destination.
- `auto_resolve_deps`: `true` (default) | `false`. Overrides the layer's MANIFEST default.

## Output

- Files created/removed under `{destination}/.agents/layers/{layer_id}/`, `{destination}/.claude/layers/{layer_id}/`, `{destination}/.codex/layers/{layer_id}/` (depending on platforms).
- `{destination}/CLAUDE.md`, `{destination}/AGENTS.md` regenerated from template + active layer sections.
- `{destination}/.claude/settings.json` updated with hook entries (only if `claude_code` is in platforms).
- `{destination}/config/manifest.yaml` updated with `layers.{layer_id}.enabled` and `version`.
- `fallback_promote_on_disable` honored on `unembed`.
- Confirmation message with inventory of what changed.

## Procedure

### Step 1 — Read layer source MANIFEST

Read `${SOURCE_ROOT}/.agents/layers/{layer_id}/MANIFEST.yaml` from the AiAgentArchitect source (the calling system, not the destination). Validate:
- File exists and parses as YAML.
- `layer_id` field matches the requested layer.
- `compatible_with` is satisfied by destination's `aiagent_architect_version` (semver range check).

If validation fails, abort with error and do not modify destination.

### Step 2 — Read destination manifest

Read `{destination}/config/manifest.yaml`. If absent, treat as a fresh install with no layers active. Determine which platforms are enabled in destination.

### Step 3 — Operation dispatch

Branch by `operation`:

#### Step 3a — `embed`

1. **Resolve dependencies**: for each `depends_on` entry, check if it is enabled in destination's manifest.
   - If enabled: continue.
   - If not enabled and `auto_resolve_deps: true`: invoke `ski-layer-embed` recursively for that dependency before continuing. Notify the user: `"Auto-enabled dependency: {dep_id}"`.
   - If not enabled and `auto_resolve_deps: false`: abort with: `"Layer {layer_id} requires {dep_id}. Activate {dep_id} first or pass --auto-deps."`
2. **Detect circular dependencies**: maintain a stack of currently-resolving layers; if `dep_id` is already in the stack, abort with: `"Circular dependency detected: {chain}"`.
3. **Copy entities**: for each platform in `platforms`, read `platform_targets.{platform}.entities_dir` and recursively copy the layer's entity tree there. Preserve subdirectory structure (`workflows/`, `skills/`, `rules/`, `knowledge_base/`, `resources/`, `hooks/`).
4. **Inject context root**: for each platform with `context_root_inject` defined:
   - Read the destination's `{file}` (e.g. `CLAUDE.md`).
   - If a section with the heading from `section` already exists, replace it. Otherwise, append after the last `## Active Layers` block (or append to file end if none).
5. **Inject hooks**: for each platform with `hooks` defined:
   - Claude Code: read `{destination}/.claude/settings.json`, parse JSON, append entries from `hooks.entries`. Each entry tagged with `_layer: {layer_id}` for later removal.
   - Antigravity: hooks live as `.md` files under `entities_dir/hooks/`; already copied in step 3.
   - Codex: skip; respect `degradation` text already injected via `context_root_inject`.
6. **Update destination manifest**: in `{destination}/config/manifest.yaml`, set `layers.{layer_id}.enabled: true`, `layers.{layer_id}.version: {layer_version}`, `layers.{layer_id}.embedded_at: {ISO_timestamp}`.
7. **Confirmation**: print inventory (entities copied, hooks added, files modified).

#### Step 3b — `unembed`

1. **Check reverse dependencies**: scan destination manifest for layers that have `{layer_id}` in their `depends_on`. If any are still enabled, abort with: `"Cannot disable {layer_id}: required by {dependents}. Disable those first."` (unless `--force` is passed; never auto-disable dependents).
2. **Apply `fallback_promote_on_disable`**: for each entry in the layer's MANIFEST `fallback_promote_on_disable`:
   - Move `{destination}/{platform_entities_dir}/{source}` to `{destination}/.agents/{target_root}` (and equivalents for other platforms).
   - This preserves entities that the framework still needs even when the layer is off.
3. **Remove entities**: delete `{destination}/.agents/layers/{layer_id}/`, `.claude/layers/{layer_id}/`, `.codex/layers/{layer_id}/`.
4. **Retire context root**: remove the layer's section from `CLAUDE.md` and `AGENTS.md` (matched by section heading).
5. **Retire hooks**: in `{destination}/.claude/settings.json`, remove all entries tagged `_layer: {layer_id}`.
6. **Update destination manifest**: set `layers.{layer_id}.enabled: false`, keep `version` for history.
7. **Confirmation**: print inventory of what was removed and what was promoted (if any).

#### Step 3c — `update`

1. Read current installed version from destination's manifest. Read source layer's current version.
2. If equal: print `"Layer {layer_id} is already at version {x}. No update needed."` and exit.
3. If source is newer: execute `unembed` followed by `embed` atomically (rollback on failure: restore previous state from a temp snapshot).
4. If source is older: refuse unless `--downgrade` flag is passed.

### Step 4 — Final manifest write

After any successful operation, write `{destination}/config/manifest.yaml` to disk and update its `last_modified` timestamp.

## Error handling

| Error | Behavior |
| ----- | -------- |
| Layer source MANIFEST not found | Abort with `"Layer {layer_id} not found in source layers/"` |
| Destination not a valid AiAgentArchitect system | Abort with `"Destination {path} does not have config/manifest.yaml. Run install.mjs first."` |
| Circular dependency | Abort, no changes |
| Compat range mismatch | Abort with `"Layer {layer_id} v{x} requires AiAgentArchitect {range}, got {y}"` |
| Embed when already enabled | Print `"Layer already enabled. Re-run with operation=update to refresh."` and exit cleanly |
| Unembed when not enabled | Print `"Layer not enabled. Nothing to do."` and exit cleanly |
| Filesystem error mid-operation | Roll back: restore from temp snapshot taken at step start |

## Confirmation message format

```
✅ Layer {layer_id} v{version} {operation}ded on {destination}

Platforms affected: {antigravity, claude_code, codex}
Entities {added|removed}: {count} workflows, {count} skills, ...
Hooks {added|removed}: {count} entries in settings.json
Context root: {file}#{section} {injected|retired}
Promotions: {list of fallback_promote_on_disable applied, if any}
Dependencies auto-resolved: {list, if any}

Destination manifest updated.
```

## Notes on the context-root template

The destination's `CLAUDE.md` and `AGENTS.md` are not edited by hand. They are regenerated by `ski-layer-embed` from `{SOURCE_ROOT}/.agents/templates/CLAUDE.md.tpl` and `AGENTS.md.tpl` (created in the templates phase) plus concatenation of all active layer sections. If those templates do not exist yet, `ski-layer-embed` falls back to direct in-place editing of the existing files (legacy mode) and prints a warning.

