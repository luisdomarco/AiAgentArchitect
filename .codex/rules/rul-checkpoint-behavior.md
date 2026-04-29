---
trigger: always_on
alwaysApply: true
tags: [checkpoints, validation, interaction]
---

## Context

This rule defines how to present summaries, manage validations, and behave at checkpoints between phases and between entities. A poorly managed checkpoint leads to misunderstandings, rework, and loss of context. A well-managed checkpoint gives the user full control over the process without unnecessary friction.

## Hard Constraints

- Never advance to the next phase or entity without explicit user approval — always via option A of the checkpoint.
- After presenting a checkpoint, STOP generating output immediately. Do not send follow-up messages, reminders, or re-ask the question. Wait in silence for the user's explicit response.
- If a hook or system prompt fires after a checkpoint presentation, do NOT use it as a reason to generate additional output. Acknowledge it internally and remain silent.
- Never interpret silence or an ambiguous response as approval.
- Never skip the phase checkpoint even if the user seems impatient.
- Never present a checkpoint without the 4 standard options.
- Never proceed with an edit without first asking the user to specify what to change.

## Soft Constraints

- Present summaries concisely: enough for the user to validate, without repeating everything already said.
- If the user chooses option B (edit), ask what they want to change before modifying anything.
- If the user chooses option C (regenerate), confirm whether they want to regenerate from scratch or with a specific instruction.
- If the user chooses option D (go back), confirm exactly which point they want to return to.

## Standard Checkpoint Format

Every checkpoint must follow this structure:

```
[Summary of what was completed in this phase/entity]

How do you want to continue?
A) ✅ Approve and [next action]
B) ✏️  Adjust [what can be adjusted]
C) 🔄 Regenerate [what is regenerated]
D) ↩️  Return to [phase or previous entity]
```

## System Checkpoints

| Checkpoint | Moment                              | Next action if A                           |
| ---------- | ----------------------------------- | ------------------------------------------ |
| CP-S0      | After structuring the initial input | Run Automatic QA cycle → Move to Step 1    |
| CP-S1      | At the close of Step 1              | Run Automatic QA cycle → Move to Step 2    |
| CP-S2      | At the close of Step 2              | Run Automatic QA cycle → Move to Step 3    |
| CP-S3-N    | After generating each entity        | Register QA Audit → Generate next entity   |
| CP-CLOSE   | When presenting process-overview.md | Run Automatic QA cycle → Close the process |

## Handling Ambiguous Responses

If the user responds in a way that does not correspond to any of the 4 options:

1. Do not interpret or assume intent.
2. Respond: _"Do you want [option A], [option B], [option C], or [option D]?"_
3. Wait for an explicit response before acting.

## Handling Changes During a Checkpoint

If the user chooses B (edit):

- Ask: _"Which part do you want to adjust?"_
- Apply only the indicated change, without modifying anything else.
- Present the modified element again with a new checkpoint.

If the user chooses C (regenerate):

- Ask: _"Do you want to regenerate with a specific instruction or from scratch?"_
- If they provide instructions, incorporate them before regenerating.
- Present the result with a new checkpoint.

If the user chooses D (go back):

- Confirm: _"Are you returning to Step [X] / to entity [name]?"_
- Resume from that point with the full context of everything that had been approved up to then.

