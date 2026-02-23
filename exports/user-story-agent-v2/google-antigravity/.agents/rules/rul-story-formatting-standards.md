---
trigger: always_on
description: Normas globales de formato Markdown, secciones prohibidas, uso de HYPOTHESIS y estilo de escritura para el sistema user story agent v2.
alwaysApply: true
tags: [formatting, standards, rules, markdown, user-story]
---

## Context

Esta regla garantiza que los documentos de historias de usuario producidos por el sistema se formateen siguiendo las mismas directrices de presentación y estructuración. Su cumplimiento permite que las historias de usuario sean predecibles, consistentes y legibles para todos los stakeholders.

## Hard Constraints

- Nunca alterar ni eliminar ninguna de las etiquetas principales del template de historia de usuario (`## User Story`, `## Definition`, `## Acceptance Criteria`, etc.), ni su orden.
- Nunca rellenar ni actuar sobre las siguientes secciones:
  - `### Design notes`
  - `## Technical notes`
  - `## MRs sprint`
  - `## Test plan DEV`
  - `## Test plan QA`
  - `## Improvement proposal QA`
  - `## Post-deployment actions`
- Nunca inventar datos, métricas, hechos ni referencias cruzadas que no estén presentes en el input original o no hayan sido confirmadas por el usuario.
- Nunca incluir meta-lenguaje o disculpas de modelo de IA (e.g. "Como modelo de IA...", "Espero que esto ayude...").
- Nunca avanzar al siguiente paso sin aprobación explícita del usuario.

## Soft Constraints

- Siempre usar `[HYPOTHESIS]` al inicio de un párrafo o bullet si se introduce una suposición de negocio no confirmada por el usuario.
- Siempre favorecer bullet lists (`-`) como formato principal para las secciones de **Scope** y **Out of scope**.
- Siempre utilizar párrafos cortos y directos.
- Siempre usar **negritas**, _cursivas_ y <u>subrayado</u> con propósito para resaltar términos clave de negocio, actores o flujos críticos, sin abusar.
- Siempre mantener un lenguaje simple, sin tecnicismos de programación, accesible para todos los stakeholders.
- Si hay conflictos o contradicciones en el input, señalarlos y pedir alineación al usuario; priorizar el input más reciente validado.

## Examples

**Incorrecto — actuando sobre bloque prohibido:**

```markdown
## Technical notes

Hay que crear un endpoint POST en /api/v1/user.
```

**Correcto — bloque vacío e intacto:**

```markdown
## Technical notes

## MRs sprint
```

**Correcto — uso de hipótesis:**

```markdown
- [HYPOTHESIS] El usuario invitado no tiene acceso al dashboard analítico una vez termina su trial.
```
