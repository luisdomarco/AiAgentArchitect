---
name: ski-pattern-analyzer
description: Analyzes all Audit and Score blocks in a qa-report.md to detect recurring failure and success patterns across phases and entities. Returns structured pattern data and prioritized improvement targets. Use at CP-CIERRE to power the Optimizer's proposals.
---

# Pattern Analyzer

## Input / Output

**Input:**

- `qa_report_content`: contenido completo del `qa-report.md`
- `meta_report_content`: contenido del `qa-meta-report.md` (opcional, para histórico)

**Output:**

- `failure_patterns`: array de `{ criterio, ocurrencias, fases_afectadas, impacto_score }`
- `success_patterns`: array de `{ criterio, ocurrencias, fases }`
- `efficiency_issues`: `{ fase, regeneraciones }` para fases con regeneraciones > 1
- `dimension_trends`: `{ dimension, score_promedio }` por dimensión
- `priority_targets`: array ordenado de `{ target_entity, descripcion_problema, prioridad }`

## Procedure

### Paso 1 — Extracción de bloques

Parsear el `qa-report.md` e identificar:

- Todos los bloques `## [Audit {fase}]` → extraer la tabla de cumplimiento
- Todos los bloques `### Score {fase}` → extraer scores por dimensión
- Bloques `## [Re-audit — {entidad} — {timestamp}]` → tratarlos como auditorías adicionales

Si existe `meta_report_content`, extraer entradas históricas de sesiones anteriores.

### Paso 2 — Análisis de fallos

Para cada criterio con estado ⚠️ o ❌:

1. Contar en cuántas fases/entidades apareció ese criterio con fallo
2. Identificar qué Rule está asociada
3. Estimar el impacto en el score (⚠️ = impacto medio, ❌ = impacto alto)

Ordenar por: `ocurrencias × impacto_score` (descendente)

### Paso 3 — Análisis de scores por dimensión

Calcular el promedio de cada dimensión a lo largo de todas las fases:

```
dimension_trend = {
  Completitud: promedio(todos los scores de Completitud),
  Calidad: promedio(todos los scores de Calidad),
  Cumplimiento: promedio(todos los scores de Cumplimiento),
  Eficiencia: promedio(todos los scores de Eficiencia)
}
```

Dimensiones con promedio < 6.0 → alta prioridad de mejora.

### Paso 4 — Análisis de eficiencia

Para cada fase, extraer el número de regeneraciones de las métricas del bloque Score.
Fases con regeneraciones > 1 → generar entrada en `efficiency_issues`.

### Paso 5 — Análisis de éxitos

Para cada criterio con estado ✅ **en todas las fases donde fue verificado**:

1. Registrarlo como patrón de éxito
2. Identificar qué Rule o diseño lo hace consistente

### Paso 6 — Generación de priority_targets

Para cada patrón de fallo, mapear a la entidad del sistema que debería ser modificada:

| Tipo de fallo                                         | Target probable                 |
| ----------------------------------------------------- | ------------------------------- |
| Criterio de rul-naming-conventions                    | `rul-naming-conventions`        |
| Checkpoint mal formado                                | `rul-checkpoint-behavior`       |
| Entrevista con múltiples preguntas                    | `rul-interview-standards`       |
| Formato de entidad incorrecto                         | `ski-entity-file-builder`       |
| Blueprint incompleto / exceso de regeneraciones en S2 | `age-spe-architecture-designer` |
| Discovery incompleto / trigger o pasos faltantes      | `age-spe-process-discovery`     |
| Score de Completitud bajo                             | entidad con más ⚠️ en S3        |

Ordenar `priority_targets` por `ocurrencias × impacto_score` → mayor primero.

## Examples

**Input (extracto de qa-report.md):**

```
## [Audit S1] — 2026-02-20T21:25:14
| rul-naming-conventions | ✅ | ... |
| rul-checkpoint-behavior | ⚠️ | Falta opción D |

## [Audit S3-age-spe-ejemplar]
| rul-naming-conventions | ❌ | Prefijo 'agent-' en lugar de 'age-spe-' |
| rul-checkpoint-behavior | ✅ | ... |
```

**Output:**

```json
{
  "failure_patterns": [
    {
      "criterio": "Checkpoint con 4 opciones (rul-checkpoint-behavior)",
      "ocurrencias": 2,
      "fases_afectadas": ["S1", "S2"],
      "impacto_score": "medio"
    },
    {
      "criterio": "Prefijo correcto en agent specialists (rul-naming-conventions)",
      "ocurrencias": 1,
      "fases_afectadas": ["S3"],
      "impacto_score": "alto"
    }
  ],
  "success_patterns": [
    {
      "criterio": "Una pregunta a la vez (rul-interview-standards)",
      "ocurrencias": 3,
      "fases": ["S1"]
    }
  ],
  "priority_targets": [
    {
      "target_entity": "rul-checkpoint-behavior",
      "descripcion_problema": "Falta opción D en 2 de 3 fases",
      "prioridad": "alta"
    },
    {
      "target_entity": "rul-naming-conventions",
      "descripcion_problema": "❌ prefijo incorrecto en S3",
      "prioridad": "alta"
    }
  ]
}
```

## Error Handling

- Si el `qa-report.md` no tiene bloques de Audit: retornar `{ failure_patterns: [], success_patterns: [], priority_targets: [] }` con nota "Sin datos suficientes para análisis"
- Si solo hay un bloque (un checkpoint): análisis parcial con nota explícita
- Si hay bloques de Re-audit: incluirlos en el análisis pero marcarlos como `tipo: "re-audit"` para distinguirlos
