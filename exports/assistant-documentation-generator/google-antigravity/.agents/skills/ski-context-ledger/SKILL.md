---
name: ski-context-ledger
description: Gestiona el Context Ledger de un workflow. Operaciones init, write y read para persistir y filtrar contexto inter-agente en context-ledger.md.
type: workflow
---

## Descripción

Skill reutilizable que proporciona las operaciones necesarias para gestionar el `context-ledger.md` de un workflow. El ledger persiste el output de cada step y permite al orquestador filtrar selectivamente qué información pasa al siguiente agente.

**El workflow decide qué fluye; esta skill ejecuta la mecánica.**

## Operaciones

### `init` — Inicializar el ledger

Crea el archivo `context-ledger.md` en la ruta destino suministrada. Aplica **Estrategia Archiver**: si ya existe un archivo previo en esa ruta, lo renombra a `archive-context-ledger-{timestamp}.md` para no perder el histórico antes de instanciar el nuevo en blanco.

**Input:**

| Campo      | Descripción                                |
| ---------- | ------------------------------------------ |
| sistema    | Nombre del sistema en ejecución            |
| workflow   | Nombre del workflow que lo invoca          |
| target_dir | Ruta del directorio donde vive la US/Épica |

**Output:** Archivo `{target_dir}/context-ledger.md` creado con frontmatter:

```markdown
---
sistema: { sistema }
workflow: { workflow }
created: { ISO timestamp }
last_updated: { ISO timestamp }
---
```

**Cuándo:** Al inicio de la ejecución del workflow, antes de invocar al primer agente.

---

### `write` — Registrar output de un step

Añade un bloque al ledger con el input recibido y output producido por un agente. **Siempre en modo append**, nunca sobreescribe bloques anteriores.

**Input:**

| Campo           | Descripción                                                                                   |
| --------------- | --------------------------------------------------------------------------------------------- |
| target_dir      | Ruta del directorio donde vive el ledger                                                      |
| step            | Número del step (1, 2, 3...)                                                                  |
| agent           | Nombre del agente que ejecutó el step                                                         |
| status          | `completed` / `in_progress` / `pending`                                                       |
| input           | Resumen del input que recibió el agente                                                       |
| output          | Output producido por el agente (JSON, texto, referencia a archivo)                            |
| reasoning_trace | (Opcional) El bloque de pensamiento `<sys-eval>` generado por el agente antes de su respuesta |

**Output:** Bloque añadido al `context-ledger.md`:

```markdown
---

<!-- separator -->

## [Step {step}] — {agent} — {status}

### Input recibido

{input}

### Reasoning Trace

{reasoning*trace} *(Añadido sólo si existe en el input)\_

### Output generado

{output}

### Metadata

- Timestamp: {ISO}
- Step: {step} de {total}
```

**Cuándo:** Inmediatamente después de que un agente completa su ejecución y antes de invocar al siguiente.

---

### `read` — Leer y filtrar contexto

Lee el ledger y extrae el contexto relevante para un step destino según el **Context Map** definido en el workflow.

**Input:**

| Campo        | Descripción                                                           |
| ------------ | --------------------------------------------------------------------- |
| target_dir   | Ruta del directorio donde vive el ledger                              |
| step_destino | Número del step que va a recibir el contexto                          |
| context_map  | Array de reglas: `[{ "de_step": N, "campos": [...], "modo": "..." }]` |

**Lógica:**

1. Leer el archivo `{target_dir}/context-ledger.md`.
2. Para cada regla del `context_map`:
   - Si `modo` = `completo`: extraer todo el bloque `### Output generado` (y `### Reasoning Trace` si existe) del step referenciado.
   - Si `modo` = `parcial`: extraer solo los campos listados en `campos` del output del step referenciado.
3. Componer el contexto filtrado como un bloque unificado.

**Output:** Contexto filtrado listo para ser inyectado como input del siguiente agente.

**Cuándo:** Antes de invocar cada agente (excepto el primero, que recibe input directo).

## Notas de uso

- El workflow es responsable de definir el **Context Map** en su propia estructura. Esta skill solo lo ejecuta.
- Si el ledger no existe al intentar `write` o `read`, emitir error y notificar al workflow.
- El `context-ledger.md` se mantiene durante toda la ejecución del workflow. No se elimina al cierre — sirve como registro de trazabilidad.
- En flujos con checkpoint humano, el `write` debe ejecutarse **después** de la aprobación del checkpoint, no antes.
