---
name: res-entity-selection-criteria
description: Detailed selection criteria and key signals for each of the 9 entity types. Read when there is doubt about which specific entity type applies to a given responsibility. Complements kno-entity-selection decision tree and comparative table.
tags: [entity-selection, criteria, architecture]
---

## Purpose

This resource contains the detailed per-entity criteria extracted from the entity selection knowledge base. Use it when the decision tree and comparative table in `kno-entity-selection` are not sufficient to disambiguate — when you need to understand the deeper signals for a specific type.

**When to read:** Conditionally, when the architecture designer is uncertain about a specific entity type after consulting `kno-entity-selection` §1 and §2.

---

## Criteria per Entity Type

### Workflow

Use it when the process involves multiple responsibilities that must execute in sequence or with branches, passing outputs from one part to the next.

**Key signals:**

- More than one responsibility domain is involved
- There are decisions or branches between parts
- Context needs to be transferred between distinct components
- There are human approval checkpoints
- The process has a start, an orchestrated flow, and a composite final output

**Validation question:** Could it be decomposed into steps with distinct responsible parties?

---

### Agent

Use it when the responsibility is single, bounded, and requires its own criteria to execute.

**Key signals:**

- A single, clear responsibility domain
- Needs to make decisions within its scope
- Can be used standalone or within a Workflow
- Has well-defined input and output

**Validation question:** Could its responsibility be described in one sentence? Does it make sense to invoke it alone?

---

### Skill

Use it when it is a technical or procedural capability that multiple agents might need, without its own identity or criteria.

**Key signals:**

- The same logic could be used in more than one Agent
- It doesn't make decisions: it executes a concrete procedure
- It has no domain context of its own
- It is activated on demand

**Validation question:** Would you find this same logic duplicated in two different Agents?

---

### Command

Use it when it is a concrete, deterministic, frequently used action that the user triggers directly with a keyword.

**Key signals:**

- Always initiated manually by the user
- Always produces the same base behavior
- Makes no sense for another Agent or Workflow to invoke it
- It is equivalent to a saved prompt

**Validation question:** Is this something the user would repeat in exactly the same way many times?

---

### Rule

Use it when you define restrictions or conventions that must condition the behavior of multiple entities without executing anything.

**Key signals:**

- The same directive applies in more than one context
- It is a restriction (never do X) or convention (always do Y this way)
- It produces no output of its own: it conditions others' outputs

**Validation question:** Did you just write the same restriction in three different Agents?

---

### Knowledge-base

Use it when it is static reference information that agents consult to ground their decisions.

**Key signals:**

- Content that doesn't change with each execution
- Agents consult it on demand, don't execute it
- Contains documentation, examples, glossaries, guides, domain data

**Validation question:** Are you stuffing a lot of factual context into an Agent's body for it to "know" it?

---

### Script

Use it when the system needs an automated, deterministic procedure that runs headlessly — linting, validation, deployment, data processing, file operations.

**Key signals:**

- The task is a concrete, repeatable procedure
- It produces side-effects (file changes, output, validations)
- It could be invoked by a hook, command, or manually
- It does not make decisions or reason — it executes steps

**Validation question:** Could this be expressed as a shell script that runs the same way every time?

---

### Hook

Use it when the system needs event-driven automation — actions that fire automatically in response to system events without manual invocation.

**Key signals:**

- The behavior should happen automatically when a system event occurs
- It delegates to a script, prompt, or agent — it does not contain complex logic itself
- It acts as a bridge between an event and an action
- It is not manually invoked — it fires on events

**Validation question:** Is there a system event (file change, tool use, session start) that should trigger this behavior automatically?
