---
description: Protocolo de lectura dinámica del QA Layer para assistant-documentation-generator. Define resolución de rutas y mantenimiento del qa-report.md.
tags: [qa, dynamic-reading, file-paths]
---

## Documentation

### Resolución de rutas

- sistema_path: exports/assistant-documentation-generator/claude-code/.claude/
- Rules activas: ["./rules/rul-output-standards.md", "./rules/rul-source-attribution.md"]
- Rutas absolutas: sistema_path + ruta_relativa

### Rutas estándar

| Tipo      | Ruta                       |
| --------- | -------------------------- |
| Rule      | ./rules/{rul-nombre}.md    |
| Agent     | ./agents/{age-nombre}.md   |
| Skill     | ./skills/{ski-nombre}.md   |
| Workflow  | ./commands/{wor-nombre}.md |
| qa-report | ../qa-report.md            |

### qa-report.md

- Ubicación: un nivel arriba de .claude/ → exports/assistant-documentation-generator/claude-code/qa-report.md
- Inicialización si no existe: frontmatter + título + nota inicial
- Mantenimiento: siempre append con separador ---

### Archivos no encontrados

Registrar como: | Archivo no encontrado | {ruta} | ❌ | Archivo no existe en ruta esperada |
