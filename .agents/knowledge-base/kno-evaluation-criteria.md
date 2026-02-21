---
description: Criterios, pesos y umbrales de evaluación para el QA Layer. Define la rúbrica de scoring por dimensión y por tipo de entidad, los pesos de fase para el scorecard global, y los umbrales de nivel de calidad.
tags: [qa, evaluation, rubric, scoring]
---

## Table of Contents

1. Rúbrica general (por dimensión)
2. Ajustes por tipo de entidad (S3)
3. Pesos de fase para el scorecard global
4. Umbrales de nivel de calidad
5. Penalizaciones y bonificaciones

---

## Documentation

### 1. Rúbrica general (por dimensión)

La rúbrica estándar se aplica a todas las fases. Cuatro dimensiones con pesos ponderados:

| Dimensión        | Peso | Qué mide                                                                   |
| ---------------- | ---- | -------------------------------------------------------------------------- |
| **Completitud**  | 30%  | ¿El output contiene todos los elementos requeridos para su fase?           |
| **Calidad**      | 30%  | ¿El contenido es específico y contextualizado, no genérico ni placeholder? |
| **Cumplimiento** | 25%  | ¿El output pasó el Audit sin alertas ⚠️ ni fallos ❌?                      |
| **Eficiencia**   | 15%  | ¿Cuántas regeneraciones/iteraciones necesitó el proceso?                   |

**Score total = (Completitud × 0.30) + (Calidad × 0.30) + (Cumplimiento × 0.25) + (Eficiencia × 0.15)**

---

### 2. Ajustes por tipo de entidad (S3)

En S3 (Entity Implementation), la Completitud verifica que todas las secciones obligatorias del tipo de entidad están presentes y no vacías:

| Tipo                          | Secciones obligatorias para Completitud                                                                                    |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Workflow (`wor-`)             | Role & Mission, Context, Goals, Tasks, Agents, Workflow Sequence, Checkpoints, Input, Output, Rules, Definition of success |
| Agent Specialist (`age-spe-`) | Role & Mission, Context, Goals, Tasks, Skills, Execution Protocol, Input, Output, Rules, Definition of success             |
| Skill (`ski-`)                | Input/Output, Procedure, Examples, Error Handling                                                                          |
| Rule (`rul-`)                 | Context, Hard Constraints, Soft Constraints                                                                                |
| Knowledge-base (`kno-`)       | Table of Contents, Documentation (≥2 subsecciones)                                                                         |
| Command (`com-`)              | System prompt con al menos 3 instrucciones estructuradas                                                                   |

Para Calidad en S3, señales de alta calidad:

- Descriptions de >40 palabras con contexto real del proceso (no descripción del tipo)
- Goals con resultados esperados explícitos, no solo verbos de intención
- Execution Protocol con ramificaciones y manejo de errores (para `complex`)
- Examples en Skills que reflejan el caso de uso real del sistema

---

### 3. Pesos de fase para el scorecard global

El scorecard global pondera las tres fases del proceso:

| Fase                       | Peso | Justificación                                                            |
| -------------------------- | ---- | ------------------------------------------------------------------------ |
| S1 — Process Discovery     | 25%  | Sienta las bases, pero errores aquí se suelen detectar y corregir en S2  |
| S2 — Architecture Design   | 35%  | Define la estructura completa; errores aquí se arrastran al S3           |
| S3 — Entity Implementation | 40%  | Es el output final real. Errores aquí afectan directamente la usabilidad |

**Score global = (Score S1 × 0.25) + (Score S2 × 0.35) + (Score S3 × 0.40)**

Si el proceso usó Modo Express (sin S2 formal), redistribuir: S1=35%, S3=65%.

---

### 4. Umbrales de nivel de calidad

| Score     | Nivel         | Interpretación                                                      |
| --------- | ------------- | ------------------------------------------------------------------- |
| ≥ 8.0     | **Excelente** | El proceso fue sólido. Pocas o ninguna mejora urgente.              |
| 6.0 – 7.9 | **Bueno**     | Resultado funcional con oportunidades de mejora no críticas.        |
| 4.0 – 5.9 | **Mejorable** | Hay patrones problemáticos que conviene abordar.                    |
| < 4.0     | **Crítico**   | El proceso tiene fallos estructurales. El Optimizador emite alerta. |

---

### 5. Penalizaciones y bonificaciones

**Penalizaciones automáticas:**

- ❌ Hard Constraint violado en Audit: -1.0 punto en score de Cumplimiento por cada fallo
- Placeholders sin rellenar (`[descripción]`, `[nombre]`) detectados: -0.5 en Calidad por cada uno
- Más de 3 regeneraciones en una misma entidad de S3: Eficiencia = 1.0 (no penaliza Completitud ni Calidad)

**Bonificaciones:**

- Ninguna bonificación automática — el scoring máximo es 10 sin necesidad de extras
- En el texto de interpretación, el Evaluador puede destacar aspectos positivos notables

---

### 6. Scoring de Eficiencia — tabla de referencia

| Regeneraciones en la fase | Score Eficiencia |
| ------------------------- | ---------------- |
| 0                         | 10.0             |
| 1                         | 8.0              |
| 2                         | 6.0              |
| 3                         | 4.0              |
| 4                         | 2.0              |
| ≥ 5                       | 1.0              |

Las iteraciones de ajuste (opción B del checkpoint, sin regenerar desde cero) cuentan como 0.3 cada una, sumadas al score de regeneraciones.
