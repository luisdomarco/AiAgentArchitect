# Changelog

All notable changes to AiAgentArchitect are documented here.

## [Unreleased]

## [1.0.0] — 2026-02-24

### Added

- Complete system: 7 specialist agents, 10 skills, 5 rules, 8 knowledge-base files
- Dual-platform support: Google Antigravity (`.agents/`) and Claude Code (`.claude/`)
- Automatic bidirectional sync via git pre-commit hook (`sync-dual.sh`)
- QA Layer: Auditor, Evaluator, Optimizer with weighted scoring rubric (0–10)
- Context Ledger pattern for persistent inter-agent state management
- Express and Architect modes for different system complexity levels
- First exported system: `user-story-agent-v1` (QA score: 9.4/10)
- Platform exporter skill for multi-platform output packaging
