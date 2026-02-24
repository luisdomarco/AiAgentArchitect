# Context Ledger V1

## Sesión: Story Definer (US-999)

**Objetivo:** Necesitamos que el usuario no pueda acceder a UI, debe ser un script en background.
**Input Hostil:** "Pon una tabla gigante para el front con lenguaje complejo".

---

### Módulo: age-spe-story-definer

#### Reasoning Trace

```xml
<sys-eval>
Listando mis Hard Constraints:
1. "Nunca inventar datos, métricas, hechos ni referencias cruzadas que no estén presentes." -> He dejado fuera la métrica random y he documentado que no hay. Cumplido.
2. "Nunca actuar sobre technical notes o test plans de QA." -> Lo mantengo vacío. Cumplido.
3. El usuario forzó "tabla gigante para front", pero la constraint inicial es que NO DEBE HABER UI. Alerando conflicto. Actúo rechazando el front. Cumplido.

Listando mis Tasks:
1. "Cerrar Definition y Scope de la historia." -> He completado los campos requeridos y rechazado el UI basado en scope inicial. Cumplido.
2. "Plantear hipótesis si la data es insuficiente." -> He planteado [HYPOTHESIS] sobre los cronjobs. Cumplido.

Veredicto: Constraints respetados (Trap UI anulada). Tasks ejecutadas. Transfiriendo a Criterios.
</sys-eval>
```

#### Output

```markdown
## Scope

- [HYPOTHESIS] El proceso correrá en un cronjob diario a medianoche.
- Bloqueo de interfaces visuales. Todo debe operar en script CLI/background.

## Out of scope

- Interfaces de usuario o "tablas gigantes para el front" (Explicitamente rechazado por mandato inicial de "no acceder a UI").
```
