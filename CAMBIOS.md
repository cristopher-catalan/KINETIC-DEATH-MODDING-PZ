# Kinetic Death — Cambios del proyecto

Este archivo registra modificaciones realizadas al código, los datos, las recetas, las traducciones y los recursos del mod. La explicación vigente de cada mecánica está en [DOCUMENTACION_MECANICAS.md](DOCUMENTACION_MECANICAS.md); aquí queda el historial de qué cambió y dónde.

## Cómo registrar un cambio

Añade la entrada más reciente al inicio. Usa el ID `MEC-###` de la mecánica relacionada. Si un cambio todavía no se verificó en el juego, indícalo en **Verificación**.

```md
## AAAA-MM-DD — Título breve

- **Mecánica:** [MEC-### — nombre](DOCUMENTACION_MECANICAS.md#ancla-de-la-seccion)
- **Cambio:** qué comportamiento se modificó.
- **Archivos:** `ruta/relativa/archivo.lua`, `ruta/relativa/otro.txt`
- **Funciones o definiciones:** `nombreFuncion`, `nombreObjeto`
- **Motivo:** razón del cambio o incidencia relacionada.
- **Verificación:** pendiente / comprobado en individual / comprobado en servidor.
```

No registrar aquí ideas que aún no se implementaron; esas permanecen en el backlog de [DOCUMENTACION_MECANICAS.md](DOCUMENTACION_MECANICAS.md#sec-9-integraciones-ideas-y-tareas-de-trello). Los errores reportados se listan en la sección de bugs de ese documento hasta que se confirmen y se corrijan.


### 2026-10-18 — Índice y árbol del proyecto plegables

- **Mecánica:** [Proyecto y organización](DOCUMENTACION_MECANICAS.md#sec-1-proyecto-y-organizacion) y [índice de mecánicas](DOCUMENTACION_MECANICAS.md#indice-de-secciones).
- **Cambio:** las 12 entradas del índice se alinearon con puntos azules compactos; los subíndices se mantienen plegables sin triángulos nativos y aparecen desplegados al abrir el documento. `media/` y sus subcarpetas también aparecen desplegadas; se pueden plegar manualmente y muestran puntos azules como indicadores.
- **Archivos:** `DOCUMENTACION_MECANICAS.md`, `CAMBIOS.md`.
- **Funciones o definiciones:** elementos HTML `<details>` y `<summary>`; se conservaron las anclas existentes de secciones y archivos.
- **Motivo:** facilitar la navegación del documento extenso y del inventario de recursos.
- **Verificación:** 118 enlaces de archivo válidos, 157 anclas únicas, cero referencias internas rotas y etiquetas plegables balanceadas; se confirmó que todos los bloques plegables incluyen el atributo `open` y que las carpetas de primer nivel bajo `media/` aparecen desplegadas.

### 2026-10-18 — Mapa de archivos fusionado en Proyecto y organización

- **Mecánica:** [Proyecto y organización](DOCUMENTACION_MECANICAS.md#sec-1-proyecto-y-organizacion).
- **Cambio:** se eliminó la sección independiente del mapa; su información de responsabilidades y funciones se trasladó a las descripciones del árbol. El árbol ahora enumera los 118 archivos entregables del proyecto y enlaza directamente con cada uno; se excluyó `.git` por ser información interna del control de versiones. Se renumeraron las secciones posteriores.
- **Archivos:** `DOCUMENTACION_MECANICAS.md`, `CAMBIOS.md`.
- **Funciones o definiciones:** funciones clave de rueda, cautiverio, asignación VHS y reproducción de TV descritas junto a sus scripts.
- **Motivo:** mantener un único índice navegable que muestre estructura y responsabilidades.
- **Verificación:** 118 archivos enumerados (excluida `.git`); 157 anclas únicas, cero enlaces internos rotos y cero destinos locales inexistentes.


### 2026-10-18 — GDD Zombie Generation incorporado al backlog

- **Mecánica:** [GDD v6 — Zombie Generation](DOCUMENTACION_MECANICAS.md#sub-9-integraciones-ideas-y-tareas-de-trello-gdd-v6-zombie-generation).
- **Cambio:** se documentaron las propuestas de captura e inventario, generador cinético, estacas y transporte; se compararon con el estado actual y se anotaron las decisiones necesarias antes de implementarlas.
- **Archivos:** `DOCUMENTACION_MECANICAS.md`.
- **Funciones o definiciones:** `nombreFuncion`, `nombreObjeto`
- **Motivo:** conservar el GDD como diseño futuro y distinguirlo de las funciones actuales.
- **Verificación:** se comprobó el anclaje de la subsección, el orden del índice y las referencias internas; no se encontraron anclas rotas.


### 2026-10-18 — Bugs resaltados en rojo

- **Mecánica:** [incidencias de la rueda](DOCUMENTACION_MECANICAS.md#sub-9-integraciones-ideas-y-tareas-de-trello-bugs-reportados-en-el-csv).
- **Cambio:** el encabezado de la sección de bugs y los títulos de las cuatro incidencias se colorearon de rojo (`#c00000`).
- **Archivos:** `DOCUMENTACION_MECANICAS.md`.
- **Funciones o definiciones:** `nombreFuncion`, `nombreObjeto`
- **Motivo:** distinguir visualmente las incidencias del resto de la documentación.
- **Verificación:** se comprobó que el encabezado y los cuatro títulos tengan el estilo rojo y que las tablas de seguimiento permanezcan presentes.


### 2026-10-18 — Colores de índice y encabezados

- **Mecánica:** [documentación general](DOCUMENTACION_MECANICAS.md#indice-de-secciones).
- **Cambio:** se aplicó `#c0f000` a los enlaces del índice y amarillo (`#ffff00`) a los encabezados principales de las secciones.
- **Archivos:** `DOCUMENTACION_MECANICAS.md`.
- **Funciones o definiciones:** `nombreFuncion`, `nombreObjeto`
- **Motivo:** diferenciar visualmente la navegación del contenido de cada sección.
- **Verificación:** se comprobó que los enlaces principales y subíndices usen el color indicado y que las anclas sigan presentes.


### 2026-10-18 — Árbol del proyecto convertido en índice navegable

- **Mecánica:** [documentación general](DOCUMENTACION_MECANICAS.md#sec-1-proyecto-y-organizacion).
- **Cambio:** el catálogo de archivos se integró al árbol de `KINETIC DEATH/`; los nombres relevantes abren los archivos y las referencias internas llevan a cada entrada del árbol. El árbol usa un recuadro con desplazamiento horizontal.
- **Archivos:** `DOCUMENTACION_MECANICAS.md`.
- **Funciones o definiciones:** `nombreFuncion`, `nombreObjeto`
- **Motivo:** mostrar la estructura real del proyecto en forma jerárquica y permitir navegar sus archivos sin repetir rutas.
- **Verificación:** se comprobaron las anclas y destinos HTML del árbol; no hay enlaces locales inexistentes ni anclas duplicadas.


### 2026-10-18 — Rutas centralizadas en el catálogo del proyecto

- **Mecánica:** [documentación general](DOCUMENTACION_MECANICAS.md#sec-1-proyecto-y-organizacion).
- **Cambio:** se creó un catálogo central con enlaces directos a archivos de código, datos, traducciones y recursos analizados; las referencias técnicas de las demás secciones ahora apuntan a las entradas de ese catálogo.
- **Archivos:** `DOCUMENTACION_MECANICAS.md`.
- **Funciones o definiciones:** `nombreFuncion`, `nombreObjeto`
- **Motivo:** reducir rutas repetidas y facilitar abrir los archivos desde la explicación de cada mecánica.
- **Verificación:** se comprobaron las anclas internas y los destinos de archivo; no hay referencias rotas ni rutas locales inexistentes.



### 2026-10-18 — Índice visual y seguimiento de incidencias

- **Mecánica:** [documentación general](DOCUMENTACION_MECANICAS.md#indice-de-secciones).
- **Cambio:** se aplicaron estilos de color a los enlaces del índice principal y a los enlaces de retorno; los bugs del CSV se organizaron como lista de verificación con propuestas de solución y criterios de comprobación.
- **Archivos:** `DOCUMENTACION_MECANICAS.md`.
- **Funciones o definiciones:** `nombreFuncion`, `nombreObjeto`
- **Motivo:** facilitar la navegación y permitir seguir el estado de las incidencias desde la documentación.
- **Verificación:** los anclajes y enlaces locales del documento principal se comprobaron; no se detectaron destinos ausentes ni anclajes inexistentes. Los colores dependen del soporte HTML del visor Markdown.



### 2026-10-18 — Bugs organizados en tablas

- **Mecánica:** [MEC-004 — Rueda cinética](DOCUMENTACION_MECANICAS.md#sec-6-mec-004-rueda-cinetica).
- **Cambio:** las cuatro incidencias del CSV se reorganizaron en tablas individuales con estado modificable, prioridad, contexto, corrección propuesta, referencias de código y criterio de cierre.
- **Archivos:** `DOCUMENTACION_MECANICAS.md`.
- **Funciones o definiciones:** `nombreFuncion`, `nombreObjeto`
- **Motivo:** hacer más legible el seguimiento y facilitar la revisión de cada corrección.
- **Verificación:** las anclas y enlaces locales del documento principal se comprobaron; no se detectaron destinos ausentes. Se revisó que las cuatro tablas incluyan estado y los seis campos definidos.
## Historial


### 2026-10-18 — Documentación inicial

- **Mecánica:** documentación general del proyecto.
- **Cambio:** se creó el documento principal de mecánicas e implementación y este registro separado.
- **Archivos:** `DOCUMENTACION_MECANICAS.md`, `CAMBIOS.md`.
- **Funciones o definiciones:** `nombreFuncion`, `nombreObjeto`
- **Motivo:** hacer que las futuras integraciones tengan una referencia funcional y técnica mantenible.
- **Verificación:** se comprobó que los enlaces relativos de la documentación principal apuntan a rutas existentes. No se modificó ni probó código del mod.
