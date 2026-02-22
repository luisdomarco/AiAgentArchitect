---
name: ski-entity-file-builder
description: Generates complete and correctly formatted instruction files for each entity type (Workflow, Agent, Skill, Command, Rule, Knowledge-base) according to the assigned intricacy level. Use it in Step 3 to materialize each entity from the architectural blueprint.
---

# Entity File Builder Skill

Genera el contenido completo de archivos de instrucciones para cada tipo de entidad, adaptando la profundidad al nivel de intricacy asignado y respetando todas las convenciones de formato.

## Input / Output

**Input:**

- Tipo de entidad: `workflow | agent-specialist | agent-supervisor | skill | command | rule | knowledge-base`
- Nivel de intricacy: `simple | medium | complex`
- Datos de la entidad del JSON de handoff (nombre, descripción, función, input, output, relaciones)
- Lista de entidades ya creadas en la sesión (para referencias cruzadas correctas)

**Output:**

- Archivo `.md` completo con frontmatter YAML y body Markdown, listo para descargar

---

## Procedure

### 1. Pre-generación: verificaciones obligatorias

Antes de escribir el archivo, verifica:

- El nombre sigue la convención kebab-case con el prefijo correcto para su tipo.
- La descripción del frontmatter no supera 250 caracteres.
- Las rutas de referencia cruzada usan el formato relativo correcto.
- El nivel de intricacy determina la densidad del contenido (ver sección 4).
- El tamaño y densidad esperados: si el contenido proyectado se aproxima o excede el límite de caracteres recomendado para el tipo de entidad (<6000 Workflow/KB, <3000 Agent/Rule, <1500 Skill/Command), prepárate para particionarlo creando documentos en el directorio `/resources` y referenciarlos.

---

### 2. Convenciones de nomenclatura por tipo

| Tipo             | Prefijo    | Ejemplo                       |
| ---------------- | ---------- | ----------------------------- |
| Workflow         | `wor-`     | `wor-customer-onboarding.md`  |
| Agent Specialist | `age-spe-` | `age-spe-email-classifier.md` |
| Agent Supervisor | `age-sup-` | `age-sup-output-validator.md` |
| Skill            | `ski-`     | `ski-format-output/SKILL.md`  |
| Command          | `com-`     | `com-quick-translate.md`      |
| Rule             | `rul-`     | `rul-output-standards.md`     |
| Knowledge-base   | `kno-`     | `kno-brand-guidelines.md`     |
| Resources        | `res-`     | `res-security-policies.md`    |

---

### 3. Plantillas por tipo de entidad

Las estructuras base, frontmatters (YAML) e introducciones descriptivas para cada tipo de entidad están externalizadas para optimizar la carga cognitiva.

> **Debes inspeccionar y copiar directamente el Baseline Format leyendo el archivo auxiliar:**
> `../../resources/res-entity-formatting-templates.md`

Extrae de allí la estructura solicitada según el `Tipo de entidad` del Input, y procede a llenarla dinámicamente según la Intricacy correspondiente.

---

### 4. Niveles de intricacy

#### `simple`

- Goals: 2-3 objetivos concisos.
- Tasks: 3-5 bullets sin descripción extensa.
- Execution Protocol / Workflow Sequence: flujo lineal, sin subsecciones.
- Rules específicas: 3-5 reglas directas.
- Skills: sin tabla si no tiene ninguna.
- Sin ejemplos extendidos.

#### `medium`

- Goals: 3-5 objetivos con resultado esperado explícito.
- Tasks: 5-8 bullets con descripción breve de cada una.
- Execution Protocol / Workflow Sequence: pasos numerados, manejo de casos alternativos.
- Rules específicas: 5-8 reglas con contexto.
- Skills: tabla completa con columna "When use it" descriptiva.
- Ejemplos en Skills cuando clarifiquen el uso.

#### `complex`

- Goals: 4-6 objetivos detallados con métrica de éxito.
- Tasks: 8+ bullets con descripción completa.
- Execution Protocol / Workflow Sequence: subsecciones por etapa, gestión de errores, loops, condiciones.
- Rules específicas: 8+ reglas con casos específicos y razonamiento.
- Skills: tabla completa + notas sobre cuándo NO usar cada una.
- Ejemplos detallados con razonamiento explícito.
- Tablas comparativas o de referencia donde aporten claridad.

---

### 5. Coherencia de referencias cruzadas

Antes de incluir cualquier referencia a otra entidad, verifica que:

- El nombre usado coincide exactamente con el nombre en el frontmatter de esa entidad.
- La ruta relativa es correcta según la arquitectura root folder:

| Tipo           | Ruta relativa desde cualquier entidad |
| -------------- | ------------------------------------- |
| Skill          | `./skills/[nombre-skill]/SKILL.md`    |
| Agent          | `./workflows/[nombre-agent].md`       |
| Workflow       | `./workflows/[nombre-workflow].md`    |
| Rule           | `./rules/[nombre-rule].md`            |
| Knowledge-base | `./knowledge-base/[nombre-kb].md`     |
| Command        | `./workflows/[nombre-command].md`     |
| Resources      | `./resources/res-[nombre-recurso].md` |

---

### 6. Estructuración y Partición de Contenido (/resources)

Si al planificar el nivel de intricacy (especialmente en `complex`) prevés que una entidad será muy extensa o superará el límite recomendado:

1. Identifica los bloques densos que puedan externalizarse (ej. prompts muy largos, tablas de categorización extensas, ejemplos de few-shot, políticas o guías de estilo detalladas).
2. Determina qué archivos de soporte crear en el directorio `./resources/` para alojar esa información en bruto.
3. En la entidad principal, haz referencia directa a los archivos de soporte estructurando la información como un sistema relacional. Ej. `Ver políticas detalladas en [Políticas de Seguridad](./resources/res-security-policies.md)`.

---

## Examples

**Ejemplo — Generación de Agent Specialist nivel simple**

Input:

```json
{
  "tipo": "agent-specialist",
  "nombre": "age-spe-email-classifier",
  "funcion": "Clasificar emails entrantes en categorías predefinidas",
  "nivel_intricacy": "simple"
}
```

Output esperado: Agent con Goals (2), Tasks (4), Execution Protocol lineal (5-6 pasos), Rules específicas (3), sin Skills ni KB si no las necesita.

---

## Error Handling

- **Nombre no sigue convención:** Corregir automáticamente y notificar al usuario.
- **Descripción supera 250 caracteres:** Resumir manteniendo el significado esencial.
- **Referencia a entidad no creada aún:** Incluir la referencia con la ruta correcta e indicar en un comentario que esa entidad se creará más adelante.
- **Inconsistencia detectada con el Blueprint:** Pausar, notificar al usuario y pedir aclaración antes de continuar.
