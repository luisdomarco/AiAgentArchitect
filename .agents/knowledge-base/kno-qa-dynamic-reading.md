---
description: Protocolo de lectura dinámica para el QA Layer. Define cómo resolver rutas, leer el contenido actual de entidades desde disco, e inicializar el qa-report.md. Garantiza que el Auditor trabaja siempre con la versión más reciente de cada archivo, sin cachés.
tags: [qa, audit, dynamic-reading, file-paths]
---

## Table of Contents

1. Principio de lectura dinámica
2. Resolución de rutas
3. Lectura por tipo de entidad
4. Inicialización y mantenimiento del qa-report.md
5. Manejo de archivos no encontrados

---

## Documentation

### 1. Principio de lectura dinámica

El Auditor **nunca usa el contenido de instrucciones desde su contexto de sesión**. Antes de cada auditoría, lee el archivo correspondiente desde su ruta en disco. Esto garantiza que:

- Si el usuario modifica una Rule entre dos checkpoints, la siguiente auditoría usa la versión actualizada.
- Si el usuario modifica un agente después de que fue generado, un `/re-audit` lo audita con la versión actual.
- No hay divergencia entre lo que el sistema tiene en disco y lo que el Auditor verifica.

Este principio aplica tanto en AiAgentArchitect como en cualquier sistema al que se embeba el QA Layer.

---

### 2. Resolución de rutas

#### 2.1 Rutas base

El orquestador provee al Auditor:

- `sistema_path`: ruta absoluta o relativa a la raíz del sistema (carpeta `.agents/`)
- `rules_activas`: lista de rutas relativas desde `sistema_path`, p.ej. `["./rules/rul-naming-conventions.md"]`

El Auditor resuelve las rutas absolutas:

```
ruta_absoluta = sistema_path + ruta_relativa
```

Ejemplo:

```
sistema_path = "exports/mi-sistema/google-antigravity/.agents/"
ruta_relativa = "./rules/rul-naming-conventions.md"
ruta_absoluta = "exports/mi-sistema/google-antigravity/.agents/rules/rul-naming-conventions.md"
```

#### 2.2 Prioridad de lectura

Si una entidad tiene múltiples versiones (p.ej. fue regenerada), el Auditor lee **el archivo en disco** en ese momento, que es la versión aprobada más reciente.

#### 2.3 Rutas estándar por tipo de entidad

| Tipo             | Ruta relativa desde sistema_path                  |
| ---------------- | ------------------------------------------------- |
| Rule             | `./rules/{rul-nombre}.md`                         |
| Agent            | `./workflows/{age-nombre}.md`                     |
| Skill            | `./skills/{ski-nombre}/SKILL.md`                  |
| Workflow         | `./workflows/{wor-nombre}.md`                     |
| Knowledge-base   | `./knowledge-base/{kno-nombre}.md`                |
| process-overview | `./process-overview.md`                           |
| qa-report        | `../qa-report.md` (un nivel arriba de `.agents/`) |

---

### 3. Lectura por tipo de entidad

#### En S1 (Process Discovery)

Leer:

- Todas las Rules en `./rules/` del sistema activo
- `kno-fundamentals-entities` → para verificar señales de escalado de modo

#### En S2 (Architecture Design)

Leer:

- Todas las Rules en `./rules/`
- `kno-entity-selection` → para verificar que las entidades seleccionadas son del tipo correcto
- JSON de handoff S1 → como referencia de lo que se prometió en Discovery

#### En S3 (Entity Implementation)

Por cada entidad generada, leer el archivo recién creado en disco + las Rules activas.

#### En re-audit

```
/re-audit rul-naming-conventions
→ Leer: exports/{nombre}/.agents/rules/rul-naming-conventions.md (versión actual)
→ Verificar contra: todos los archivos de entidades generadas en S3

/re-audit S2
→ Leer: todas las Rules activas (versión actual) + el JSON de handoff S2
→ Auditar: el Blueprint completo contra las Rules actuales

/re-audit sistema
→ Leer: todas las entidades en todas las carpetas del sistema (dentro de .agents/ y, en el caso del sistema nativo Architect, también la carpeta repository/ en la raíz)
→ Verificar contra: todas las Rules activas
→ Genera un audit report completo del estado actual del sistema
```

---

### 4. Inicialización y mantenimiento del qa-report.md

#### Inicialización (al primer Audit del proceso)

Si `qa-report.md` no existe al ejecutar el primer Audit:

```markdown
---
sistema: { nombre-sistema }
fecha-inicio: { timestamp }
fecha-cierre: null
score-global: pending
---

# QA Report — {nombre-sistema}

_Iniciado automáticamente al aprobar el primer checkpoint._
```

Ubicación: Un nivel arriba de `.agents/`, en la raíz del directorio del sistema.

#### Ejemplo de estructura de carpetas:

```
exports/mi-sistema/google-antigravity/
├── .agents/
│   ├── rules/
│   ├── workflows/
│   └── ...
└── qa-report.md    ← aquí, accesible sin entrar a .agents/
```

#### Mantenimiento

- Cada nuevo bloque se añade al final del archivo con una línea de separación (`---`)
- El frontmatter solo se actualiza al cierre del proceso (`fecha-cierre` + `score-global`)
- Los bloques de re-audit siempre llevan timestamp para distinguirlos de las auditorías automáticas

---

### 5. Manejo de archivos no encontrados

Si al resolver una ruta el archivo no existe en disco:

1. No lanzar error — registrar como criterio de auditoría:

```markdown
| Archivo no encontrado | {ruta-relativa} | ❌ | El archivo no existe en la ruta esperada |
```

2. Continuar la auditoría con los demás archivos disponibles.
3. En el resumen, incluir: `⚠️ {N} archivo(s) referenciado(s) no encontrado(s)`

Causas comunes y sugerencias de diagnóstico:

- Ruta relativa incorrecta → verificar la arquitectura root folder con `kno-system-architecture`
- Archivo borrado manualmente → el Optimizador puede proponer recrearlo
- Nombre con typo → buscar archivos similares en la misma carpeta
