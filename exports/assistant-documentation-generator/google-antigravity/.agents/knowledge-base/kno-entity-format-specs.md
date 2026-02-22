---
description: Especificaciones de formato y estructura para archivos knowledge-base, rules y resources generados por el sistema.
tags: [format, specs, structure, templates, entities]
---

## Table of Contents

- [1. Knowledge-Base (kno-)](#1-knowledge-base-kno-)
- [2. Rule (rul-)](#2-rule-rul-)
- [3. Resource (res-)](#3-resource-res-)

## 1. Knowledge-Base (kno-)

**Definición:** Documentos que contienen información estática, directrices de dominio o datos de referencia que los agentes deben consultar, pero que no dictan explícitamente el comportamiento o las restricciones del sistema.

### Estructura obligatoria:

- **Frontmatter YAML:** `description` (máx. 250 caracteres), `tags`.
- **Table of Contents:** Enlaces internos a las secciones principales.
- **Secciones:** Contenido estructurado empleando encabezados Markdown (`##`, `###`), viñetas y tablas para maximizar la legibilidad por agentes.

### Límites:

- **Recomendado:** < 6.000 caracteres.
- **Máximo absoluto:** 12.000 caracteres.
- **Partición:** Si excede el límite recomendado, particionar en un archivo suplementario en `/resources/`.

## 2. Rule (rul-)

**Definición:** Documentos que imponen restricciones, estándares de calidad, convenciones y formas de actuar que condicionan el comportamiento de los agentes.

### Estructura obligatoria:

- **Frontmatter YAML:** `trigger` (always_on, manual, model_decision, glob), opcionalmente `description` o `globs`, `alwaysApply`, `tags`.
- **Context:** Por qué existe esta regla (1-2 párrafos).
- **Hard Constraints:** Lo que el agente NUNCA debe hacer. (Viñetas).
- **Soft Constraints:** Buenas prácticas y preferencias. (Viñetas).
- **Examples:** Casos base vs casos correctos/incorrectos.

### Límites:

- **Recomendado:** < 3.000 caracteres.
- **Máximo absoluto:** 12.000 caracteres.
- **Partición:** Si excede el límite recomendado, particionar la casuística detallada en `/resources/`.

## 3. Resource (res-)

**Definición:** Archivos de soporte que contienen información extensa, datos en bruto, plantillas base o contenido particionado de otras entidades para aligerar su carga cognitiva.

### Estructura obligatoria:

- **Frontmatter YAML:** `name` (res-\*\*\*), `description` (máx. 250 caracteres), `tags`.
- **Contenido libre:** El formato depende del tipo de recurso (markdown, JSON, CSV, etc.), pero debe ser altamente estructurado si es un documento de referencia. No requiere secciones fijas de Context o Tasks.

### Límites:

- **Recomendado:** < 6.000 caracteres.
- **Máximo absoluto:** 12.000 caracteres.
