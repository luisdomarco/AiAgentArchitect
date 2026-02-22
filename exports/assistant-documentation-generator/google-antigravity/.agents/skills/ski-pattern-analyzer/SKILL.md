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
