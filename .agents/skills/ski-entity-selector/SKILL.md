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

### 1. Extracción de Métricas Estructurales

Los árboles de decisión, matrices discriminatorias por atributos compartidos y las políticas de anti-patrones relacionales ya no habitan hardcoded aquí. Evitas sesgos obteniendo el "Architecture Component Metrics" actualizado del marco de centralización.

> **Debes leer primero y de forma obligatoria el siguiente recurso antes de accionar la lógica deductiva:**
> `../../resources/res-architecture-component-metrics.md`

Extrae de allí los bloques 1 al 4 (Decision Tree, Threshold discriminatorio, Resolución Límite y Anti-Patrones Prohibidos) y utilízalos para resolver el planteamiento estructural.

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

Responsabilidad: _"Formatear el output como JSON estructurado según un schema fijo."_

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

Responsabilidad: _"Recibir un email, clasificarlo, buscarlo en el CRM, generar una respuesta y enviársela al cliente."_

Análisis:

- ¿Múltiples responsabilidades? Sí: clasificar, buscar en CRM, generar respuesta, enviar.
- ¿Transferencia de outputs entre partes? Sí: la clasificación alimenta la búsqueda, que alimenta la generación.

→ **WORKFLOW** + Agents Specialist por cada responsabilidad diferenciada.

---

## Error Handling

- **Ambigüedad irresoluble:** Si tras aplicar el árbol y la tabla la selección no está clara, presentar las dos opciones al usuario con su justificación y pedir que decida.
- **El usuario propone un tipo incorrecto:** Explicar el anti-patrón que generaría y proponer la alternativa correcta con justificación.
