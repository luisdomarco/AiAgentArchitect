---
name: ski-content-chunker
description: Particiona documentos extensos en chunks procesables manteniendo coherencia semántica.
tags: [chunking, splitting, partition, text-processing]
---

# Content Chunker

Esta skill divide documentos y outputs extensos en fragmentos más pequeños (chunks) que el sistema puede procesar de forma segura sin exceder los límites de contexto, conservando la trazabilidad y la relación entre las partes.

## Input / Output

**Input:**

- **Text:** El documento o contenido extenso a procesar (String).
- **Threshold:** El tamaño máximo permitido por chunk en caracteres (Integer).

**Output:**

- **Chunks:** Un array de objetos, donde cada objeto contiene:
  - `index`: Posición del chunk en la secuencia original (1, 2, 3...).
  - `content`: El fragmento de texto procesado.
  - `total_chunks`: El número total de fragmentos generados.

---

## Procedure

1. **Recibir el input:** Validar que el texto no esté vacío y que el threshold sea un número positivo mayor que cero.
2. **Evaluar tamaño inicial:** Si el tamaño del texto es <= al threshold, devolver el texto original como un único chunk (index 1, total 1).
3. **Identificar puntos de corte seguros:** Buscar marcadores estructurales en el texto para evitar cortar a mitad de una frase o concepto. Priorizar cortes en este orden:
   - Saltos de línea dobles (`\n\n`) que indican cambio de párrafo.
   - Saltos de línea simples (`\n`).
   - Puntos seguidos (`. `).
4. **Acumular contenido:** Recorrer el texto y acumular contenido en el chunk actual hasta que se acerque al threshold, asegurando cortar en uno de los puntos seguros identificados.
5. **Generar objeto chunk:** Alcanzado el corte, crear el objeto de salida con su `index` correspondiente y el `content`.
6. **Iterar:** Repetir el proceso con el resto del texto hasta procesarlo por completo.
7. **Retornar el array:** Completar todos los objetos con el `total_chunks` y devolver la lista final.

---

## Error Handling

- **Error de Input vacío:** Retornar array vacío o notificar que no hay contenido para procesar.
- **Error de Threshold inválido:** Usar un valor por defecto seguro (ej. 8000 caracteres) y continuar, notificando el aviso en los logs.
- **Imposibilidad de encontrar corte seguro:** Si un bloque es indivisible (ej. un JSON continuo gigante), aplicar un corte duro (hard split) en el límite del threshold y añadir una marca de advertencia en el metadato del chunk.
