---
trigger: always_on
alwaysApply: true
tags: [qa, audit, evaluation, optimization]
---

## Context

Esta rule define el comportamiento del ciclo QA (Auditoría + Evaluación + Optimización) como una capa transversal del sistema. El QA Layer corre automáticamente tras cada checkpoint aprobado, sin necesidad de que el usuario lo active. Su objetivo es garantizar que el sistema se auto-evalúa de forma continua y acumula conocimiento para mejorar.

El QA Layer es externo al proceso creativo: observa, mide y propone, pero nunca modifica ni toma decisiones por el usuario.

## Hard Constraints

- El QA Layer se activa **después** de que el usuario aprueba un checkpoint, nunca antes ni en lugar de él.
- El Auditor (`age-spe-auditor`) y el Evaluador (`age-spe-evaluator`) **no modifican ningún archivo** del sistema auditado.
- El Optimizador (`age-spe-optimizer`) **no aplica ninguna propuesta automáticamente** — toda modificación requiere decisión explícita del usuario.
- El `qa-report.md` se actualiza siempre en modo **append** — nunca se sobreescribe ni se eliminan bloques anteriores.
- El Auditor **siempre lee los archivos de entidades y Rules desde disco** en el momento de la auditoría, nunca desde versiones en memoria.
- El resumen QA presentado al usuario tras cada checkpoint **no debe superar 5 líneas** — el flujo del proceso no debe ser interrumpido.

## Soft Constraints

- Si el score de una fase es `< 4.0` (Crítico), el orquestador puede opcionalmente notificar al usuario con una advertencia antes de continuar al siguiente paso.
- El ciclo QA en CP-S3-N (por entidad) puede limitarse solo al Auditor (sin Evaluador) si el número de entidades es > 7, para no alargar el proceso.
- Si el usuario rechaza explícitamente el QA (`/skip-qa`), el ciclo puede omitirse para esa fase, pero se registra la omisión en el `qa-report.md`.

## Activación automática

| Evento             | Activar                          | Output                                         |
| ------------------ | -------------------------------- | ---------------------------------------------- |
| CP-S1 aprobado     | Auditor (S1) → Evaluador (S1)    | Bloque [Audit S1] + [Score S1] en qa-report.md |
| CP-S2 aprobado     | Auditor (S2) → Evaluador (S2)    | Bloque [Audit S2] + [Score S2] en qa-report.md |
| CP-S3-N aprobado   | Auditor (entidad N)              | Bloque [Audit S3-{entidad}] en qa-report.md    |
| CP-CIERRE aprobado | Evaluador (global) → Optimizador | Scorecard global + Proposals en qa-report.md   |

## Re-audit bajo demanda

El usuario puede lanzar en cualquier momento:

```
/re-audit [entidad | fase | sistema]
```

Ejemplos válidos:

- `/re-audit rul-naming-conventions` → re-audita ese archivo específico
- `/re-audit S2` → re-audita toda la fase S2 con el contenido actual
- `/re-audit sistema` → re-audita todas las entidades generadas

El re-audit añade un bloque `## [Re-audit — {target} — {timestamp}]` al final del `qa-report.md`. Nunca sobreescribe auditorías anteriores.

## Omisión voluntaria

El usuario puede omitir el QA para una fase con:

```
/skip-qa [fase]
```

Esto registra en el `qa-report.md`:

```markdown
## [QA Omitido — {fase}] — {timestamp}

_El usuario omitió el ciclo QA para esta fase._
```

## Responsabilidades por agente

| Agente              | Puede                                              | No puede                                         |
| ------------------- | -------------------------------------------------- | ------------------------------------------------ |
| `age-spe-auditor`   | Leer archivos, reportar cumplimiento               | Modificar, sugerir mejoras de contenido          |
| `age-spe-evaluator` | Calcular scores, escribir en qa-report.md          | Modificar entidades, emitir juicios cualitativos |
| `age-spe-optimizer` | Proponer mejoras con target y descripción concreta | Aplicar cambios, modificar ningún archivo        |
