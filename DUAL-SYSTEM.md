# Sistema Dual: .agents/ y .claude/

Este proyecto mantiene dos implementaciones del mismo sistema agéntico, cada una optimizada para su plataforma de ejecución.

---

## Visión general

AiAgentArchitect genera sistemas agénticos completos. Para soportar múltiples plataformas, el propio sistema de diseño se mantiene en dos estructuras paralelas:

| Directorio | Plataforma | Propósito |
|------------|------------|-----------|
| `.agents/` | Google Antigravity | Estructura original, source of truth para convenciones |
| `.claude/` | Claude Code | Estructura adaptada a las convenciones de Claude Code |

Ambas contienen las **mismas entidades** con el **mismo contenido funcional**. Las diferencias son exclusivamente estructurales (organización de directorios) y de enrutamiento (rutas relativas entre archivos).

---

## Estructura comparativa

```
.agents/ (Google Antigravity)          .claude/ (Claude Code)
├── workflows/                         ├── commands/
│   ├── wor-*.md ─────────────────────→│   ├── wor-*.md
│   ├── age-spe-*.md ─────────────────→│   └── test.md
│   ├── age-sup-*.md                   ├── agents/
│   ├── com-*.md                      →│   ├── age-spe-*.md
│   └── test.md                        │   └── age-sup-*.md
├── skills/                            ├── skills/
│   └── ski-*/                         │   └── ski-*.md (aplanado)
│       └── SKILL.md ─────────────────→│
├── rules/                             ├── rules/
│   └── rul-*.md ─────────────────────→│   └── rul-*.md (idéntico)
├── knowledge-base/                    ├── knowledge-base/
│   └── kno-*.md ─────────────────────→│   └── kno-*.md (idéntico)
├── resources/                         ├── resources/
│   └── res-*.md ─────────────────────→│   └── res-*.md (idéntico)
                                       ├── settings.local.json (solo Claude)
                                       └── plans/ (solo Claude)
```

---

## Mapeo de entidades

| Tipo | .agents/ | .claude/ | Transformación |
|------|----------|----------|----------------|
| Workflow | `workflows/wor-*.md` | `commands/wor-*.md` | Cambio de directorio + rutas |
| Agent Specialist | `workflows/age-spe-*.md` | `agents/age-spe-*.md` | Cambio de directorio + rutas |
| Agent Supervisor | `workflows/age-sup-*.md` | `agents/age-sup-*.md` | Cambio de directorio + rutas |
| Command | `workflows/com-*.md` | `commands/com-*.md` | Cambio de directorio + rutas |
| Skill | `skills/ski-*/SKILL.md` | `skills/ski-*.md` | Aplanado de estructura |
| Rule | `rules/rul-*.md` | `rules/rul-*.md` | Copia directa |
| Knowledge-base | `knowledge-base/kno-*.md` | `knowledge-base/kno-*.md` | Copia directa |
| Resource | `resources/res-*.md` | `resources/res-*.md` | Copia directa |

---

## Transformaciones de rutas

Las entidades referencian otras entidades con rutas relativas. Cuando la estructura de directorios cambia, las rutas se transforman automáticamente.

### Rutas que cambian

| Referencia | En .agents/ | En .claude/ |
|------------|-------------|-------------|
| Agent desde workflow | `./age-spe-*.md` | `../agents/age-spe-*.md` |
| Supervisor desde workflow | `./age-sup-*.md` | `../agents/age-sup-*.md` |
| Skill desde agent/workflow | `../skills/ski-*/SKILL.md` | `../skills/ski-*.md` |

### Rutas que NO cambian

| Referencia | Ruta (igual en ambos) |
|------------|----------------------|
| Rule | `../rules/rul-*.md` |
| Knowledge-base | `../knowledge-base/kno-*.md` |
| Resource | `../resources/res-*.md` |

### Protecciones

Las transformaciones de rutas **no afectan** a:
- Templates/plantillas genéricas (ej: `../skills/[nombre-skill]/SKILL.md` en documentación de cómo generar sistemas)
- Rutas con patrones genéricos entre corchetes `[nombre]`
- Contenido dentro de bloques de código que documentan la arquitectura de sistemas generados

---

## Archivos específicos por plataforma

Estos archivos **no se sincronizan** porque son exclusivos de su plataforma:

| Archivo | Plataforma | Propósito |
|---------|------------|-----------|
| `.claude/settings.local.json` | Claude Code | Permisos de ejecución |
| `.claude/plans/` | Claude Code | Planes de implementación |

---

## Sincronización automática

### Mecanismo: Git Pre-commit Hook

Cada vez que haces `git commit`, un hook automático:

1. Detecta si hay archivos `.md` modificados en `.agents/` o `.claude/`
2. Sincroniza hacia el lado contrario aplicando las transformaciones
3. Añade los archivos sincronizados al commit

```
  Editas .agents/workflows/age-spe-auditor.md
       ↓
  git add .agents/workflows/age-spe-auditor.md
       ↓
  git commit -m "update auditor"
       ↓
  [pre-commit hook] Detecta cambio en .agents/
       ↓
  [sync-dual.sh] Copia → .claude/agents/age-spe-auditor.md
                  Transforma rutas de skills
       ↓
  [pre-commit hook] git add .claude/agents/age-spe-auditor.md
       ↓
  Commit incluye ambos archivos automáticamente
```

### Protección contra conflictos

Si se detectan cambios en **ambos lados** simultáneamente, el hook **bloquea el commit** y pide resolución manual:

```
[pre-commit] Cambios detectados en ambos lados simultáneamente.
[pre-commit] Por favor, sincroniza manualmente primero:
  ./scripts/sync-dual.sh --agents-to-claude  (si .agents/ es el source)
  ./scripts/sync-dual.sh --claude-to-agents  (si .claude/ es el source)
```

---

## Uso manual del script

### Comandos disponibles

```bash
# Detectar automáticamente qué lado cambió y sincronizar
./scripts/sync-dual.sh --auto

# Forzar sincronización en una dirección
./scripts/sync-dual.sh --agents-to-claude
./scripts/sync-dual.sh --claude-to-agents

# Sincronizar un archivo específico
./scripts/sync-dual.sh --file .agents/rules/rul-audit-behavior.md

# Solo validar que ambas estructuras están sincronizadas
./scripts/sync-dual.sh --validate
```

### Watch en tiempo real (opcional)

Para sincronización en tiempo real mientras editas (requiere `fswatch`):

```bash
# Instalar fswatch si no está disponible
brew install fswatch

# Iniciar el watcher
./scripts/watch-sync.sh
```

El watcher detecta cambios en el filesystem y sincroniza automáticamente sin necesidad de commit.

---

## Flujo de trabajo diario

### Opción A: Trabajar con git hook (recomendado)

1. Edita archivos en `.agents/` o `.claude/` (el que prefieras)
2. Haz `git add` de tus cambios
3. Haz `git commit` — el hook sincroniza automáticamente
4. Ambos lados quedan actualizados en el mismo commit

### Opción B: Trabajar con watch en tiempo real

1. Ejecuta `./scripts/watch-sync.sh` en una terminal
2. Edita archivos en cualquier lado
3. Los cambios se replican al instante
4. Cuando termines, haz commit normal

### Opción C: Sincronización manual bajo demanda

1. Edita archivos en un lado
2. Ejecuta `./scripts/sync-dual.sh --auto`
3. Verifica con `./scripts/sync-dual.sh --validate`
4. Haz commit

---

## Resolución de problemas

### El hook bloqueó mi commit

**Causa:** Hay cambios staged en `.agents/` Y `.claude/` simultáneamente.

**Solución:** Decide cuál es el source y sincroniza manualmente:
```bash
./scripts/sync-dual.sh --agents-to-claude   # si editaste .agents/
./scripts/sync-dual.sh --claude-to-agents   # si editaste .claude/
git add .agents/ .claude/
git commit -m "tu mensaje"
```

### Los archivos están desincronizados

**Verificar:**
```bash
./scripts/sync-dual.sh --validate
```

**Forzar resincronización completa:**
```bash
./scripts/sync-dual.sh --agents-to-claude   # .agents/ como source of truth
```

### Añadí una nueva entidad y no se sincroniza

Verifica que el nombre del archivo sigue las convenciones de nomenclatura (`wor-*`, `age-spe-*`, `ski-*`, `rul-*`, `kno-*`, `res-*`). El script solo sincroniza archivos que matchean estos patrones.

### El watch no detecta cambios

Verifica que `fswatch` está instalado:
```bash
brew install fswatch
```

---

## Inventario actual

### Entidades compartidas (34 archivos)

**Commands/Workflows (2):**
- `wor-agentic-architect.md`
- `test.md`

**Agents (6):**
- `age-spe-process-discovery.md`
- `age-spe-architecture-designer.md`
- `age-spe-entity-builder.md`
- `age-spe-auditor.md`
- `age-spe-evaluator.md`
- `age-spe-optimizer.md`

**Skills (9):**
- `ski-compliance-checker`
- `ski-diagram-generator`
- `ski-entity-file-builder`
- `ski-entity-selector`
- `ski-pattern-analyzer`
- `ski-platform-exporter`
- `ski-process-interviewer`
- `ski-qa-embed`
- `ski-rubric-scorer`

**Rules (4):**
- `rul-audit-behavior.md`
- `rul-checkpoint-behavior.md`
- `rul-interview-standards.md`
- `rul-naming-conventions.md`

**Knowledge-base (7):**
- `kno-entity-selection.md`
- `kno-evaluation-criteria.md`
- `kno-fundamentals-entities.md`
- `kno-handoff-schemas.md`
- `kno-qa-dynamic-reading.md`
- `kno-qa-layer-template.md`
- `kno-system-architecture.md`

**Resources (6):**
- `res-architect-execution-phases.md`
- `res-architecture-component-metrics.md`
- `res-entity-formatting-templates.md`
- `res-interview-question-trees.md`
- `res-qa-layer-raw-templates.md`
- `res-system-packaging-logic.md`
