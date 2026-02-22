# AiAgentArchitect

Sistema para diseñar y generar sistemas agénticos completos.

## Cómo funciona

Ejecuta el workflow principal para iniciar una sesión de diseño:

**Desde Google Antigravity:**
```
wor-agentic-architect
```

**Desde Claude Code:**
```
/wor-agentic-architect
```

## Estructura del Proyecto

Este proyecto mantiene **dos implementaciones del mismo sistema agéntico**, cada una optimizada para su plataforma:

### 1. Google Antigravity (`.agents/`)

Estructura original para Google Antigravity:

- `.agents/`
  - `workflows/` — Workflows (`wor-*`) y Agentes (`age-spe-*`)
  - `skills/` — Skills con estructura de subdirectorios (`ski-*/SKILL.md`)
  - `rules/` — Reglas (`rul-*`)
  - `knowledge-base/` — Base de conocimiento (`kno-*`)
  - `resources/` — Recursos de referencia (`res-*`)

### 2. Claude Code (`.claude/`)

Estructura adaptada para Claude Code:

- `.claude/`
  - `commands/` — Workflows principales (`wor-*`)
  - `agents/` — Agents especializados (`age-spe-*`)
  - `skills/` — Skills con estructura aplanada (`ski-*.md`)
  - `rules/` — Reglas (`rul-*`)
  - `knowledge-base/` — Base de conocimiento (`kno-*`)
  - `resources/` — Recursos de referencia (`res-*`)
  - `settings.local.json` — Configuración de permisos

**Diferencias clave entre `.agents/` y `.claude/`:**
- Workflows y Agents separados: `workflows/` → `commands/` (workflows) + `agents/` (agents)
- Skills aplanados: `skills/ski-*/SKILL.md` → `skills/ski-*.md`
- Referencias ajustadas automáticamente según contexto

### 3. Sistemas Generados (`exports/`)

Directorio de salida para sistemas generados:

- `exports/`
  - `template/` — base para copiar y renombrar
  - `{nombre-sistema}/google-antigravity/` — export por defecto
  - `{nombre-sistema}/{plataforma}/` — exports opcionales

## Rules Activas

Las siguientes reglas aplican en ambas implementaciones (`.agents/` y `.claude/`):

- **`rul-naming-conventions`** — Prefijos y convenciones de nomenclatura para entidades
- **`rul-checkpoint-behavior`** — Formato de checkpoints y validaciones estructuradas
- **`rul-interview-standards`** — Protocolo de entrevista (una pregunta a la vez, sin asumir)
- **`rul-audit-behavior`** — QA Layer: activación del ciclo de auditoría y responsabilidades

## Sincronización

Ambas implementaciones deben mantenerse sincronizadas. Los cambios en una estructura deben replicarse en la otra ajustando las rutas según corresponda:
- `.agents/workflows/` ↔ `.claude/commands/` + `.claude/agents/`
- `.agents/skills/ski-*/SKILL.md` ↔ `.claude/skills/ski-*.md`
