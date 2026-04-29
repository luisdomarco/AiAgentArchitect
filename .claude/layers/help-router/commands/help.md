---
description: Show context-aware help — what you can do right now, based on your current phase, project state, and active layers.
---

# /help

Invoke `ski-help-router` to render the right menu for the current moment.

## Behavior

1. Auto-detect the current context by reading `config/manifest.yaml` and (if Memory layer is active) the most recent Memory snapshot.
2. Look up the matching menu in `.agents/layers/help-router/skills/ski-help-router/menus.csv`.
3. Filter out any options whose required layer is not currently enabled.
4. Render the menu inline in chat.

## Usage

```
/help              # context-aware menu
/help --verbose    # also explain why each option is shown or filtered
```

## When to use

- "What can I do now?"
- Mid-flow and unsure of next step.
- After a long pause; want to see resumable options.
- New to the system; want the entry-point menu.

## Implementation

This command is a thin shim. All logic lives in `ski-help-router`. The shim's job is to make `/help` invokable as a one-keystroke command from Claude Code chat.
