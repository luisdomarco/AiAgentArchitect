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
