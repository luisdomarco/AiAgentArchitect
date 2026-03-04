---
description: Dynamic reading protocol for the QA Layer. Defines how to resolve paths, read the current content of entities from disk, and initialize the qa-report.md. Ensures the Auditor always works with the most recent version of each file, without caches.
tags: [qa, audit, dynamic-reading, file-paths]
---

## Table of Contents

1. Dynamic reading principle
2. Path resolution
3. Reading by entity type
4. Initialization and maintenance of qa-report.md
5. Handling files not found

---

## Documentation

### 1. Dynamic reading principle

The Auditor **never uses instruction content from its session context**. Before each audit, it reads the corresponding file from its disk path. This guarantees that:

- If the user modifies a Rule between two checkpoints, the next audit uses the updated version.
- If the user modifies an agent after it was generated, a `/re-audit` audits it with the current version.
- There is no divergence between what the system has on disk and what the Auditor verifies.

This principle applies in AiAgentArchitect as well as in any system where the QA Layer is embedded.

---

### 2. Path resolution

#### 2.1 Base paths

The orchestrator provides the Auditor with:

- `system_path`: absolute or relative path to the system root (`agents/` folder)
- `active_rules`: list of relative paths from `system_path`, e.g. `["./rules/rul-naming-conventions.md"]`

The Auditor resolves absolute paths:

```
absolute_path = system_path + relative_path
```

Example:

```
system_path = "exports/my-system/google-antigravity/.agents/"
relative_path = "./rules/rul-naming-conventions.md"
absolute_path = "exports/my-system/google-antigravity/.agents/rules/rul-naming-conventions.md"
```

#### 2.2 Reading priority

If an entity has multiple versions (e.g. it was regenerated), the Auditor reads **the file on disk** at that moment, which is the most recently approved version.

#### 2.3 Standard paths by entity type

| Type             | Relative path from system_path                 |
| ---------------- | ---------------------------------------------- |
| Rule             | `./rules/{rul-name}.md`                        |
| Agent            | `./workflows/{age-name}.md`                    |
| Skill            | `./skills/{ski-name}/SKILL.md`                 |
| Workflow         | `./workflows/{wor-name}.md`                    |
| Knowledge-base   | `./knowledge-base/{kno-name}.md`               |
| process-overview | `./process-overview.md`                        |
| qa-report        | `../qa-report.md` (one level above `.agents/`) |

---

### 3. Reading by entity type

#### In S1 (Process Discovery)

Read:

- All Rules in `./rules/` of the active system
- `kno-fundamentals-entities` → to verify mode escalation signals

#### In S2 (Architecture Design)

Read:

- All Rules in `./rules/`
- `kno-entity-selection` → to verify that selected entities are of the correct type
- S1 handoff JSON → as reference of what was promised in Discovery

#### In S3 (Entity Implementation)

For each generated entity, read the newly created file on disk + the active Rules.

#### In re-audit

```
/re-audit rul-naming-conventions
→ Read: exports/{name}/.agents/rules/rul-naming-conventions.md (current version)
→ Verify against: all entity files generated in S3

/re-audit S2
→ Read: all active Rules (current version) + the S2 handoff JSON
→ Audit: the complete Blueprint against the current Rules

/re-audit system
→ Read: all entities in all folders of the system (inside .agents/ and, in the native Architect system, also the repository/ folder at the root)
→ Verify against: all active Rules
→ Generates a complete audit report of the current state of the system
```

---

### 4. Initialization and maintenance of qa-report.md

#### Initialization (at the first Audit of the process)

If `qa-report.md` does not exist when executing the first Audit:

```markdown
---
system: { system-name }
start-date: { timestamp }
close-date: null
global-score: pending
---

# QA Report — {system-name}

_Automatically initialized upon approving the first checkpoint._
```

Location: One level above `.agents/`, at the root of the system directory.

#### Example folder structure:

```
exports/my-system/google-antigravity/
├── .agents/
│   ├── rules/
│   ├── workflows/
│   └── ...
└── qa-report.md    ← here, accessible without entering .agents/
```

#### Maintenance

- Each new block is added at the end of the file with a separator line (`---`)
- The frontmatter is only updated at process close (`close-date` + `global-score`)
- Re-audit blocks always carry a timestamp to distinguish them from automatic audits

---

### 5. Handling files not found

If when resolving a path the file does not exist on disk:

1. Do not throw an error — record it as an audit criterion:

```markdown
| File not found | {relative-path} | ❌ | The file does not exist at the expected path |
```

2. Continue the audit with the remaining available files.
3. In the summary, include: `⚠️ {N} referenced file(s) not found`

Common causes and diagnostic suggestions:

- Incorrect relative path → verify the root folder architecture with `kno-system-architecture`
- File manually deleted → the Optimizer can propose recreating it
- Name with a typo → look for similar files in the same folder
