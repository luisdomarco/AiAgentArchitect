# Contributing to AiAgentArchitect

## Development Workflow

AiAgentArchitect uses a **dual-system architecture**. Source of truth is `.agents/` (Google Antigravity format). The `.claude/` directory (Claude Code format) is an auto-synced mirror — never edit it directly.

**Always edit in `.agents/`. The sync runs automatically on commit.**

See [DUAL-SYSTEM.md](DUAL-SYSTEM.md) for the full sync architecture.

---

## Naming Conventions

All entity files must follow strict naming conventions. Violations will break cross-references.

### Prefixes by entity type

| Type             | Prefix     | Example                       |
| :--------------- | :--------- | :---------------------------- |
| Workflow         | `wor-`     | `wor-customer-onboarding.md`  |
| Agent Specialist | `age-spe-` | `age-spe-email-classifier.md` |
| Agent Supervisor | `age-sup-` | `age-sup-output-validator.md` |
| Skill            | `ski-`     | `ski-format-output/SKILL.md`  |
| Command          | `com-`     | `com-quick-translate.md`      |
| Rule             | `rul-`     | `rul-output-standards.md`     |
| Knowledge-base   | `kno-`     | `kno-brand-guidelines.md`     |
| Resources        | `res-`     | `res-security-policies.md`    |

### Hard rules

- No uppercase letters in file or folder names
- No spaces — use hyphens (`-`)
- `name` field in frontmatter: max **64 characters**
- `description` field in frontmatter: max **250 characters**
- No two entities with the same name, regardless of type

---

## Character Limits per Entity Type

| Entity type    | Recommended   | Maximum      |
| :------------- | :------------ | :----------- |
| Workflow       | < 6,000 chars | 12,000 chars |
| Agent          | < 3,000 chars | 12,000 chars |
| Skill          | < 1,500 chars | 12,000 chars |
| Command        | < 1,500 chars | 12,000 chars |
| Rule           | < 3,000 chars | 12,000 chars |
| Knowledge-base | < 6,000 chars | 12,000 chars |

When a file approaches the recommended limit, partition it — move extended content to a `res-` file in `/resources/` and reference it from the main entity.

---

## Adding a New Entity

1. **Create the file** in `.agents/{directory}/` following the prefix and naming rules above.
2. **Add required frontmatter** (`name:` and `description:` fields).
3. **Commit** — the pre-commit hook runs `sync-dual.sh` automatically and propagates the new file to `.claude/`.
4. **Update the repository index** in `repository/` if the entity is meant for reuse across systems.

---

## Sync Commands

The sync script lives at `scripts/sync-dual.sh`.

```bash
# Sync .agents/ → .claude/ (use when you edited .agents/)
./scripts/sync-dual.sh --agents-to-claude

# Sync .claude/ → .agents/ (use when you edited .claude/)
./scripts/sync-dual.sh --claude-to-agents

# Auto-detect direction and sync
./scripts/sync-dual.sh --auto

# Validate sync without modifying anything
./scripts/sync-dual.sh --validate

# Sync a single file
./scripts/sync-dual.sh --file .agents/rules/rul-my-rule.md
```

The pre-commit hook runs validation automatically — if both sides have diverged, the commit is blocked with instructions to sync first.

---

## QA Process

Every generated system optionally includes a QA Layer (Auditor → Evaluator → Optimizer) that runs after each checkpoint. The QA layer writes to `qa-report.md` in the generated system's root.

**Manual re-audit commands** (invoke inside the workflow session):

```
/re-audit {entity-name}   → Re-audit a specific entity
/re-audit S2              → Re-audit an entire phase
/re-audit system          → Re-audit the entire system
/skip-qa S1               → Skip QA for a specific phase
```

Source: [`rul-audit-behavior.md`](.agents/rules/rul-audit-behavior.md)
