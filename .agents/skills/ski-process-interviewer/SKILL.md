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

### 3. Ejecución Estructural desde Recursos

Las plantillas de ingeniería inversa (para desambiguar términos), el Cuestionario Express y los Bloques Complejos para Arquitectos ya no residen codificados en esta Skill, sino en un recurso centralizado para aligerar la carga de la memoria estática.

> **El skill de entrevistador requiere que previamente cargues y estudies el siguiente recurso:**
> `../../resources/res-interview-question-trees.md`

Extrae de allí la matriz que corresponda a tu modo operativo (Express = Cuestionario Corto, Architect = Bloques 1-6 con Descomposición Dinámica) e interroga respetando la cadencia de una pregunta por turno.

---

### 6. Challenge del flujo

Antes de cerrar la entrevista en Modo Architect, valida activamente la comprensión:

**Paso 1 — Reflejo del proceso:**
_"Antes de continuar, quiero confirmar que lo he entendido correctamente. El proceso es: [resumen en 3-5 pasos]. ¿Es correcto?"_

**Paso 2 — Challenge con casos extremos:**
Una vez confirmado el flujo, haz al menos 2 preguntas de challenge sobre:

- El caso de error más probable
- El caso excepcional más relevante que hayas detectado durante la entrevista

Ejemplo: _"Has mencionado que el sistema envía una respuesta al cliente. ¿Qué ocurre si el cliente no responde en X tiempo? ¿Hay un reintento o se escala a un humano?"_

---

## Examples

**Ejemplo 1 — Descomposición de descripción vaga**

Usuario: _"Quiero agentizar la atención al cliente."_

Aplicación de ingeniería inversa:

1. _"¿Por qué canales entran las solicitudes de clientes? (email, chat, teléfono, formulario web...)"_
2. _[respuesta: email y chat]_ → _"¿Qué tipo de solicitudes son las más frecuentes? ¿Tienes los 3 casos más comunes?"_
3. _[respuesta: dudas sobre facturación, cambios de plan, incidencias técnicas]_ → _"¿Qué sistema usáis hoy para gestionar estas solicitudes? ¿Hay un CRM o helpdesk?"_

**Ejemplo 2 — Detección de complejidad oculta**

Usuario: _"Es simple, solo necesito que clasifique los emails y los reenvíe al departamento correcto."_

Challenge: _"Cuando dices 'departamento correcto', ¿cuántos departamentos hay? ¿Qué ocurre si un email podría ir a más de uno? ¿Y si la clasificación no es clara?"_

→ Si el usuario revela 5+ departamentos y casos de ambigüedad, señal de escalado a Architect.

---

## Error Handling

- **Respuesta demasiado breve:** Repregunta con una formulación más específica. No avances.
- **Respuesta contradictoria:** Señala la contradicción directamente: _"Antes mencionaste X, pero ahora describes Y. ¿Cuál es el comportamiento correcto?"_
- **El usuario no sabe responder:** Ofrece opciones concretas para que elija: _"¿El trigger es A, B o C?"_
- **El usuario da información de más bloques a la vez:** Anótala internamente para el bloque correspondiente, pero sigue el orden de bloques sin saltar.
