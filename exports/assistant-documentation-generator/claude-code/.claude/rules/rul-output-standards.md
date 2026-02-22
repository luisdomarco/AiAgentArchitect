---
trigger: always_on
description: Estándares de calidad, límites de caracteres y convenciones de naming para archivos generados.
alwaysApply: true
tags: [standards, formatting, limits, naming]
---

## Context

Esta regla garantiza que todos los archivos `.md` generados por el Assistant Documentation Generator (knowledge-base, rules, resources y overview) mantengan un formato estandarizado, respeten los límites de tamaño para consumo óptimo por IA y empleen convenciones de nomenclatura coherentes. Previene la generación de documentos monolíticos o confusos que dificultarían la operación de futuros sistemas agénticos.

## Hard Constraints

- Nunca generar un archivo sin el frontmatter YAML adecuadamente formateado (`name` o `description`).
- Nunca usar mayúsculas ni espacios en los nombres de archivo (usar siempre `kebab-case`).
- Nunca generar un archivo sin el prefijo correcto de su tipo (`kno-`, `rul-`, `res-`).
- Nunca exceder los 64 caracteres en el campo de nombre del archivo.
- Nunca exceder los 250 caracteres en el campo `description` del frontmatter.
- Nunca permitir que un archivo supere los límites de tamaño máximos absolutos permitidos por tipo.
- Si un bloque de contenido previsiblemente excede el límite recomendado, NUNCA debe mantenerse monolítico: se debe particionar delegando el contenido extenso a archivos suplementarios (con prefijo `res-` en la subcarpeta `resources/`) referenciando éstos desde el documento original mediante enlaces Markdown explícitos.

## Soft Constraints

- Siempre preferir nombres descriptivos y específicos que revelen el contenido (ej. `kno-api-rest-endpoints.md` es preferible a `kno-api-doc.md`).
- Siempre redactar la descripción del frontmatter para que pueda leerse de forma independiente y entenderse sin contexto adicional extra.
- Siempre estructurar el cuerpo del documento empleando jerarquía Markdown clara (encabezados `##`, viñetas `-`, tablas) para maximizar la legibilidad y el parsing por otros agentes.

## Limits and Prefix Reference

| Tipo de Entidad | Prefijo | Directorio de Salida | Límite Recomendado | Límite Máximo Absoluto |
| --------------- | ------- | -------------------- | ------------------ | ---------------------- |
| Knowledge-base  | `kno-`  | `/knowledge-base/`   | <6.000 caracteres  | 12.000 caracteres      |
| Rule            | `rul-`  | `/rules/`            | <3.000 caracteres  | 12.000 caracteres      |
| Resources       | `res-`  | `/resources/`        | <6.000 caracteres  | 12.000 caracteres      |

## Examples

**Output Correcto:**

- Nombre: `kno-auth-security-policies.md`
- Ubicación: `output/knowledge-base/kno-auth-security-policies.md`
- Partición: "Las políticas detalladas se encuentran en `[Políticas de Contraseñas](../resources/res-password-policies.md)`"

**Output Incorrecto:**

- Nombre: `Auth Security.md` _(Contiene mayúsculas, espacios, y carece de prefijo)_
- Formato: Archivo de 15.000 caracteres sin partición referencial.
