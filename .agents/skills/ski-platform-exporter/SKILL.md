---
name: ski-platform-exporter
description: Convierte un export de Google Antigravity a otras plataformas (Claude Code, ChatGPT, Claude.ai, Dust, Gemini). Aplica el mapeo correcto según la plataforma destino y genera la estructura de archivos correspondiente. Invocable desde el workflow post-empaquetado o directamente por el usuario.
---

# Platform Exporter Skill

Convierte un sistema exportado para Google Antigravity a otras plataformas, aplicando las transformaciones necesarias según las convenciones de cada plataforma.

## Input / Output

**Input:**

- Ruta del sistema en `exports/{nombre}/google-antigravity/`
- Plataforma destino: `claude-code`, `chatgpt`, `claude-ai`, `dust`, `gemini`
- Nombre del sistema (extraído del path o proporcionado)

**Output:**

- Archivos generados en `exports/{nombre}/{plataforma}/`
- Resumen de entidades exportadas

---

## Procedure

### 1. Validar input

- Comprobar que existe `exports/{nombre}/google-antigravity/.agents/`
- Verificar que la plataforma destino es soportada
- Si la plataforma ya existe en `exports/{nombre}/{plataforma}/`, preguntar si sobrescribir

---

### 2. Leer estructura de Antigravity

Escanear `.agents/` y registrar todas las entidades encontradas:

```
.agents/
├── workflows/      → listar todos los .md
├── agents/         → listar todos los .md
├── skills/         → listar todos los subdirectorios (ski-nombre/)
├── rules/          → listar todos los .md
├── knowledge-base/ → listar todos los .md
├── commands/       → listar todos los .md
└── process-overview.md
```

---

### 3. Aplicar mapeo según plataforma destino

Consultar `kno-system-architecture` Sección 3 para el mapeo correcto.

#### Para Claude Code

**Estructura de destino:**

```
exports/{nombre}/claude-code/
├── .claude/
│   ├── knowledge-base/
│   ├── rules/
│   ├── resources/
│   ├── skills/
│   ├── agents/
│   ├── commands/
│   └── settings.json
├── CLAUDE.md
└── process-overview.md
```

**Mapeo:**

- Workflows → `.claude/commands/` (copiar contenido)
- Agents → `.claude/agents/` (copiar directamente)
- Skills → `.claude/skills/` (copiar directorios completos)
- Rules → `.claude/rules/` (copiar) + referenciar en `CLAUDE.md`
- Knowledge-base → `.claude/knowledge-base/` (copiar) + referenciar en `CLAUDE.md`
- Resources → `.claude/resources/` (copiar)
- Commands → `.claude/commands/` (copiar directamente)
- process-overview.md → raíz

**Generar `settings.json`:**

```json
{
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

**Generar `CLAUDE.md`:**

```markdown
# {Nombre del Sistema}

[Descripción extraída del process-overview.md]

## Estructura

- `.claude/skills/` — capacidades reutilizables
- `.claude/agents/` — agentes especializados
- `.claude/commands/` — comandos directos
- `knowledge-base/` — información de referencia
- `process-overview.md` — documentación completa

## Rules activas

[Listar las rules encontradas con breve descripción de cada una]

## Cómo usarlo

[Instrucciones básicas extraídas del process-overview]
```

---

#### Para Aplicaciones (ChatGPT, Claude.ai, Dust, Gemini)

**Estructura de destino:**

```
exports/{nombre}/{plataforma}/
├── knowledge-base/
├── rules/
├── skills/
├── workflows/
├── resources/
└── process-overview.md
```

**Mapeo:**

- Workflows, Agents, Commands → `workflows/` (copiar `.md` directamente)
- Skills → `skills/` (copiar `ski-nombre/` con todo su contenido intacto)
- Rules → `rules/` (copiar `.md` directamente)
- Knowledge-base → `knowledge-base/` (copiar `.md` directamente)
- Resources → `resources/` (copiar `.md` directamente)
- process-overview.md → raíz

---

### 4. Ejecutar la conversión

Para cada entidad en la lista:

1. Leer el archivo fuente desde `.agents/{tipo}/{nombre}`
2. Aplicar transformaciones si aplica (ninguna necesaria para la mayoría)
3. Escribir en la ruta destino según el mapeo

Mantener la estructura de subdirectorios (ej: skills mantienen su carpeta interna).

---

### 5. Presentar resumen

```
✅ Export a {plataforma} completado.
Ubicación: exports/{nombre}/{plataforma}/

Entidades exportadas:
- {N} workflows
- {N} agents
- {N} skills
- {N} rules
- {N} knowledge-bases
- {N} commands

[Instrucciones específicas según plataforma]
```

**Instrucciones por plataforma:**

- **Claude Code**: "Abre este directorio en Claude Code para usar el sistema completo."
- **ChatGPT**: "Sube los archivos .md a tu proyecto en ChatGPT."
- **Claude.ai**: "Crea un nuevo proyecto y adjunta los archivos .md."
- **Dust / Gemini**: "Sube los archivos según las convenciones de la plataforma."

---

## Examples

**Ejemplo 1 — Export a Claude Code**

Input:

```json
{
  "sistema": "exports/customer-onboarding/google-antigravity/",
  "plataforma": "claude-code"
}
```

Output esperado:

- Directorio `exports/customer-onboarding/claude-code/` con estructura `.claude/`
- `CLAUDE.md` generado con contexto del sistema
- `settings.json` creado
- 2 workflows convertidos a commands en `.claude/commands/`
- 3 agents copiados a `.claude/agents/`
- 1 skill copiada a `.claude/skills/`
- 2 rules copiadas en `.claude/rules/` y referenciadas en `CLAUDE.md`

**Ejemplo 2 — Export a ChatGPT**

Input:

```json
{
  "sistema": "exports/email-classifier/google-antigravity/",
  "plataforma": "chatgpt"
}
```

Output esperado:

- Directorio `exports/email-classifier/chatgpt/` con carpetas alineadas a la arquitectura
- 1 agent en `workflows/age-spe-email-classifier.md`
- 2 skills en `skills/ski-xxx/SKILL.md`
- 1 rule en `rules/rul-xxx.md`
- process-overview.md en raíz

---

## Error Handling

- **Sistema no encontrado**: Verificar que existe `exports/{nombre}/google-antigravity/`. Si no, listar los sistemas disponibles en `exports/` y pedir al usuario que especifique correctamente.

- **Plataforma no soportada**: Mostrar lista de plataformas soportadas: `claude-code`, `chatgpt`, `claude-ai`, `dust`, `gemini`.

- **Export destino ya existe**: Preguntar:

  ```
  El export a {plataforma} ya existe en exports/{nombre}/{plataforma}/.

  ¿Quieres sobrescribirlo?
  A) Sí, sobrescribir
  B) No, cancelar
  C) Generar en un directorio diferente ({plataforma}-v2)
  ```

- **Archivo corrupto o ilegible**: Notificar y omitir ese archivo. Continuar con el resto. Listar archivos omitidos en el resumen.
