---
name: kno-qa-governance-layer
description: Documentación técnica exhaustiva del Framework de Gobernanza, Control de Calidad (QA), y Trazabilidad Cognitiva implementado en AiAgentArchitect. Diseñado para consumo por IAs en la instanciación de nuevos sistemas.
---

# Framework de Gobernanza y QA en Sistemas Agénticos

Este documento describe **cómo implementar técnicamente** los mecanismos arquitectónicos de Gobernanza, Control de Calidad (QA), trazabilidad del contexto y persistencia de datos en redes multi-agente complejas.

Cualquier Inteligencia Artificial encargada de instanciar, replicar o escalar nuevos sistemas agénticos **debe integrar el siguiente plano de ejecución arquitectónica de forma obligatoria**.

---

## 1. Trazabilidad Cognitiva: El bloque `<sys-eval>`

Para evitar la pereza inherente de los modelos fundacionales, el desvío de atención y las asunciones rápidas, el sistema implementa un mecanismo de **Cadena de Pensamiento (Chain of Thought - CoT) Condicional**.

### ¿Cómo implementarlo?

1. **En las Reglas Base:** El nuevo sistema debe poseer una regla tipo `rul-strict-compliance.md` que obligue al LLM a abrir un tag XML `<sys-eval>` antes de emitir cualquier output final. Dentro de él, el LLM debe hacer dos checks verbalizados:
   - _Listando mis Hard Constraints:_ Verifica que no rompe lo prohibido por las reglas activas.
   - _Listando mis Tasks:_ Verifica que ha ejecutado todo lo que se le ordenó en su prompt o rol.
2. **En el Orquestador:** El flujo de código del Orquestador (el agente maestro de la sesión) debe interceptar la respuesta pura del agente especialista, extraer mediante regex o partición el string que se encuentra dentro de `<sys-eval>...</sys-eval>`, y almacenarlo transitoriamente en una variable llamada `reasoning_trace`.

---

## 2. Definición del Scope y Storage: `target_dir`

Para evitar que los sistemas agénticos polucionen la raíz de los repositorios con logs masivos, la persistencia se aísla de forma quirúrgica en el primer paso del proceso estableciendo un **área de trabajo aislada (sandbox)**.

### ¿Cómo implementarlo?

1. **Cálculo de Ruta:** El Workflow orquestador es el responsable de computar y crear una variable `target_dir` nada más iniciarse (Step 0 o Step 1).
   - _Dominio General:_ Por defecto el `target_dir` suele ser la ruta de exportación del proceso, ej. `exports/[nombre]/google-antigravity/` en el framework maestro.
   - _Dominio V1 (User Story Agent):_ En sistemas de negocio, la ruta debe reflejar estrictamente la jerarquía del output. En V1, el workflow orquestador detecta y rutea por sí mismo el `target_dir` a:
     - `output/[EPIC-ID]/[US-ID]/` -> Si la historia de usuario pertenece a una épica padre.
     - `output/[US-ID]/` -> Si la historia de usuario es independiente.
2. **Distribución del Scope:** Todos los agentes subsecuentes, especialmente el que maneja la persistencia temporal (el Context Ledger) y el que maneja el Quality Assurance (Auditor QA), **deben recibir esta variable `target_dir` como un argumento inamovible** en cada invocación para saber dónde grabar sus acciones.

---

## 3. Memoria Temporal y Archiver (Context Ledger)

Los sistemas multi-agente pierden contexto si dependen exclusivamente de la ventana de contexto bruta del chat. Se utiliza la figura del **Context Ledger** (`ski-context-ledger`) para crear y leer un estado de persistencia efímero llamado `context-ledger.md` dentro de nuestro `target_dir`.

### ¿Cómo implementarlo?

1. **Directorio Objetivo:** El archivo de estado debe crearse obligatoriamente en `{target_dir}/context-ledger.md`.
2. **Estrategia Archiver en el Orquestador:** `ski-context-ledger` no debe borrar ni sobrescribir ejecuciones antiguas si el proceso colapsa y el usuario tiene que reiniciar la app. Al hacer el `init`, si localiza un `context-ledger.md` previo en esa ruta, debe renombrarlo insertando un timestamp (ej. `archive-context-ledger-2026-02-24-10-30-00.md`) y empezar uno virtualmente en blanco.
3. **Flujo de Escritura Inquebrantable:** Cada vez que el Orquestador recibe el OK de que un Agente Especialista ha terminado, tiene prohibido avanzar sin antes invocar a la operación `write` del Ledger. Debe grabar allí simultáneamente:
   - El _Output limpio_ del agente.
   - La variable _`reasoning_trace`_ pura, bajo una sección estandarizada (ej. `### Reasoning Trace`).

---

## 4. Orquestación de Checkpoints y QA (El "No-Salto")

El avance iterativo en un sistema agéntico debe estar rígidamente condicionado por la validación del usuario. Esta es la barrera arquitectónica para que **nadie se salte la revisión de calidad**.

### ¿Cómo implementarlo y cuándo interviene el QA?

Al finalizar la labor de cada agente especialista (Step), el Orquestador debe pausar incondicionalmente y forzar el siguiente menú al usuario:

- A: ✅ Aprobar y pasar al siguiente paso
- B: ✏️ Ajustar este resultado
- C: 🔄 Regenerar
- D: ↩️ Retroceder

**La obligación de la Opción A:**
Solo y exclusivamente cuando el usuario teclea/selecciona la Opción `A`, el Orquestador activa el "Ciclo QA".

- Si elige B, C o D: Se interrumpe la lógica, se vuelve invocar al especialista para corregir y se vuelve otra vez al Checkpoint.
- Si elige A: Se asume que el output local humano es aceptable. E INMEDIATAMENTE ANTES de saltar al _Step N+1_, se invoca a las rutinas de QA en background presentándole las evidencias de esa fase.

---

## 5. Ciclo QA y Evaluaciones Rotativas (QA-Reports)

El bloque de Quality Assurance está pensado para auditar al LLM contra sí mismo. La auditoría está prohibido que frene la ejecución a menos que encuentre un fallo destructivo; su función es dejar un rastro de cumplimiento indexable y penalizar desviaciones detectadas en background.

### ¿Cómo implementarlo paso a paso?

1. **Invocación al Agente Auditor (`age-spe-auditor`):** Tras la Opción A, el Orquestador notifica al Auditor pasándole estas coordenadas exactas:
   - Nombre de la Fase (`S1`, `S2`, etc.).
   - El _Output_ exacto que se acaba de generar.
   - El _Reasoning Trace_ sacado del Ledger.
   - El _`target_dir`_ computado inicialmente.
2. **Lectura Dinámica del Auditor:** El Auditor debe ir al disco (`/rules`) y leer el texto estricto de las reglas que debían ser obedecidas en ese step concreto. **Debe leerlas del disco** (`kno-qa-dynamic-reading`), nunca tirar de su entrenamiento internalizado.
3. **Verificación Semántica (`ski-compliance-checker`):** El Auditor cruza las leyes extraídas con el `reasoning_trace`. Debe responderse a esta interrogante del framework: _¿El agente razonó antes de actuar y contempló X restricción o fue ignorada deliberadamente?_ Se evalúan y emiten juicios visuales (✅/❌/⚠️).
4. **Almacenamiento Rotativo del Reporte:**
   - El Auditor tiene **prohibido estructuralmente hacer append** a un megalítico documento gigante de QA. Esta práctica agota la ventana de tokens.
   - El Auditor acude a la variable `target_dir` y crea programáticamente el sub-directorio de auditorías: `{target_dir}/qa-reports/`.
   - Crea un archivo de evaluación con sello horario exacto y único: `{target_dir}/qa-reports/qa-report-{yyyy-mm-dd-hh-mm-ss}.md`.
   - Vuelca allí la rúbrica de cumplimiento Markdown de ese step en particular.
