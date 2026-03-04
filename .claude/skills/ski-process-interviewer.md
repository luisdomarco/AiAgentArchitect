---
name: ski-process-interviewer
description: Structured interview technique for process discovery. Use it to conduct BPM/BPA interviews, apply inverse engineering on vague descriptions, and extract complete process information through organized question blocks.
---

# Process Interviewer Skill

Structured interview protocol to discover processes with depth and precision. Combines BPM, BPA, and reverse engineering techniques.

## Input / Output

**Input:**

- Initial description of the process in natural language
- Active mode: `express` or `architect`

**Output:**

- Set of structured questions by block
- Response quality validations
- Alert signals to detect hidden complexity

---

## Procedure

### 1. Analysis before the first question

Before formulating any question, analyze the initial description and identify:

- **What is known:** explicit information in the description.
- **What is implicit:** information that can be inferred but has not been stated.
- **What is missing:** information without which nothing can be designed.

Prioritize questions about what is missing. Do not ask what you already know.

---

### 2. Interview principles

**One question at a time.** Never formulate two questions in the same message, even if they seem related.

**Validate before advancing.** If the answer is vague or incomplete, re-ask before moving to the next topic.

**Decompose the vague.** If the user uses generic terms, decompose into specifics.

**Do not assume.** No process field can be completed by inference without explicit validation from the user.

---

### 3. Structural Execution from Resources

The reverse engineering templates (to disambiguate terms), the Express Questionnaire, and the Complex Blocks for Architects no longer reside hardcoded in this Skill, but rather in a centralized resource to lighten the static memory load.

> **The interviewer skill requires that you first load and study the following resource:**
> `../../resources/res-interview-question-trees.md`

Extract from there the matrix corresponding to your operating mode (Express = Short Questionnaire, Architect = Blocks 1-6 with Dynamic Decomposition) and interview while respecting the cadence of one question per turn.

---

### 6. Flow challenge

Before closing the interview in Architect Mode, actively validate understanding:

**Step 1 — Process reflection:**
_"Before continuing, I want to confirm I understood correctly. The process is: [summary in 3-5 steps]. Is that correct?"_

**Step 2 — Challenge with extreme cases:**
Once the flow is confirmed, ask at least 2 challenge questions about:

- The most likely error case
- The most relevant exceptional case you detected during the interview

Example: _"You mentioned the system sends a response to the client. What happens if the client doesn't respond within X time? Is there a retry or does it escalate to a human?"_

---

## Examples

**Example 1 — Decomposition of vague description**

User: _"I want to agentize customer support."_

Reverse engineering application:

1. _"Through what channels do customer requests come in? (email, chat, phone, web form...)"_
2. _[answer: email and chat]_ → _"What type of requests are most frequent? Do you have the 3 most common cases?"_
3. _[answer: billing questions, plan changes, technical incidents]_ → _"What system do you use today to manage these requests? Is there a CRM or helpdesk?"_

**Example 2 — Detection of hidden complexity**

User: _"It's simple, I just need it to classify emails and forward them to the correct department."_

Challenge: _"When you say 'correct department', how many departments are there? What happens if an email could go to more than one? And if the classification is not clear?"_

→ If the user reveals 5+ departments and cases of ambiguity, signal to escalate to Architect.

---

## Error Handling

- **Answer too brief:** Re-ask with a more specific formulation. Do not advance.
- **Contradictory answer:** Point out the contradiction directly: _"Earlier you mentioned X, but now you describe Y. Which is the correct behavior?"_
- **User doesn't know how to answer:** Offer concrete options to choose from: _"Is the trigger A, B, or C?"_
- **User gives information from more blocks at once:** Record it internally for the corresponding block, but continue following the block order without skipping.
