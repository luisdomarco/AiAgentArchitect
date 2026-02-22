---
description: Schemas JSON de transferencia de contexto entre los Steps del workflow wor-agentic-architect. Define la estructura de handoff S1→S2 y S2→S3.
tags: [handoff, schemas, workflow, json]
---

## Table of Contents

- [1. Handoff S1 → S2 (Process Discovery → Architecture Design)](#1-handoff-s1--s2)
- [2. Handoff S2 → S3 (Architecture Design → Entity Implementation)](#2-handoff-s2--s3)
- [3. Objeto de métricas de fase](#3-objeto-de-métricas-de-fase)

---

## 1. Handoff S1 → S2

Generado por `age-spe-process-discovery`. Recibido por `age-spe-architecture-designer`.

```json
{
  "modo": "express | architect",
  "proceso": {
    "nombre": "",
    "descripcion": "",
    "objetivo": "",
    "trigger": "",
    "pasos": [],
    "decisiones": [],
    "integraciones": [],
    "checkpoints_humanos": [],
    "input": {},
    "output": {},
    "restricciones": []
  },
  "diagrama_as_is": "código Mermaid | null"
}
```

**Notas:**

- `diagrama_as_is` es obligatorio en Modo Architect antes de cerrar S1.
- `restricciones` incluye limitaciones técnicas, de negocio o de acceso.

---

## 2. Handoff S2 → S3

Generado por `age-spe-architecture-designer`. Recibido por `age-spe-entity-builder`.

```json
{
  "entidades": [
    {
      "tipo": "workflow | agent | skill | command | rule | knowledge-base",
      "nombre": "",
      "descripcion": "",
      "funcion": "",
      "relaciones": [],
      "es_nueva": true,
      "nivel_intricacy": "simple | medium | complex"
    }
  ],
  "diagrama_arquitectura": "código Mermaid | null",
  "orden_creacion": [],
  "skills_reutilizadas": []
}
```

**Notas:**

- `orden_creacion` define la secuencia de generación de entidades en S3.
- `skills_reutilizadas` lista Skills existentes que no se generarán de nuevo.
- `diagrama_arquitectura` es obligatorio en Modo Architect antes de cerrar S2.

---

## 3. Objeto de métricas de fase

Mantenido por el orquestador y pasado al Evaluador en cada ciclo QA:

```json
{ "regeneraciones": 0, "iteraciones": 0 }
```

- **regeneraciones:** incrementar 1 cada vez que el usuario elige opción C (regenerar) en un checkpoint.
- **iteraciones:** incrementar 1 cada vez que el usuario elige opción B (editar/ajustar) en un checkpoint.
- En S3, las métricas son la suma acumulada de todas las entidades del Step.
