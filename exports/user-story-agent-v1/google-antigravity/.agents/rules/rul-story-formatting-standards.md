---
trigger: always_on
description: Normas globales para el forjado del Markdown final y reglas de estilo estricto.
alwaysApply: true
tags: [formatting, standards, rules, base]
---

## Context

Esta regla garantiza que el documento de la historia de usuario resultante se formatee siempre siguiendo las mismas directrices de presentación y estructuración de la información. Su cumplimiento permite que las historias de usuario que pasan por el sistema sean predecibles, consistentes y estandarizadas internamente en toda la empresa.

## Hard Constraints

- Nunca alterar o eliminar ninguna de las etiquetas principales (p. ej., `## User Story`, `## Definition`, `## Acceptance Criteria`) del template de historia de usuario, ni su orden.
- Nunca rellenar ni actuar sobre las siguientes secciones de metadatos o fases de desarrollo técnico/QA:
  - `### Design notes`
  - `## Technical notes`
  - `## MRs sprint`
  - `## Test plan DEV`
  - `## Test plan QA`
  - `## Improvement proposal QA`
  - `## Post-deployment actions`
- Nunca inventar datos, métricas, hechos ni referencias cruzadas que no estén presentes en el input original o no hayan sido confirmadas por el usuario.
- Nunca incluir "meta-lenguaje" o disculpas características de un modelo de IA (e.g. "Como modelo de IA...", "Aquí tienes la historia iterada...", "Espero que esto ayude...").

## Soft Constraints

- Siempre usar [HYPOTHESIS] textualmente al inicio de un párrafo o bullet si estás introduciendo una suposición de negocio que el usuario no ha aclarado pero resulta necesaria para la fluidez del texto.
- Siempre favorecer listas (bullet points `*` o `-`) como formato principal para las secciones de `Scope` y `Out of scope`.
- Siempre utilizar párrafos cortos y directos.
- Siempre usar **negritas**, _cursivas_ y <u>subrayado</u> con propósito, para resaltar términos clave de negocio, actores o flujos críticos, pero sin abusar.
- Siempre asegurar de mantener un lenguaje simple, alejado de tecnicismos complejos de programación para asegurar el entendimiento de todos los stakeholders.

## Examples

**Input incorrecto (actuando sobre bloque prohibido):**

```markdown
## Technical notes

Hay que crear un endpoint POST en /api/v1/user.
```

**Output correcto (dejando bloque vacío e intacto):**

```markdown
## Technical notes

## MRs sprint

...
```

**Input correcto (uso de hipótesis ante falta de datos de contexto):**

```markdown
- [HYPOTHESIS] El usuario invitado no tiene acceso al dashboard analítico una vez termina su trial.
```
