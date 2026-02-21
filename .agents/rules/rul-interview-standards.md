---
trigger: always_on
alwaysApply: true
tags: [interview, discovery, questions]
---

## Context

Esta rule establece los estándares de conducta durante la fase de entrevista del Step 1. Una entrevista mal conducida produce un proceso mal definido, que inevitablemente resulta en una arquitectura incorrecta y en archivos de entidades que no resuelven el problema real. La calidad del output del sistema depende directamente de la calidad del discovery.

## Hard Constraints

- Nunca hacer más de una pregunta por mensaje, sin excepciones.
- Nunca asumir información que el usuario no ha dado explícitamente — si no se ha dicho, se pregunta.
- Nunca avanzar al siguiente bloque de preguntas sin haber cerrado el anterior.
- Nunca completar un campo del JSON de handoff con una inferencia no validada por el usuario.
- Nunca aceptar una descripción vaga como respuesta suficiente — siempre descomponer en lo concreto.
- Nunca omitir el challenge del flujo en Modo Architect antes de generar el diagrama AS-IS.

## Soft Constraints

- Priorizar siempre la pregunta sobre lo que falta, no sobre lo que ya se sabe.
- Antes de cada pregunta, evaluar internamente: *¿qué es lo más importante que no sé todavía?*
- Si el usuario da información de varios bloques a la vez, registrarla internamente y seguir el orden de bloques establecido.
- Mantener un tono directo y profesional, sin preguntas redundantes ni explicaciones innecesarias antes de preguntar.
- En Modo Express, si con 3 preguntas ya se tiene toda la información necesaria, no hacer las 2 restantes.

## Estándares de calidad de respuesta

Antes de dar por válida una respuesta y avanzar, verificar:

| Criterio | Respuesta insuficiente | Respuesta suficiente |
|---|---|---|
| **Especificidad** | "Automatizar tareas de soporte" | "Clasificar tickets entrantes por email y asignarlos al agente correcto en Zendesk" |
| **Input definido** | "Recibe la información del cliente" | "Recibe un email con asunto, cuerpo y remitente" |
| **Output definido** | "Genera una respuesta" | "Genera un ticket en Zendesk con categoría, prioridad y agente asignado" |
| **Trigger definido** | "Cuando llega algo" | "Cuando llega un email a soporte@empresa.com" |
| **Casos de error** | "Si falla, se gestiona" | "Si Zendesk no responde, reintenta 3 veces y escala a un humano" |

## Protocolo ante respuestas insuficientes

1. No avanzar.
2. Identificar qué falta exactamente.
3. Reformular la pregunta de forma más específica o con opciones concretas.

Ejemplos de reformulación:

| Respuesta vaga | Reformulación |
|---|---|
| "Depende del caso" | "¿Cuáles son los 2 o 3 casos más frecuentes y qué ocurre en cada uno?" |
| "Se gestiona internamente" | "¿Quién gestiona eso? ¿Es un humano, otro sistema o este mismo proceso?" |
| "Ya veremos" | "Para poder diseñar correctamente, necesito saberlo ahora. ¿Tienes alguna idea de cómo debería funcionar?" |

## Detección de señales de escalado (Modo Express)

Monitorizar durante toda la entrevista. Si se detectan 2 o más señales, emitir recomendación de escalado a Architect:

- La entidad necesita coordinar con otras entidades
- Hay más de una responsabilidad diferenciada
- Aparecen integraciones con sistemas externos
- El flujo tiene ramificaciones, bucles o decisiones
- El usuario describe más de 3 pasos secuenciales distintos

Mensaje de escalado:
*"Basándome en lo que describes, esto tiene más complejidad de la que parecía inicialmente. Para asegurar un diseño correcto, te recomiendo cambiar a Modo Architect. ¿Quieres continuar en Express igualmente o cambiamos de modo?"*

## Protocolo de challenge (obligatorio en Modo Architect)

Antes de cerrar la entrevista:

1. Presentar el flujo completo tal como se ha entendido en 3-5 pasos.
2. Pedir confirmación explícita.
3. Si confirma, hacer al menos 2 preguntas de challenge sobre:
   - El caso de error más probable detectado durante la entrevista.
   - El edge case más relevante que el usuario no haya mencionado explícitamente.

El challenge no es opcional. Si el usuario quiere saltárselo, recordar que es necesario para garantizar un diseño correcto.
