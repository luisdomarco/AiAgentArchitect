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

## Soft Constraints

- Preferir nombres descriptivos y específicos sobre nombres genéricos (`age-spe-email-classifier` es mejor que `age-spe-agent-1`).
- El nombre debe reflejar la función de la entidad, no su posición en el flujo.
- La descripción del frontmatter debe poder leerse de forma independiente y entenderse sin contexto adicional.

## Prefijos por tipo de entidad

| Tipo | Prefijo | Ejemplo |
|---|---|---|
| Workflow | `wor-` | `wor-customer-onboarding.md` |
| Agent Specialist | `age-spe-` | `age-spe-email-classifier.md` |
| Agent Supervisor | `age-sup-` | `age-sup-output-validator.md` |
| Skill | `ski-` | `ski-format-output/SKILL.md` |
| Command | `com-` | `com-quick-translate.md` |
| Rule | `rul-` | `rul-output-standards.md` |
| Knowledge-base | `kno-` | `kno-brand-guidelines.md` |

## Estructura de archivos por tipo

```
agentic/
├── workflows/        → wor-[nombre].md
├── agents/           → age-spe-[nombre].md / age-sup-[nombre].md
├── skills/
│   └── ski-[nombre]/
│       └── SKILL.md  → el nombre de la carpeta es el identificador
├── commands/         → com-[nombre].md
├── rules/            → rul-[nombre].md
└── knowledge-base/   → kno-[nombre].md
```

## Rutas relativas entre entidades

Cuando una entidad referencia a otra, usar siempre rutas relativas desde `agentic/`:

| Entidad referenciada | Ruta relativa |
|---|---|
| Skill | `./skills/ski-[nombre]/SKILL.md` |
| Agent | `./agents/age-[tipo]-[nombre].md` |
| Workflow | `./workflows/wor-[nombre].md` |
| Rule | `./rules/rul-[nombre].md` |
| Knowledge-base | `./knowledge-base/kno-[nombre].md` |
| Command | `./commands/com-[nombre].md` |

## Límites de caracteres

| Campo | Recomendado | Máximo |
|---|---|---|
| `name` (frontmatter) | — | 64 |
| `description` (frontmatter) | — | 250 |
| Contenido Workflow | 6.000–8.000 | 12.000 |
| Contenido Agent | 6.000–8.000 | 12.000 |
| Contenido Skill | 4.000–6.000 | 12.000 |
| Contenido Command | 4.000–6.000 | 12.000 |
| Contenido Rule | 4.000–6.000 | 12.000 |
| Contenido Knowledge-base | 4.000–6.000 | 12.000 |
