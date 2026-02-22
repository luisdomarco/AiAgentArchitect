---
trigger: always_on
alwaysApply: true
tags: [qa, audit, evaluation]
---

## Context

El QA Layer de assistant-documentation-generator corre automáticamente tras cada checkpoint aprobado. Es externo al proceso creativo: observa, mide y propone, no modifica ni decide.

## Hard Constraints

- QA se activa DESPUÉS de que el usuario aprueba un checkpoint, nunca antes
- age-spe-auditor y age-spe-evaluator NO modifican ningún archivo
- age-spe-optimizer NO aplica propuestas automáticamente
- qa-report.md: siempre append, nunca sobreescribir. **Esta actualización debe hacerse en disco de forma inmediata** en el momento de la auditoría, no al final del proceso.
- El Auditor SIEMPRE lee archivos desde disco en el momento de la auditoría
- TRAS ESCRIBIR EL REPORTE EN DISCO: El Auditor o Evaluador **siempre debe emitir un resumen visible por chat al usuario** de máximo 5 líneas. El ciclo QA no es silencioso; el usuario debe saber qué se ha evaluado.

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
