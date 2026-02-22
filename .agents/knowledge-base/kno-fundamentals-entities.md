---
description: Definición, propósito, activación, responsabilidades y especificaciones de formato de las 6 entidades agénticas del sistema.
tags: [entities, fundamentals, architecture]
---

## Table of Contents

- [1. Workflow](#1-workflow)
- [2. Agent](#2-agent)
- [3. Skill](#3-skill)
- [4. Command](#4-command)
- [5. Rule](#5-rule)
- [6. Knowledge-base](#6-knowledge-base)
- [7. Resources](#7-resources)
- [8. Límites de caracteres por entidad](#8-límites-de-caracteres-por-entidad)
- [9. Patrones de Workflow](#9-patrones-de-workflow)

---

## 1. Workflow

**Definición:** Secuencia de pasos predefinida, ordenada y repetible que automatiza un proceso completo de principio a fin.

**Objetivo:** Coordinar la ejecución de múltiples componentes (Agents, Skills, Rules, Knowledge-base) para completar un proceso.

**Activación:**

- Manual: iniciado explícitamente por el usuario.
- Instrucciones: invocado por otro workflow, agent, skill o command.

**Atributos clave:**

| Atributo           | Descripción                                                          |
| ------------------ | -------------------------------------------------------------------- |
| Conocimiento       | Conoce el flujo completo del proceso                                 |
| Función            | Invoca Agents en secuencia                                           |
| Transferencia      | Pasa outputs de unos agentes como inputs de otros                    |
| Supervisión        | Gestiona checkpoints y aprobaciones humanas                          |
| Context Management | Persiste estado inter-agente en `context-ledger.md` (ver sección 10) |
| Restricción        | **No ejecuta tareas directamente**, solo coordina                    |

**Prefijo de archivo:** `wor-`
**Estructura:** Frontmatter YAML + Body Markdown con secciones 1-11.

---

## 2. Agent

**Definición:** Conjunto de instrucciones con identidad, propósito y dominio específico que opera de forma autónoma para desempeñar funciones delimitadas.

**Objetivo:** Delegar una responsabilidad concreta a una entidad especializada que sabe qué hacer, cómo hacerlo y qué devolver.

**Activación:**

- Manual: iniciado explícitamente por el usuario.
- Instrucciones: invocado por un workflow, agent, skill o command.

**Atributos clave:**

| Atributo     | Descripción                                     |
| ------------ | ----------------------------------------------- |
| Conocimiento | Conoce solo sus propias tareas                  |
| Aislamiento  | No conoce ni depende de otros agentes           |
| Interface    | Define `input_schema` y `output_schema` claros  |
| Capacidades  | Puede utilizar Skills asignadas                 |
| Invocación   | Puede usarse standalone o dentro de un Workflow |

**Roles:**

- **Supervisor (`age-sup-`):** Supervisión de calidad o validación de outputs.
- **Specialist (`age-spe-`):** Ejecución de funciones de dominio específico.

**Estructura:** Frontmatter YAML + Body Markdown con secciones 1-11.

---

## 3. Skill

**Definición:** Paquete de conocimiento especializado y reutilizable que dota a un agente de capacidades concretas para una tarea específica.

**Objetivo:** Extender las capacidades de un agente de forma modular y bajo demanda, sin sobrecargar su contexto con conocimiento que puede no ser necesario en todas las ejecuciones.

**Activación:**

- Automática: activada por el agente cuando detecta que la tarea lo requiere.
- Instrucciones: invocada por un workflow, agent o command.

**Características:**

- Reutilizable por múltiples agentes distintos.
- Sin dependencias de un agente específico.
- Se carga solo cuando es relevante para la tarea en curso.

**Tipos:**

| Tipo              | Descripción                              | Ejemplo                         |
| ----------------- | ---------------------------------------- | ------------------------------- |
| `tool`            | Función o API call específica            | `parse_email`, `validate_input` |
| `workflow`        | Sub-proceso con múltiples pasos internos | `complete_onboarding`           |
| `integration`     | Conexión con un sistema externo          | `zendesk_create_ticket`         |
| `reasoning`       | Lógica de decisión o clasificación       | `classify_urgency`              |
| `text-processing` | Transformación o análisis de texto       | `format_output`, `translate`    |
| `other`           | Otros cometidos                          | —                               |

**Estructura de carpeta:**

```
ski-[nombre]/
├── SKILL.md          (obligatorio)
├── scripts/          (opcional)
├── resources/        (opcional)
└── examples/         (opcional)
```

**Prefijo:** `ski-` (en el nombre de la carpeta, no del archivo)

---

## 4. Command

**Definición:** Instrucción directa y predefinida que dispara una acción o procedimiento concreto de forma inmediata y determinista.

**Objetivo:** Ejecutar procedimientos guardados de forma rápida y precisa, reduciendo la fricción en tareas frecuentes.

**Activación:** Manual — invocado siempre por el usuario mediante palabra clave o atajo predefinido.

**Características:**

- Ejecución determinista: el mismo Command produce siempre el mismo comportamiento base.
- Puede invocar Agents o Skills.
- No requiere que el usuario redacte instrucciones cada vez.
- Orientado a tareas atómicas o de uso frecuente.
- Es similar a un prompt guardado.

**Diferencia con Workflow:** Un Command es una acción única o de pocos pasos. Un Workflow es un proceso completo multi-agente. Un Command puede ser un paso dentro de un Workflow, pero no al revés.

**Prefijo de archivo:** `com-`
**Estructura:** Frontmatter YAML + Body Markdown (system prompt estructurado).

---

## 5. Rule

**Definición:** Conjunto de directrices, pautas o restricciones que condicionan el comportamiento de Workflows, Agents, Skills o Commands.

**Objetivo:** Garantizar consistencia, calidad y adherencia a estándares en todas las ejecuciones.

**Características:**

- No ejecuta tareas, solo define cómo deben ejecutarse.
- Puede ser global (aplica a todo) o específica (aplica a un contexto).
- Es el componente más pasivo: guía sin actuar.

**Modos de activación:**

| Modo             | Descripción                                      |
| ---------------- | ------------------------------------------------ |
| `always_on`      | Se aplica siempre, en cualquier contexto         |
| `manual`         | Activada explícitamente por mención directa      |
| `model_decision` | El modelo evalúa si aplica según el contexto     |
| `glob`           | Se aplica a archivos que coincidan con un patrón |

**Prefijo de archivo:** `rul-`
**Estructura:** Frontmatter YAML (`trigger`, `description`, `globs`, `alwaysApply`, `tags`) + Body Markdown.

---

## 6. Knowledge-base

**Definición:** Repositorio de información de referencia que los agentes consultan para fundamentar sus decisiones y outputs.

**Objetivo:** Proveer contexto factual, datos del dominio, ejemplos o documentación sin incorporar ese conocimiento directamente en las instrucciones de cada agente.

**Características:**

- No ejecuta ni coordina: es contenido estático consultable.
- Puede contener: documentación técnica, guías de estilo, datos de referencia, ejemplos, glosarios.
- Los agentes la consultan bajo demanda.
- Desacopla el conocimiento del dominio de la lógica de los agentes.

**Prefijo de archivo:** `kno-`
**Estructura:** Frontmatter YAML (`description`, `tags`) + Body Markdown con tabla de contenidos.

---

## 7. Resources

**Definición:** Se trata de un directorio, al mismo nivel de "/workflows" o "/knowledge-base" donde se irán creando/almacenando otros recursos que no son algunos de los considerados hasta el momento y que son necesarios o dan soporte a las diferentes entidades o procesos.

**Prefijo de archivo:** `res-`

---

## 8. Límites de caracteres por entidad

| Entidad        | Name (máx.) | Description (máx.) | Content recomendado | Content máximo |
| -------------- | ----------- | ------------------ | ------------------- | -------------- |
| Workflow       | 64          | 250                | <6000               | 12.000         |
| Agent          | 64          | 250                | <3000               | 12.000         |
| Skill          | 64          | 250                | <1500               | 12.000         |
| Command        | 64          | 250                | <1500               | 12.000         |
| Rule           | 64          | 250                | <3000               | 12.000         |
| Knowledge-base | 64          | 250                | <6000               | 12.000         |

---

## 9. Patrones de Workflow

**Patrón 1 — Lineal:**

```
Input → Agent A → Agent B → Agent C → Output
```

**Patrón 2 — Con Checkpoints:**

```
Input → Agent A → [Checkpoint] → Agent B → [Checkpoint] → Output
```

**Patrón 3 — Con Decisiones:**

```
Input → Classifier →
  ├─ Condición A → Agent A → Output
  └─ Condición B → Agent B → Output
```

**Patrón 4 — Con Integraciones:**

```
Input → Agent A → Integration Agent → Sistema Externo
                        ↓
                  Agent B → Output
```

**Patrón 5 — Paralelo con Consolidación:**

```
Input → Dispatcher →
  ├─ Agent A →
  ├─ Agent B → → Consolidator → Output
  └─ Agent C →
```

---

## 10. Context Management — Context Ledger

En flujos secuenciales multi-agente, el workflow gestiona la transferencia de contexto entre agentes mediante un **Context Ledger**: un archivo temporal `context-ledger.md` que persiste el output de cada step y permite al orquestador filtrar selectivamente qué información pasa al siguiente agente.

### Principio

El **workflow** es la única entidad que conoce el flujo completo y, por tanto, la única que decide **qué contexto fluye y hacia dónde**. Los agentes no leen ni escriben en el ledger directamente — el orquestador lo hace por ellos.

### Flujo

```
1. Workflow inicializa el context-ledger.md
2. Workflow invoca Agent A
3. Workflow escribe el output de Agent A en el ledger
4. Workflow lee el ledger, filtra según el Context Map, y construye el input para Agent B
5. Workflow invoca Agent B con el input filtrado
6. Workflow escribe el output de Agent B en el ledger
7. [Repite para cada step siguiente]
```

### Context Map

Cada workflow que usa el patrón debe incluir una sección **Context Map** que define, por cada step, qué campos del output de qué steps anteriores necesita como input:

```markdown
| Step destino | Consume de      | Campos / Secciones    | Modo     |
| ------------ | --------------- | --------------------- | -------- |
| Step 2       | Step 1 → output | proceso, diagrama     | parcial  |
| Step 3       | Step 2 → output | entidades, orden      | completo |
| Step 3       | Step 1 → output | nombre, restricciones | parcial  |
```

- **Modo `completo`**: el output íntegro del step referenciado.
- **Modo `parcial`**: solo los campos listados en "Campos / Secciones".

### Cuándo aplicar este patrón

- Workflows con **2+ agentes en secuencia** que necesitan datos de agentes anteriores.
- Workflows donde el contexto debe ser **trazable** (auditoría, debugging).
- No es necesario en workflows de un solo agente ni en commands.

### Skill de soporte

Para crear y operar el ledger, los workflows pueden usar la skill `ski-context-ledger` (`./skills/ski-context-ledger/SKILL.md`).
