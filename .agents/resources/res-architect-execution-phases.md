---
name: res-architect-execution-phases
description: Detalle estructural de las fases de ejecución del orquestador, endpoints y flujo QA.
tags: [workflow, routing, phases, orchestration, S1, S2, S3]
---

# Architect Execution Phases

Este documento detalla la lógica operativa y los bucles de interacción que ejecuta el orquestador principal (`wor-agentic-architect`) campo a través durante el discovery, arquitectura y generación humana/QA.

## Tracking de métricas

Mantener el objeto de métricas `{ "regeneraciones", "iteraciones" }` por Step (ver `kno-handoff-schemas` §3). Incrementar en regeneraciones (opción C) o iteraciones (opción B). Pasar al Evaluador junto al contexto de cada fase.

---

## Step 1 — Process Discovery

**Activa:** `age-spe-process-discovery` con el modo y descripción inicial. El agente conduce la entrevista completa y devuelve el handoff S1→S2 (schema en `kno-handoff-schemas` §1).

**Context Ledger:** Tras obtener el JSON de handoff S1, ejecutar `ski-context-ledger` operación `write` con step=1, agent=`age-spe-process-discovery`, output=JSON S1.

**Checkpoint S1:** A) ✅ Aprobar → Step 2 · B) ✏️ Editar resumen · C) 🔄 Regenerar · D) ↩️ Volver atrás

**QA automático tras aprobación:**

1. `age-spe-auditor` — Lee Rules activas + JSON S1 desde disco → produce tabla de cumplimiento.
2. `age-spe-evaluator` — Puntúa S1. Crea el `qa-report.md` en la raíz del sistema generado (`{export-path}/qa-report.md`) con [Audit S1] + [Score S1].

- Mostrar: `🔍 QA S1 — {N} criterios | ✅ {X} / ⚠️ {Y} / ❌ {Z} — Score: {X.X}/10 ({nivel})`
- Si hay alertas: bullet con el criterio más crítico.

> `/skip-qa S1` omite el ciclo QA para esta fase.

---

## Step 2 — Architecture Design

**Context Ledger (read):** Antes de invocar al agente, ejecutar `ski-context-ledger` operación `read` con step_destino=2 y el Context Map del workflow. Esto extrae el JSON S1 completo del ledger.

**Activa:** `age-spe-architecture-designer` con el contexto filtrado por el ledger. El agente diseña el Blueprint y devuelve el handoff S2→S3 (schema en `kno-handoff-schemas` §2).

**Context Ledger (write):** Tras obtener el JSON de handoff S2, ejecutar `ski-context-ledger` operación `write` con step=2, agent=`age-spe-architecture-designer`, output=JSON S2.

**Checkpoint S2:** A) ✅ Aprobar Blueprint → Step 3 · B) ✏️ Ajustar entidad · C) 🔄 Rediseñar arquitectura · D) ↩️ Volver a S1

**QA automático tras aprobación:**

1. `age-spe-auditor` — Lee Rules activas + Blueprint desde disco → tabla de cumplimiento.
2. `age-spe-evaluator` — Puntúa S2. Añade [Audit S2] + [Score S2] al `qa-report.md`.

- Mostrar: `🔍 QA S2 — {N} criterios | ✅ {X} / ⚠️ {Y} / ❌ {Z} — Score: {X.X}/10`

> `/skip-qa S2` omite el ciclo QA para esta fase.

---

## Step 3 — Entity Implementation

**Context Ledger (read):** Antes de invocar al agente, ejecutar `ski-context-ledger` operación `read` con step_destino=3 y el Context Map del workflow. Esto extrae: JSON S2 completo + campos parciales de S1 (`proceso.nombre`, `proceso.restricciones`, `diagrama_as_is`).

**Activa:** `age-spe-entity-builder` con el contexto filtrado por el ledger. El agente genera entidades una a una.

**Context Ledger (write):** Tras la aprobación final de todas las entidades y el `process-overview.md`, ejecutar `ski-context-ledger` operación `write` con step=3, agent=`age-spe-entity-builder`, output=lista de archivos generados.

**Checkpoint por entidad:** A) ✅ Aprobar → siguiente entidad · B) ✏️ Ajustar · C) 🔄 Regenerar · D) ↩️ Volver al Blueprint

**Audit automático tras cada aprobación:**

- **Lotes normales (≤ 7 entidades):** `age-spe-auditor` sobre el archivo recién generado. Añade [Audit S3-{nombre}] al `qa-report.md`. Presenta resumen en pantalla (máx. 5 líneas).
- **Lotes grandes (> 7 entidades):** Para no interrumpir al usuario, `age-spe-auditor` actúa en **background silencioso** acumulando el [Audit] en disco sin pedir confirmación bloqueante ni emitir resumen por pantalla (a menos que haya un ❌ crítico).

Al finalizar todas las entidades, el agente genera `process-overview.md`.

**Checkpoint de cierre:** A) ✅ Aprobar → empaquetado final · B) ✏️ Ajustar process-overview · C) 🔄 Volver a S3 · D) ↩️ Volver al Blueprint

**QA global tras aprobación:**

1. `age-spe-evaluator` — Score S3: promedio de audits individuales. Métricas = suma acumulada de S3.
2. `age-spe-evaluator` — Score global ponderado (S1×25% + S2×35% + S3×40%). Añade [Evaluación Global] al `qa-report.md` y entrada al `qa-meta-report.md`.
3. `age-spe-optimizer` — Lee `qa-report.md` desde disco. Usa `ski-pattern-analyzer`. Añade [Optimization Proposals] al `qa-report.md`.

- Mostrar: `📊 Score: {X.X}/10 — {nivel} | S1:{X.X} S2:{X.X} S3:{X.X} | 🔧 {N} propuestas (ver qa-report.md)`
