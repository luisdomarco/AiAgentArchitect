---
name: res-system-packaging-logic
description: Políticas estrictas de empaquetado, exportación y checkpoints de error.
tags: [export, packaging, checkpoint, error, handler]
---

# System Packaging Logic

Este documento contiene las ramas de decisión a ejecutar cuando el Architect orquesta el cierre del sistema e inyecta capas periféricas.

## Empaquetado Final

Genera archivos en `exports/{nombre-sistema}/google-antigravity/.agents/` (ver `kno-system-architecture` §3). Estructura: `workflows/`, `skills/`, `rules/`, `knowledge-base/`, `resources/`, `process-overview.md`.

Mostrar resumen de export con número de entidades generadas por tipo.

**Checkpoint post-empaquetado:**
A) ✅ Finalizar · B) 📦 Exportar a Claude Code · C) 📦 Exportar a app (ChatGPT/Claude.ai/Dust/Gemini) · D) 📦 Múltiples formatos

Si B/C/D: activar `ski-platform-exporter` con sistema y plataforma destino → genera en `exports/{nombre}/{plataforma}/`. Permitir múltiples iteraciones.

**Pregunta de embebido QA:**
A) ✅ Sí, embeber QA Layer (3 agents + 3 skills + 1 rule + 1 knowledge-base) · B) ⏭️ No, finalizar

Si A: activar `ski-qa-embed` con `sistema_path`, `sistema_nombre`, `workflow_path` y `rules_existentes`. La skill crea los archivos QA, inicializa `qa-report.md` en blanco e inserta los hooks en el workflow del sistema.

## Checkpoint Routing Table

| ID        | Momento                     | QA automático                    |
| --------- | --------------------------- | -------------------------------- |
| CP-S1     | Cierre Step 1               | Auditor + Evaluador (S1)         |
| CP-S2     | Cierre Step 2               | Auditor + Evaluador (S2)         |
| CP-S3-N   | Cada entidad en Step 3      | Auditor (entidad N)              |
| CP-CIERRE | Aprobación process-overview | Evaluador (global) + Optimizador |

## Gestión de Errores Activa

- **JSON de handoff incompleto:** solicitar al agente responsable que lo complete antes de continuar al siguiente Step.
- **Respuesta ambigua en checkpoint:** preguntar siempre explícitamente qué cambiar antes de actuar.
- **Inconsistencia entre entidades:** pausar y notificar al usuario antes de permitir la continuidad gráfica.

> **Importante:** El JSON de handoff es el único mecanismo de transferencia de contexto entre Steps. Cada agente recibe el JSON del Step anterior y entrega el suyo propio de vuelta al pipeline principal.
