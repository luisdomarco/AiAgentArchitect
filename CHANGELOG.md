# Changelog — AiAgentArchitect Lite

## 0.1.0-lite — 2026-04-29

Initial release of the public Lite preview. Filtered subset of AiAgentArchitect v3 with the core flow and four small layers.

**Includes**

- Workflow: `wor-agentic-architect` with 3-step flow (Discovery → Architecture → Implementation).
- Agents: `age-spe-input-enricher`, `age-spe-process-discovery`, `age-spe-architecture-designer`, `age-spe-entity-builder`.
- Skills: `ski-process-interviewer`, `ski-entity-selector`, `ski-entity-file-builder`, `ski-diagram-generator`, `ski-output-claude-code`, `ski-output-codex`, `ski-platform-exporter`, `ski-layer-embed`.
- Layers: `context-ledger`, `memory`, `help-router`, `onboarding` (all enabled by default).
- Three host platforms: Antigravity, Claude Code, Codex.

**Deliberately omitted**

- QA layer (Auditor / Evaluator / Optimizer).
- Multi-project iteration commands (`com-iterate-system`, `com-publish-system`, `com-clone-system`, `com-export-system`, `com-abandon-project`).
- Layer management commands (`com-layer-list`, `com-layer-enable`, etc.).
- Adversarial review, compression, elicitation methods, methods registry, MCP, telemetry, state-tracking, templates layer, cross-project aggregator.

**Notes**

- The orchestrator is layer-aware (`active_layers` set built from `config/manifest.yaml`); references to disabled layers are silently skipped (graceful degradation).
- `rul-strict-compliance` (the `<sys-eval>` rule) was promoted from the QA layer to root rules to preserve it independently of QA.
