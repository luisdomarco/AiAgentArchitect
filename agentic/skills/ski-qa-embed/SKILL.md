---
name: ski-qa-embed
description: Transversal skill that takes a freshly generated system path and embeds the QA Layer (3 agents + 3 skills + 1 rule + 1 knowledge-base) into it. Parametrizes templates from kno-qa-layer-template with the target system's name and rules. Also inserts QA hooks into the target system's workflow and initializes a blank qa-report.md. Use after the packaging step when the user opts to embed QA in the new system.
---

# QA Embed

## Input / Output

**Input:**

- `sistema_path`: ruta base del sistema destino, p.ej. `exports/mi-sistema/google-antigravity/.agent/`
- `sistema_nombre`: nombre del sistema (p.ej. `mi-sistema`)
- `workflow_path`: ruta del workflow principal del sistema destino (p.ej. `./workflows/wor-mi-nombre.md`)
- `rules_existentes`: lista de rutas de Rules del sistema destino (p.ej. `["./rules/rul-mi-rule.md"]`)

**Output:**

- Archivos creados en `sistema_path/agents/` (3 agents QA parametrizados)
- Archivos creados en `sistema_path/skills/` (3 skills QA)
- Archivo creado en `sistema_path/rules/rul-audit-behavior.md`
- Archivo creado en `sistema_path/knowledge-base/kno-qa-dynamic-reading.md`
- Workflow del sistema destino modificado con los hooks QA
- `sistema_path/qa-report.md` inicializado en blanco con frontmatter
- Mensaje de confirmación con inventario de lo creado

## Procedure

### Paso 1 — Lectura de plantillas

Leer `kno-qa-layer-template` para obtener las plantillas de:

- `age-spe-auditor` (plantilla base)
- `age-spe-evaluator` (plantilla base)
- `age-spe-optimizer` (plantilla base)
- `ski-compliance-checker` (plantilla base)
- `ski-rubric-scorer` (plantilla base)
- `ski-pattern-analyzer` (plantilla base)
- `rul-audit-behavior` (plantilla base)
- `kno-qa-dynamic-reading` (plantilla base)

### Paso 2 — Parametrización

Para cada plantilla, reemplazar los tokens de parametrización:

- `{SISTEMA_NOMBRE}` → valor de `sistema_nombre`
- `{WORKFLOW_PATH}` → valor de `workflow_path`
- `{RULES_EXISTENTES}` → lista formateada de `rules_existentes`
- `{SISTEMA_PATH}` → valor de `sistema_path`

Los agentes del QA ya saben auditar las Rules del sistema destino porque reciben la lista en cada activación.

### Paso 3 — Creación de archivos

Crear los archivos en las rutas correctas dentro de `sistema_path`:

```
{sistema_path}/
├── agents/
│   ├── age-spe-auditor.md        ← parametrizado
│   ├── age-spe-evaluator.md      ← parametrizado
│   └── age-spe-optimizer.md      ← parametrizado
├── skills/
│   ├── ski-compliance-checker/
│   │   └── SKILL.md
│   ├── ski-rubric-scorer/
│   │   └── SKILL.md
│   └── ski-pattern-analyzer/
│       └── SKILL.md
├── rules/
│   └── rul-audit-behavior.md     ← parametrizado
├── knowledge-base/
│   └── kno-qa-dynamic-reading.md ← parametrizado
└── qa-report.md                  ← inicializado en blanco
```

### Paso 4 — Inicialización del qa-report.md

Crear el archivo `{sistema_path}/../qa-report.md` (un nivel arriba de `.agent/`, en la raíz del sistema exportado) con el frontmatter inicial:

```markdown
---
sistema: { sistema_nombre }
fecha-inicio: { timestamp-actual }
fecha-cierre: null
score-global: pending
---

# QA Report — {sistema_nombre}

_Este reporte se irá completando automáticamente con cada checkpoint aprobado._
```

### Paso 5 — Modificación del workflow destino

Leer el workflow principal del sistema destino (`workflow_path`). Añadir al final de la sección de Workflow Sequence (o al inicio del empaquetado final) el bloque de hooks QA:

```markdown
### QA Layer — Activación automática

Tras cada checkpoint aprobado, activar el ciclo QA correspondiente:

| Checkpoint            | Activar                                                                    |
| --------------------- | -------------------------------------------------------------------------- |
| CP-S1 (o equivalente) | `age-spe-auditor` → `age-spe-evaluator` → qa-report.md actualizado         |
| CP-S2 (o equivalente) | `age-spe-auditor` → `age-spe-evaluator` → qa-report.md actualizado         |
| CP por entidad        | `age-spe-auditor` → qa-report.md actualizado                               |
| CP-CIERRE             | `age-spe-evaluator` (global) → `age-spe-optimizer` → qa-report.md completo |

Para re-auditorías manuales usar: `/re-audit [entidad | fase | sistema]`

Rules activas del sistema que se auditan: {RULES_EXISTENTES}
```

### Paso 6 — Actualización del process-overview.md del sistema destino

Si existe `{sistema_path}/../process-overview.md`, añadir el QA Layer al inventario de entidades y al diagrama de arquitectura.

### Paso 7 — Mensaje de confirmación

```
✅ QA Layer embebido en {sistema_nombre}

Entidades añadidas:
- 3 agents: age-spe-auditor, age-spe-evaluator, age-spe-optimizer
- 3 skills: ski-compliance-checker, ski-rubric-scorer, ski-pattern-analyzer
- 1 rule: rul-audit-behavior
- 1 knowledge-base: kno-qa-dynamic-reading

qa-report.md inicializado en: exports/{sistema_nombre}/google-antigravity/qa-report.md

El sistema {sistema_nombre} evaluará automáticamente su propio proceso en cada checkpoint.
```

## Error Handling

- Si `sistema_path` no existe: error — `"El sistema destino no existe en la ruta indicada"`
- Si ya existe un `age-spe-auditor.md` en el destino: preguntar `"Ya existe un QA Layer en este sistema. ¿Sobreescribir? A) Sí / B) No"`
- Si el workflow destino no tiene sección de Workflow Sequence identificable: añadir el bloque al final del archivo con nota explicativa
- Si `rules_existentes` está vacío: embeber con advertencia `"Sin Rules activas detectadas — el Auditor usará solo las reglas del QA Layer"`
