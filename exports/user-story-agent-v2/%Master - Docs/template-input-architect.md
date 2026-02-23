# Agentic Architect — Template Architect

Rellena este template antes de iniciar la sesión. Cuanto más completo llegues, menos preguntas necesitará el sistema en el Step 1 y más rápido llegarás al diseño arquitectónico.

No te preocupes si no tienes todas las respuestas. Deja en blanco lo que no sepas — el sistema lo trabajará contigo durante la entrevista.

---

## 1. Qué quieres agentizar

**Nombre o título del proceso:** `user story agent v1`

**Describe el proceso en 2-4 frases:** Sistema que asiste en la creación y refinamiento de historias de usuario. A partir de una plantilla parcial o totalmente cubierta, guía al usuario paso a paso para asegurar que cada sección queda bien definida, clara y orientada al negocio, produciendo como resultado un documento estructurado listo para usar.

**¿Cuál es el tipo de proceso?** `creación / refinamiento`

**¿Cómo se hace hoy sin el sistema?** Proceso completamente manual. El usuario redacta y refina cada sección de la historia de usuario por su cuenta, sin asistencia ni validación estructurada.

**¿Qué pasa si el sistema no existe o falla?** El usuario continúa haciéndolo manualmente, con el coste de tiempo y la falta de consistencia que eso implica.

---

## 2. Input del proceso

**¿Cómo se inicia el proceso?** El usuario lo lanza manualmente con una solicitud, aportando una o varias historias de usuario en formato `.md`, total o parcialmente cubiertas.

**Estructura del input:**

- El input puede ser **una o varias historias de usuario** dentro de una misma carpeta
- La carpeta padre tiene el **ID de la épica**
- Cada archivo `.md` dentro tiene el **ID de la historia de usuario** como nombre
- Cada historia se trata de forma **individual e independiente**

**Ejemplo de estructura:**

```
EPIC-123/
  US-001.md
  US-002.md
  US-003.md
```

**Plantilla de historia de usuario:**

```markdown
## User Story

**As**
**I want**
**So that**

## Definition

**Brand:** 
**Jobs:** 
**Modules:** 

**Related:** 

**Problem / Need**

**Scope**

**Out of scope**

**Proposal**

### Design notes

## Acceptance Criteria

## Technical notes

## MRs sprint

## Test plan DEV

## Test plan QA

## Improvement proposal QA

## Post-deployment actions
```

Sobre estas secciones nunca actuarás, déjalas vacías:**

```markdown
### Design notes

## Technical notes

## MRs sprint

## Test plan DEV

## Test plan QA

## Improvement proposal QA

## Post-deployment actions
```

---

## 3. Flujo del proceso

**Pasos principales:**

```
1. Recepción del input
   - El usuario aporta la historia de usuario (parcial o completa) en formato .md
   - Si hay varias historias, se procesan de forma individual

2. Asegurar la Definición
   - Brand, Jobs y Modules deben estar cubiertos
   - Si faltan, el agente los solicita al usuario
   - Related es opcional

3. Problem / Need
   - El problema o necesidad debe estar claramente definido
   - Si el usuario aporta contenido, el agente valida el entendimiento y lo refina
   - Debe estar orientado al impacto en negocio / usuario

4. Scope
   - Definición general de qué se abordará para dar respuesta al Problem / Need
   - Especificación a nivel negocio / usuario, NO técnica
   - Formato: bullet list

5. Out of scope
   - Qué queda fuera del alcance de esta historia
   - Formato: bullet list

6. Motivation (User Story)
   - El agente genera: As / I want / So that
   - Se basa en el Problem / Need y el Scope definidos

7. Title
   - El agente genera el título de la historia de usuario
   - Debe ser claro, conciso y orientado al usuario

8. Proposal (Opcional)
   - Si el usuario lo solicita o hay información suficiente, el agente genera la propuesta
   - Especificación a nivel de acciones sobre el Producto

9. Acceptance Criteria
   - El agente genera los criterios de aceptación
   - Siempre en lenguaje de negocio / usuario
   - Ejemplo correcto: "Cuando el usuario guarda el cambio, es alertado de que la acción fue completada satisfactoriamente"
   - Ejemplo incorrecto: "Cuando el proceso termine satisfactoriamente mostrar un toast con este texto"
   - Este paso se ejecuta en tres fases secuenciales, cada una con su propia validación.
     - 9.1 Features + Backgrounds
       - El agente identifica y define todos los posibles Features con su Background
       → Validación: el usuario aprueba o refina la lista antes de continuar 
     - 9.2 Scenarios por Feature
       - Para cada Feature + Background aprobado, el agente define los Scenarios posibles
       → Validación: el usuario aprueba o refina los scenarios antes de continuar
     - 9.3 Criterios de aceptación por Scenario
       - Para cada Scenario aprobado, el agente genera el criterio en formato Given / When / Then / Etc
       → Validación: el usuario aprueba o refina cada criterio antes de cerrar el paso

```

**¿Hay decisiones o bifurcaciones en el flujo?** Cada paso donde el agente actúa lleva asociada una validación humana. Si el usuario no aprueba el output, el agente repite el paso incorporando el feedback recibido.

**¿Hay pasos que se repiten?** Sí. En cada paso el usuario debe confirmar el output antes de continuar. Si no lo aprueba, el paso se repite con feedback hasta obtener su visto bueno.

---

## 4. Output del proceso

**¿Qué produce el sistema al finalizar?** Un archivo `.md` por cada historia de usuario procesada, exportado en la subcarpeta `output/` dentro de la carpeta de la épica.

**Nomenclatura del archivo:** `{id}-output.md`

**Ejemplo de estructura de output:**

```
EPIC-123/
  US-001.md
  US-002.md
  output/
    US-001-output.md
    US-002-output.md
```

---

## 5. Contexto técnico

**¿El proceso interactúa con sistemas externos?** No.

**¿Hay puntos donde un humano debe revisar o aprobar antes de continuar?** Sí, en cada paso donde el agente actúa. El usuario valida el output antes de avanzar al siguiente paso.

**¿Hay acciones irreversibles en el proceso?** No.

---

## 6. Reglas de comportamiento del agente

- Transformar el input en una especificación clara del problema orientada al impacto en negocio / usuario
- Generar preguntas de clarificación para cubrir gaps de información
- Producir el Markdown de forma consistente y sin redundancias
- Si falta información crítica, preguntar de forma directa y específica
- Si hay ambigüedad, clarificar o marcar con `[HYPOTHESIS]`
- Si hay conflictos o contradicciones, señalarlos y pedir alineación; priorizar el input más reciente validado
- No inventar datos, hechos ni referencias
- No usar meta-lenguaje sobre ser un modelo de IA
- Mantener el lenguaje simple y sin ambigüedades
- En **Scope** y **Out of scope**, usar bullet list como formato principal
- Usar párrafos cortos, bullet lists, **negritas**, _cursivas_ y <u>subrayado</u> para estructurar la información de forma clara y visible

---

## 7. Skills y entidades existentes _(opcional)_

**¿Tienes Skills ya creadas que podrían reutilizarse?** No.

**¿Hay procesos similares ya agentizados como referencia?** No.

---

## 8. Restricciones conocidas _(opcional)_

**¿Hay algo que el sistema nunca deba hacer?** No.

**¿Hay restricciones legales, de negocio o técnicas relevantes?** No.

**¿Hay información de referencia que el sistema deba conocer?**

- Plantilla de historia de usuario (incluida en la Sección 2)
- Knowledge base de acceptance criteria: adjuntar `acceptance-criteria-knowledgebase`
	- este conocimiento y reglas deben prevalecer para la parte de criterios de aceptación

---

## 9. Resultado esperado _(opcional)_

**¿Cómo se ve el éxito cuando el sistema funciona correctamente?**

- Se mantiene la estructura del template original
- Se respetan los formatos y estilos definidos (bullet lists, negritas, cursivas, subrayado)
- Se siguen los pasos en el orden definido
- Los criterios de aceptación cumplen las reglas de la knowledge base
- La motivación (As / I want / So that) es coherente con el Problem / Need y el Scope aprobados
- El título refleja con precisión el valor que aporta la historia al usuario
- Los criterios de aceptación cubren todos los Scenarios aprobados en la fase 9.2, sin omisiones
- Cada criterio está escrito en lenguaje de negocio / usuario, sin referencias a implementación técnica
- El archivo de output se genera con la nomenclatura correcta `{id}-output.md` en la carpeta `output/`
- En ningún paso el agente avanza sin haber recibido la aprobación explícita del usuario

**¿Hay métricas o criterios concretos para saber que funciona bien?**
- El agente avanza al siguiente paso sin esperar validación
- El agente inventa información no aportada por el usuario y no la marca como `[HYPOTHESIS]`
- Los criterios de aceptación describen comportamiento técnico en lugar de comportamiento de usuario
- Scope o Out of scope mezclan especificación de negocio con detalles de implementación
- La motivación no es coherente con el Problem / Need definido — parece generada de forma genérica
- El título es ambiguo o demasiado técnico para que un stakeholder de negocio lo entienda
- Los Scenarios de la fase 9.2 no tienen cobertura completa en los criterios finales
- El output altera el formato del template (elimina secciones, cambia el orden, modifica la estructura)
- El archivo de output no se genera o se genera con un nombre o ruta incorrectos

---

_Pega el contenido de este template al inicio de la conversación con el Agentic Architect._