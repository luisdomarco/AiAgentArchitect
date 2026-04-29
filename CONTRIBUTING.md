# Contributing

This is the **Lite** edition — a public preview of AiAgentArchitect. The full system lives upstream.

## Reporting bugs

Open an issue with:

- The version (`config/manifest.yaml` field `aiagent_architect_version`)
- The host platform (Antigravity, Claude Code, or Codex)
- The slash command or workflow you ran
- What you expected vs. what happened

If the orchestrator wrote a `context-ledger/<timestamp>-<project>.md` file before the bug, attach it (or the relevant section) — it is the most useful debug artifact.

## Suggesting changes

The Lite edition is intentionally minimal. Before proposing a feature, please check whether it already exists in the full edition (most likely the answer for: QA, iteration, refinement methods, multi-project, telemetry, MCP).

Suggestions that are appropriate for Lite:

- Bug fixes in the core 4 agents or the orchestrator.
- Improvements to the bundled layers (memory, context-ledger, help-router, onboarding).
- Better defaults or copy in the install wizard.
- Documentation corrections.

## Local development

```bash
git clone <this-repo>
cd AiAgentArchitect
bash install.sh --yes
```

Edit entities in `.agents/` (the source of truth). Then re-sync:

```bash
bash scripts/sync-dual.sh --agents-to-claude --prune
python3 scripts/build-codex.py
python3 scripts/build-context-roots.py
```

Re-open the IDE to pick up the changes.

## License

See [LICENSE](LICENSE).
