---
trigger: always_on
alwaysApply: true
tags: [checkpoints, validation, interaction]
---

## Context

Esta rule define cómo presentar resúmenes, gestionar validaciones y comportarse en los checkpoints entre fases y entre entidades. Un checkpoint mal gestionado lleva a malentendidos, retrabajo y pérdida de contexto. Un checkpoint bien gestionado da al usuario control total sobre el proceso sin fricción innecesaria.

## Hard Constraints

- Nunca avanzar de fase o de entidad sin aprobación explícita del usuario — siempre mediante la opción A del checkpoint.
- Nunca interpretar silencio o respuesta ambigua como aprobación.
- Nunca omitir el checkpoint de fase aunque el usuario parezca impaciente.
- Nunca presentar un checkpoint sin las 4 opciones estándar.
- Nunca proceder con una edición sin pedir primero al usuario que especifique qué cambiar.

## Soft Constraints

- Presentar los resúmenes de forma concisa: lo suficiente para que el usuario pueda validar, sin repetir todo lo ya dicho.
- Si el usuario elige la opción B (editar), preguntar qué quiere cambiar antes de modificar nada.
- Si el usuario elige la opción C (regenerar), confirmar si quiere regenerar desde cero o con alguna indicación específica.
- Si el usuario elige la opción D (volver atrás), confirmar a qué punto exacto quiere retroceder.

## Formato estándar de checkpoint

Todo checkpoint debe seguir esta estructura:

```
[Resumen de lo completado en esta fase/entidad]

¿Cómo quieres continuar?
A) ✅ Aprobar y [siguiente acción]
B) ✏️  Ajustar [qué se puede ajustar]
C) 🔄 Regenerar [qué se regenera]
D) ↩️  Volver a [fase o entidad anterior]
```

## Checkpoints del sistema

| Checkpoint | Momento | Siguiente acción si A |
|---|---|---|
| CP-S1 | Al cerrar el Step 1 | Pasar al Step 2 |
| CP-S2 | Al cerrar el Step 2 | Pasar al Step 3 |
| CP-S3-N | Tras generar cada entidad | Generar siguiente entidad |
| CP-CIERRE | Al presentar el process-overview.md | Cerrar el proceso |

## Gestión de respuestas ambiguas

Si el usuario responde de forma que no corresponde a ninguna de las 4 opciones:

1. No interpretar ni asumir la intención.
2. Responder: *"¿Quieres [opción A], [opción B], [opción C] o [opción D]?"*
3. Esperar respuesta explícita antes de actuar.

## Gestión de cambios durante un checkpoint

Si el usuario elige B (editar):
- Preguntar: *"¿Qué parte quieres ajustar?"*
- Aplicar solo el cambio indicado, sin modificar el resto.
- Presentar de nuevo el elemento modificado con un nuevo checkpoint.

Si el usuario elige C (regenerar):
- Preguntar: *"¿Quieres regenerar con alguna indicación específica o desde cero?"*
- Si da indicaciones, incorporarlas antes de regenerar.
- Presentar el resultado con un nuevo checkpoint.

Si el usuario elige D (volver):
- Confirmar: *"¿Vuelves al Step [X] / a la entidad [nombre]?"*
- Retomar desde ese punto con el contexto íntegro de lo que había sido aprobado hasta entonces.
