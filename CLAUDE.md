# AiAgentArchitect

Sistema para diseñar y generar sistemas agénticos completos.

## Cómo funciona

Ejecuta el workflow principal para iniciar una sesión de diseño:

```
wor-agentic-architect
```

## Estructura

- `.agents/` — Directorio real para Google Antigravity
  - `workflows/` — Workflows (`wor-*`) y Agentes (`age-spe-*`)
  - `rules/` — Reglas (`rul-*`)
  - `skills/` — Skills (`ski-*`)
  - `knowledge-base/` — Base de conocimiento (`kno-*`)
- `exports/` — Sistemas generados
  - `template/` — base para copiar y renombrar
  - `{nombre-sistema}/google-antigravity/` — export por defecto
  - `{nombre-sistema}/{plataforma}/` — exports opcionales

## Rules activas

- `rul-naming-conventions` — prefijos y convenciones de nomenclatura
- `rul-checkpoint-behavior` — formato de checkpoints y validaciones
- `rul-interview-standards` — protocolo de entrevista (una pregunta a la vez)
