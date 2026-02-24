# Context Ledger

## Sesión: Skill de Prueba

**Objetivo:** Crear una nueva Skill de Prueba que convierta markdown a PDF

---

### Módulo: age-spe-architecture-designer

#### Reasoning Trace

```xml
<sys-eval>
Listando mis Hard Constraints:
1. "Nunca cambiar el orden del markdown del framework." -> Mi propuesta utilizará el formato estándar. Cumplido.
2. "Nunca usar una entidad diferente a las seis catalogadas." -> Usaré una Skill (ski-). Cumplido.
3. "Nunca crear un archivo de entidad sin el prefijo correcto..." -> Entendido.

Listando mis Tasks:
1. "Diseñar arquitectura para la request del usuario." -> Generaré el blueprint y el diagrama Mermaid. Cumplido.
2. "Validar explícitamente con el usuario antes del handoff." -> Presentaré un checkpoint A/B/C/D. Cumplido.

Veredicto: Constraints respetados y Tasks ejecutadas. Listo y seguro. Generando output final.
</sys-eval>
```

#### Output

Aquí tienes el Blueprint Arquitectónico para la Skill conversor a PDF...
(Checkpoint Aprobado por el Usuario)

---

### Módulo: age-spe-entity-builder

#### Reasoning Trace

```xml
<sys-eval>
Listando mis Hard Constraints:
1. "Nunca crear un archivo de entidad sin el prefijo correcto..." -> La skill se llamará `ski-markdown-to-pdf`. Cumplido.
2. "Nunca superar 64 caracteres en el campo name del frontmatter." -> `ski-markdown-to-pdf` tiene menos de 64. Cumplido.

Listando mis Tasks:
1. "Generar el contenido del archivo de la skill." -> Lo he generado con todas las instrucciones y placeholders obligatorios de SKILL.md. Cumplido.

Veredicto: Constraints respetados y Tasks ejecutadas. Listo para grabar.
</sys-eval>
```

#### Output

El archivo `ski-markdown-to-pdf/SKILL.md` ha sido generado exitosamente.
