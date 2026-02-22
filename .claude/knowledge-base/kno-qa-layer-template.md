---
description: Plantillas parametrizables del QA Layer completo (3 agents + 3 skills + 1 rule + 1 knowledge-base) para embeber en sistemas nuevos. Usadas por ski-qa-embed. Los tokens {SISTEMA_NOMBRE}, {WORKFLOW_PATH}, {RULES_EXISTENTES} y {SISTEMA_PATH} se sustituyen en la parametrización.
tags: [qa, templates, embed, propagation]
---

## Table of Contents

1. Plantilla: age-spe-auditor
2. Plantilla: age-spe-evaluator
3. Plantilla: age-spe-optimizer
4. Plantilla: ski-compliance-checker
5. Plantilla: ski-rubric-scorer
6. Plantilla: ski-pattern-analyzer
7. Plantilla: rul-audit-behavior
8. Plantilla: kno-qa-dynamic-reading

---

## Documentation

> Todas las plantillas en bruto han sido externalizadas para optimizar la carga estática. El orquestador o la skill `ski-qa-embed` ya no extraen los schemas directamente desde este knowledge base, sino que este archivo actúa apuntando sus lógicas.
> **Para leer los markdown en bruto (raw templates) extraíbles de los tres agentes, tres skills y base de conocimiento que componen el QA layer, lee:**
> `../resources/res-qa-layer-raw-templates.md`
