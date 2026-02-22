---
name: res-entity-formatting-templates
description: Core markdown schemas and baseline templates for all AI Agent Architect entity types.
tags: [template, formatting, schema, core, entity]
---

# Entity Formatting Templates

El sistema utiliza estas plantillas estandarizadas para materializar las distintas entidades agénticas. Cuando el Entity Builder genera un archivo, debe calcar exactamente estas estructuras y frontmatters.

---

## 1. Workflow (`wor-[nombre]`)

```markdown
---
name: wor-[nombre-kebab-case]
description: [máx. 250 caracteres — objetivo y misión del workflow]
---

## 1. Role & Mission

[Quién es este workflow y cuál es su misión principal.]

## 2. Context

[En qué contexto opera. Plataforma, equipo, sistema al que pertenece.]

## 3. Goals

- **G1:** [Objetivo específico con resultado esperado]
- **G2:** [Objetivo específico con resultado esperado]

## 4. Tasks

- [Tarea principal 1]
- [Tarea principal 2]

## 5. Agents

| **Agent**      | **Route**                     | **When use it**    |
| -------------- | ----------------------------- | ------------------ |
| `nombre-agent` | `./workflows/nombre-agent.md` | [cuándo invocarlo] |

## 6. Knowledge base

| Knowledge base | **Route**                       | Description    |
| -------------- | ------------------------------- | -------------- |
| `nombre-kb`    | `./knowledge-base/nombre-kb.md` | [qué contiene] |

## 7. Workflow Sequence

[Descripción paso a paso del flujo completo, incluyendo cuándo y cómo invocar cada Agent.]

### Checkpoints

[Puntos donde se requiere aprobación humana explícita y qué opciones se presentan.]

### Gestión de errores

[Cómo actuar ante fallos, contradicciones o casos no esperados.]

### Context Map

Define qué contexto fluye entre los Steps/Agents de este workflow (ver `kno-fundamentals-entities` §10):

| Step destino | Consume de        | Campos / Secciones | Modo               |
| ------------ | ----------------- | ------------------ | ------------------ |
| [step N]     | Step [M] → output | [campos o *]       | [parcial/completo] |

> Si el workflow tiene 2+ agentes en secuencia, usar `ski-context-ledger` para persistir y filtrar contexto. Ver `kno-handoff-schemas` §4-5.

### Gestión de errores

[Cómo actuar ante fallos, contradicciones o casos no esperados.]

## 8. Input

[Qué recibe, de quién, en qué formato.]

## 9. Output

[Qué produce, a quién va, en qué formato.]

## 10. Rules

### 10.1. Specific rules

- [Regla específica de este workflow]

### 10.2. Related rules

| Rule          | **Route**                | Description  |
| ------------- | ------------------------ | ------------ |
| `nombre-rule` | `./rules/nombre-rule.md` | [qué regula] |

## 11. Definition of success

[Criterios concretos que determinan que el workflow ha funcionado correctamente.]
```

---

## 2. Agent (`age-spe-[nombre]` | `age-sup-[nombre]`)

```markdown
---
name: age-spe-[nombre] | age-sup-[nombre]
description: [máx. 250 caracteres — rol y misión del agente]
---

## 1. Role & Mission

[Quién es este agente, su rol y su misión concreta.]

## 2. Context

[En qué contexto opera. De dónde viene su input y adónde va su output.]

## 3. Goals

- **G1:** [Objetivo con resultado esperado]
- **G2:** [Objetivo con resultado esperado]

## 4. Tasks

- [Tarea 1]
- [Tarea 2]

## 5. Skills

| **Skill**      | **Route**                        | **When use it**    |
| -------------- | -------------------------------- | ------------------ |
| `nombre-skill` | `./skills/nombre-skill/SKILL.md` | [cuándo activarla] |

## 6. Knowledge base

| Knowledge base | **Route**                       | Description    |
| -------------- | ------------------------------- | -------------- |
| `nombre-kb`    | `./knowledge-base/nombre-kb.md` | [qué contiene] |

## 7. Execution Protocol

[Cómo ejecutar las tareas paso a paso. Incluir cuándo usar cada Skill y cómo aplicar las Rules.]

## 8. Input

[Qué recibe, de quién, en qué formato.]

## 9. Output

[Qué produce, formato exacto.]

## 10. Rules

### 10.1. Specific rules

- [Regla específica de este agente]

### 10.2. Related rules

| Rule          | **Route**                | Description  |
| ------------- | ------------------------ | ------------ |
| `nombre-rule` | `./rules/nombre-rule.md` | [qué regula] |

## 11. Definition of success

[Criterios concretos de éxito para este agente.]
```

---

## 3. Skill (`ski-[nombre]/SKILL.md`)

```markdown
---
name: ski-[nombre-kebab-case]
description: [máx. 250 caracteres — qué hace Y cuándo usarla]
---

# [Nombre Legible de la Skill]

[Descripción breve de qué hace esta skill y para qué sirve.]

## Input / Output

**Input:**

- [Campo 1: tipo y descripción]
- [Campo 2: tipo y descripción]

**Output:**

- [Qué produce y en qué formato]

---

## Procedure

[Pasos concretos y ordenados para ejecutar la skill.
Usar numeración clara. Incluir condiciones si aplica.]

---

## Examples

[Casos de uso concretos con input de ejemplo y output esperado.
Incluir razonamiento si el nivel es medium o complex.]

---

## Error Handling

- **[Tipo de error]:** [Cómo actuar]
- **[Tipo de error]:** [Cómo actuar]
```

---

## 4. Command (`com-[nombre]`)

```markdown
---
name: com-[nombre-kebab-case]
description: [máx. 250 caracteres — qué hace y cuándo usarlo]
---

[System prompt estructurado. Usar headings y bullets cuando aplique.
Debe ser directo y determinista: el mismo comando produce siempre el mismo comportamiento base.]

## Objetivo

[Qué debe hacer cuando se ejecuta este command.]

## Comportamiento

[Cómo debe actuar. Pasos o instrucciones claras.]

## Output esperado

[Qué debe producir y en qué formato.]

## Restricciones

- [Lo que no debe hacer]
```

---

## 5. Rule (`rul-[nombre]`)

```markdown
---
trigger: always_on | manual | model_decision | glob
description: [10-20 palabras — solo si trigger es model_decision]
globs: [lista de patrones — solo si trigger es glob]
alwaysApply: true | false
tags: [lista de etiquetas]
---

## Context

[Por qué existe esta rule. Qué problema o riesgo previene.]

## Hard Constraints

[Lo que el modelo NUNCA debe hacer. Redactar en negativo.]

- Nunca [acción prohibida]
- Nunca [acción prohibida]

## Soft Constraints

[Estilos preferidos, convenciones, buenas prácticas. Redactar en positivo.]

- Siempre [comportamiento preferido]
- Preferir [opción A] sobre [opción B]

## Examples

[Bloques de código o ejemplos mostrando Input incorrecto vs Output correcto cuando sea útil.]
```

---

## 6. Knowledge-base (`kno-[nombre]`)

```markdown
---
description:
  [10-20 palabras para indexación semántica — qué contiene y para qué]
tags: [lista de etiquetas temáticas]
---

## Table of Contents

- [Sección 1](#sección-1)
- [Sección 2](#sección-2)

## [Sección 1]

[Contenido estructurado con headings cuando aplique.]

## [Sección 2]

[Contenido estructurado.]
```
