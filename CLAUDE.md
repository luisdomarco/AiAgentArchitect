# AiAgentArchitect

Sistema para diseñar y generar sistemas agénticos completos.

## Cómo funciona

Ejecuta el workflow principal para iniciar una sesión de diseño:

```
wor-agentic-architect
```

## Estructura

- `agentic/` — source of truth de todas las entidades (workflows, agents, skills, rules, knowledge-base)
- `.agent/` → symlinks a agentic/ para Antigravity
- `exports/` — sistemas generados
  - `template/` — base para copiar y renombrar
  - `{nombre-sistema}/google-antigravity/` — export por defecto (listo para Antigravity)
  - `{nombre-sistema}/{plataforma}/` — exports opcionales (Claude Code, apps)

## Rules activas

- `rul-naming-conventions` — prefijos y convenciones de nomenclatura
- `rul-checkpoint-behavior` — formato de checkpoints y validaciones
- `rul-interview-standards` — protocolo de entrevista (una pregunta a la vez)
