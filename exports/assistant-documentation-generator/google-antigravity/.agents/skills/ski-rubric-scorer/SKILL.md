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
