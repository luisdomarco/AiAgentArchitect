---
name: ski-entity-selector
description: Applies the entity decision tree to determine the correct entity type for each identified responsibility. Use it during architecture design to select Workflow, Agent, Skill, Command, Rule or Knowledge-base systematically.
---

# Entity Selector Skill

Aplica el árbol de decisión de entidades para seleccionar el tipo correcto para cada responsabilidad identificada en un proceso. Evita la selección por intuición y garantiza coherencia arquitectónica.

## Input / Output

**Input:**
- Descripción de una responsabilidad o capacidad a modelar
- Contexto del proceso completo (para evaluar relaciones con otras entidades)

**Output:**
- Tipo de entidad recomendado con justificación
- Señales que confirman la selección
- Alertas si hay ambigüedad entre dos tipos

---

## Procedure

### 1. Árbol de decisión principal

Aplica las preguntas en orden. La primera respuesta afirmativa determina la entidad.

```
¿Qué estás modelando?
│
├── ¿Condiciona cómo se comportan otras entidades sin ejecutar nada?
│   (restricciones, convenciones, estándares de calidad)
│   └── SÍ → RULE
│
├── ¿Es información estática de referencia que los agentes consultan?
│   (documentación, ejemplos, datos del dominio, guías)
│   └── SÍ → KNOWLEDGE-BASE
│
├── ¿Es una acción única, determinista, disparada siempre manualmente por el usuario?
│   (nunca la invocaría otro agente o workflow)
│   └── SÍ → COMMAND
│
└── ¿Ejecuta o coordina lógica activa?
    │
    ├── ¿Involucra múltiples responsabilidades diferenciadas o transferencia
    │   de outputs entre partes distintas?
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

### 2. Tabla de atributos discriminantes

Cuando el árbol no resuelve la ambigüedad, usa esta tabla para comparar:

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

### 3. Resolución de casos límite frecuentes

#### Agent vs Skill

Pregunta clave: **¿Necesita tomar decisiones o solo ejecutar un procedimiento?**

| Situación | Entidad |
|---|---|
| Necesita razonar y decidir dentro de su ejecución | Agent |
| Solo ejecuta pasos dados un input concreto | Skill |
| Tiene nombre de dominio ("Validador de contratos") | Agent |
| Es una capacidad técnica genérica ("parse_json", "format_output") | Skill |
| Tiene sentido usarla de forma standalone | Agent |
| Solo tiene sentido dentro de un Agent o Workflow | Skill |
| La misma lógica aparecería en dos Agents distintos | Skill |

---

#### Command vs Agent

Pregunta clave: **¿Podría otro componente invocarla, o solo el usuario?**

| Situación | Entidad |
|---|---|
| Solo tiene sentido como disparo manual del usuario | Command |
| Podría ser invocada por un Workflow o Agent | Agent |
| Produce siempre el mismo comportamiento base | Command |
| Adapta su comportamiento al contexto recibido | Agent |
| Es equivalente a un prompt guardado | Command |

---

#### Workflow vs Agent complejo

Pregunta clave: **¿Hay más de una responsabilidad diferenciada?**

| Situación | Entidad |
|---|---|
| Dos o más responsabilidades con dominios distintos | Workflow |
| Una sola responsabilidad con muchos pasos internos | Agent |
| Necesita transferir outputs entre partes distintas | Workflow |
| Gestiona checkpoints de aprobación humana | Workflow |
| Necesita invocar a otro Agent | Workflow |
| Opera de forma completamente autónoma en su dominio | Agent |

---

#### Rule vs Specific rules de un Agent

| Situación | Entidad |
|---|---|
| La restricción aplica solo a esta entidad | Specific rule en sección 10.1 del Agent |
| La misma restricción aplica a dos o más entidades | Rule independiente |
| Es un estándar global del sistema | Rule con `alwaysApply: true` |
| Es una restricción contextual | Rule con `trigger: model_decision` |

---

### 4. Anti-patrones a detectar

Alerta si el diseño cae en alguno de estos patrones incorrectos:

| Anti-patrón | Señal | Corrección |
|---|---|---|
| Agent que invoca a otro Agent | Un Agent referencia a otro en sus instrucciones | Crear un Workflow que orqueste ambos |
| Skill con criterio propio | La Skill "decide" cómo actuar según contexto | Convertirla en Agent Specialist |
| Workflow de una sola entidad | Solo hay una responsabilidad | Es un Agent, no un Workflow |
| Contexto factual en body de Agent | El Agent tiene párrafos de datos o guías | Extraer a Knowledge-base |
| Misma restricción en múltiples Agents | Se repite la misma regla en 2+ Agents | Extraer a Rule |
| Command invocable por Workflow | El Command tiene sentido como paso de un flujo | Convertirlo en Agent |

---

### 5. Output de la selección

Para cada responsabilidad analizada, entrega:

```
Responsabilidad: [descripción]
Entidad seleccionada: [TIPO]
Justificación: [por qué este tipo y no otro]
Señales confirmatorias:
  - [señal 1]
  - [señal 2]
Alertas: [si hay ambigüedad residual o riesgo de anti-patrón]
```

---

## Examples

**Ejemplo 1 — Selección correcta de Skill vs Agent**

Responsabilidad: *"Formatear el output como JSON estructurado según un schema fijo."*

Análisis:
- ¿Condiciona comportamiento? No.
- ¿Es información estática? No.
- ¿Es manual/determinista? No.
- ¿Múltiples responsabilidades? No.
- ¿Necesita identidad y decisión propia? No — siempre hace lo mismo dado el input.
- ¿Es reutilizable por múltiples agentes? Sí.

→ **SKILL** (`ski-format-json-output`)

---

**Ejemplo 2 — Detección de Workflow necesario**

Responsabilidad: *"Recibir un email, clasificarlo, buscarlo en el CRM, generar una respuesta y enviársela al cliente."*

Análisis:
- ¿Múltiples responsabilidades? Sí: clasificar, buscar en CRM, generar respuesta, enviar.
- ¿Transferencia de outputs entre partes? Sí: la clasificación alimenta la búsqueda, que alimenta la generación.

→ **WORKFLOW** + Agents Specialist por cada responsabilidad diferenciada.

---

## Error Handling

- **Ambigüedad irresoluble:** Si tras aplicar el árbol y la tabla la selección no está clara, presentar las dos opciones al usuario con su justificación y pedir que decida.
- **El usuario propone un tipo incorrecto:** Explicar el anti-patrón que generaría y proponer la alternativa correcta con justificación.
