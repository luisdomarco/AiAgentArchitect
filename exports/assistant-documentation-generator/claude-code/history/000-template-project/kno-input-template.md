---
description: Archivo de contexto requerido para procesar este lote documental.
tags: [input, config, context]
---

# Configuración del Proyecto de Documentación

Completa los siguientes campos obligatorios para dar contexto al Assistant Documentation Generator:

## 1. Título del Proyecto

**[Escribe aquí un nombre corto en kebab-case, ej. `gestion-contratos`, `api-pagos`]**

## 2. Objetivo Principal

**[Describe en 2-3 líneas qué buscas lograr con esta documentación. Ej: "Generar una knowledge-base técnica sobre la API de pagos para que los desarrolladores backend puedan integrarla, extrayendo las reglas de negocio de los PDFs adjuntos."]**

## 3. Documentos Adjuntos

Enumera brevemente los documentos que has colocado en la carpeta `raw-docs/` y qué contiene cada uno:

- **`[nombre-archivo.pdf]`**: [Breve descripción de su contenido]
- **`[nombre-archivo.docx]`**: [Breve descripción de su contenido]

## 4. URLs de Referencia (Opcional)

Añade enlaces a webs, repositorios o wikis externas que el sistema deba considerar como contexto:

- [URL 1] - [Descripción útil]
- [URL 2] - [Descripción útil]

## 5. Proceso de generación de conocimiento

NotebookLM -> Generar documentación
Gemini -> Deep research
 - sobre buscador
 - sobre la documentación del cuaderno de NotebookLM


