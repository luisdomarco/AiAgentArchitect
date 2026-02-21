---
description: Arquitectura de persistencia de entidades agénticas. Define la estructura root folder, convenciones de rutas y arquitectura dual Antigravity y Claude Code.
tags: [architecture, file-structure, deployment]
---

## Table of Contents

- [1. Arquitectura root folder](#1-arquitectura-root-folder)
- [2. Arquitectura para aplicaciones](#2-arquitectura-para-aplicaciones)
- [3. Arquitectura dual: Antigravity y Claude Code](#3-arquitectura-dual-antigravity-y-claude-code)
- [4. Rutas relativas entre entidades](#4-rutas-relativas-entre-entidades)

---

## 1. Arquitectura root folder

La carpeta `agentic/` es el **source of truth** de todas las entidades. Es agnóstica a la plataforma de destino.

```
agentic/
├── workflows/
│   └── wor-[nombre].md
│
├── agents/
│   ├── age-spe-[nombre].md
│   └── age-sup-[nombre].md
│
├── skills/
│   └── ski-[nombre]/
│       └── SKILL.md
│
├── commands/
│   └── com-[nombre].md
│
├── rules/
│   └── rul-[nombre].md
│
└── knowledge-base/
    └── kno-[nombre].md
```

Desde este catálogo, un agente de exportación se encarga de distribuir las entidades a sus correspondientes arquitecturas según la plataforma de destino.

---

## 2. Arquitectura para aplicaciones

Se aplica cuando la plataforma de destino es una aplicación de chat: Claude.ai Projects, Gemini, Dust, ChatGPT.

| Entidad | Formato en la plataforma |
|---|---|
| Workflows | Instrucciones en un único archivo `.md` |
| Agents | Instrucciones en un único archivo `.md` |
| Skills | Estructura de carpeta comprimida en `.zip` |
| Rules | N archivos `.md` adjuntos al proyecto |
| Knowledge-bases | N archivos `.md` adjuntos al proyecto |
| Commands | Se ejecutan directamente en el chat como prompt |

---

## 3. Arquitectura de exportación

Define cómo se estructuran los sistemas generados en `exports/` según la plataforma de destino.

### Export por defecto: Google Antigravity

Todos los sistemas generados se exportan primero a Google Antigravity. La estructura coloca todas las entidades dentro de `.agents/` para máxima compatibilidad.

```
exports/{nombre-sistema}/google-antigravity/
└── .agents/
    ├── workflows/              ← archivos .md de workflows
    ├── agents/                 ← archivos .md de agents (referenciados desde workflows)
    ├── skills/                 ← carpetas ski-nombre/SKILL.md
    ├── rules/                  ← archivos .md de rules
    ├── knowledge-base/         ← archivos .md (referenciados desde workflows/agents)
    ├── commands/               ← archivos .md de commands (si los hay)
    └── process-overview.md     ← documentación del sistema
```

**Nota sobre paths**: Los workflows y agents usan rutas relativas como `./agents/age-xxx.md` o `./skills/ski-xxx/SKILL.md`. Estas rutas se resuelven desde `.agents/` como raíz, dado que todas las carpetas son siblings directos dentro de `.agents/`.

---

### Exports opcionales (bajo demanda)

Tras el export a Antigravity, el usuario puede solicitar exports adicionales a otras plataformas usando `ski-platform-exporter`.

#### Claude Code

```
exports/{nombre-sistema}/claude-code/
├── .claude/
│   ├── skills/                 ← carpetas ski-nombre/SKILL.md
│   ├── agents/                 ← archivos .md de agents
│   ├── commands/               ← workflows convertidos a commands (.md)
│   └── settings.json           ← configuración de permisos
├── CLAUDE.md                   ← contexto global + rules activas
├── knowledge-base/             ← archivos .md (referenciados en CLAUDE.md)
└── process-overview.md
```

**Conversión Workflow → Command**: Los workflows se convierten en commands para Claude Code. El contenido del workflow se adapta como system prompt del command.

**Rules**: Se integran en `CLAUDE.md` en la sección de instrucciones globales.

---

#### Aplicaciones (ChatGPT, Claude.ai, Dust, Gemini)

```
exports/{nombre-sistema}/{plataforma}/
├── workflows/
│   └── wor-nombre.md           ← instrucciones directas
├── agents/
│   └── age-spe-nombre.md       ← instrucciones directas
├── skills/
│   └── ski-nombre.zip          ← carpeta comprimida
├── rules/
│   └── rul-nombre.md           ← archivos adjuntables
├── knowledge-base/
│   └── kno-nombre.md           ← archivos adjuntables
└── process-overview.md         ← overview del sistema
```

**Formato**: Archivos `.md` individuales para workflows, agents, rules y knowledge-bases. Skills comprimidas como `.zip`. El usuario sube estos archivos manualmente al proyecto de la plataforma correspondiente.

---

### Tabla de mapeo: source → plataformas

| Entidad | Antigravity Export | Claude Code Export | Aplicaciones Export |
|---|---|---|---|
| Workflow | `.agents/workflows/wor-xxx.md` | `.claude/commands/wor-xxx.md` | `workflows/wor-xxx.md` |
| Agent | `.agents/agents/age-xxx.md` | `.claude/agents/age-xxx.md` | `agents/age-xxx.md` |
| Skill | `.agents/skills/ski-xxx/SKILL.md` | `.claude/skills/ski-xxx/SKILL.md` | `skills/ski-xxx.zip` |
| Rule | `.agents/rules/rul-xxx.md` | Integrada en `CLAUDE.md` | `rules/rul-xxx.md` |
| Knowledge-base | `.agents/knowledge-base/kno-xxx.md` | `knowledge-base/kno-xxx.md` + ref en `CLAUDE.md` | `knowledge-base/kno-xxx.md` |
| Command | `.agents/commands/com-xxx.md` | `.claude/commands/com-xxx.md` | `commands/com-xxx.md` |
| process-overview | `.agents/process-overview.md` | `process-overview.md` | `process-overview.md` |

---

### Skill de conversión: ski-platform-exporter

Para generar exports adicionales, el sistema usa `ski-platform-exporter`:

**Input**: ruta del export Antigravity (`exports/{nombre}/google-antigravity/`) + plataforma destino

**Output**: archivos generados en `exports/{nombre}/{plataforma}/`

**Plataformas soportadas**: `claude-code`, `chatgpt`, `claude-ai`, `dust`, `gemini`

**Invocación**: desde el workflow (checkpoint post-empaquetado) o directamente por el usuario en cualquier momento

---

## 4. Rutas relativas entre entidades

Todas las rutas de referencia cruzada se expresan de forma relativa desde `agentic/`:

| Entidad referenciada | Ruta relativa |
|---|---|
| Skill | `./skills/ski-[nombre]/SKILL.md` |
| Agent Specialist | `./agents/age-spe-[nombre].md` |
| Agent Supervisor | `./agents/age-sup-[nombre].md` |
| Workflow | `./workflows/wor-[nombre].md` |
| Rule | `./rules/rul-[nombre].md` |
| Knowledge-base | `./knowledge-base/kno-[nombre].md` |
| Command | `./commands/com-[nombre].md` |
