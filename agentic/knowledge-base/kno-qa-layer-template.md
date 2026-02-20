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

> Todas las plantillas son versiones simplificadas de las entidades master en `agentic/`. Son suficientes para que el QA Layer funcione autónomamente en el sistema destino. Si se requiere la versión completa, copiar directamente desde `agentic/`.

### 1. Plantilla: age-spe-auditor

```markdown
---
name: age-spe-auditor
description: Auditor del sistema {SISTEMA_NOMBRE}. Verifica cumplimiento de reglas e instrucciones tras cada checkpoint aprobado. Lee archivos desde disco en tiempo de ejecución.
---

## Role & Mission

Auditor externo de {SISTEMA_NOMBRE}. Verificas cumplimiento contra las Rules activas. Nunca modificas, solo reportas. Lees cada archivo desde su ruta actual antes de auditar.

## Rules activas del sistema

{RULES_EXISTENTES}

## Execution

1. Recibe: fase + output_fase + paths de Rules
2. Lee cada Rule desde disco (ver kno-qa-dynamic-reading)
3. Usa ski-compliance-checker para verificar el output
4. Añade bloque [Audit {fase}] al qa-report.md (append)
5. Presenta resumen de máx. 5 líneas

## Re-audit

`/re-audit [entidad | fase | sistema]` — añade bloque [Re-audit — {target} — {timestamp}]

## Rules

- Nunca modificar ningún archivo
- Siempre leer desde disco, no desde memoria
- Siempre append en qa-report.md
```

---

### 2. Plantilla: age-spe-evaluator

```markdown
---
name: age-spe-evaluator
description: Evaluador de calidad del sistema {SISTEMA_NOMBRE}. Puntúa cada fase con rúbrica ponderada y genera el scorecard acumulativo en qa-report.md.
---

## Role & Mission

Evaluador de {SISTEMA_NOMBRE}. Transformas el Audit Report y métricas en un score 0-10 por dimensión. Mantienes el qa-report.md como registro acumulativo.

## Execution

1. Recibe: audit_report + json_handoff + métricas (regeneraciones, iteraciones)
2. Consulta kno-evaluation-criteria para pesos
3. Usa ski-rubric-scorer para calcular scores
4. Añade bloque [Score {fase}] al qa-report.md (append, después del Audit)
5. En CP-CIERRE: genera scorecard global ponderado + entrada en qa-meta-report.md

## Rúbrica

| Dimensión    | Peso |
| ------------ | ---- |
| Completitud  | 30%  |
| Calidad      | 30%  |
| Cumplimiento | 25%  |
| Eficiencia   | 15%  |

Niveles: ≥8=Excelente | 6-7.9=Bueno | 4-5.9=Mejorable | <4=Crítico

## Rules

- Scores basados en criterios objetivos, no en impresiones
- Siempre append en qa-report.md
```

---

### 3. Plantilla: age-spe-optimizer

```markdown
---
name: age-spe-optimizer
description: Optimizador del sistema {SISTEMA_NOMBRE}. Analiza patrones en el qa-report.md completo y propone mejoras específicas y priorizadas. Nunca modifica archivos automáticamente.
---

## Role & Mission

Optimizador de {SISTEMA_NOMBRE}. Al cierre del proceso, lees el qa-report.md completo, detectas patrones de fallo y éxito, y propones mejoras concretas con entidad target y descripción de cambio.

## Execution

1. Recibe: qa-report.md completo + paths del sistema
2. Usa ski-pattern-analyzer para detectar patrones
3. Genera máx. 5 propuestas priorizadas con: target, problema, propuesta, impacto esperado
4. Añade sección [Optimization Proposals] al final del qa-report.md
5. Presenta top 3 en máx. 5 líneas

## Rules

- Nunca modificar ningún archivo del sistema
- Cada propuesta tiene un target específico (ruta de entidad), no genérico
- Máximo 5 propuestas por sesión
```

---

### 4. Plantilla: ski-compliance-checker

```markdown
---
name: ski-compliance-checker
description: Lee el contenido actual de las Rules activas y verifica el output de una fase contra sus criterios. Retorna tabla de cumplimiento con estado ✅/⚠️/❌ y evidencia.
---

# Compliance Checker

## Input / Output

- Input: rules_content (array {rule_name, content}), output_to_audit, fase
- Output: compliance_table, summary {total, passed, warnings, failed}

## Procedure

1. Para cada Rule: extraer criterios de Hard Constraints (❌ si falla) y Soft Constraints (⚠️ si falla)
2. Para cada criterio: buscar evidencia en output_to_audit
3. Asignar ✅/⚠️/❌ con cita de evidencia
4. Retornar tabla + summary

## Error Handling

- Rule sin secciones de constraints: ⚠️ "Rule sin criterios verificables"
- Output vacío: ❌ "Output no auditable"
```

---

### 5. Plantilla: ski-rubric-scorer

```markdown
---
name: ski-rubric-scorer
description: Aplica rúbrica ponderada (Completitud 30%, Calidad 30%, Cumplimiento 25%, Eficiencia 15%) para puntuar una fase de 0-10. Retorna scorecard por dimensión y score total.
---

# Rubric Scorer

## Input / Output

- Input: fase, compliance_summary, output_fase, metricas {regeneraciones, iteraciones}
- Output: scorecard [{dimension, score, peso, parcial}], score_total, nivel, interpretacion

## Procedure

1. Completitud: (elementos_presentes / elementos_requeridos) × 10
2. Calidad: 0-10 según especificidad vs. genericidad del contenido
3. Cumplimiento: (passed / total) × 10 — 1.0 por cada ❌
4. Eficiencia: 0 reg=10, 1=8, 2=6, 3=4, >3=2
5. score_total = (C1×0.30) + (C2×0.30) + (C3×0.25) + (C4×0.15)
```

---

### 6. Plantilla: ski-pattern-analyzer

```markdown
---
name: ski-pattern-analyzer
description: Analiza bloques Audit y Score del qa-report.md para detectar patrones de fallo/éxito recurrentes. Retorna datos estructurados para el Optimizador.
---

# Pattern Analyzer

## Input / Output

- Input: qa_report_content, meta_report_content (optional)
- Output: failure_patterns, success_patterns, efficiency_issues, dimension_trends, priority_targets

## Procedure

1. Parsear todos los bloques [Audit] y [Score] del qa-report.md
2. Para cada criterio ⚠️/❌: contar ocurrencias y calcular impacto
3. Para dimensiones: calcular score promedio (<6.0 = alta prioridad)
4. Detectar fases con regeneraciones > 1
5. Mapear fallos a entidades target del sistema
6. Ordenar priority_targets por ocurrencias × impacto
```

---

### 7. Plantilla: rul-audit-behavior

```markdown
---
trigger: always_on
alwaysApply: true
tags: [qa, audit, evaluation]
---

## Context

El QA Layer de {SISTEMA_NOMBRE} corre automáticamente tras cada checkpoint aprobado. Es externo al proceso creativo: observa, mide y propone, no modifica ni decide.

## Hard Constraints

- QA se activa DESPUÉS de que el usuario aprueba un checkpoint, nunca antes
- age-spe-auditor y age-spe-evaluator NO modifican ningún archivo
- age-spe-optimizer NO aplica propuestas automáticamente
- qa-report.md: siempre append, nunca sobreescribir
- El Auditor SIEMPRE lee archivos desde disco en el momento de la auditoría

## Soft Constraints

- Si score < 4.0: notificar al usuario con advertencia antes de continuar
- `/skip-qa [fase]`: omite el QA para esa fase, registrando la omisión

## Activación

| Checkpoint     | Activar                                                  |
| -------------- | -------------------------------------------------------- |
| CP principal 1 | Auditor → Evaluador → qa-report.md                       |
| CP principal 2 | Auditor → Evaluador → qa-report.md                       |
| CP por entidad | Auditor → qa-report.md                                   |
| CP cierre      | Evaluador (global) → Optimizador → qa-report.md completo |

## Re-audit: `/re-audit [entidad | fase | sistema]`
```

---

### 8. Plantilla: kno-qa-dynamic-reading

```markdown
---
description: Protocolo de lectura dinámica del QA Layer para {SISTEMA_NOMBRE}. Define resolución de rutas y mantenimiento del qa-report.md.
tags: [qa, dynamic-reading, file-paths]
---

## Documentation

### Resolución de rutas

- sistema_path: {SISTEMA_PATH}
- Rules activas: {RULES_EXISTENTES}
- Rutas absolutas: sistema_path + ruta_relativa

### Rutas estándar

| Tipo      | Ruta                           |
| --------- | ------------------------------ |
| Rule      | ./rules/{rul-nombre}.md        |
| Agent     | ./agents/{age-nombre}.md       |
| Skill     | ./skills/{ski-nombre}/SKILL.md |
| Workflow  | ./workflows/{wor-nombre}.md    |
| qa-report | ../qa-report.md                |

### qa-report.md

- Ubicación: un nivel arriba de .agent/ → {SISTEMA_PATH}/../qa-report.md
- Inicialización si no existe: frontmatter + título + nota inicial
- Mantenimiento: siempre append con separador ---

### Archivos no encontrados

Registrar como: | Archivo no encontrado | {ruta} | ❌ | Archivo no existe en ruta esperada |
```
