---
name: ski-diagram-generator
description: Generates Mermaid diagrams for process flows, AS-IS states, and entity architectures. Use whenever a visual representation of a process or architecture is needed for validation or documentation, such as at Step 1 (AS-IS) and Step 2 (architecture blueprint).
allowed-tools: Write
user-invocable: false
---

# Diagram Generator Skill

Generates diagrams in Mermaid syntax to represent processes, flows, and agentic entity architectures. Diagrams are importable directly into draw.io/diagrams.net.

## Input / Output

**Input:**

- Type of diagram to generate: `as-is` | `architecture` | `sequence` | `flow`
- Process or architecture data to represent (from the corresponding handoff JSON)

**Output:**

- Mermaid code block ready to render and export to draw.io

---

## Procedure

### 1. Diagram type selection

| Type           | When to use it                                              | Mermaid syntax    |
| -------------- | ----------------------------------------------------------- | ----------------- |
| `as-is`        | When closing Step 1 to reflect the current process          | `flowchart TD`    |
| `architecture` | When closing Step 2 to show entities and relationships      | `flowchart TD`    |
| `sequence`     | When the order of interactions between entities is critical | `sequenceDiagram` |
| `flow`         | For the flow diagram in `process-overview.md`               | `flowchart TD`    |

---

### 2. Style conventions

**Node shapes according to role:**

```
([text])   → Start / End (stadium shape)
[text]     → Process / Entity (rectangle)
{text}     → Decision (diamond)
[(text)]   → Database / External system (cylinder)
((text))   → Event (circle)
```

**Arrow labels:**

```
A -->|"action or data"| B     → flow with label
A -.->|"optional"| B          → optional or conditional flow
A ==>|"critical"| B           → main or critical flow
```

**Subgraphs for grouping related entities:**

```
subgraph "Group name"
  entity1
  entity2
end
```

---

### 3. AS-IS diagram construction

Represents the process as it was described in Step 1.

Required structure:

1. Start node with the trigger
2. Process steps as rectangular nodes
3. Decisions as diamond nodes with two labeled branches
4. External systems as cylindrical nodes
5. Human checkpoints with explicit label
6. End node with the output

**Template:**

```mermaid
flowchart TD
    START([Trigger: trigger name])

    P1[Step 1]
    P2[Step 2]
    D1{Condition?}
    P3A[Step if Yes]
    P3B[Step if No]
    EXT[(External system)]
    CP1{{"👤 Checkpoint: human approval"}}
    END([Output: output description])

    START --> P1
    P1 --> P2
    P2 --> D1
    D1 -->|Yes| P3A
    D1 -->|No| P3B
    P3A --> EXT
    EXT --> CP1
    CP1 -->|Approved| END
    CP1 -->|Rejected| P1
```

---

### 4. Architecture diagram construction

Represents the Blueprint entities and their relationships.

Node prefix convention to identify entity type:

```
WF[wor-name]          → Workflow
AGS[age-spe-name]     → Agent Specialist
AGU[age-sup-name]     → Agent Supervisor
SK[ski-name]          → Skill
CMD[com-name]         → Command
RUL[rul-name]         → Rule
KB[(kno-name)]        → Knowledge-base
EXT[(External system)] → External system
```

**Template:**

```mermaid
flowchart TD
    U([User])
    WF[wor-workflow-name]

    subgraph "Agents"
        AG1[age-spe-agent-1]
        AG2[age-spe-agent-2]
    end

    subgraph "Skills"
        SK1[ski-skill-1]
        SK2[ski-skill-2]
    end

    subgraph "Resources"
        RUL1[rul-rule-1]
        KB1[(kno-knowledge-base)]
    end

    U -->|input| WF
    WF -->|invokes| AG1
    WF -->|invokes| AG2
    AG1 -->|uses| SK1
    AG2 -->|uses| SK1
    AG2 -->|uses| SK2
    AG1 -.->|consults| KB1
    AG1 -.->|conditioned by| RUL1
    AG2 -.->|conditioned by| RUL1
    WF -->|output| U
```

---

### 5. Presentation to the user

Always present the diagram with:

1. A context line: _"This is the [type] diagram of the [name] process."_
2. The Mermaid code block.
3. An import instruction: _"To open it in draw.io: Extras → Edit Diagram → paste the code."_
4. The validation question: _"Does it correctly reflect the [process / architecture]?"_

---

## Examples

**Example — AS-IS diagram of email classification**

```mermaid
flowchart TD
    START([📧 Incoming email])

    P1[Read and analyze email]
    D1{Type of request?}
    P2A[Route: Billing]
    P2B[Route: Technical support]
    P2C[Route: Commercial]
    EXT[(CRM Zendesk)]
    CP1{{"👤 Checkpoint: ambiguous cases"}}
    END([✅ Ticket created and assigned])

    START --> P1
    P1 --> D1
    D1 -->|Billing| P2A
    D1 -->|Technical| P2B
    D1 -->|Commercial| P2C
    D1 -->|Ambiguous| CP1
    P2A & P2B & P2C --> EXT
    CP1 -->|Classified| EXT
    EXT --> END
```

---

## Error Handling

- **Diagram too complex to render:** Split into two diagrams (one per sub-process or architecture layer).
- **Node with very long name:** Shorten to a descriptive alias on the node and add a legend if necessary.
- **User indicates the diagram does not reflect the process:** Ask which part is incorrect and correct only that part, not regenerate everything.
