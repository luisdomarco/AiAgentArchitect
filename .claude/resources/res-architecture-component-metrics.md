---
name: res-architecture-component-metrics
description: Árboles lógicos, asignación de Intricacy y matrices de decisión para arquitectura.
tags: [architecture, design, metrics, mapping, blueprint, blueprints]
---

# Architecture Component Metrics

Este documento centraliza todas las lógicas deductivas para diseñar sistemas limpios, incluyendo la selección de entidades y la configuración de intricacy para sus directrices. Se consulta por el `age-spe-architecture-designer` y su skill `ski-entity-selector`.

## 1. Entity Decision Tree

Aplica este árbol secuencial para decidir la responsabilidad base de cualquier nodo:

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

## 2. Threshold discriminatorio por Atributos

| Atributo                              | Workflow | Agent    | Skill | Command | Rule | Knowledge-base |
| ------------------------------------- | -------- | -------- | ----- | ------- | ---- | -------------- |
| Ejecuta tareas directamente           | No       | Sí       | Sí    | Sí      | No   | No             |
| Coordina otras entidades              | Sí       | No       | No    | No      | No   | No             |
| Tiene identidad y dominio propio      | Sí       | Sí       | No    | No      | No   | No             |
| Puede usarse standalone               | Sí       | Sí       | No    | Sí      | No   | No             |
| Reutilizable por múltiples agentes    | No       | No       | Sí    | No      | Sí   | Sí             |
| Siempre lo dispara el usuario         | Opcional | Opcional | No    | Siempre | No   | No             |
| Gestiona flujo y checkpoints          | Sí       | No       | No    | No      | No   | No             |
| Condiciona el comportamiento de otros | No       | No       | No    | No      | Sí   | No             |

## 3. Resolución de Casos Límite Frecuentes

### Agent vs Skill

- **Agent:** Necesita razonar/decidir dentro de su ejecución, tiene nombre de dominio o tiene sentido de forma asilada.
- **Skill:** Solo ejecuta pasos deterministas, ejerce una función técnica genérica, es repetible entre distintos agentes.

### Command vs Agent

- **Command:** Útil sólo como disparo de usuario, es determinista (actúa como prompt fijo).
- **Agent:** Invocable por un Workflow u otro agent, adapta su comportamiento según contexto variable.

### Workflow vs Agent

- **Workflow:** 2+ responsabilidades con dominios distintos, transfiere outputs y delega las tareas.
- **Agent:** 1 responsabilidad con muchos pasos internos, opera de forma muy autónoma.

### Rule vs Specific rules dentro del Agent

- **Agent:** Aplica solo localmente.
- **Rule:** Aplica transversalmente o condiciona 2+ entidades independientes.

## 4. Anti-Patrones Estructurales Prohibidos

| Anti-patrón                             | Corrección                          |
| --------------------------------------- | ----------------------------------- |
| **Agent que invoca a otro Agent:**      | Crear un Workflow que orqueste.     |
| **Skill que toma decisiones:**          | Subir categoría a Agent Specialist. |
| **Workflow de 1 entidad:**              | Degradar a Agent independiente.     |
| **Párrafos masivos de facts en Agent:** | Desacoplar a un Knowledge-Base.     |
| **Constraint repetido en n-Agents:**    | Desacoplar a una Rule transversal.  |

## 5. Mapeo de Intricacy Levels

El Blueprint requiere un asignamiento de intricacy para guiar su construcción al `age-spe-entity-builder`:

| Nivel     | Cuándo aplica                                                                    |
| --------- | -------------------------------------------------------------------------------- |
| `simple`  | Una tarea clara, sin decisiones complejas, sin ramificaciones                    |
| `medium`  | Varias tareas, alguna decisión, manejo de errores básico                         |
| `complex` | Múltiples tareas, lógica de decisión, integraciones, gestión de errores avanzada |

## 6. Salida del Blueprint JSON (Handoff S2 -> S3)

```json
{
  "modo": "express | architect",
  "entidades": [
    {
      "tipo": "workflow | agent | skill | command | rule | knowledge-base",
      "nombre": "nombre-en-kebab-case",
      "descripcion": "descripción para el frontmatter",
      "funcion": "qué hace esta entidad",
      "input": { "descripcion": "", "formato": "" },
      "output": { "descripcion": "", "formato": "" },
      "relaciones": [
        {
          "entidad": "",
          "tipo": "invoca | es-invocado-por | consulta | es-condicionado-por",
          "descripcion": ""
        }
      ],
      "es_nueva": true,
      "reutilizada_de": null,
      "nivel_intricacy": "simple | medium | complex"
    }
  ],
  "diagrama_arquitectura": "código Mermaid completo | null si Express",
  "orden_creacion": ["..."],
  "skills_reutilizadas": ["..."]
}
```
