---
name: res-interview-question-trees
description: Árboles lógicos de preguntas, técnicas de descomposición y bloques de entrevista para Discovery.
tags: [interview, questions, process, discovery, BPM]
---

# Process Interview Question Trees

Este documento actúa como el "cerebro conversacional" del especialista en descubrimiento de procesos (`age-spe-process-discovery` y su skill `ski-process-interviewer`). Contiene todas las preguntas aplicables organizadas por nivel de profundidad.

## Técnica de Ingeniería Inversa

Ante descripciones vagas o genéricas, descompón sistemáticamente:

> _"Cuando dices [término vago], ¿te refieres a [opción A], [opción B] o [opción C]?"_

| Descripción vaga         | Descomposición                                                                                          |
| ------------------------ | ------------------------------------------------------------------------------------------------------- |
| "Automatizar [proceso]"  | ¿Qué pasos concretos tiene ese proceso hoy? ¿Cuál de ellos consume más tiempo? ¿Cuál tiene más errores? |
| "Gestionar [entidad]"    | ¿Gestionar en qué sentido: crear, actualizar, eliminar, clasificar, enrutar?                            |
| "Procesar [datos]"       | ¿Qué se hace exactamente con esos datos? ¿Se transforman, se validan, se almacenan, se envían?          |
| "Mejorar [área]"         | ¿Qué problema concreto existe hoy en esa área? ¿Cómo se mide que está mejorado?                         |
| "Integrar con [sistema]" | ¿Qué información se lee de ese sistema? ¿Qué información se escribe? ¿Con qué frecuencia?               |

---

## Bloques de Entrevista (Modo Architect)

Aplica los bloques en orden. Dentro de cada bloque, formula una pregunta a la vez.

### Bloque 1 — Objetivo del sistema

- ¿Qué problema específico debe resolver este sistema? _(validación: descripción concreta, no genérica)_
- ¿Cuál es el resultado cuando funciona correctamente? ¿Cómo se ve ese éxito?
- ¿Cómo se hace esto hoy, sin el sistema? ¿Qué pasos se siguen manualmente?
- ¿Qué pasa si el sistema falla o no existe? ¿Cuál es el coste o impacto?

### Bloque 2 — Flujo de datos

- Describe el flujo paso a paso. _(formato sugerido: 1. → 2. → 3.)_
- ¿Qué INPUT recibe el sistema para iniciarse? ¿Cuál es su formato y origen?
- ¿Quién o qué dispara el proceso? _(usuario, evento, cron job, webhook, email...)_
- ¿Qué OUTPUT produce al finalizar? ¿A quién o qué sistema va ese output?

### Bloque 3 — Validación del flujo (Complejidad)

- ¿Hay decisiones o bifurcaciones? ¿En qué puntos y qué condiciona cada camino?
- ¿Hay pasos que pueden fallar? ¿Qué ocurre cuando fallan?
- ¿Hay pasos que se repiten hasta que se cumpla alguna condición?
- ¿Hay casos excepcionales o edge cases que el sistema debe manejar diferente?

### Bloque 4 — Integraciones

- ¿El proceso interactúa con algún sistema externo? _(CRM, ERP, base de datos, API, email, Slack...)_
- Para cada sistema: ¿qué información se lee? ¿qué información se escribe? ¿con qué frecuencia?
- ¿Hay credenciales o autenticación involucrada?
- ¿Esos sistemas tienen limitaciones de uso o rate limits relevantes?

### Bloque 5 — Autonomía y control

- ¿Hay puntos donde un humano debe revisar o aprobar antes de continuar?
- ¿Qué decisiones nunca debe tomar el sistema solo? ¿Por qué?
- ¿Qué nivel de autonomía se espera en el día a día?
- ¿Hay acciones irreversibles en el proceso? _(enviar email, borrar datos, hacer un pago)_

### Bloque 6 — Contexto adicional

- ¿Hay documentación, ejemplos o datos de referencia que el sistema deba conocer?
- ¿Hay restricciones legales, de negocio o técnicas a tener en cuenta?
- ¿Hay procesos similares ya agentizados que pueda reutilizar o tomar como referencia?
- ¿Hay algo importante que no haya preguntado y debería saber?

---

## Cuestionario Rápido (Modo Express)

Si el modo es Express, aplica únicamente la siguiente matriz en el menor número de intervenciones posibles:

1. **Propósito:** ¿Qué problema concreto resuelve esta entidad?
2. **Input:** ¿Qué recibe exactamente como input para funcionar?
3. **Output:** ¿Qué produce como output y a quién o qué se lo entrega?
4. **Comportamiento:** ¿Cómo debe actuar ante los casos más comunes?
5. **Restricciones:** ¿Hay algo que nunca deba hacer o alguna restricción importante?
