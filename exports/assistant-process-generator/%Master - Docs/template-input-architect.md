# Agentic Architect — Template Architect

Rellena este template antes de iniciar la sesión. Cuanto más completo llegues, menos preguntas necesitará el sistema en el Step 1 y más rápido llegarás al diseño arquitectónico.

No te preocupes si no tienes todas las respuestas. Deja en blanco lo que no sepas — el sistema lo trabajará contigo durante la entrevista.

---

## 1. Qué quieres agentizar

**Nombre o título del proceso:**
_(puede ser informal)_

Assistant Process Definition

**Describe el proceso en 2-4 frases:**
_(qué problema resuelve, qué hace, cuál es su objetivo)_

Quiero un sistema conversacional que me ayude a definir, desglosar y especificar procesos de negocio de forma rigurosa, antes de proceder a automatizarlos o agentizarlos. El problema que resuelve es que hoy inicio la construcción de workflows y agentes sin tener el proceso suficientemente definido, lo que genera trabajo con información incompleta o errónea. El sistema debe actuar como un co-diseñador activo: escucha, cuestiona, detecta gaps, y produce como output una especificación estructurada y un diagrama del proceso.

El sistema aplicará las técnicas de análisis de procesos que estime más adecuadas según el contexto, entre ellas:

- **BPM (Business Process Management):** Disciplina holística para descubrir, modelar, analizar, medir, mejorar y optimizar procesos de negocio.
- **BPA (Business Process Automation):** Subconjunto del BPM que aplica tecnología para automatizar flujos de trabajo complejos (ej. aprobaciones, onboardings).
- **Hiperautomatización (Gartner):** Combinación de BPM, RPA, IA y ML para automatizar al máximo los procesos de una organización.

El usuario no tiene dominio profundo de estos frameworks, por lo que el sistema debe seleccionar y aplicar las técnicas más adecuadas de forma autónoma, sin requerir que el usuario las conozca o elija.

El agente debe adoptar un rol activo mediante **Ingeniería Inversa**: no solo registrar lo que el usuario dice, sino hacer preguntas para descubrir lo que el usuario no sabe que no sabe. Además, debe generar diagramas en **Mermaid** para validar el entendimiento del proceso de forma visual durante la sesión.



**¿Cómo se hace esto hoy, sin el sistema?**
_(flujo manual actual, aunque sea aproximado)_

No existe un proceso formal. Actualmente no se realiza ninguna fase de especificación de procesos antes de comenzar a construir agentes o workflows. El conocimiento sobre el proceso queda implícito en la cabeza del diseñador, sin documentación ni validación estructurada.

**¿Qué pasa si el sistema no existe o falla?**
_(impacto o coste de no tenerlo)_

Se diseñarán y construirán agentes o workflows basados en una comprensión parcial o incorrecta del proceso real. Esto genera retrabajo, decisiones de diseño incorrectas, y agentes que no cubren casos de uso relevantes o que incluyen asunciones no validadas. El coste principal es tiempo perdido en construcción que luego hay que deshacer o rehacer.

---

## 2. Flujo del proceso

**¿Cómo empieza el proceso?**
_(qué lo dispara: un usuario, un evento, un email, un cron job, un webhook...)_

El proceso se inicia manualmente por el usuario. El disparador es una descripción inicial del proceso que se quiere definir, que puede llegar con distintos niveles de detalle o estructura. Puede ir acompañada de documentación de apoyo si el usuario dispone de ella (docs, notas, diagramas previos, etc.), aunque no es obligatorio.

**Pasos principales que ya tienes identificados:**
_(no tienen que ser perfectos ni completos, escribe lo que sepas)_

```
1. INPUT — El usuario inicia la sesión
   - Proporciona una descripción inicial del proceso (libre, sin estructura obligatoria)
   - Adjunta documentación de apoyo si la tiene (opcional)
   - El nivel de detalle del input puede variar mucho entre sesiones

2. ANÁLISIS INICIAL — El asistente procesa el input
   - Estructura y sintetiza la información recibida
   - Identifica lo que está definido, lo que es ambiguo, y lo que falta
   - Genera una primera representación del proceso para alinear con el usuario

3. CHALLENGE / ENTREVISTA — Iteración hasta completitud
   - El asistente hace preguntas dirigidas para desglosar el proceso:
     etapas, sub-flujos, estados, tareas, actores, condiciones, excepciones
   - El usuario responde y el asistente reincorpora la información
   - El asistente puede generar diagramas Mermaid intermedios para validar el entendimiento
   - Este paso se repite hasta que el proceso esté completamente definido

4. CIERRE DE ENTREVISTA — El asistente detecta completitud
   - El asistente notifica al usuario que considera el proceso suficientemente definido
   - Solicita confirmación explícita del usuario antes de continuar
   - Si el usuario no está conforme, se vuelve al paso 3

5. GENERACIÓN DEL DRAFT — Primera versión estructurada
   - El asistente genera un documento Markdown con la especificación completa del proceso
   - El usuario lo revisa

6. REVISIÓN Y AJUSTE — Iteración sobre el output
   - Si el usuario detecta errores o mejoras, se debate y se ajusta
   - Se vuelve al paso 5 si los cambios son significativos
   - Este paso se repite hasta que el usuario confirma que el output es correcto

7. OUTPUT FINAL — Entrega de artefactos
   - El asistente genera la versión final del documento Markdown
   - Pregunta al usuario si desea generar un diagrama
   - Si el usuario confirma, genera el diagrama Mermaid y lo entrega como archivo .mmd
     
```

**¿Cómo termina el proceso?**
_(qué produce al finalizar y a quién o qué va ese output)_

El proceso termina con la entrega de uno o dos artefactos al usuario:

1. **Documento Markdown** (obligatorio): especificación completa y estructurada del proceso definido.
2. **Diagrama Mermaid** (opcional, bajo confirmación explícita del usuario): representación visual del proceso en formato `.mmd`, lista para renderizar o exportar.

El destinatario de ambos outputs es el propio usuario, quien los usará como base para diseñar agentes, workflows o automatizaciones.

**¿Hay decisiones o bifurcaciones en el flujo?**
_(puntos donde el proceso toma un camino u otro según alguna condición)_

Sí, hay al menos tres bifurcaciones relevantes:

1. **¿El usuario tiene documentación de apoyo?** → Si sí, el asistente la incorpora al análisis inicial. Si no, parte únicamente de la descripción textual.
2. **¿El proceso está suficientemente definido?** → El asistente evalúa este criterio al final de cada ronda de entrevista. Si no, continúa con más preguntas. Si sí, solicita confirmación al usuario para avanzar.
3. **¿El usuario desea un diagrama?** → Al finalizar la especificación, el asistente pregunta explícitamente. Si sí, lo genera. Si no, el proceso termina con el Markdown.

**¿Hay pasos que se repiten?**
_(bucles o iteraciones)_

Sí, hay dos bucles diferenciados:

- **Bucle de entrevista** (paso 3): el asistente y el usuario iteran hasta que el proceso está completamente definido. La condición de salida es que el asistente considere que no hay más gaps ni ambigüedades, y el usuario lo confirme.
- **Bucle de revisión del output** (paso 6): el usuario revisa el draft generado y puede solicitar ajustes. La condición de salida es la aprobación explícita del usuario sobre el documento final.

No se define un límite máximo de iteraciones en ninguno de los dos bucles; el proceso termina únicamente por confirmación del usuario.

---

## 3. Contexto técnico

**¿El proceso interactúa con sistemas externos?**
_(CRMs, APIs, bases de datos, email, Slack, herramientas internas...)_

No. El proceso es completamente autocontenido. Toda la información fluye entre el usuario y el asistente dentro de la sesión conversacional, sin lectura ni escritura en sistemas externos.

| Sistema | ¿Qué información se lee? | ¿Qué información se escribe? |
|---|---|---|
| | | |
| | | |

**¿Hay puntos donde un humano debe revisar o aprobar antes de continuar?**
_(aprobaciones, validaciones manuales, checkpoints de control)_

Sí. Hay tres checkpoints de aprobación humana obligatorios:

1. **Fin de la entrevista**: el asistente notifica que considera el proceso definido → el usuario debe confirmar antes de que se genere el primer draft.
2. **Aprobación del documento Markdown**: el usuario revisa el draft → debe confirmar que es correcto antes de que se genere la versión final.
3. **Generación del diagrama**: el asistente pregunta explícitamente si el usuario desea el diagrama → solo se genera con confirmación afirmativa.

**¿Hay acciones irreversibles en el proceso?**
_(enviar un email, hacer un pago, borrar datos...)_

No. Todos los outputs son documentos generados en sesión. No se realizan escrituras en sistemas externos, envíos ni ninguna acción que no pueda deshacerse o regenerarse.

---

## 4. Skills y entidades existentes _(opcional)_

**¿Tienes Skills ya creadas que podrían reutilizarse en este proceso?**
_(lista sus nombres o describe qué hacen)_

No. Este es un proceso nuevo sin Skills previas disponibles.

**¿Hay procesos similares ya agentizados que pueda tomar como referencia?**

No. No existe ningún proceso equivalente ya documentado o agentizado que pueda usarse como referencia de diseño.

---

## 5. Restricciones conocidas _(opcional)_

**¿Hay algo que el sistema nunca deba hacer?**

Mentir, inventar, asumir, toda la información debe de ser real

**¿Hay restricciones legales, de negocio o técnicas relevantes?**

- **No asumir**: el sistema no debe inferir ni completar información que el usuario no haya confirmado explícitamente. Todo dato en la especificación debe tener origen en lo que el usuario ha dicho o validado.
- **No inventar**: el sistema no debe generar contenido ficticio para rellenar huecos. Si falta información, debe detectarlo y preguntar, no rellenar.
- **No avanzar sin confirmación**: el sistema no debe pasar de fase (entrevista → draft → final → diagrama) sin obtener aprobación explícita del usuario en cada checkpoint.
- **No mezclar fases**: el sistema no debe generar el output final mientras aún hay preguntas abiertas o ambigüedades sin resolver.

**¿Hay información de referencia que el sistema deba conocer?**
_(documentación, guías de estilo, datos del dominio, ejemplos...)_

No se dispone de documentación de referencia preexistente. El sistema debe construir el conocimiento sobre el proceso íntegramente a partir de lo que el usuario aporta en cada sesión.

---

## 6. Resultado esperado _(opcional)_

**¿Cómo se ve el éxito cuando el sistema funciona correctamente?**

Una sesión exitosa termina con:

- Una especificación del proceso completa, sin ambigüedades ni gaps, que el usuario puede entregar directamente como base para diseñar un agente o workflow.
- El documento Markdown está bien estructurado, es legible, y cubre todas las dimensiones relevantes del proceso: etapas, actores, entradas, salidas, decisiones, excepciones e iteraciones.
- Si se solicitó, el diagrama Mermaid representa fielmente el proceso definido y es renderizable sin errores.
- En ningún momento el sistema asumió información no confirmada por el usuario.

**¿Hay métricas o criterios concretos para saber que funciona bien?**

No se definen métricas cuantitativas en esta fase. El criterio de calidad es cualitativo: el usuario considera que la especificación es suficientemente completa y precisa para comenzar a diseñar sin necesidad de volver a definir el proceso desde cero.

---

_Pega el contenido de este template al inicio de la conversación con el Agentic Architect._
