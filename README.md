# 🤖 AiAgentArchitect

> **The Engine for Modular, Multi-Agent Systems.**

AiAgentArchitect is a meta-system designed to discover, architect, and implement high-performance agentic systems. By combining **BPM/BPA techniques** with a strictly decoupled **Entity-Based Architecture**, it transforms vague requirements into ready-to-use multi-agent structures.

---

## 🏛️ System Philosophy

The core of AiAgentArchitect is the decoupling of logic, capability, and rule. Every system is composed of 6 atomic entities:

| Entity                 | Purpose       | Role                                                         |
| :--------------------- | :------------ | :----------------------------------------------------------- |
| **Workflow** (`wor-`)  | Orchestration | The "brain" that coordinates agents and steps.               |
| **Agent** (`age-`)     | Execution     | Specialized entity with a specific domain of responsibility. |
| **Skill** (`ski-`)     | Capability    | Reusable packages (tools, APIs) that extend agent power.     |
| **Command** (`com-`)   | Direct Action | Deterministic, high-speed shortcuts for frequent tasks.      |
| **Rule** (`rul-`)      | Constraint    | The guardrails that guarantee quality and consistency.       |
| **Knowledge** (`kno-`) | Context       | Static data or documentation consulted on-demand.            |

---

## ⚙️ Core Mechanism: The 3tep Journey

AiAgentArchitect operates through a structured pipeline that ensures zero ambiguity from start to finish.

### Step 1: Process Discovery

The **Specialist Discovery Agent** conducts a structured interview using BPA/BPM techniques. It performs inverse engineering on vague requests and generates an **AS-IS Diagram** in Mermaid.

### Step 2: Architecture Design

The **Architecture Designer** translates the discovered process into a **Blueprint**. It selects the optimal combination of entities, assigns intricacy levels, and generates a **To-Be Architecture Diagram**.

### Step 3: Entity Implementation

The **Entity Builder** materializes the Blueprint into functional `.md` files. It applies strict formatting rules, manages character limits, and integrates the **Context Ledger** for inter-agent state management.

---

## 🛠️ Key Components & Features

### 🗂️ Context Management (Context Ledger)

Unlike traditional "stateless" agent flows, we implement a **Persistent Context Pattern**. The workflow manages a `context-ledger.md` to persist, filter, and route information between sequential agents, ensuring that each agent receives exactly what it needs and nothing more.

### 🛡️ Built-in QA Layer

Optionally, every generated system can include a dedicated QA Layer. This adds:

- **Auditor Agent**: Real-time compliance check against rules.
- **Evaluador Agent**: Weighted scoring of performance and quality.
- **Optimizer Agent**: Pattern detection to propose systemic improvements.

### 🏗️ Directory Structure

```text
(Project Root)
├── .agents/            # The Source of Truth
│   ├── workflows/      # Orchestrators and Agents
│   ├── skills/         # Modular capabilities
│   ├── rules/          # System guardrails
│   ├── knowledge-base/ # Static documentation
│   └── resources/      # Support templates and logic
├── repository/         # Index for entity reuse
└── scripts/           # Automation and utility scripts
```

---

## 🚀 Getting Started

To invoke the architect and start building your own agentic system:

1. **Invoke the Workflow**: Call `/wor-agentic-architect`.
2. **Follow the Steps**: The system will guide you through Discovery, Architecture, and Implementation.
3. **Approve Checkpoints**: Each phase requires your explicit validation before proceeding.

---

## 🔗 Related Documentation

- [Entity Fundamentals](.agents/knowledge-base/kno-fundamentals-entities.md)
- [System Architecture Details](.agents/knowledge-base/kno-system-architecture.md)
- [Handoff & Context Schemas](.agents/knowledge-base/kno-handoff-schemas.md)

---

_Created with ❤️ for Advanced Agentic Coding._
