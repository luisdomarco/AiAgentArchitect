---
trigger: always_on
alwaysApply: true
---

## Context

This rule prevents unnecessary token consumption by enforcing strict read boundaries. Without these boundaries, the AI may read all exported systems when working on AiAgentArchitect itself, or read the parent system's implementation when working on a specific export — both of which waste context and introduce confusion.

## Hard Constraints

### Boundary A: Working on AiAgentArchitect

When improving the system itself, running `wor-agentic-architect`, or making changes to `.agents/` / `.claude/`:

- Never read files inside `exports/` except `exports/template/`.
- Never list or scan `exports/` directories to "understand" the system — the system is defined in `.agents/` and `.claude/`, not in its outputs.
- If information about a generated system is needed, ask the user which specific project to reference.

### Boundary B: Working on a specific exported project

When working directly on files within a specific `exports/{system-name}/` (editing, fixing, adding entities):

- Only read files inside that specific project's directory.
- Never read other `exports/{other-system}/` directories.
- Never read the parent AiAgentArchitect's `.agents/` or `.claude/` implementation files — they are the architect, not the project.
- Exception: reading `exports/template/` is allowed if needed for structural reference.

### General

- Never read ALL exported projects to build context. Each project is independent.
- Never assume a pattern from one exported project applies to another.

## Soft Constraints

- Prefer reading `system-overview.md` before individual entity files when starting work on AiAgentArchitect.
- Prefer reading a project's own `process-overview.md` or `system-overview.md` before diving into its entity files.
- If unsure which boundary applies, ask the user.

## Detection Heuristic

| Signal | Boundary |
| --- | --- |
| User invokes `wor-agentic-architect` or `/wor-agentic-architect` | A |
| User asks to improve, fix, or extend AiAgentArchitect | A |
| User references a specific `exports/{name}` project | B |
| User asks to edit/fix entities in a generated system | B |
| Ambiguous — could be either | Ask the user |
