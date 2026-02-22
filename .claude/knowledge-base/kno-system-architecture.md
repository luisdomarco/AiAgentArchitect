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

La carpeta root es el **source of truth** de todas las entidades. Es agnóstica a la plataforma de destino.

```
(Project Root)
├── .agents/
│   ├── workflows/
│   │   ├── wor-[nombre].md
│   │   ├── age-spe-[nombre].md
│   │   ├── age-sup-[nombre].md
│   │   └── com-[nombre].md
│   │
│   ├── skills/
│   │   └── ski-[nombre]/
│   │       └── SKILL.md
│   │
│   ├── rules/
│   │   └── rul-[nombre].md
│   │
│   ├── knowledge-base/
│   │   └── kno-[nombre].md
│   │
│   └── resources/
│       └── res-[nombre].md
│
├── exports/
│   └── [nombre-sistema]/
│
└── repository/
    └── [tipo]-repo.md
```

Desde este catálogo, un agente de exportación se encarga de distribuir las entidades a sus correspondientes arquitecturas según la plataforma de destino.

---

## 2. Arquitectura para aplicaciones

Se aplica cuando la plataforma de destino es una aplicación de chat: Claude.ai Projects, Gemini, Dust, ChatGPT.

| Entidad         | Formato en la plataforma                            |
| --------------- | --------------------------------------------------- |
| Workflows       | Instrucciones en un único archivo `.md`             |
| Agents          | Instrucciones en un único archivo `.md`             |
| Skills          | Estructura de carpeta contenida igual que el origen |
| Rules           | N archivos `.md` adjuntos al proyecto               |
| Knowledge-bases | N archivos `.md` adjuntos al proyecto               |
| Commands        | Se ejecutan directamente en el chat como prompt     |

---

## 3. Arquitectura de exportación

Define cómo se estructuran los sistemas generados en `exports/` según la plataforma de destino.

### Export por defecto: Google Antigravity

Todos los sistemas generados se exportan primero a Google Antigravity. La estructura coloca todas las entidades dentro de `.agents/` para máxima compatibilidad.

```
exports/{nombre-sistema}/google-antigravity/
└── .agents/
    ├── workflows/              ← archivos .md de workflows, agents y commands
    ├── skills/                 ← carpetas ski-nombre/SKILL.md
    ├── rules/                  ← archivos .md de rules
    ├── knowledge-base/         ← archivos .md (referenciados desde workflows/agents)
    ├── resources/              ← archivos .md de recursos de apoyo
    └── process-overview.md     ← documentación del sistema
```

**Nota sobre paths**: Los workflows y agents usan rutas relativas internas como `./workflows/age-xxx.md` o `./skills/ski-xxx/SKILL.md`.
Cada plataforma de destino genera una copia independiente (N copias totales) de los archivos originales. Las rutas relativas se resuelven siempre localmente dentro del directorio de la exportación (p.ej., `.agents/` en Antigravity, `.claude/` en Claude Code, o el raíz en otras aplicaciones). Ninguna referencia de un export debe apuntar a la carpeta original ni a otra exportación.

---

### Exports opcionales (bajo demanda)

Tras el export a Antigravity, el usuario puede solicitar exports adicionales a otras plataformas usando `ski-platform-exporter`.

#### Claude Code

```
exports/{nombre-sistema}/claude-code/
├── .claude/
│   ├── knowledge-base/         ← archivos .md de base de conocimiento
│   ├── rules/                  ← archivos .md de rules
│   ├── resources/              ← archivos .md de recursos de apoyo
│   ├── skills/                 ← carpetas ski-nombre/SKILL.md
│   ├── agents/                 ← archivos .md de agents
│   ├── commands/               ← workflows convertidos a commands (.md)
│   ├── settings.json           ← configuración de permisos
│   └── CLAUDE.md               ← contexto global + referenciación
└── process-overview.md         ← overview del sistema
```

**Conversión Workflow → Command**: Los workflows se convierten en commands para Claude Code. Solamente es exportarlos en la carpeta `/commands` ya que siguen la misma estructura.

**Rules**: Claude Code (`CLAUDE.md`) posee conocimiento de las reglas, cuándo se aplican, y las referencia. Las reglas siguen depositadas físicamente en `/rules`.

---

#### Aplicaciones (ChatGPT, Claude.ai, Dust, Gemini)

```
exports/{nombre-sistema}/{nombre-aplicación}/
├── knowledge-base/             ← archivos .md
├── rules/                      ← archivos .md
├── skills/                     ← carpetas ski-nombre/SKILL.md
├── workflows/                  ← archivos .md de workflows, agents y commands
├── resources/                  ← archivos .md
└── process-overview.md         ← overview del sistema
```

**Formato**: Archivos `.md` individuales para workflows, agents, rules, knowledge-bases y resources. El usuario sube estos archivos manualmente al proyecto de la plataforma correspondiente.

---

### Tabla de mapeo: source → plataformas

| Entidad          | Antigravity Export                  | Claude Code Export                  | Aplicaciones Export         |
| ---------------- | ----------------------------------- | ----------------------------------- | --------------------------- |
| Workflow         | `.agents/workflows/wor-xxx.md`      | `.claude/commands/wor-xxx.md`       | `workflows/wor-xxx.md`      |
| Agent            | `.agents/workflows/age-xxx.md`      | `.claude/agents/age-xxx.md`         | `workflows/age-xxx.md`      |
| Command          | `.agents/workflows/com-xxx.md`      | `.claude/commands/com-xxx.md`       | `workflows/com-xxx.md`      |
| Skill            | `.agents/skills/ski-xxx/SKILL.md`   | `.claude/skills/ski-xxx/SKILL.md`   | `skills/ski-xxx/SKILL.md`   |
| Rule             | `.agents/rules/rul-xxx.md`          | `.claude/rules/rul-xxx.md`          | `rules/rul-xxx.md`          |
| Knowledge-base   | `.agents/knowledge-base/kno-xxx.md` | `.claude/knowledge-base/kno-xxx.md` | `knowledge-base/kno-xxx.md` |
| Resources        | `.agents/resources/res-xxx.md`      | `.claude/resources/res-xxx.md`      | `resources/res-xxx.md`      |
| process-overview | `.agents/process-overview.md`       | `process-overview.md`               | `process-overview.md`       |

---

### Skill de conversión: ski-platform-exporter

Para generar exports adicionales, el sistema usa `ski-platform-exporter`:

**Input**: ruta del export Antigravity (`exports/{nombre}/google-antigravity/`) + plataforma destino

**Output**: archivos generados en `exports/{nombre}/{plataforma}/`

**Plataformas soportadas**: `claude-code`, `chatgpt`, `claude-ai`, `dust`, `gemini`

**Invocación**: desde el workflow (checkpoint post-empaquetado) o directamente por el usuario en cualquier momento

---

## 4. Rutas relativas entre entidades

Todas las rutas de referencia cruzada se expresan de forma relativa desde el root de la arquitectura:

| Entidad referenciada | Ruta relativa                      |
| -------------------- | ---------------------------------- |
| Skill                | `./skills/ski-[nombre]/SKILL.md`   |
| Agent Specialist     | `./workflows/age-spe-[nombre].md`  |
| Agent Supervisor     | `./workflows/age-sup-[nombre].md`  |
| Workflow             | `./workflows/wor-[nombre].md`      |
| Rule                 | `./rules/rul-[nombre].md`          |
| Knowledge-base       | `./knowledge-base/kno-[nombre].md` |
| Command              | `./workflows/com-[nombre].md`      |
