---
trigger: always_on
alwaysApply: true
tags: [attribution, sourcing, traceability, rejection-logging]
---

## Context

Esta regla garantiza la trazabilidad completa del contenido propuesto por el sistema. El usuario debe poder distinguir inmediatamente qué información proviene literalmente del documento original y qué información o estructuras han sido sugeridas por la inferencia del sistema. Además, asegura que ningún contenido del input original se descarte sin una justificación observable.

## Hard Constraints

- Nunca omitir la etiqueta obligatoria de fuente para cada propuesta de contenido generada.
- Nunca descartar información presente en los documentos de entrada sin generar una justificación explícita de descarte.
- Nunca mezclar en un mismo bloque de contenido información extraída del original con inferencias propias sin diferenciarlas.

## Soft Constraints

- Siempre utilizar el emoji `📄` (Doc) para marcar contenido extraído o resumido directamente de los documentos de entrada.
- Siempre utilizar el emoji `🧠` (Sistema) para marcar propuestas de contenido nuevo, estructuras sugeridas, o deducciones lógicas no presentes literalmente en el input.
- Preferir listas ordenadas o viñetas simples para presentar los descartes justificados al usuario.

## Examples

**Input:** "El sistema debe manejar hasta 500 requests por segundo."

**Output Correcto:**

- `📄` Requisito de rendimiento: Capacidad para 500 requests/s. _(Extraído del documento TDR)_

**Output Correcto (Enriquecimiento):**

- `🧠` Se sugiere añadir: Implementación de un rate limiter para proteger contra picos por encima de los 500 req/s.

**Descarte Correcto:**

- **Descartado:** "Historia de la empresa desde 1995" -> **Justificación:** Irrelevante para la construcción de la knowledge-base técnica requerida.
