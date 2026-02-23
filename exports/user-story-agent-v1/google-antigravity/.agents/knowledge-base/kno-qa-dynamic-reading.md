---
description: Protocolo de lectura dinámica del QA Layer para user-story-agent-v1. Define resolución de rutas y mantenimiento del qa-report.md.
tags: [qa, dynamic-reading, file-paths]
---

## Documentation

### Resolución de rutas

- sistema_path: /Users/luisr.domarco/github/projects/AiAgentArchitect/exports/user-story-agent-v1/google-antigravity/.agents
- Rules activas: ["./rules/rul-story-formatting-standards.md", "./rules/rul-acceptance-criteria-generation.md"]
- Rutas absolutas: sistema_path + ruta_relativa

### Rutas estándar

| Tipo      | Ruta                           |
| --------- | ------------------------------ |
| Rule      | ./rules/{rul-nombre}.md        |
| Agent     | ./workflows/{age-nombre}.md    |
| Skill     | ./skills/{ski-nombre}/SKILL.md |
| Workflow  | ./workflows/{wor-nombre}.md    |
| qa-report | ../qa-report.md                |

### qa-report.md

- Ubicación: un nivel arriba de .agents/ → /Users/luisr.domarco/github/projects/AiAgentArchitect/exports/user-story-agent-v1/google-antigravity/qa-report.md
- Inicialización si no existe: frontmatter + título + nota inicial
- Mantenimiento: siempre append con separador ---

### Archivos no encontrados

Registrar como: | Archivo no encontrado | {ruta} | ❌ | Archivo no existe en ruta esperada |
