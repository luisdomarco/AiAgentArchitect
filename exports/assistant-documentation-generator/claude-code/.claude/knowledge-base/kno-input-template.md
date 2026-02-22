---
description: Documentación de la plantilla kno-input-template.md y sus campos requeridos (título, objetivo, recursos).
tags: [input, template, fields, documentation]
---

## Table of Contents

- [1. Estructura de kno-input-template.md](#1-estructura)
- [2. Campos Obligatorios](#2-campos-obligatorios)
- [3. Referencia a la Plantilla](#3-referencia-a-la-plantilla)

## 1. Estructura

El archivo `kno-input-template.md` es el punto de entrada principal para el Assistant Documentation Generator. Este archivo debe ubicarse transversalmente en la ruta `history/{nombre-proyecto}/kno-input-template.md`, acompañando a la carpeta `raw-docs/` con los documentos brutos del proyecto. Provee el contexto esencial y los metadatos necesarios para que el flujo entienda qué debe generar.

## 2. Campos Obligatorios

El workflow requiere que el archivo contenga la siguiente información declarada de forma clara:

- **Título del Proyecto:** Nombre corto y descriptivo del conjunto de documentación que se va a generar. Define el `{title}` de las rutas de salida.
- **Objetivo Principal:** Qué se espera lograr con esta documentación. Da contexto a los agentes sobre el tono y nivel de detalle requerido.
- **Descripción de Archivos Adjuntos:** Breve enumeración de los documentos brutos subidos en la misma carpeta, indicando qué contiene cada uno (ej. "Términos y condiciones legales", "Guía de uso interna").
- **URLs de Referencia:** Enlaces externos opcionales que el sistema deba considerar como contexto adicional durante la generación.

## 3. Referencia a la Plantilla

Para ver el formato exacto en Markdown de la plantilla física que el usuario rellena, consultar:
`../resources/res-input-template.md`
