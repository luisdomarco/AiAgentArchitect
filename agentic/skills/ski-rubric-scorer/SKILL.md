---
name: ski-rubric-scorer
description: Applies a weighted rubric (Completeness 30%, Quality 30%, Compliance 25%, Efficiency 15%) to score a process phase from 0-10 per dimension. Uses audit results and process metrics as input. Returns a structured scorecard. Use after each compliance check to power the evaluation report.
---

# Rubric Scorer

## Input / Output

**Input:**

- `fase`: identificador de fase (`S1 | S2 | S3 | global`)
- `compliance_summary`: `{ total, passed, warnings, failed }` del Audit
- `output_fase`: el output generado en la fase (JSON de handoff o entidad)
- `metricas`: `{ regeneraciones: N, iteraciones: N }`
- `criteria_config`: configuración de pesos desde `kno-evaluation-criteria` (opcional, usa defaults si no se provee)

**Output:**

- `scorecard`: array de `{ dimension, score, peso, parcial }`
- `score_total`: número entre 0-10
- `nivel`: `Excelente | Bueno | Mejorable | Crítico`
- `interpretacion`: 1-2 frases de contexto

## Procedure

### Paso 1 — Scoring de Completitud (peso: 30%)

Verificar que el output contiene todos los elementos requeridos para la fase:

| Fase   | Elementos requeridos                                                                            |
| ------ | ----------------------------------------------------------------------------------------------- |
| S1     | proceso.nombre, proceso.objetivo, proceso.pasos, proceso.trigger, proceso.input, proceso.output |
| S2     | entidades (array no vacío), orden_creacion, diagrama_arquitectura                               |
| S3     | archivo con todas las secciones del formato para su tipo de entidad                             |
| global | proceso-overview.md con todas sus secciones                                                     |

Scoring: `(elementos_presentes / elementos_requeridos) × 10`

### Paso 2 — Scoring de Calidad (peso: 30%)

Evaluar si el contenido es específico vs. genérico. Señales de calidad alta:

- Descriptions de >50 palabras con contexto real del proceso
- Goals con verbos de acción concretos (no "gestionar", "asegurar" genérico)
- Tasks con pasos específicos, no bullet genérico
- Examples en Skills que corresponden al contexto real

Señales de baja calidad:

- Placeholders sin rellenar (`[descripción]`, `[nombre]`)
- Descripciones de una sola línea en entidades `complex`
- Repetición literal del objetivo como descripción

Scoring: `0`=todo genérico, `5`=mitad específico, `10`=todo específico y contextualizado

### Paso 3 — Scoring de Cumplimiento (peso: 25%)

Directo desde el Audit Report:

```
score_cumplimiento = (passed / total) × 10
```

Si hay `❌` (Hard Constraints): penalización adicional de -1 punto por cada fallo.

### Paso 4 — Scoring de Eficiencia (peso: 15%)

| Regeneraciones | Score |
| -------------- | ----- |
| 0              | 10    |
| 1              | 8     |
| 2              | 6     |
| 3              | 4     |
| >3             | 2     |

### Paso 5 — Score total ponderado

```
score_total = (completitud × 0.30) + (calidad × 0.30) + (cumplimiento × 0.25) + (eficiencia × 0.15)
```

Niveles:

- `≥ 8.0` → **Excelente**
- `6.0 – 7.9` → **Bueno**
- `4.0 – 5.9` → **Mejorable**
- `< 4.0` → **Crítico**

### Paso 6 — Interpretación

Generar 1-2 frases que expliquen el resultado de forma accionable:

- Si score alto: qué funcionó bien
- Si score bajo: cuál dimensión arrastró más el resultado y por qué

## Examples

**Input:**

```json
{
  "fase": "S1",
  "compliance_summary": { "total": 5, "passed": 4, "warnings": 1, "failed": 0 },
  "metricas": { "regeneraciones": 1, "iteraciones": 3 },
  "output_fase": { "proceso": { "nombre": "...", "objetivo": "...", "pasos": [...], ... } }
}
```

**Output:**

```json
{
  "scorecard": [
    { "dimension": "Completitud", "score": 9.0, "peso": "30%", "parcial": 2.7 },
    { "dimension": "Calidad", "score": 7.5, "peso": "30%", "parcial": 2.25 },
    {
      "dimension": "Cumplimiento",
      "score": 8.0,
      "peso": "25%",
      "parcial": 2.0
    },
    { "dimension": "Eficiencia", "score": 8.0, "peso": "15%", "parcial": 1.2 }
  ],
  "score_total": 8.15,
  "nivel": "Excelente",
  "interpretacion": "El Discovery capturó todos los elementos clave del proceso. La calidad del contenido es sólida aunque podría ser más específica en la descripción de decisiones."
}
```

## Error Handling

- Si `compliance_summary` está vacío: usar `{ total: 1, passed: 0, warnings: 0, failed: 1 }` y registrar nota en interpretación
- Si no se provee `criteria_config`: usar weights por defecto (30/30/25/15)
- Si el output de fase no permite evaluar Completitud: asignar score 5 con nota "Output parcial — evaluación aproximada"
