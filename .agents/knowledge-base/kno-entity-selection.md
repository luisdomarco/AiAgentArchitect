---
description: Árbol de decisión, tabla comparativa y criterios para seleccionar la entidad correcta ante cualquier responsabilidad o capacidad a modelar.
tags: [entity-selection, decision-tree, architecture]
---

## Table of Contents

- [1. Árbol de decisión](#1-árbol-de-decisión)
- [2. Tabla comparativa](#2-tabla-comparativa)
- [3. Criterios por entidad](#3-criterios-por-entidad)
- [4. Casos límite frecuentes](#4-casos-límite-frecuentes)
- [5. Anti-patrones](#5-anti-patrones)

---

## 1. Árbol de decisión

```
¿Qué estás modelando?
│
├── ¿Condiciona cómo se comportan otras entidades sin ejecutar nada?
│   └── SÍ → RULE
│
├── ¿Es información estática de referencia que los agentes consultan?
│   └── SÍ → KNOWLEDGE-BASE
│
├── ¿Es una acción única, determinista, disparada siempre manualmente por el usuario?
│   (nunca la invocaría otro agente o workflow)
│   └── SÍ → COMMAND
│
└── ¿Ejecuta o coordina lógica activa?
    │
    ├── ¿Involucra múltiples responsabilidades diferenciadas o
    │   transferencia de outputs entre partes distintas?
    │   └── SÍ → WORKFLOW
    │
    └── ¿Es una responsabilidad única y acotada?
        │
        ├── ¿Necesita identidad propia, toma decisiones en su dominio
        │   y tiene sentido usarla de forma standalone?
        │   └── SÍ → AGENT
        │
        └── ¿Es un procedimiento técnico reutilizable sin identidad
            ni criterio propios?
            └── SÍ → SKILL
```

---

## 2. Tabla comparativa

| Atributo | Workflow | Agent | Skill | Command | Rule | Knowledge-base |
|---|---|---|---|---|---|---|
| Ejecuta tareas directamente | No | Sí | Sí | Sí | No | No |
| Coordina otras entidades | Sí | No | No | No | No | No |
| Tiene identidad y dominio propio | Sí | Sí | No | No | No | No |
| Puede usarse standalone | Sí | Sí | No | Sí | No | No |
| Reutilizable por múltiples agentes | No | No | Sí | No | Sí | Sí |
| Siempre lo dispara el usuario | Opcional | Opcional | No | Siempre | No | No |
| Gestiona flujo y checkpoints | Sí | No | No | No | No | No |
| Condiciona el comportamiento de otros | No | No | No | No | Sí | No |

---

## 3. Criterios por entidad

### Workflow

Úsalo cuando el proceso involucra múltiples responsabilidades que deben ejecutarse en secuencia o con ramificaciones, pasando outputs de una parte a la siguiente.

**Señales clave:**
- Hay más de un dominio de responsabilidad involucrado
- Existen decisiones o bifurcaciones entre partes
- Se necesita transferir contexto entre componentes distintos
- Hay checkpoints de aprobación humana
- El proceso tiene un inicio, un flujo orquestado y un output final compuesto

**Pregunta de validación:** ¿Podría descomponerse en pasos con responsables distintos?

---

### Agent

Úsalo cuando la responsabilidad es única, acotada y requiere criterio propio para ejecutarse.

**Señales clave:**
- Un único dominio de responsabilidad claro
- Necesita tomar decisiones dentro de su ámbito
- Puede usarse standalone o dentro de un Workflow
- Tiene input y output bien definidos

**Pregunta de validación:** ¿Podría describirse su responsabilidad en una frase? ¿Tiene sentido invocarlo solo?

---

### Skill

Úsalo cuando es una capacidad técnica o procedimental que varios agentes podrían necesitar, sin identidad ni criterio propios.

**Señales clave:**
- La misma lógica podría usarse en más de un Agent
- No toma decisiones: ejecuta un procedimiento concreto
- No tiene contexto de dominio propio
- Se activa bajo demanda

**Pregunta de validación:** ¿Encontrarías esta misma lógica duplicada en dos Agents distintos?

---

### Command

Úsalo cuando es una acción concreta, determinista y de uso frecuente que el usuario dispara directamente con una palabra clave.

**Señales clave:**
- Siempre lo inicia el usuario de forma manual
- Produce siempre el mismo comportamiento base
- No tiene sentido que otro Agent o Workflow lo invoque
- Es equivalente a un prompt guardado

**Pregunta de validación:** ¿Es algo que el usuario repetiría exactamente igual muchas veces?

---

### Rule

Úsalo cuando defines restricciones o convenciones que deben condicionar el comportamiento de múltiples entidades sin ejecutar nada.

**Señales clave:**
- La misma directriz aplica en más de un contexto
- Es una restricción (nunca hacer X) o convención (siempre hacer Y de este modo)
- No produce output propio: condiciona los outputs de otros

**Pregunta de validación:** ¿Acabas de escribir la misma restricción en tres Agents distintos?

---

### Knowledge-base

Úsalo cuando es información de referencia estática que los agentes consultan para fundamentar sus decisiones.

**Señales clave:**
- Contenido que no cambia con cada ejecución
- Los agentes la consultan bajo demanda, no la ejecutan
- Contiene documentación, ejemplos, glosarios, guías, datos del dominio

**Pregunta de validación:** ¿Estás metiendo mucho contexto factual en el body de un Agent para que "lo sepa"?

---

## 4. Casos límite frecuentes

### Agent vs Skill

| Situación | Entidad |
|---|---|
| Necesita tomar decisiones dentro de su ejecución | Agent |
| Solo ejecuta un procedimiento dado un input | Skill |
| Tiene sentido usarlo standalone | Agent |
| Solo tiene sentido dentro de otro Agent o Workflow | Skill |
| Tiene nombre de dominio ("Validador de contratos") | Agent |
| Es una capacidad técnica genérica ("parse_json") | Skill |
| La misma lógica aparecería en dos Agents distintos | Skill |

### Command vs Agent

| Situación | Entidad |
|---|---|
| Solo tiene sentido como disparo manual del usuario | Command |
| Podría ser invocado también por un Workflow | Agent |
| Produce siempre el mismo comportamiento base | Command |
| Adapta su comportamiento al contexto recibido | Agent |
| Es equivalente a un prompt guardado | Command |

### Workflow vs Agent complejo

| Situación | Entidad |
|---|---|
| Dos o más responsabilidades con dominios distintos | Workflow |
| Una sola responsabilidad con muchos pasos internos | Agent |
| Necesita transferir outputs entre partes distintas | Workflow |
| Gestiona checkpoints de aprobación humana | Workflow |
| Necesita invocar a otro Agent | Workflow |
| Opera de forma autónoma en su dominio | Agent |

### Rule vs Specific rules de un Agent

| Situación | Entidad |
|---|---|
| La restricción aplica solo a este Agent | Specific rule en sección 10.1 del Agent |
| La misma restricción aplica a 2+ entidades | Rule independiente referenciada en 10.2 |
| Es un estándar global del sistema | Rule con `alwaysApply: true` |
| Es una restricción contextual | Rule con `trigger: model_decision` |

---

## 5. Anti-patrones

| Anti-patrón | Señal | Corrección |
|---|---|---|
| Agent que invoca a otro Agent | Un Agent referencia a otro en sus instrucciones | Crear un Workflow que orqueste ambos |
| Skill con criterio propio | La Skill "decide" cómo actuar según contexto | Convertirla en Agent Specialist |
| Workflow de una sola entidad | Solo hay una responsabilidad | Es un Agent, no un Workflow |
| Contexto factual en body de Agent | El Agent tiene párrafos de datos o guías | Extraer a Knowledge-base |
| Misma restricción en múltiples Agents | Se repite la misma regla en 2+ Agents | Extraer a Rule |
| Command invocable por Workflow | El Command tiene sentido como paso de un flujo | Convertirlo en Agent |
