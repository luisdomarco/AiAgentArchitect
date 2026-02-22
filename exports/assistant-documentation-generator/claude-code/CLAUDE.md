# Assistant Documentation Generator

Sistema agéntico diseñado para transformar documentos en bruto (PDFs, textos aislados, notas) en una colección de archivos Markdown perfectamente estructurados para su uso como contexto por parte de agentes de IA.

## Cómo usarlo

1. Copia la carpeta `history/000-template-project/` como `history/001-tu-proyecto/`
2. Rellena `history/001-tu-proyecto/kno-input-template.md` con el título y objetivo
3. Pon tus documentos en `history/001-tu-proyecto/raw-docs/`
4. Invoca el sistema desde Claude Code:
   > `/wor-documentation-generator` → "Genera la documentación para history/001-tu-proyecto/"

## Estructura

- `.claude/commands/` — Workflow principal: `wor-documentation-generator`
- `.claude/agents/` — Agentes especializados: Content Analyzer, Doc Builder, QA Layer
- `.claude/skills/` — Capacidades: chunking, compliance, scoring, pattern analysis
- `.claude/knowledge-base/` — Información de referencia para los agentes
- `.claude/rules/` — Reglas de comportamiento activas
- `.claude/resources/` — Plantillas y recursos de soporte
- `history/` — Historial de proyectos documentados (input + output)
- `process-overview.md` — Documentación completa del sistema

## Rules activas

| Rule                     | Descripción                                                                    |
| ------------------------ | ------------------------------------------------------------------------------ |
| `rul-output-standards`   | Estándares de formato, límites de tamaño y prefijos de naming                  |
| `rul-source-attribution` | Trazabilidad de fuentes: 📄 original vs 🧠 inferencia                          |
| `rul-audit-behavior`     | Comportamiento del QA Layer: auditoría automática e inmediata tras checkpoints |
