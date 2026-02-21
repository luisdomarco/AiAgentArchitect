---
name: ski-process-interviewer
description: Structured interview technique for process discovery. Use it to conduct BPM/BPA interviews, apply inverse engineering on vague descriptions, and extract complete process information through organized question blocks.
---

# Process Interviewer Skill

Protocolo de entrevista estructurada para descubrir procesos con profundidad y precisión. Combina técnicas de BPM, BPA e ingeniería inversa.

## Input / Output

**Input:**
- Descripción inicial del proceso en lenguaje natural
- Modo activo: `express` o `architect`

**Output:**
- Conjunto de preguntas estructuradas por bloque
- Validaciones de calidad de respuesta
- Señales de alerta para detectar complejidad oculta

---

## Procedure

### 1. Análisis previo a la primera pregunta

Antes de formular ninguna pregunta, analiza la descripción inicial e identifica:

- **Lo que se sabe:** información explícita en la descripción.
- **Lo que está implícito:** información que se puede inferir pero no se ha dicho.
- **Lo que falta:** información sin la que no se puede diseñar nada.

Prioriza las preguntas sobre lo que falta. No preguntes lo que ya sabes.

---

### 2. Principios de la entrevista

**Una pregunta a la vez.** Nunca formular dos preguntas en el mismo mensaje, aunque parezcan relacionadas.

**Validar antes de avanzar.** Si la respuesta es vaga o incompleta, repregunta antes de pasar al siguiente tema.

**Descomponer lo vago.** Si el usuario usa términos genéricos, descompón en lo concreto.

**No asumir.** Ningún campo del proceso puede completarse por inferencia sin validación explícita del usuario.

---

### 3. Técnica de ingeniería inversa

Ante descripciones vagas o genéricas, aplica la descomposición sistemática:

**Patrón general:**
> *"Cuando dices [término vago], ¿te refieres a [opción A], [opción B] o [opción C]?"*

**Patrones específicos por tipo de vaguedad:**

| Descripción vaga | Descomposición |
|---|---|
| "Automatizar [proceso]" | ¿Qué pasos concretos tiene ese proceso hoy? ¿Cuál de ellos consume más tiempo? ¿Cuál tiene más errores? |
| "Gestionar [entidad]" | ¿Gestionar en qué sentido: crear, actualizar, eliminar, clasificar, enrutar? |
| "Procesar [datos]" | ¿Qué se hace exactamente con esos datos? ¿Se transforman, se validan, se almacenan, se envían? |
| "Mejorar [área]" | ¿Qué problema concreto existe hoy en esa área? ¿Cómo se mide que está mejorado? |
| "Integrar con [sistema]" | ¿Qué información se lee de ese sistema? ¿Qué información se escribe? ¿Con qué frecuencia? |

---

### 4. Bloques de preguntas para Modo Architect

Aplica los bloques en orden. Dentro de cada bloque, una pregunta a la vez.

#### Bloque 1 — Objetivo del sistema

Objetivo: entender el problema real y el resultado esperado.

- ¿Qué problema específico debe resolver este sistema? *(validación: descripción concreta, no genérica)*
- ¿Cuál es el resultado cuando funciona correctamente? ¿Cómo se ve ese éxito?
- ¿Cómo se hace esto hoy, sin el sistema? ¿Qué pasos se siguen manualmente?
- ¿Qué pasa si el sistema falla o no existe? ¿Cuál es el coste o impacto?

**Señal de respuesta insuficiente:** El usuario describe el qué pero no el por qué, o el resultado pero no el problema de partida. Repregunta.

---

#### Bloque 2 — Flujo de datos

Objetivo: mapear el proceso completo de inicio a fin.

- Describe el flujo paso a paso. *(formato sugerido: 1. → 2. → 3.)*
- ¿Qué INPUT recibe el sistema para iniciarse? ¿Cuál es su formato y origen?
- ¿Quién o qué dispara el proceso? *(usuario, evento, cron job, webhook, email...)*
- ¿Qué OUTPUT produce al finalizar? ¿A quién o qué sistema va ese output?

**Señal de respuesta insuficiente:** El flujo tiene saltos temporales ("y luego ya está listo") sin explicar qué ocurre en el medio. Pide que detalle ese gap.

---

#### Bloque 3 — Validación del flujo

Objetivo: descubrir complejidad oculta en el flujo.

- ¿Hay decisiones o bifurcaciones? ¿En qué puntos y qué condiciona cada camino?
- ¿Hay pasos que pueden fallar? ¿Qué ocurre cuando fallan?
- ¿Hay pasos que se repiten hasta que se cumpla alguna condición?
- ¿Hay casos excepcionales o edge cases que el sistema debe manejar diferente?

**Señal de respuesta insuficiente:** El usuario dice "no" a todo. Proactivamente pregunta: *"¿Qué pasa si el input llega mal formado? ¿Y si el sistema externo no responde?"*

---

#### Bloque 4 — Integraciones

Objetivo: identificar dependencias con sistemas externos.

- ¿El proceso interactúa con algún sistema externo? *(CRM, ERP, base de datos, API, email, Slack...)*
- Para cada sistema: ¿qué información se lee? ¿qué información se escribe? ¿con qué frecuencia?
- ¿Hay credenciales o autenticación involucrada?
- ¿Esos sistemas tienen limitaciones de uso o rate limits relevantes?

---

#### Bloque 5 — Autonomía y control

Objetivo: definir los límites de autonomía del sistema.

- ¿Hay puntos donde un humano debe revisar o aprobar antes de continuar?
- ¿Qué decisiones nunca debe tomar el sistema solo? ¿Por qué?
- ¿Qué nivel de autonomía se espera en el día a día?
- ¿Hay acciones irreversibles en el proceso? *(enviar email, borrar datos, hacer un pago)*

---

#### Bloque 6 — Contexto adicional

Objetivo: capturar información de soporte relevante.

- ¿Hay documentación, ejemplos o datos de referencia que el sistema deba conocer?
- ¿Hay restricciones legales, de negocio o técnicas a tener en cuenta?
- ¿Hay procesos similares ya agentizados que pueda reutilizar o tomar como referencia?
- ¿Hay algo importante que no haya preguntado y debería saber?

---

### 5. Preguntas de Modo Express

Si el modo es Express, usa únicamente estas preguntas (máx. 5, en el orden que la descripción inicial haga más relevante):

1. ¿Qué problema concreto resuelve esta entidad?
2. ¿Qué recibe exactamente como input para funcionar?
3. ¿Qué produce como output y a quién o qué se lo entrega?
4. ¿Cómo debe actuar ante los casos más comunes?
5. ¿Hay algo que nunca deba hacer o alguna restricción importante?

Si con menos preguntas tienes la información completa, no hagas las restantes.

---

### 6. Challenge del flujo

Antes de cerrar la entrevista en Modo Architect, valida activamente la comprensión:

**Paso 1 — Reflejo del proceso:**
*"Antes de continuar, quiero confirmar que lo he entendido correctamente. El proceso es: [resumen en 3-5 pasos]. ¿Es correcto?"*

**Paso 2 — Challenge con casos extremos:**
Una vez confirmado el flujo, haz al menos 2 preguntas de challenge sobre:
- El caso de error más probable
- El caso excepcional más relevante que hayas detectado durante la entrevista

Ejemplo: *"Has mencionado que el sistema envía una respuesta al cliente. ¿Qué ocurre si el cliente no responde en X tiempo? ¿Hay un reintento o se escala a un humano?"*

---

## Examples

**Ejemplo 1 — Descomposición de descripción vaga**

Usuario: *"Quiero agentizar la atención al cliente."*

Aplicación de ingeniería inversa:
1. *"¿Por qué canales entran las solicitudes de clientes? (email, chat, teléfono, formulario web...)"*
2. *[respuesta: email y chat]* → *"¿Qué tipo de solicitudes son las más frecuentes? ¿Tienes los 3 casos más comunes?"*
3. *[respuesta: dudas sobre facturación, cambios de plan, incidencias técnicas]* → *"¿Qué sistema usáis hoy para gestionar estas solicitudes? ¿Hay un CRM o helpdesk?"*

**Ejemplo 2 — Detección de complejidad oculta**

Usuario: *"Es simple, solo necesito que clasifique los emails y los reenvíe al departamento correcto."*

Challenge: *"Cuando dices 'departamento correcto', ¿cuántos departamentos hay? ¿Qué ocurre si un email podría ir a más de uno? ¿Y si la clasificación no es clara?"*

→ Si el usuario revela 5+ departamentos y casos de ambigüedad, señal de escalado a Architect.

---

## Error Handling

- **Respuesta demasiado breve:** Repregunta con una formulación más específica. No avances.
- **Respuesta contradictoria:** Señala la contradicción directamente: *"Antes mencionaste X, pero ahora describes Y. ¿Cuál es el comportamiento correcto?"*
- **El usuario no sabe responder:** Ofrece opciones concretas para que elija: *"¿El trigger es A, B o C?"*
- **El usuario da información de más bloques a la vez:** Anótala internamente para el bloque correspondiente, pero sigue el orden de bloques sin saltar.
