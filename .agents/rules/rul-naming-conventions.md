---
trigger: always_on
alwaysApply: true
tags: [naming, conventions, architecture]
---

## Context

Esta rule garantiza que todos los archivos de entidades generados por el sistema Agentic Architect siguen convenciones de nomenclatura consistentes. La consistencia en nombres y rutas es crítica para que las referencias cruzadas entre entidades funcionen correctamente y para que los archivos sean identificables de un vistazo.

## Hard Constraints

- Nunca crear un archivo de entidad sin el prefijo correcto para su tipo.
- Nunca usar mayúsculas en nombres de archivos o carpetas de entidades.
- Nunca usar espacios en nombres de archivos — siempre guiones (`-`).
- Nunca superar 64 caracteres en el campo `name` del frontmatter.
- Nunca superar 250 caracteres en el campo `description` del frontmatter.
- Nunca usar el mismo nombre para dos entidades distintas, independientemente de su tipo.
- Nunca referenciar una entidad con un nombre distinto al definido en su frontmatter.
- Si el contenido de la entidad se aproxima o excede el límite recomendado, NUNCA debe mantenerse monolítico. La información debe ser estructurada y particionada creando documentos de soporte en el directorio `/resources` y referenciarlos desde las instrucciones de la entidad principal. Se debe primar un sistema relacional y de jerarquías.

## Soft Constraints

- Preferir nombres descriptivos y específicos sobre nombres genéricos (`age-spe-email-classifier` es mejor que `age-spe-agent-1`).
- El nombre debe reflejar la función de la entidad, no su posición en el flujo.
- La descripción del frontmatter debe poder leerse de forma independiente y entenderse sin contexto adicional.

## Prefijos por tipo de entidad

| Tipo             | Prefijo          | Ejemplo                       |
| ---------------- | ---------------- | ----------------------------- |
| Workflow         | `wor-`           | `wor-customer-onboarding.md`  |
| Agent Specialist | `age-spe-`       | `age-spe-email-classifier.md` |
| Agent Supervisor | `age-sup-`       | `age-sup-output-validator.md` |
| Skill            | `ski-`           | `ski-format-output/SKILL.md`  |
| Command          | `com-`           | `com-quick-translate.md`      |
| Rule             | `rul-`           | `rul-output-standards.md`     |
| Knowledge-base   | `kno-`           | `kno-brand-guidelines.md`     |
| Resources        | `res-`           | `res-security-policies.md`    |
| Repository Index | `-repo` (sufijo) | `workflows-repo.md`           |

## Estructura de archivos por tipo

```
├── workflows/        → wor-[nombre].md / age-spe-[nombre].md / age-sup-[nombre].md / com-[nombre].md
├── skills/
│   └── ski-[nombre]/
│       └── SKILL.md  → el nombre de la carpeta es el identificador
├── rules/            → rul-[nombre].md
├── knowledge-base/   → kno-[nombre].md
└── resources/        → res-[nombre].md
```

## Rutas relativas entre entidades

Cuando una entidad referencia a otra, usar siempre rutas relativas desde el directorio raíz:

| Entidad referenciada | Ruta relativa                        |
| -------------------- | ------------------------------------ |
| Skill                | `./skills/ski-[nombre]/SKILL.md`     |
| Agent                | `./workflows/age-[tipo]-[nombre].md` |
| Workflow             | `./workflows/wor-[nombre].md`        |
| Rule                 | `./rules/rul-[nombre].md`            |
| Knowledge-base       | `./knowledge-base/kno-[nombre].md`   |
| Command              | `./workflows/com-[nombre].md`        |
| Resources            | `./resources/res-[nombre].md`        |
| Repository Index     | `../../repository/[tipo]-repo.md`    |

## Límites de caracteres

| Tipo de contenido        | Recomendado | Máximo |
| ------------------------ | ----------- | ------ |
| Contenido Workflow       | <6.000      | 12.000 |
| Contenido Agent          | <3.000      | 12.000 |
| Contenido Skill          | <1.500      | 12.000 |
| Contenido Command        | <1.500      | 12.000 |
| Contenido Rule           | <3.000      | 12.000 |
| Contenido Knowledge-base | <6.000      | 12.000 |

## Formato de Archivos Repository Index

Todos los archivos con sufijo `-repo.md` dentro de la carpeta `repository/` deben contener obligatoriamente una única tabla de Markdown con las siguientes 4 columnas literales:

| Nombre | Sistemas donde se utiliza | Relacionado con | Finalidad / Descripción |
| ------ | ------------------------- | --------------- | ----------------------- |

**Constraints para esta tabla:**

- **Columna 1 (Nombre)**: Referencia en backticks al nombre exacto de la entidad (ej. `age-spe-email-classifier`).
- **Columna 2 (Sistemas)**: Lista separada por comas de todos los {nombre-sistema} exportados que consumen esta entidad.
- **Columna 3 (Relaciones)**: Entidades conectadas conocidas, o guión `-` si no aplica.
- **Columna 4 (Finalidad)**: Párrafo conciso que describa el objetivo operativo de la pieza para promover su reutilización.
