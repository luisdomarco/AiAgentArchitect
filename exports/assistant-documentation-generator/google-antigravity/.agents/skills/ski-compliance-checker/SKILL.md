---
name: ski-compliance-checker
description: Reads the current content of active Rules from disk paths, extracts compliance criteria, and verifies them against the provided phase output. Returns a structured compliance table. Use after any phase checkpoint to power the audit report.
---

# Compliance Checker

## Input / Output

**Input:**

- `rules_content`: array de objetos `{ rule_name, content }` con el contenido actual de cada Rule leída desde disco
- `output_to_audit`: el contenido del output de la fase (JSON de handoff, archivo de entidad, etc.)
- `fase`: identificador de la fase auditada (`S1 | S2 | S3-N`)
- `reasoning_trace`: (Opcional) El log de pensamiento del agente estructurado en `<sys-eval>`.

**Output:**

- `compliance_table`: array de objetos `{ criterio, rule, estado, evidencia }`
- `summary`: `{ total: N, passed: X, warnings: Y, failed: Z }`

## Procedure

### Paso 1 — Extracción de criterios

Para cada Rule en `rules_content`:

1. Identificar la sección `## Hard Constraints` → criterios obligatorios (fallo = ❌)
2. Identificar la sección `## Soft Constraints` → criterios recomendados (fallo = ⚠️)
3. Extraer cada criterio como una condición verificable

### Paso 2 — Verificación

Para cada criterio extraído:

1. Buscar en `output_to_audit` y en `reasoning_trace` la evidencia de cumplimiento o incumplimiento
2. Asignar estado:
   - `✅` — El output cumple explícitamente el criterio con evidencia clara. Si el criterio requería razonamiento (Hard Constraint LLM), el `reasoning_trace` contiene prueba de obediencia.
   - `⚠️` — El output cumple parcialmente o la evidencia es ambigua (Soft Constraint). O si el output cumple, pero el agente omitió el razonamiento dictado por `rul-strict-compliance`.
   - `❌` — El output no cumple el criterio (Hard Constraint violado) o flagrante negligencia cognitiva.
3. Registrar la evidencia concreta: cita textual del output o del trace que justifica el estado.

### Paso 3 — Composición de la tabla

```markdown
| Criterio                         | Rule         | Estado     | Evidencia                         |
| -------------------------------- | ------------ | ---------- | --------------------------------- |
| {descripción corta del criterio} | {rul-nombre} | {✅/⚠️/❌} | {cita o descripción de evidencia} |
```

### Paso 4 — Generación del resumen

```json
{
  "total": N,
  "passed": X,
  "warnings": Y,
  "failed": Z
}
```

## Examples

**Input simplificado:**

```
rules_content: [
  { rule_name: "rul-naming-conventions", content: "## Hard Constraints\n- Todos los agents deben usar prefijo age-spe- o age-sup-\n- Nombres en kebab-case, máx. 40 caracteres..." }
]
output_to_audit: "name: age-architecture-designer\ndescription: ..."
```

**Output:**

```json
{
  "compliance_table": [
    {
      "criterio": "Prefijo correcto para agent specialist",
      "rule": "rul-naming-conventions",
      "estado": "❌",
      "evidencia": "El nombre 'age-architecture-designer' usa 'age-' en lugar de 'age-spe-'"
    }
  ],
  "summary": { "total": 1, "passed": 0, "warnings": 0, "failed": 1 }
}
```

## Error Handling

- Si una Rule no tiene sección `## Hard Constraints` ni `## Soft Constraints`: registrar `⚠️ Rule sin criterios verificables — revisar formato`
- Si el output_to_audit está vacío o malformado: registrar `❌ Output vacío o sin estructura — no auditable`
- Si no se puede determinar el cumplimiento con certeza: asignar `⚠️` con evidencia `"No determinable con el output disponible"`
