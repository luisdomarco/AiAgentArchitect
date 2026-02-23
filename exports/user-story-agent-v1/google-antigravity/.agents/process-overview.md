# User Story Agent v1 - Process Overview

## Descripción General

Este proceso transforma una idea o plantilla parcial en una historia de usuario completa y estructurada, siguiendo estrictamente el estándar de la organización, los principios de Behavior-Driven Development (BDD) y el modelo 3C de Scrum.

## Fases y Entidades

1. **Step 1: Story Definition**
   - **Agente:** `age-spe-story-definer`
   - **Objetivo:** Recibir el input original y asegurar que la `Definition` (Brand, Jobs, Modules) esté completa. Traduce descripciones técnicas excesivas a un `Problem / Need` centrado en el valor de negocio.
   - **Punto de control:** Checkpoint S1.

2. **Step 2: Scope Definition**
   - **Agente:** `age-spe-scope-definer`
   - **Objetivo:** Extraer el `Scope` explícito y los límites funcionales (`Out of Scope`). Redacta el Título y la motivación de la historia bajo el marco "As / I want / So that".
   - **Reglas:** `rul-story-formatting-standards` (uso de listas y marcas de hipótesis).
   - **Punto de control:** Checkpoint S2.

3. **Step 3: Acceptance Criteria Generation**
   - **Agente:** `age-spe-criteria-generator`
   - **Objetivo:** Convertir el Scope en escenarios testeables y exhaustivos libres de backend-logic, asegurando Happy Path, Unhappy Path y Error Path.
   - **Conocimiento:** `kno-acceptance-criteria-fundamentals` y `kno-gherkin-syntax-reference`.
   - **Reglas:** `rul-acceptance-criteria-generation` (salida en formato de listas de Markdown).
   - **Punto de control:** Checkpoint S3.

4. **Step 4: Compilación Final (Assembly)**
   - **Workflow:** `wor-user-story-generator`
   - **Objetivo:** Estructurar de manera definitiva la User Story en un solo bloque de Markdown y preservando las secciones técnicas no abordadas (Design notes, Test plans).

5. **Capa Transversal: Quality Assurance (QA Layer)**
   - **Agentes:** `age-spe-auditor`, `age-spe-evaluator`, `age-spe-optimizer`
   - **Objetivo:** Auditar el cumplimiento de reglas, calificar el trabajo mediante rúbricas y proponer optimizaciones basadas en patrones. Todo esto se ejecuta automáticamente tras los checkpoints convalidados por el usuario, sin modificar archivos originarios y emitiendo un reporte acumulativo en `qa-report.md`.

## Estructura de Salida (Output)

El sistema devuelve la historia de usuario estructurada en formato Markdown final, listo para integrarse a un sistema de tickets como Jira o ADO.
