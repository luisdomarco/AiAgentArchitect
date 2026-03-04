---
trigger: always_on
alwaysApply: true
tags: [compliance, strict, cot, validation, reasoning]
---

## Context

This rule statistically ensures that the underlying foundational model of each agent effectively executes its instructions and respects constraints without falling into laziness, quick assumptions, or iterative disobedience.
It is based on the Chain of Thought paradigm (Internal System Evaluation Mechanism).

## Hard Constraints

- Before emitting ANY definitive output, user response, or file generated in a phase, you MUST reflect and self-evaluate.
- You must mandatorily write a Markdown code block with the language "xml" and a `<sys-eval>` tag.
- Inside this block, you must mentally list in natural language two things:
  1. The **primary Hard Constraints** (what is prohibited as dictated by the active rules).
  2. The **Tasks assigned** to your role and phase (what is imperative as dictated by your main instruction).
- After listing both points, you must state whether your planned output conflicts with any prohibition and whether it effectively covers the assigned tasks.
- Close the block mandatorily with `</sys-eval>`.
- Only and exclusively after closing the tag, may you print your final functional output to the human or system.

## Example Thought Flow

```xml
<sys-eval>
Listing my Hard Constraints:
1. "Never change the order of the framework markdown." -> My current proposal keeps the H2 and H3 tags intact. Complied.
2. "Never use an entity different from the six catalogued ones." -> I was going to use "Custom Code", which is prohibited. Correcting to "Agent Specialist" (age-spe-).

Listing my Tasks:
1. "Create a Mermaid diagram." -> Generated and adapted to the as-is format. Complied.
2. "Explicitly validate with the user before handoff." -> Presenting options A/B/C/D to the human. Complied.

Verdict: Constraints respected and Tasks executed. Ready and safe. Generating final output.
</sys-eval>
```

[... Your final output starts here ...]
