# Agentic Architect — Template Architect

Fill in this template before starting the session. The more complete it is, the fewer questions the system will need in Step 1 and the faster you'll reach the architectural design.

Don't worry if you don't have all the answers. Leave blank what you don't know — the system will work through it with you during the interview.

---

## 1. What you want to agentize

**Name or title of the process:**
_(can be informal)_

**Describe the process in 2-4 sentences:**
_(what problem it solves, what it does, what its objective is)_

**How is this done today, without the system?**
_(current manual flow, even if approximate)_

**What happens if the system doesn't exist or fails?**
_(impact or cost of not having it)_

---

## 2. Process flow

**How does the process start?**
_(what triggers it: a user, an event, an email, a cron job, a webhook...)_

**Main steps you have already identified:**
_(they don't need to be perfect or complete, write what you know)_

```
1.
2.
3.
4.
...
```

**How does the process end?**
_(what it produces when finished and to whom or what does that output go)_

**Are there decisions or branches in the flow?**
_(points where the process takes one path or another depending on some condition)_

**Are there repeating steps?**
_(loops or iterations)_

---

## 3. Technical context

**Does the process interact with external systems?**
_(CRMs, APIs, databases, email, Slack, internal tools...)_

| System | What information is read? | What information is written? |
| ------ | ------------------------- | ---------------------------- |
|        |                           |                              |
|        |                           |                              |

**Are there points where a human must review or approve before continuing?**
_(approvals, manual validations, control checkpoints)_

**Are there irreversible actions in the process?**
_(sending an email, making a payment, deleting data...)_

---

## 4. Existing skills and entities _(optional)_

**Do you have Skills already created that could be reused in this process?**
_(list their names or describe what they do)_

**Are there similar processes already agentized that can be used as reference?**

---

## 5. Known constraints _(optional)_

**Is there anything the system should never do?**

**Are there relevant legal, business, or technical restrictions?**

**Is there reference information the system should know?**
_(documentation, style guides, domain data, examples...)_

---

## 6. Expected result _(optional)_

**What does success look like when the system is working correctly?**

**Are there metrics or concrete criteria to know it's working well?**

---

_Paste the content of this template at the start of the conversation with the Agentic Architect._
