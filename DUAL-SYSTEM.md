# Dual System: .agents/ and .claude/

This project maintains two implementations of the same agentic system, each optimized for its execution platform.

---

## Overview

AiAgentArchitect generates complete agentic systems. To support multiple platforms, the design system itself is maintained in two parallel structures:

| Directory  | Platform           | Purpose                                             |
| ---------- | ------------------ | --------------------------------------------------- |
| `.agents/` | Google Antigravity | Original structure, source of truth for conventions |
| `.claude/` | Claude Code        | Structure adapted to Claude Code conventions        |

Both contain the **same entities** with the **same functional content**. The differences are exclusively structural (directory organization) and routing (relative paths between files).

---

## Comparative Structure

```
.agents/ (Google Antigravity)          .claude/ (Claude Code)
├── workflows/                         ├── commands/
│   ├── wor-*.md ─────────────────────→│   ├── wor-*.md
│   ├── age-spe-*.md ─────────────────→│   └── test.md
│   ├── age-sup-*.md                   ├── agents/
│   ├── com-*.md                      →│   ├── age-spe-*.md
│   └── test.md                        │   └── age-sup-*.md
├── skills/                            ├── skills/
│   └── ski-*/                         │   └── ski-*.md (flattened)
│       └── SKILL.md ─────────────────→│
├── rules/                             ├── rules/
│   └── rul-*.md ─────────────────────→│   └── rul-*.md (identical)
├── knowledge-base/                    ├── knowledge-base/
│   └── kno-*.md ─────────────────────→│   └── kno-*.md (identical)
├── resources/                         ├── resources/
│   └── res-*.md ─────────────────────→│   └── res-*.md (identical)
                                       ├── settings.local.json (Claude only)
                                       └── plans/ (Claude only)
```

---

## Entity Mapping

| Type             | .agents/                  | .claude/                  | Transformation           |
| ---------------- | ------------------------- | ------------------------- | ------------------------ |
| Workflow         | `workflows/wor-*.md`      | `commands/wor-*.md`       | Directory change + paths |
| Agent Specialist | `workflows/age-spe-*.md`  | `agents/age-spe-*.md`     | Directory change + paths |
| Agent Supervisor | `workflows/age-sup-*.md`  | `agents/age-sup-*.md`     | Directory change + paths |
| Command          | `workflows/com-*.md`      | `commands/com-*.md`       | Directory change + paths |
| Skill            | `skills/ski-*/SKILL.md`   | `skills/ski-*.md`         | Flattened structure      |
| Rule             | `rules/rul-*.md`          | `rules/rul-*.md`          | Direct copy              |
| Knowledge-base   | `knowledge-base/kno-*.md` | `knowledge-base/kno-*.md` | Direct copy              |
| Resource         | `resources/res-*.md`      | `resources/res-*.md`      | Direct copy              |

---

## Path Transformations

Entities reference other entities with relative paths. When the directory structure changes, paths are automatically transformed.

### Paths that change

| Reference                 | In .agents/                | In .claude/              |
| ------------------------- | -------------------------- | ------------------------ |
| Agent from workflow       | `./age-spe-*.md`           | `../agents/age-spe-*.md` |
| Supervisor from workflow  | `./age-sup-*.md`           | `../agents/age-sup-*.md` |
| Skill from agent/workflow | `../skills/ski-*/SKILL.md` | `../skills/ski-*.md`     |

### Paths that do NOT change

| Reference      | Path (same in both)          |
| -------------- | ---------------------------- |
| Rule           | `../rules/rul-*.md`          |
| Knowledge-base | `../knowledge-base/kno-*.md` |
| Resource       | `../resources/res-*.md`      |

### Protections

Path transformations **do not affect**:

- Generic templates/placeholders (e.g. `../skills/[skill-name]/SKILL.md` in system generation documentation)
- Paths with generic patterns in brackets `[name]`
- Content inside code blocks that document the architecture of generated systems

---

## Platform-specific Files

These files **are not synced** because they are exclusive to their platform:

| File                          | Platform    | Purpose               |
| ----------------------------- | ----------- | --------------------- |
| `.claude/settings.local.json` | Claude Code | Execution permissions |
| `.claude/plans/`              | Claude Code | Implementation plans  |

---

## Automatic Synchronization

### Mechanism: Git Pre-commit Hook

Every time you run `git commit`, an automatic hook:

1. Detects if any `.md` files have been modified in `.agents/` or `.claude/`
2. Syncs toward the opposite side applying the transformations
3. Adds the synced files to the commit

```
  You edit .agents/workflows/age-spe-auditor.md
       ↓
  git add .agents/workflows/age-spe-auditor.md
       ↓
  git commit -m "update auditor"
       ↓
  [pre-commit hook] Detects change in .agents/
       ↓
  [sync-dual.sh] Copies → .claude/agents/age-spe-auditor.md
                  Transforms skill paths
       ↓
  [pre-commit hook] git add .claude/agents/age-spe-auditor.md
       ↓
  Commit includes both files automatically
```

### Conflict Protection

If changes are detected on **both sides** simultaneously, the hook **blocks the commit** and requests manual resolution:

```
[pre-commit] Changes detected on both sides simultaneously.
[pre-commit] Please sync manually first:
  ./scripts/sync-dual.sh --agents-to-claude  (if .agents/ is the source)
  ./scripts/sync-dual.sh --claude-to-agents  (if .claude/ is the source)
```

---

## Manual Script Usage

### Available Commands

```bash
# Auto-detect which side changed and sync
./scripts/sync-dual.sh --auto

# Force sync in a specific direction
./scripts/sync-dual.sh --agents-to-claude
./scripts/sync-dual.sh --claude-to-agents

# Sync a specific file
./scripts/sync-dual.sh --file .agents/rules/rul-audit-behavior.md

# Validate that both structures are in sync
./scripts/sync-dual.sh --validate
```

### Real-time Watch (optional)

For real-time synchronization while editing (requires `fswatch`):

```bash
# Install fswatch if not available
brew install fswatch

# Start the watcher
./scripts/watch-sync.sh
```

The watcher detects filesystem changes and syncs automatically without requiring a commit.

---

## Daily Workflow

### Option A: Work with git hook (recommended)

1. Edit files in `.agents/` or `.claude/` (whichever you prefer)
2. Run `git add` for your changes
3. Run `git commit` — the hook syncs automatically
4. Both sides are updated in the same commit

### Option B: Work with real-time watch

1. Run `./scripts/watch-sync.sh` in a terminal
2. Edit files on either side
3. Changes are replicated instantly
4. When done, commit normally

### Option C: Manual on-demand sync

1. Edit files on one side
2. Run `./scripts/sync-dual.sh --auto`
3. Verify with `./scripts/sync-dual.sh --validate`
4. Commit

---

## Troubleshooting

### The hook blocked my commit

**Cause:** There are staged changes in `.agents/` AND `.claude/` simultaneously.

**Solution:** Decide which is the source and sync manually:

```bash
./scripts/sync-dual.sh --agents-to-claude   # if you edited .agents/
./scripts/sync-dual.sh --claude-to-agents   # if you edited .claude/
git add .agents/ .claude/
git commit -m "your message"
```

### Files are out of sync

**Check:**

```bash
./scripts/sync-dual.sh --validate
```

**Force full resync:**

```bash
./scripts/sync-dual.sh --agents-to-claude   # .agents/ as source of truth
```

### I added a new entity and it's not syncing

Verify that the file name follows the naming conventions (`wor-*`, `age-spe-*`, `ski-*`, `rul-*`, `kno-*`, `res-*`). The script only syncs files that match these patterns.

### The watch is not detecting changes

Verify that `fswatch` is installed:

```bash
brew install fswatch
```

---

## Current Inventory

### Shared Entities (34 files)

**Commands/Workflows (2):**

- `wor-agentic-architect.md`
- `test.md`

**Agents (6):**

- `age-spe-process-discovery.md`
- `age-spe-architecture-designer.md`
- `age-spe-entity-builder.md`
- `age-spe-auditor.md`
- `age-spe-evaluator.md`
- `age-spe-optimizer.md`

**Skills (9):**

- `ski-compliance-checker`
- `ski-diagram-generator`
- `ski-entity-file-builder`
- `ski-entity-selector`
- `ski-pattern-analyzer`
- `ski-platform-exporter`
- `ski-process-interviewer`
- `ski-qa-embed`
- `ski-rubric-scorer`

**Rules (4):**

- `rul-audit-behavior.md`
- `rul-checkpoint-behavior.md`
- `rul-interview-standards.md`
- `rul-naming-conventions.md`

**Knowledge-base (7):**

- `kno-entity-selection.md`
- `kno-evaluation-criteria.md`
- `kno-fundamentals-entities.md`
- `kno-handoff-schemas.md`
- `kno-qa-dynamic-reading.md`
- `kno-qa-layer-template.md`
- `kno-system-architecture.md`

**Resources (6):**

- `res-architect-execution-phases.md`
- `res-architecture-component-metrics.md`
- `res-entity-formatting-templates.md`
- `res-interview-question-trees.md`
- `res-qa-layer-raw-templates.md`
- `res-system-packaging-logic.md`
