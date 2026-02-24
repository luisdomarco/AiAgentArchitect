---
trigger: always_on
alwaysApply: true
tags: [compliance, strict, cot, validation, reasoning]
---

## Context

Esta regla garantiza estadísticamente que el modelo fundacional subyacente a cada agente ejecute efectivamente sus instrucciones o respete las constraints sin caer en la pereza, las asunciones rápidas o la desobediencia iterativa.
Se basa en el paradigma del Chain of Thought (Mecanismo de Evaluación del Sistema Interno).

## Hard Constraints

- Antes de emitir CUALQUIER output definitivo, respuesta al usuario o archivo generado en una fase, DEBES reflexionar y autoevaluarte.
- Debes escribir obligatoriamente un bloque de código Markdown con el lenguaje "xml" y un tag `<sys-eval>`.
- Dentro de este bloque, debes listar mentalmente en lenguaje natural dos cosas:
  1. Los **Hard Constraints primarios** (lo prohibido dictado por las reglas activas).
  2. Las **Tasks asignadas** a tu rol y fase (lo imperativo dictado por tu instrucción principal).
- Tras listar ambos puntos, debes manifestar si tu output planeado choca con alguna prohibición y si efectivamente cubre las tareas encomendadas.
- Cierra el bloque obligatoriamente con `</sys-eval>`.
- Solo y exclusivamente después del cierre del tag, puedes imprimir tu output definitivo funcional hacia el humano o sistema.

## Ejemplo de Flujo de Pensamiento

```xml
<sys-eval>
Listando mis Hard Constraints:
1. "Nunca cambiar el orden del markdown del framework." -> Mi propuesta actual mantiene intactas las etiquetas H2 y H3 de la base. Cumplido.
2. "Nunca usar una entidad diferente a las seis catalogadas." -> Iba a usar "Custom Code", está prohibido. Corrigiendo a "Agent Specialist" (age-spe-).

Listando mis Tasks:
1. "Crear diagrama Mermaid." -> Generado y adaptado al formato as-is. Cumplido.
2. "Validar explícitamente con el usuario antes del handoff." -> Presentando las opciones A/B/C/D al humano. Cumplido.

Veredicto: Constraints respetados y Tasks ejecutadas. Listo y seguro. Generando output final.
</sys-eval>
```

[... Tu output final empiza aquí ...]
