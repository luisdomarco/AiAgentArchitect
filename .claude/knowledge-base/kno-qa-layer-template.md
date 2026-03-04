---
description: Parametrizable templates for the complete QA Layer (3 agents + 3 skills + 1 rule + 1 knowledge-base) for embedding in new systems. Used by ski-qa-embed. The tokens {SYSTEM_NAME}, {WORKFLOW_PATH}, {EXISTING_RULES}, and {SYSTEM_PATH} are substituted during parametrization.
tags: [qa, templates, embed, propagation]
---

## Table of Contents

1. Template: age-spe-auditor
2. Template: age-spe-evaluator
3. Template: age-spe-optimizer
4. Template: ski-compliance-checker
5. Template: ski-rubric-scorer
6. Template: ski-pattern-analyzer
7. Template: rul-audit-behavior
8. Template: kno-qa-dynamic-reading

---

## Documentation

> All raw templates have been externalized to optimize static loading. The orchestrator or the `ski-qa-embed` skill no longer extract schemas directly from this knowledge base; instead, this file acts as a pointer to their logic.
> **To read the raw markdown (raw templates) extractable from the three agents, three skills, and knowledge base that make up the QA layer, read:**
> `../resources/res-qa-layer-raw-templates.md`
