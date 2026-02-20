---
name: ski-entity-file-builder
description: Generates complete and correctly formatted instruction files for each entity type (Workflow, Agent, Skill, Command, Rule, Knowledge-base) according to the assigned intricacy level. Use it in Step 3 to materialize each entity from the architectural blueprint.
---

# Entity File Builder Skill

Genera el contenido completo de archivos de instrucciones para cada tipo de entidad, adaptando la profundidad al nivel de intricacy asignado y respetando todas las convenciones de formato.

## Input / Output

**Input:**
- Tipo de entidad: `workflow | agent-specialist | agent-supervisor | skill | command | rule | knowledge-base`
- Nivel de intricacy: `simple | medium | complex`
- Datos de la entidad del JSON de handoff (nombre, descripción, función, input, output, relaciones)
- Lista de entidades ya creadas en la sesión (para referencias cruzadas correctas)

**Output:**
- Archivo `.md` completo con frontmatter YAML y body Markdown, listo para descargar

---

## Procedure

### 1. Pre-generación: verificaciones obligatorias

Antes de escribir el archivo, verifica:

- El nombre sigue la convención kebab-case con el prefijo correcto para su tipo.
- La descripción del frontmatter no supera 250 caracteres.
- Las rutas de referencia cruzada usan el formato relativo correcto.
- El nivel de intricacy determina la densidad del contenido (ver sección 4).

---

### 2. Convenciones de nomenclatura por tipo

| Tipo | Prefijo | Ejemplo |
|---|---|---|
| Workflow | `wor-` | `wor-customer-onboarding.md` |
| Agent Specialist | `age-spe-` | `age-spe-email-classifier.md` |
| Agent Supervisor | `age-sup-` | `age-sup-output-validator.md` |
| Skill | `ski-` | `ski-format-output/SKILL.md` |
| Command | `com-` | `com-quick-translate.md` |
| Rule | `rul-` | `rul-output-standards.md` |
| Knowledge-base | `kno-` | `kno-brand-guidelines.md` |

---

### 3. Plantillas por tipo de entidad

#### 3.1 Workflow

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

| **Agent** | **Route** | **When use it** |
| --- | --- | --- |
| `nombre-agent` | `./agents/nombre-agent.md` | [cuándo invocarlo] |

## 6. Knowledge base

| Knowledge base | **Route** | Description |
| --- | --- | --- |
| `nombre-kb` | `./knowledge-base/nombre-kb.md` | [qué contiene] |

## 7. Workflow Sequence

[Descripción paso a paso del flujo completo, incluyendo cuándo y cómo invocar cada Agent.]

### Checkpoints

[Puntos donde se requiere aprobación humana explícita y qué opciones se presentan.]

### Gestión de errores

[Cómo actuar ante fallos, contradicciones o casos no esperados.]

### Gestión de información entre agentes

[Cómo se transfiere el contexto entre agentes. Formato de handoff.]

## 8. Input

[Qué recibe, de quién, en qué formato.]

## 9. Output

[Qué produce, a quién va, en qué formato.]

## 10. Rules

### 10.1. Specific rules

- [Regla específica de este workflow]

### 10.2. Related rules

| Rule | **Route** | Description |
| --- | --- | --- |
| `nombre-rule` | `./rules/nombre-rule.md` | [qué regula] |

## 11. Definition of success

[Criterios concretos que determinan que el workflow ha funcionado correctamente.]
```

---

#### 3.2 Agent (Specialist y Supervisor)

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

| **Skill** | **Route** | **When use it** |
| --- | --- | --- |
| `nombre-skill` | `./skills/nombre-skill/SKILL.md` | [cuándo activarla] |

## 6. Knowledge base

| Knowledge base | **Route** | Description |
| --- | --- | --- |
| `nombre-kb` | `./knowledge-base/nombre-kb.md` | [qué contiene] |

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

| Rule | **Route** | Description |
| --- | --- | --- |
| `nombre-rule` | `./rules/nombre-rule.md` | [qué regula] |

## 11. Definition of success

[Criterios concretos de éxito para este agente.]
```

---

#### 3.3 Skill

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

#### 3.4 Command

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

#### 3.5 Rule

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

#### 3.6 Knowledge-base

```markdown
---
description: [10-20 palabras para indexación semántica — qué contiene y para qué]
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

---

### 4. Niveles de intricacy

#### `simple`
- Goals: 2-3 objetivos concisos.
- Tasks: 3-5 bullets sin descripción extensa.
- Execution Protocol / Workflow Sequence: flujo lineal, sin subsecciones.
- Rules específicas: 3-5 reglas directas.
- Skills: sin tabla si no tiene ninguna.
- Sin ejemplos extendidos.

#### `medium`
- Goals: 3-5 objetivos con resultado esperado explícito.
- Tasks: 5-8 bullets con descripción breve de cada una.
- Execution Protocol / Workflow Sequence: pasos numerados, manejo de casos alternativos.
- Rules específicas: 5-8 reglas con contexto.
- Skills: tabla completa con columna "When use it" descriptiva.
- Ejemplos en Skills cuando clarifiquen el uso.

#### `complex`
- Goals: 4-6 objetivos detallados con métrica de éxito.
- Tasks: 8+ bullets con descripción completa.
- Execution Protocol / Workflow Sequence: subsecciones por etapa, gestión de errores, loops, condiciones.
- Rules específicas: 8+ reglas con casos específicos y razonamiento.
- Skills: tabla completa + notas sobre cuándo NO usar cada una.
- Ejemplos detallados con razonamiento explícito.
- Tablas comparativas o de referencia donde aporten claridad.

---

### 5. Coherencia de referencias cruzadas

Antes de incluir cualquier referencia a otra entidad, verifica que:

- El nombre usado coincide exactamente con el nombre en el frontmatter de esa entidad.
- La ruta relativa es correcta según la arquitectura root folder:

| Tipo | Ruta relativa desde cualquier entidad |
|---|---|
| Skill | `./skills/[nombre-skill]/SKILL.md` |
| Agent | `./agents/[nombre-agent].md` |
| Workflow | `./workflows/[nombre-workflow].md` |
| Rule | `./rules/[nombre-rule].md` |
| Knowledge-base | `./knowledge-base/[nombre-kb].md` |
| Command | `./commands/[nombre-command].md` |

---

## Examples

**Ejemplo — Generación de Agent Specialist nivel simple**

Input:
```json
{
  "tipo": "agent-specialist",
  "nombre": "age-spe-email-classifier",
  "funcion": "Clasificar emails entrantes en categorías predefinidas",
  "nivel_intricacy": "simple"
}
```

Output esperado: Agent con Goals (2), Tasks (4), Execution Protocol lineal (5-6 pasos), Rules específicas (3), sin Skills ni KB si no las necesita.

---

## Error Handling

- **Nombre no sigue convención:** Corregir automáticamente y notificar al usuario.
- **Descripción supera 250 caracteres:** Resumir manteniendo el significado esencial.
- **Referencia a entidad no creada aún:** Incluir la referencia con la ruta correcta e indicar en un comentario que esa entidad se creará más adelante.
- **Inconsistencia detectada con el Blueprint:** Pausar, notificar al usuario y pedir aclaración antes de continuar.
