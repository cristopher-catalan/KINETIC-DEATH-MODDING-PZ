# Kinetic Death — Mecánicas e implementación

> **Tipo:** documentación técnica y funcional del mod  
> **Estado de esta revisión:** análisis estático del proyecto; no se ejecutó una sesión de juego  
> **Fecha de revisión:** 2026-10-18  
> **Build declarada:** Build 42 (según etiquetas de Workshop; probar la versión concreta del juego antes de publicar)

Este documento reúne la descripción funcional y técnica de las mecánicas, los asuntos de Trello incluidos en `yC3cdCRp - kinetic-death.csv` y las propuestas del GDD v6 `Kinetic_Dead_Zombie_Generation_GDD_v6.pdf`. El historial de cambios del proyecto se mantiene por separado en [CAMBIOS.md](CAMBIOS.md). Las rutas de código son relativas a la carpeta `KINETIC DEATH` y enlazan con la copia del mod dentro de `Contents`.

Los estados describen lo que se encontró en archivos, no certifican que cada función opere correctamente en juego:

- **Implementado en código:** existe una ruta de código o definición identificable.
- **Reportado como completado:** aparece en la lista exportada de Trello como completado.
- **En desarrollo / idea:** el CSV lo muestra en desarrollo o en backlog.
- **Incidencia reportada:** aparece en la lista de bugs; requiere confirmar si sigue ocurriendo.
- **Pendiente de prueba:** solo puede confirmarse en una partida o servidor.

<a id="indice-de-secciones"></a>
## <span style="color:#ffff00">Índice de secciones</span>

<p style="margin:0.55em 0;"><span style="color:#00aaff;">●</span> <a href="#sec-1-proyecto-y-organizacion" style="color:#c0f000">1. PROYECTO Y ORGANIZACIÓN</a></p>
<p style="margin:0.55em 0;"><span style="color:#00aaff;">●</span> <a href="#sec-2-indice-de-mecanicas" style="color:#c0f000">2. ÍNDICE DE MECÁNICAS</a></p>
<details open>
<summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> <a href="#sec-3-mec-001-vhs-registro-distribucion-y-reproduccion" style="color:#c0f000">3. MEC-001 — VHS: REGISTRO, DISTRIBUCIÓN Y REPRODUCCIÓN</a></summary>
<ul>
<li><a href="#sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-que-hace-en-el-juego" style="color:#c0f000">Qué hace en el juego</a></li>
<li><a href="#sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-flujo-de-registro-y-asignacion" style="color:#c0f000">Flujo de registro y asignación</a></li>
<li><a href="#sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-categorias-y-contenido-encontrado" style="color:#c0f000">Categorías y contenido encontrado</a></li>
<li><a href="#sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-distribucion-observada" style="color:#c0f000">Distribución observada</a></li>
<li><a href="#sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-archivos-y-funciones" style="color:#c0f000">Archivos y funciones</a></li>
<li><a href="#sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-observaciones-para-la-siguiente-revision" style="color:#c0f000">Observaciones para la siguiente revisión</a></li>
</ul>
</details>
<details open>
<summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> <a href="#sec-4-mec-002-relatos-y-aprendizaje-progresivo" style="color:#c0f000">4. MEC-002 — RELATOS Y APRENDIZAJE PROGRESIVO</a></summary>
<ul>
<li><a href="#sub-4-mec-002-relatos-y-aprendizaje-progresivo-que-hace-en-el-juego" style="color:#c0f000">Qué hace en el juego</a></li>
<li><a href="#sub-4-mec-002-relatos-y-aprendizaje-progresivo-implementacion-y-referencias" style="color:#c0f000">Implementación y referencias</a></li>
<li><a href="#sub-4-mec-002-relatos-y-aprendizaje-progresivo-verificacion-pendiente" style="color:#c0f000">Verificación pendiente</a></li>
</ul>
</details>
<details open>
<summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> <a href="#sec-5-mec-003-cautiverio-de-zombis" style="color:#c0f000">5. MEC-003 — CAUTIVERIO DE ZOMBIS</a></summary>
<ul>
<li><a href="#sub-5-mec-003-cautiverio-de-zombis-que-hace-en-el-juego" style="color:#c0f000">Qué hace en el juego</a></li>
<li><a href="#sub-5-mec-003-cautiverio-de-zombis-reglas-y-estado-tecnico" style="color:#c0f000">Reglas y estado técnico</a></li>
<li><a href="#sub-5-mec-003-cautiverio-de-zombis-archivos-y-funciones" style="color:#c0f000">Archivos y funciones</a></li>
<li><a href="#sub-5-mec-003-cautiverio-de-zombis-integracion-y-limites" style="color:#c0f000">Integración y límites</a></li>
</ul>
</details>
<details open>
<summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> <a href="#sec-6-mec-004-rueda-cinetica" style="color:#c0f000">6. MEC-004 — RUEDA CINÉTICA</a></summary>
<ul>
<li><a href="#sub-6-mec-004-rueda-cinetica-construccion" style="color:#c0f000">Construcción</a></li>
<li><a href="#sub-6-mec-004-rueda-cinetica-meter-al-zombi-dentro" style="color:#c0f000">Meter al zombi dentro</a></li>
<li><a href="#sub-6-mec-004-rueda-cinetica-posicion-y-animacion" style="color:#c0f000">Posición y animación</a></li>
<li><a href="#sub-6-mec-004-rueda-cinetica-menu-de-controles" style="color:#c0f000">Menú de controles</a></li>
<li><a href="#sub-6-mec-004-rueda-cinetica-incidencias-y-verificacion" style="color:#c0f000">Incidencias y verificación</a></li>
</ul>
</details>
<details open>
<summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> <a href="#sec-7-mec-005-reproduccion-audiovisual-en-televisores" style="color:#c0f000">7. MEC-005 — REPRODUCCIÓN AUDIOVISUAL EN TELEVISORES</a></summary>
<ul>
<li><a href="#sub-7-mec-005-reproduccion-audiovisual-en-televisores-que-hace-en-el-juego" style="color:#c0f000">Qué hace en el juego</a></li>
<li><a href="#sub-7-mec-005-reproduccion-audiovisual-en-televisores-archivos-y-funciones" style="color:#c0f000">Archivos y funciones</a></li>
</ul>
</details>
<details open>
<summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> <a href="#sec-8-mec-006-traducciones-y-recursos" style="color:#c0f000">8. MEC-006 — TRADUCCIONES Y RECURSOS</a></summary>
<ul>
<li><a href="#sub-8-mec-006-traducciones-y-recursos-traducciones-detectadas" style="color:#c0f000">Traducciones detectadas</a></li>
<li><a href="#sub-8-mec-006-traducciones-y-recursos-recursos-principales" style="color:#c0f000">Recursos principales</a></li>
</ul>
</details>
<details open>
<summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> <a href="#sec-9-integraciones-ideas-y-tareas-de-trello" style="color:#c0f000">9. INTEGRACIONES, IDEAS Y TAREAS DE TRELLO</a></summary>
<ul>
<li><a href="#sub-9-integraciones-ideas-y-tareas-de-trello-integraciones-o-tareas-marcadas-como-completadas-en-el-csv" style="color:#c0f000">Integraciones o tareas marcadas como completadas en el CSV</a></li>
<li><a href="#sub-9-integraciones-ideas-y-tareas-de-trello-bugs-reportados-en-el-csv" style="color:#c0f000">Bugs reportados en el CSV</a></li>
<li><a href="#sub-9-integraciones-ideas-y-tareas-de-trello-ideas-y-trabajo-futuro" style="color:#c0f000">Ideas y trabajo futuro</a></li>
<li><a href="#sub-9-integraciones-ideas-y-tareas-de-trello-gdd-v6-zombie-generation" style="color:#c0f000">GDD v6 — Zombie Generation</a></li>
</ul>
</details>
<p style="margin:0.55em 0;"><span style="color:#00aaff;">●</span> <a href="#sec-10-como-mantener-este-documento" style="color:#c0f000">10. CÓMO MANTENER ESTE DOCUMENTO</a></p>
<p style="margin:0.55em 0;"><span style="color:#00aaff;">●</span> <a href="#sec-11-historial-de-cambios" style="color:#c0f000">11. HISTORIAL DE CAMBIOS</a></p>
<p style="margin:0.55em 0;"><span style="color:#00aaff;">●</span> <a href="#sec-12-glosario" style="color:#c0f000">12. GLOSARIO</a></p>

<a id="sec-1-proyecto-y-organizacion"></a>
## <span style="color:#ffff00">1. Proyecto y organización</span>

El proyecto de Workshop tiene esta forma. El árbol enumera los archivos entregables del proyecto; se omite `.git`, que contiene datos internos del control de versiones. Las carpetas dentro de `media` aparecen desplegadas y se pueden plegar al seleccionarlas:

<div style="max-width:100%; overflow-x:auto; border:1px solid #bbb; padding:0.75rem;">
<div style="max-width:100%; overflow-x:auto; border:1px solid #bbb; padding:0.75rem;">
<p><strong>KINETIC DEATH/</strong></p>
<ul class="project-tree">
  <li><a id="archivo-cambios-md"></a><a href="CAMBIOS.md">CAMBIOS.md</a> — Historial de modificaciones implementadas.</li>
  <li><a id="archivo-documentacion-mecanicas-md"></a><a href="DOCUMENTACION_MECANICAS.md">DOCUMENTACION_MECANICAS.md</a> — Mec&#225;nicas, arquitectura y referencias del proyecto.</li>
  <li><a id="recurso-preview"></a><a href="preview.png">preview.png</a> — Imagen de portada para Workshop.</li>
  <li><a id="archivo-workshop"></a><a href="workshop.txt">workshop.txt</a> — Metadatos de publicaci&#243;n e ID de Workshop.</li>
  <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> Contents/</summary>
  <ul>
    <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> mods/</summary>
    <ul>
      <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> KINETIC-DEAD/</summary>
      <ul>
        <li><a id="archivo-contents-mods-kinetic-dead-comandos-prueba-lua-txt"></a><a href="Contents/mods/KINETIC-DEAD/comandos_prueba_lua.txt">comandos_prueba_lua.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
        <li><a id="archivo-contents-mods-kinetic-dead-logo-png"></a><a href="Contents/mods/KINETIC-DEAD/LOGO.png">LOGO.png</a> — Imagen o textura del mod.</li>
        <li><a id="archivo-readme-mod"></a><a href="Contents/mods/KINETIC-DEAD/README.txt">README.txt</a> — Resumen incluido con el mod.</li>
        <li><a id="archivo-registro-vhs"></a><a href="Contents/mods/KINETIC-DEAD/REGISTRO_VHS.md">REGISTRO_VHS.md</a> — Notas anteriores del sistema de registro de VHS.</li>
        <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> 42/</summary>
        <ul>
          <li><a id="archivo-contents-mods-kinetic-dead-42-icon-png"></a><a href="Contents/mods/KINETIC-DEAD/42/icon.png">icon.png</a> — Imagen o textura del mod.</li>
          <li><a id="archivo-modinfo-b42"></a><a href="Contents/mods/KINETIC-DEAD/42/mod.info">mod.info</a> — Recurso del proyecto.</li>
          <li><a id="archivo-contents-mods-kinetic-dead-42-poster-png"></a><a href="Contents/mods/KINETIC-DEAD/42/poster.png">poster.png</a> — Imagen o textura del mod.</li>
          <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> media/</summary>
          <ul>
            <li><a id="archivo-guid-table"></a><a href="Contents/mods/KINETIC-DEAD/42/media/fileGuidTable.xml">fileGuidTable.xml</a> — Definiciones de recursos, animaciones o modelos.</li>
            <li><a id="archivo-contents-mods-kinetic-dead-42-media-rueda-tiledefinitions-tiles"></a><a href="Contents/mods/KINETIC-DEAD/42/media/rueda_tiledefinitions.tiles">rueda_tiledefinitions.tiles</a> — Recurso del proyecto.</li>
            <li><a id="archivo-tiles-rueda"></a><a href="Contents/mods/KINETIC-DEAD/42/media/rueda_tiledefinitions.tiles.txt">rueda_tiledefinitions.tiles.txt</a> — Definiciones de tiles que forman la estructura de la rueda.</li>
            <li><a id="archivo-contents-mods-kinetic-dead-42-media-rueda-tiledefinitions-tiles-txt-bak"></a><a href="Contents/mods/KINETIC-DEAD/42/media/rueda_tiledefinitions.tiles.txt.bak">rueda_tiledefinitions.tiles.txt.bak</a> — Recurso del proyecto.</li>
            <li><a id="archivo-config-pack-rueda"></a><a href="Contents/mods/KINETIC-DEAD/42/media/rueda.txt">rueda.txt</a> — Metadatos del paquete de texturas de la rueda.</li>
            <li><a id="archivo-contents-mods-kinetic-dead-42-media-rueda-txt-bak"></a><a href="Contents/mods/KINETIC-DEAD/42/media/rueda.txt.bak">rueda.txt.bak</a> — Recurso del proyecto.</li>
            <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> anims_X/</summary>
            <ul>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> Bob/</summary>
              <ul>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-anims-x-bob-bob-handscuffed-fbx"></a><a href="Contents/mods/KINETIC-DEAD/42/media/anims_X/Bob/Bob_HandsCuffed.fbx">Bob_HandsCuffed.fbx</a> — Modelo 3D.</li>
              </ul>
              </details></li>
            </ul>
            </details></li>
            <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> AnimSets/</summary>
            <ul>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> zombie/</summary>
              <ul>
                <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> idle/</summary>
                <ul>
                  <li><a id="archivo-contents-mods-kinetic-dead-42-media-animsets-zombie-idle-catbr-preso-xml"></a><a href="Contents/mods/KINETIC-DEAD/42/media/AnimSets/zombie/idle/CatBR_Preso.xml">CatBR_Preso.xml</a> — Definiciones de recursos, animaciones o modelos.</li>
                </ul>
                </details></li>
                <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> walk/</summary>
                <ul>
                  <li><a id="archivo-contents-mods-kinetic-dead-42-media-animsets-zombie-walk-catbr-rueda-xml"></a><a href="Contents/mods/KINETIC-DEAD/42/media/AnimSets/zombie/walk/CatBR_Rueda.xml">CatBR_Rueda.xml</a> — Definiciones de recursos, animaciones o modelos.</li>
                </ul>
                </details></li>
              </ul>
              </details></li>
            </ul>
            </details></li>
            <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> clothing/</summary>
            <ul>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> clothingItems/</summary>
              <ul>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-clothing-clothingitems-catbr-coto-l-xml"></a><a href="Contents/mods/KINETIC-DEAD/42/media/clothing/clothingItems/CatBR_Coto_L.xml">CatBR_Coto_L.xml</a> — Definiciones de recursos, animaciones o modelos.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-clothing-clothingitems-catbr-coto-r-xml"></a><a href="Contents/mods/KINETIC-DEAD/42/media/clothing/clothingItems/CatBR_Coto_R.xml">CatBR_Coto_R.xml</a> — Definiciones de recursos, animaciones o modelos.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-clothing-clothingitems-catbr-sembracos-xml"></a><a href="Contents/mods/KINETIC-DEAD/42/media/clothing/clothingItems/CatBR_SemBracos.xml">CatBR_SemBracos.xml</a> — Definiciones de recursos, animaciones o modelos.</li>
              </ul>
              </details></li>
            </ul>
            </details></li>
            <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> lua/</summary>
            <ul>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> client/</summary>
              <ul>
                <li><a id="archivo-animacion-rueda"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/client/animacion_rueda.lua">animacion_rueda.lua</a> — Animaci&#243;n y estado de rueda; funciones KineticDeadStartWheelAt, KineticDeadStartWheelNearSquare, KineticDeadStopWheelForZombie, KineticDeadWheelCaptiveSquare, ToggleRuedasArea y men&#250; contextual.</li>
                <li><a id="archivo-catbr-client"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/client/CatBR_Client.lua">CatBR_Client.lua</a> — Interacciones cliente de cautiverio; CatBR.amarrarEnRueda, CatBR.colocarEnRueda, libertarZumbi, controlar y men&#250;s contextuales.</li>
                <li><a id="archivo-invocador-items"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/client/invocador_items.txt">invocador_items.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
                <li><a id="archivo-reproductor-tele"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/client/reproductor_tele.lua">reproductor_tele.lua</a> — Control de audio de TV/VHS, eventos de reproducci&#243;n y aprendizaje de recetas al completar la cinta.</li>
                <li><a id="archivo-tv-animator"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/client/TV_Animator.lua">TV_Animator.lua</a> — Reproducci&#243;n visual en televisores; CustomTVTest.Start, LoadFrame, OnTick, Stop y men&#250;s de TV.</li>
              </ul>
              </details></li>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> server/</summary>
              <ul>
                <li><a id="archivo-catbr-server"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/server/CatBR_Server.lua">CatBR_Server.lua</a> — Comandos de servidor y sincronizaci&#243;n; Cmd.Amarrar, Cmd.Desamarrar, Cmd.AmarraBrava, Cmd.SemBraco, Cmd.Mochila y Cmd.PedirEstado.</li>
                <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> Items/</summary>
                <ul>
                  <li><a id="archivo-vhs-distribucion"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/server/Items/VHS_Distribucion.lua">VHS_Distribucion.lua</a> — Asigna VHS por serie y categor&#237;a al generar contenedores; elegirSerie, asignar, elegirDeCategoria y generar.</li>
                </ul>
                </details></li>
              </ul>
              </details></li>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> shared/</summary>
              <ul>
                <li><a id="archivo-catbr-shared"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/CatBR_Shared.lua">CatBR_Shared.lua</a> — Funciones compartidas CatBR.log, CatBR.dados, CatBR.idAmarra y CatBR.acharAlgema.</li>
                <li><a id="archivo-recorded-media"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/recorded_media.lua">recorded_media.lua</a> — Ajusta la duraci&#243;n de los medios registrados con SincronizarDuracionVHS.</li>
                <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> Translate/</summary>
                <ul>
                  <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> EN/</summary>
                  <ul>
                    <li><a id="archivo-contextmenu-en"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/EN/ContextMenu_EN.txt">ContextMenu_EN.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-en-contextmenu-json"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/EN/ContextMenu.json">ContextMenu.json</a> — Datos de configuraci&#243;n o recurso.</li>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-en-ig-ui-en-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/EN/IG_UI_EN.txt">IG_UI_EN.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-en-ig-ui-json"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/EN/IG_UI.json">IG_UI.json</a> — Datos de configuraci&#243;n o recurso.</li>
                  </ul>
                  </details></li>
                  <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> ES/</summary>
                  <ul>
                    <li><a id="archivo-contextmenu-es"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/ES/ContextMenu_ES.txt">ContextMenu_ES.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
                    <li><a id="archivo-contextmenu-json-es"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/ES/ContextMenu.json">ContextMenu.json</a> — Datos de configuraci&#243;n o recurso.</li>
                    <li><a id="archivo-ig-ui-es"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/ES/IG_UI_ES.txt">IG_UI_ES.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-es-ig-ui-json"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/ES/IG_UI.json">IG_UI.json</a> — Datos de configuraci&#243;n o recurso.</li>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-es-itemname-es-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/ES/ItemName_ES.txt">ItemName_ES.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-es-recipes-json"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/ES/Recipes.json">Recipes.json</a> — Datos de configuraci&#243;n o recurso.</li>
                  </ul>
                  </details></li>
                  <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> PT/</summary>
                  <ul>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-pt-contextmenu-json"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/PT/ContextMenu.json">ContextMenu.json</a> — Datos de configuraci&#243;n o recurso.</li>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-pt-ig-ui-json"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/PT/IG_UI.json">IG_UI.json</a> — Datos de configuraci&#243;n o recurso.</li>
                  </ul>
                  </details></li>
                  <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> PTBR/</summary>
                  <ul>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-ptbr-contextmenu-ptbr-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/PTBR/ContextMenu_PTBR.txt">ContextMenu_PTBR.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-ptbr-contextmenu-json"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/PTBR/ContextMenu.json">ContextMenu.json</a> — Datos de configuraci&#243;n o recurso.</li>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-ptbr-ig-ui-ptbr-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/PTBR/IG_UI_PTBR.txt">IG_UI_PTBR.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
                    <li><a id="archivo-contents-mods-kinetic-dead-42-media-lua-shared-translate-ptbr-ig-ui-json"></a><a href="Contents/mods/KINETIC-DEAD/42/media/lua/shared/Translate/PTBR/IG_UI.json">IG_UI.json</a> — Datos de configuraci&#243;n o recurso.</li>
                  </ul>
                  </details></li>
                </ul>
                </details></li>
              </ul>
              </details></li>
            </ul>
            </details></li>
            <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> models_X/</summary>
            <ul>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> CatBRCoto/</summary>
              <ul>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-models-x-catbrcoto-amputation-left-upperarm-female-fbx"></a><a href="Contents/mods/KINETIC-DEAD/42/media/models_X/CatBRCoto/Amputation_Left_UpperArm_Female.fbx">Amputation_Left_UpperArm_Female.fbx</a> — Modelo 3D.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-models-x-catbrcoto-amputation-left-upperarm-male-fbx"></a><a href="Contents/mods/KINETIC-DEAD/42/media/models_X/CatBRCoto/Amputation_Left_UpperArm_Male.fbx">Amputation_Left_UpperArm_Male.fbx</a> — Modelo 3D.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-models-x-catbrcoto-amputation-right-upperarm-female-fbx"></a><a href="Contents/mods/KINETIC-DEAD/42/media/models_X/CatBRCoto/Amputation_Right_UpperArm_Female.fbx">Amputation_Right_UpperArm_Female.fbx</a> — Modelo 3D.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-models-x-catbrcoto-amputation-right-upperarm-male-fbx"></a><a href="Contents/mods/KINETIC-DEAD/42/media/models_X/CatBRCoto/Amputation_Right_UpperArm_Male.fbx">Amputation_Right_UpperArm_Male.fbx</a> — Modelo 3D.</li>
              </ul>
              </details></li>
            </ul>
            </details></li>
            <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> scripts/</summary>
            <ul>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-scripts-catbr-items-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/scripts/catbr_items.txt">catbr_items.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
              <li><a id="archivo-items"></a><a href="Contents/mods/KINETIC-DEAD/42/media/scripts/items.txt">items.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
              <li><a id="archivo-kineticdead-vhs"></a><a href="Contents/mods/KINETIC-DEAD/42/media/scripts/kineticdead_vhs.txt">kineticdead_vhs.txt</a> — Definiciones de cintas VHS y categor&#237;as de medios.</li>
              <li><a id="archivo-recetas"></a><a href="Contents/mods/KINETIC-DEAD/42/media/scripts/recetas_recipes.txt">recetas_recipes.txt</a> — Recetas de construcci&#243;n; incluye requisitos de aprendizaje.</li>
              <li><a id="archivo-revistas"></a><a href="Contents/mods/KINETIC-DEAD/42/media/scripts/revistas.txt">revistas.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-scripts-sounds-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/scripts/sounds.txt">sounds.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> entities/</summary>
              <ul>
                <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> Rueda/</summary>
                <ul>
                  <li><a id="archivo-skin-rueda"></a><a href="Contents/mods/KINETIC-DEAD/42/media/scripts/entities/Rueda/entity_carpentry_estructurarueda_xui_skin.txt">entity_carpentry_estructurarueda_xui_skin.txt</a> — Definici&#243;n de la rueda como entidad de carpinter&#237;a y opciones de colocaci&#243;n.</li>
                </ul>
                </details></li>
              </ul>
              </details></li>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> generated/</summary>
              <ul>
                <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> entities/</summary>
                <ul>
                  <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> Rueda/</summary>
                  <ul>
                    <li><a id="archivo-entidad-rueda"></a><a href="Contents/mods/KINETIC-DEAD/42/media/scripts/generated/entities/Rueda/entity_carpentry_estructurarueda.txt">entity_carpentry_estructurarueda.txt</a> — Definici&#243;n generada de entidad para las piezas de la rueda.</li>
                  </ul>
                  </details></li>
                </ul>
                </details></li>
              </ul>
              </details></li>
            </ul>
            </details></li>
            <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> sound/</summary>
            <ul>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-sound-boondocks-ogg"></a><a href="Contents/mods/KINETIC-DEAD/42/media/sound/boondocks.ogg">boondocks.ogg</a> — Audio utilizado por el mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-sound-joven-ogg"></a><a href="Contents/mods/KINETIC-DEAD/42/media/sound/joven.ogg">joven.ogg</a> — Audio utilizado por el mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-sound-noticiero-ogg"></a><a href="Contents/mods/KINETIC-DEAD/42/media/sound/noticiero.ogg">noticiero.ogg</a> — Audio utilizado por el mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-sound-ricardo-milos-ogg"></a><a href="Contents/mods/KINETIC-DEAD/42/media/sound/ricardo_milos.ogg">ricardo_milos.ogg</a> — Audio utilizado por el mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-sound-rickroll-ogg"></a><a href="Contents/mods/KINETIC-DEAD/42/media/sound/rickroll.ogg">rickroll.ogg</a> — Audio utilizado por el mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-sound-trailer-ogg"></a><a href="Contents/mods/KINETIC-DEAD/42/media/sound/trailer.ogg">trailer.ogg</a> — Audio utilizado por el mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-sound-walkin-ogg"></a><a href="Contents/mods/KINETIC-DEAD/42/media/sound/walkin.ogg">walkin.ogg</a> — Audio utilizado por el mod.</li>
            </ul>
            </details></li>
            <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> texturepacks/</summary>
            <ul>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-boondocks-pack"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/boondocks.pack">boondocks.pack</a> — Paquete de recursos audiovisuales.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-boondocks-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/boondocks.txt">boondocks.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-joven-pack"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/joven.pack">joven.pack</a> — Paquete de recursos audiovisuales.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-joven-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/joven.txt">joven.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-noticiero-pack"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/noticiero.pack">noticiero.pack</a> — Paquete de recursos audiovisuales.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-noticiero-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/noticiero.txt">noticiero.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-ricardo-milos-pack"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/ricardo_milos.pack">ricardo_milos.pack</a> — Paquete de recursos audiovisuales.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-ricardo-milos-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/ricardo_milos.txt">ricardo_milos.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-rickroll-pack"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/rickroll.pack">rickroll.pack</a> — Paquete de recursos audiovisuales.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-rickroll-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/rickroll.txt">rickroll.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
              <li><a id="archivo-pack-rueda"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/rueda.pack">rueda.pack</a> — Paquete de recursos audiovisuales.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-trailer-pack"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/trailer.pack">trailer.pack</a> — Paquete de recursos audiovisuales.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-trailer-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/trailer.txt">trailer.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-walkin-pack"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/walkin.pack">walkin.pack</a> — Paquete de recursos audiovisuales.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-texturepacks-walkin-txt"></a><a href="Contents/mods/KINETIC-DEAD/42/media/texturepacks/walkin.txt">walkin.txt</a> — Definiciones, traducciones o metadatos del mod.</li>
            </ul>
            </details></li>
            <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> textures/</summary>
            <ul>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-build-rueda-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/build_rueda.png">build_rueda.png</a> — Imagen o textura del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-item-animado-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Item_Animado.png">Item_Animado.png</a> — Imagen o textura del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-item-cassette3-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Item_Cassette3.png">Item_Cassette3.png</a> — Imagen o textura del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-item-logan-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Item_logan.png">Item_logan.png</a> — Imagen o textura del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-item-loganc-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Item_loganc.png">Item_loganc.png</a> — Imagen o textura del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-item-magazineelectronics04-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Item_MagazineElectronics04.png">Item_MagazineElectronics04.png</a> — Imagen o textura del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-item-peruano-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Item_peruano.png">Item_peruano.png</a> — Imagen o textura del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-item-recetavhs-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Item_RecetaVHS.png">Item_RecetaVHS.png</a> — Imagen o textura del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-item-ruiz-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Item_ruiz.png">Item_ruiz.png</a> — Imagen o textura del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-item-thorne-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Item_thorne.png">Item_thorne.png</a> — Imagen o textura del mod.</li>
              <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-renombrar-py"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/renombrar.py">renombrar.py</a> — Recurso del proyecto.</li>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> Body/</summary>
              <ul>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-body-catbr-invisivel-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Body/CatBR_Invisivel.png">CatBR_Invisivel.png</a> — Imagen o textura del mod.</li>
              </ul>
              </details></li>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> CatBR/</summary>
              <ul>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbr-catbr-blank-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBR/CatBR_Blank.png">CatBR_Blank.png</a> — Imagen o textura del mod.</li>
              </ul>
              </details></li>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> CatBRCoto/</summary>
              <ul>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin01-l1-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin01_l1.png">z_skin01_l1.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin01-l2-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin01_l2.png">z_skin01_l2.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin01-l3-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin01_l3.png">z_skin01_l3.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin02-l1-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin02_l1.png">z_skin02_l1.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin02-l2-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin02_l2.png">z_skin02_l2.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin02-l3-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin02_l3.png">z_skin02_l3.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin03-l1-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin03_l1.png">z_skin03_l1.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin03-l2-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin03_l2.png">z_skin03_l2.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin03-l3-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin03_l3.png">z_skin03_l3.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin04-l1-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin04_l1.png">z_skin04_l1.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin04-l2-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin04_l2.png">z_skin04_l2.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-catbrcoto-z-skin04-l3-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/CatBRCoto/z_skin04_l3.png">z_skin04_l3.png</a> — Imagen o textura del mod.</li>
              </ul>
              </details></li>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> Portadas_Cineticas/</summary>
              <ul>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-portadas-cineticas-kd-portada-cuadrada-energia-cinetica-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Portadas_Cineticas/KD_Portada_Cuadrada_Energia_Cinetica.png">KD_Portada_Cuadrada_Energia_Cinetica.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-portadas-cineticas-kd-portada-cuadrada-logan-energia-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Portadas_Cineticas/KD_Portada_Cuadrada_Logan_Energia.png">KD_Portada_Cuadrada_Logan_Energia.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-portadas-cineticas-kd-portada-cuadrada-logan-motor-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Portadas_Cineticas/KD_Portada_Cuadrada_Logan_Motor.png">KD_Portada_Cuadrada_Logan_Motor.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-portadas-cineticas-kd-portada-cuadrada-thorne-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Portadas_Cineticas/KD_Portada_Cuadrada_Thorne.png">KD_Portada_Cuadrada_Thorne.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-portadas-cineticas-kd-portada-rectangular-logan-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Portadas_Cineticas/KD_Portada_Rectangular_Logan.png">KD_Portada_Rectangular_Logan.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-portadas-cineticas-kd-portada-rectangular-thorne-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/Portadas_Cineticas/KD_Portada_Rectangular_Thorne.png">KD_Portada_Rectangular_Thorne.png</a> — Imagen o textura del mod.</li>
              </ul>
              </details></li>
              <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> VHS_Covers/</summary>
              <ul>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-vhs-covers-cover-vhs-logan-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/VHS_Covers/Cover_VHS_Logan.png">Cover_VHS_Logan.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-vhs-covers-cover-vhs-loganc-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/VHS_Covers/Cover_VHS_LoganC.png">Cover_VHS_LoganC.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-vhs-covers-cover-vhs-ruiz-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/VHS_Covers/Cover_VHS_Ruiz.png">Cover_VHS_Ruiz.png</a> — Imagen o textura del mod.</li>
                <li><a id="archivo-contents-mods-kinetic-dead-42-media-textures-vhs-covers-cover-vhs-thorne-png"></a><a href="Contents/mods/KINETIC-DEAD/42/media/textures/VHS_Covers/Cover_VHS_Thorne.png">Cover_VHS_Thorne.png</a> — Imagen o textura del mod.</li>
              </ul>
              </details></li>
            </ul>
            </details></li>
          </ul>
          </details></li>
        </ul>
        </details></li>
        <li style="list-style:none;"><details open><summary style="list-style:none; cursor:pointer;"><span style="color:#00aaff;">●</span> common/</summary>
        <ul>
          <li><a id="archivo-modinfo-common"></a><a href="Contents/mods/KINETIC-DEAD/common/mod.info">mod.info</a> — Recurso del proyecto.</li>
        </ul>
        </details></li>
      </ul>
      </details></li>
    </ul>
    </details></li>
  </ul>
  </details></li>
</ul>
</div>
</div>

Algunas entradas corresponden a carpetas. Los enlaces a archivos abren su contenido; las referencias de las secciones siguientes apuntan a su posición en este árbol. Si el árbol supera el ancho disponible, desplázate horizontalmente dentro del recuadro.

El mod se identifica como `KineticDead_Ronald`. El archivo de Workshop declara el ID `3814398423`, título `Kinetic Death`, visibilidad pública y etiquetas que incluyen Build 42. `common/mod.info` y `42/mod.info` comparten nombre, ID, descripción, versión y autor; el `mod.info` de Build 42 añade el paquete de tiles y su definición.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sec-2-indice-de-mecanicas"></a>
## <span style="color:#ffff00">2. Índice de mecánicas</span>

| ID | Mecánica | Estado observado | Sección |
|---|---|---|---|
| MEC-001 | VHS: registro, distribución y reproducción | Implementado en código; pendiente de prueba integral | [VHS](#sec-3-mec-001-vhs-registro-distribucion-y-reproduccion) |
| MEC-002 | Relatos y aprendizaje progresivo | Implementado en código para dos hitos concretos | [Relatos y aprendizaje](#sec-4-mec-002-relatos-y-aprendizaje-progresivo) |
| MEC-003 | Someter, conducir, amarrar y liberar zombis | Integración de cautiverio implementada; reportes de fallos en CSV | [Cautiverio](#sec-5-mec-003-cautiverio-de-zombis) |
| MEC-004 | Construcción, menú y animación de la rueda | Implementado en código; hay incidencias reportadas que requieren retest | [Rueda](#sec-6-mec-004-rueda-cinetica) |
| MEC-005 | Reproducción audiovisual en televisores | Implementado en código para medios identificados | [Televisores](#sec-7-mec-005-reproduccion-audiovisual-en-televisores) |
| MEC-006 | Traducciones y recursos | Archivos presentes; cobertura y consistencia requieren revisión | [Recursos](#sec-8-mec-006-traducciones-y-recursos) |

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sec-3-mec-001-vhs-registro-distribucion-y-reproduccion"></a>
## <span style="color:#ffff00">3. MEC-001 — VHS: registro, distribución y reproducción</span>

<a id="sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-que-hace-en-el-juego"></a>
### Qué hace en el juego

El mod registra relatos y películas como contenido de `RecMedia`, define tipos físicos de cassette con categorías propias y asigna un contenido compatible cuando se genera un contenedor admitido. La categoría del contenido se valida antes de adjuntarlo al cassette. Los relatos se reproducen como líneas de medio; las películas se enlazan a sus recursos audiovisuales.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-flujo-de-registro-y-asignacion"></a>
### Flujo de registro y asignación

1. `recorded_media.lua` crea entradas `RecMedia[id]` con título, autor, categoría y líneas.
2. `kineticdead_vhs.txt` y `items.txt` asignan `MediaCategory` a los objetos VHS.
3. `VHS_Distribucion.lua`, mediante el evento `Events.OnFillContainer`, filtra los tipos de contenedor admitidos y selecciona una serie.
4. `elegirDeCategoria()` obtiene un registro de la categoría elegida.
5. `asignar()` comprueba que exista y que coincida la categoría esperada; después llama `item:setRecordedMediaData(data)`.
6. Al reproducir un medio, `reproductor_tele.lua` conserva la sesión y comprueba su finalización.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-categorias-y-contenido-encontrado"></a>
### Categorías y contenido encontrado

| Objeto de inventario | Categoría del objeto | Registros encontrados | Contenido |
|---|---|---:|---|
| `Base.VHS_Logan` | `Logan-VHS` | 17 | `CazadoresMuertos01–17` |
| `Base.VHS_LoganC` | `LoganC-VHS` | 1 | `CazadoresMuertos18` (cinta especial) |
| `Base.VHS_Ruiz` | `Ruiz-VHS` | 9 | `DiariosRuiz01–09` |
| `Base.VHS_Thorne` | `Thorne-VHS` | 21 | `BitacorasThorne01–21` |
| `Base.VHS_Animado` | `Animado-VHS` | 7 | `boondocks`, `noticiero`, `walkin`, `trailer`, `ricardo_milos`, `joven`, `rickroll` |

Hay 48 registros narrativos (17 Logan + 1 LoganC + 9 Ruiz + 21 Thorne) y 7 películas/medios animados. Esto coincide con la cantidad total de relatos anunciada en el README, aunque el desglose de VHS Logan descrito en `REGISTRO_VHS.md` debe actualizarse: indica 18 Logan ordinarios y no separa el único registro LoganC.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-distribucion-observada"></a>
### Distribución observada

`elegirSerie()` usa pesos de 33% Logan, 33% Ruiz, 32% Thorne y 2% LoganC. Esos porcentajes son la selección de serie por cada contenedor admitido, no una probabilidad independiente acumulada para todo el mundo. `CONTENEDORES` incluye `bin`, `dumpster`, `crate`, `shelves`, `sidetable`, `wardrobe` y `displaycase`.

El código marca el contenedor como procesado (`kineticDeadVhsProcessed`) antes de intentar asignar el medio. La selección narrativa se intenta con `ZombRand(100) < 100`, una condición que siempre se cumple para el rango habitual de `ZombRand(100)`. Si la asignación no se completa, queda una alternativa de 15% para un VHS animado. Si el contenedor ya está marcado, no vuelve a intentarlo.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-archivos-y-funciones"></a>
### Archivos y funciones

| Etapa | Referencia | Responsabilidad |
|---|---|---|
| Registro de medios | [recorded_media.lua](#archivo-recorded-media) — `SincronizarDuracionVHS`, `RecMedia[id]` | Declara 48 relatos y 7 medios animados; enlaza duración y cuadros de los medios audiovisuales. |
| Definición de VHS de relato | [kineticdead_vhs.txt](#archivo-kineticdead-vhs) | Define `VHS_Logan`, `VHS_LoganC`, `VHS_Ruiz` y `VHS_Thorne` con sus categorías. |
| Definición de VHS animado | [items.txt](#archivo-items) | Define `VHS_Animado` con `Animado-VHS`. |
| Asignación a contenedores | [VHS_Distribucion.lua](#archivo-vhs-distribucion) — `elegirSerie`, `asignar`, `elegirDeCategoria`, `generar` | Selecciona serie, valida categoría, asigna contenido y registra contenedores procesados. |
| Definiciones auxiliares de duración | [reproductor_tele.lua](#archivo-reproductor-tele) | Controla reproducción y seguimiento de medios en dispositivos. |

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-3-mec-001-vhs-registro-distribucion-y-reproduccion-observaciones-para-la-siguiente-revision"></a>
### Observaciones para la siguiente revisión

- Confirmar en una partida que cada categoría genera cassettes con el diseño esperado y que `LoganC` conserva su rareza.
- Confirmar si la marca por contenedor se guarda y se replica de forma adecuada en multijugador.
- La cinta VHS fabricable definida en `recetas_recipes.txt` produce `VHS_Animado`; las cintas narrativas se asignan mediante distribución de contenedores.
- `REGISTRO_VHS.md` es una nota técnica previa dentro de la carpeta del mod. Este documento es el mapa principal del proyecto; conviene evitar mantener conteos divergentes en dos sitios.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sec-4-mec-002-relatos-y-aprendizaje-progresivo"></a>
## <span style="color:#ffff00">4. MEC-002 — Relatos y aprendizaje progresivo</span>

<a id="sub-4-mec-002-relatos-y-aprendizaje-progresivo-que-hace-en-el-juego"></a>
### Qué hace en el juego

El aprendizaje está ligado a la finalización completa de dos medios concretos, no a recoger el cassette ni simplemente iniciar su reproducción:

| Medio completado | Efecto registrado en `player:getModData().KineticDeadKnowledge` | Resultado |
|---|---|---|
| `CazadoresMuertos01` | `captura = true` | Habilita la opción para someter zombis. |
| `CazadoresMuertos02` | `rueda = true` | Añade `Rueda_Estructura` a las recetas conocidas y habilita la opción contextual de la rueda. |

`reproductor_tele.lua` rastrea la reproducción al llamar al método original de `ISRadioAction:performTogglePlayMedia`. En cada tick, `hasListenedToAll()` determina si se escucharon todas las líneas del medio rastreado. `KineticDeadGrantLearning()` aplica el aprendizaje una sola vez por personaje y muestra el mensaje correspondiente.

La receta de la rueda también declara `NeedToBeLearn = true` en su definición de entidad. Por lo tanto, según el código, la intención es que la receta se aprenda al completar `CazadoresMuertos02`. La persistencia exacta del dato y del aprendizaje requiere comprobarla en juego y en multijugador.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-4-mec-002-relatos-y-aprendizaje-progresivo-implementacion-y-referencias"></a>
### Implementación y referencias

- [reproductor_tele.lua](#archivo-reproductor-tele) — `ISRadioAction:performTogglePlayMedia`, `KineticDeadGrantLearning` y el manejador `Events.OnTick` que llama `hasListenedToAll()`.
- [CatBR_Client.lua](#archivo-catbr-client) — `onMenu` revisa `KineticDeadKnowledge.captura` antes de ofrecer someter un zombi.
- [animacion_rueda.lua](#archivo-animacion-rueda) — `KineticDeadWheelCaptiveMenu` revisa `KineticDeadKnowledge.rueda` antes de mostrar “Meter dentro de rueda”.
- [entity_carpentry_estructurarueda.txt](#archivo-entidad-rueda) — `CraftRecipe` exige aprendizaje para construir la rueda.
- [IG_UI_ES.txt](#archivo-ig-ui-es) — textos de aprendizaje en español.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-4-mec-002-relatos-y-aprendizaje-progresivo-verificacion-pendiente"></a>
### Verificación pendiente

- Reproducir cada cinta hasta el final y comprobar que el desbloqueo ocurre una vez.
- Comprobar que la opción de someter aparece tras el primer relato y la receta/menú de la rueda tras el segundo.
- Salir y volver a entrar, y probar en servidor, para verificar persistencia y sincronización.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sec-5-mec-003-cautiverio-de-zombis"></a>
## <span style="color:#ffff00">5. MEC-003 — Cautiverio de zombis</span>

<a id="sub-5-mec-003-cautiverio-de-zombis-que-hace-en-el-juego"></a>
### Qué hace en el juego

El cautiverio proviene del módulo integrado CatBR. El jugador aprende la mecánica con el primer VHS de Logan. El código busca zombis cercanos y presenta opciones contextuales según el estado del zombi. Para dominar uno, el personaje debe estar agachado, a no más de 1,3 tiles y llevar uno de los objetos aceptados como grillete o cuerda. El objeto se consume al dominarlo y se devuelve al liberar al zombi.

Los zombis dominados pueden ser conducidos con una `Base.Rope`, amarrados a un punto, calmados o enfurecidos, y liberados. El estado global de las amarras se almacena con `ModData` y se sincroniza mediante comandos cliente-servidor.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-5-mec-003-cautiverio-de-zombis-reglas-y-estado-tecnico"></a>
### Reglas y estado técnico

- Distancia para detectar el menú: `CatBR.Config.DIST_MENU = 2.5`.
- Dominar: requiere sigilo/agacharse, cercanía de hasta 1,3 y un objeto de `CatBR.Config.ALGEMAS`.
- Conducir: requiere `Base.Rope`; `SEGUE`, `PARA` y `CORDA_MAX` controlan seguimiento y separación máxima.
- Amarrar a un punto consume una cuerda; liberar devuelve la cuerda y el objeto usado para dominar.
- `setUseless(true/false)` es parte del mecanismo utilizado para fijar o activar el zombi. La conducta exacta depende del motor de Project Zomboid.
- Acciones visuales de mochila y amputación aparecen comentadas o deshabilitadas en el menú; no deben documentarse como funciones disponibles.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-5-mec-003-cautiverio-de-zombis-archivos-y-funciones"></a>
### Archivos y funciones

| Etapa | Referencia | Responsabilidad |
|---|---|---|
| Configuración y datos comunes | [CatBR_Shared.lua](#archivo-catbr-shared) — `CatBR.Config`, `CatBR.dados`, `CatBR.acharAlgema`, `CatBR.idAmarra` | Lista objetos admitidos, distancias, clave de ModData y utilidades. |
| Menús e interacción | [CatBR_Client.lua](#archivo-catbr-client) — `onMenu`, `dominarZumbi`, `conduzirZumbi`, `amarrarZumbi`, `libertarZumbi` | Muestra opciones y ejecuta dominar, conducir, amarrar y liberar. |
| Integración directa con rueda | [CatBR_Client.lua](#archivo-catbr-client) — `CatBR.amarrarEnRueda`, `CatBR.colocarEnRueda` | Registra el cautivo en el punto de rueda, actualiza `CatBRRueda` y `bMoving`, elimina visuales de cuerda en la transición. |
| Control periódico | [CatBR_Client.lua](#archivo-catbr-client) — `controlar`, `grampoAmarra`, evento `OnPlayerUpdate` | Mantiene el comportamiento local del zombi atado y recupera referencias cercanas. |
| Sincronización | [CatBR_Server.lua](#archivo-catbr-server) — `Cmd.Amarrar`, `Cmd.Desamarrar`, `Cmd.AmarraBrava`, `Cmd.PedirEstado` | Actualiza la tabla global y aplica el estado del zombi en servidor. |
| Traducciones | [ContextMenu_ES.txt](#archivo-contextmenu-es), [ContextMenu_EN.txt](#archivo-contextmenu-en) | Etiquetas y consejos del menú contextual. |

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-5-mec-003-cautiverio-de-zombis-integracion-y-limites"></a>
### Integración y límites

La documentación de Trello describe que se integró Zombie Leash & Lead BR para reutilizar animaciones, modelos y recursos. En la copia examinada hay recursos `anims_X`, `models_X`, `clothing` y `AnimSets` dentro de `media`, además de lógica CatBR propia. No hay en `mod.info` una dependencia declarada; se debe comprobar si el contenido está embebido por completo o si alguna parte espera otro mod activo.

La lista exportada de Trello contiene incidencias sobre uso de sogas al mismo tiempo que un zombi está en la rueda y sobre persistencia de la animación al cargar o descargar chunks. Se documentan abajo como reportes pendientes de reproducción, no como errores confirmados en esta revisión.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sec-6-mec-004-rueda-cinetica"></a>
## <span style="color:#ffff00">6. MEC-004 — Rueda cinética</span>

<a id="sub-6-mec-004-rueda-cinetica-construccion"></a>
### Construcción

La rueda se declara como entidad de carpintería `Base.Rueda_Estructura`. La receta integrada pide nivel 1 de Carpintería, un martillo (se conserva y puede degradarse), seis tablas, cuatro clavos y un colchón. `NeedToBeLearn = true`; el aprendizaje se intenta otorgar tras completar `CazadoresMuertos02`.

- [Definición de entidad y receta](#archivo-entidad-rueda)
- [Skin XUI de la entidad](#archivo-skin-rueda)
- [Definiciones de tiles](#archivo-tiles-rueda)
- [Configuración del pack de textura](#archivo-config-pack-rueda)
- [Textura empaquetada de la rueda](#archivo-pack-rueda)

La receta usa `Base.Mattress`. La tarjeta de Trello “Corregir receta de fabricación rueda” señala que quieren sustituir materiales para que la construcción sea coherente y refleje conocimientos de electrónica. Esa corrección no está implementada en la receta examinada y debe tratarse como pendiente de diseño.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-6-mec-004-rueda-cinetica-meter-al-zombi-dentro"></a>
### Meter al zombi dentro

Hay dos recorridos para introducir un zombi:

1. **Zombi que el jugador conduce con cuerda:** `CatBR_Client.lua` detecta que el clic fue sobre una rueda y añade “Meter dentro de rueda”. Al elegirla llama `CatBR.amarrarEnRueda()`, que consume la cuerda, registra el zombi en la rueda, lo coloca en la casilla interior y activa la animación mediante `KineticDeadStartWheelNearSquare()`.
2. **Zombi ya amarrado cerca de la rueda:** `KineticDeadWheelCaptiveMenu()` identifica la estructura con `AnimRueda.Diccionario`, verifica `KineticDeadKnowledge.rueda`, calcula el punto interior con `KineticDeadWheelCaptiveSquare()`, localiza el zombi con `KineticDeadFindBoundZombie()` y ofrece la misma opción. Al elegirla, llama `CatBR.colocarEnRueda()` y `KineticDeadStartWheelAt()`.

`CatBR.colocarEnRueda()` cambia el punto de amarre del cautivo, limpia la cuerda visual anterior y establece `CatBRRueda = true`, `bPathfind = false` y `bMoving = true`. `CatBR.amarrarEnRueda()` realiza la transición directa desde el modo de conducción y también registra la rueda como nueva amarra. En ambos recorridos, la intención es que el zombi camine en el sitio dentro de la estructura.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-6-mec-004-rueda-cinetica-posicion-y-animacion"></a>
### Posición y animación

`KineticDeadWheelCaptiveSquare()` detecta el área ocupada por los tiles, calcula el centro y aplica ajustes por orientación y por `AnimRueda.OffsetCautivo`. El ajuste de depuración `KineticDeadSetWheelCaptiveOffset(x, y)` permite cambiar el desplazamiento para la sesión de prueba. La animación recorre cuadros definidos en `animacion_rueda.lua`; la lista `AnimRueda.activas` mantiene las ruedas activas localmente.

- [Animación y menú contextual](#archivo-animacion-rueda) — `KineticDeadSetWheelCaptiveOffset`, `KineticDeadStartWheelAt`, `KineticDeadStartWheelNearSquare`, `KineticDeadStopWheelForZombie`, `AnimRueda.OnTick`, `KineticDeadWheelCaptiveSquare`, `KineticDeadFindBoundZombie`, `KineticDeadWheelCaptiveMenu`.
- [Estados del zombi y liberación](#archivo-catbr-client) — `CatBR.colocarEnRueda`, `CatBR.amarrarEnRueda`, `libertarZumbi`, `grampoAmarra`.
- [Rótulos y tips en español](#archivo-contextmenu-json-es).

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-6-mec-004-rueda-cinetica-menu-de-controles"></a>
### Menú de controles

En `animacion_rueda.lua` permanece comentada la conexión del menú general anterior (`Events.OnFillWorldObjectContextMenu.Add(RuedaContextMenu)`). La conexión activa del menú para meter al zombi es `KineticDeadWheelCaptiveMenu`. El código de controles generales y sus textos existe, pero su disponibilidad depende de que la conexión comentada siga sin activarse.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-6-mec-004-rueda-cinetica-incidencias-y-verificacion"></a>
### Incidencias y verificación

El CSV de Trello contiene estos reportes asociados a la rueda:

| Reporte | Prioridad en CSV | Referencia del código relacionada | Estado documental |
|---|---|---|---|
| El zombi puede salir de posición durante la animación | Media | `KineticDeadWheelCaptiveSquare`, `CatBR.colocarEnRueda`, `AnimRueda.OnTick` | Pendiente de reproducir y confirmar. |
| Zombis rompen tiles, pero la estructura no se elimina como se espera | Alta | Definiciones de entidad/tiles y lógica de daño del mundo | Requiere localizar la interacción exacta y probar. |
| La rueda o animación se detiene al cargar/descargar chunks y hay que meter al zombi de nuevo | Crítica | `AnimRueda.activas` es una lista en memoria; estado del cautivo está en ModData | Pendiente de resolver y probar persistencia. |
| La cuerda integrada se comporta de forma confusa al intentar atar otro zombi | Alta | `CatBR_Client.lua`, `CatBR.amarrarEnRueda`, lógica de `fantasmaConducir` | Pendiente de reproducir con dos zombis. |
| Receta actual usa colchón y requiere revisión de conocimientos/materiales | Baja | `entity_carpentry_estructurarueda.txt` | Pendiente de decisión e implementación. |

La animación visual de la rueda y la animación de caminar del zombi son sistemas distintos: `animacion_rueda.lua` cambia los tiles de la estructura; `CatBR_Client.lua` configura la variable `bMoving` del cautivo. La documentación no asume que esta animación equivalga a producción eléctrica efectiva: en los archivos revisados no se encontró una mecánica que calcule watts o alimente aparatos.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sec-7-mec-005-reproduccion-audiovisual-en-televisores"></a>
## <span style="color:#ffff00">7. MEC-005 — Reproducción audiovisual en televisores</span>

<a id="sub-7-mec-005-reproduccion-audiovisual-en-televisores-que-hace-en-el-juego"></a>
### Qué hace en el juego

`TV_Animator.lua` precarga y muestra cuadros de videos en televisores compatibles, registra pantallas animadas y expone opciones para activar videos o televisores en un área. `reproductor_tele.lua` intercepta acciones de reproducción, detiene audio al parar/apagar el dispositivo y administra volumen según distancia para medios personalizados.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-7-mec-005-reproduccion-audiovisual-en-televisores-archivos-y-funciones"></a>
### Archivos y funciones

- [TV_Animator.lua](#archivo-tv-animator) — `CustomTVTest.PreloadAll`, `CustomTVTest.Start`, `CustomTVTest.LoadFrame`, `CustomTVTest.OnTick`, `TVTestMenu`, `ISMoveablesAction:start`, `ISMoveablesAction:complete`, `CustomTVTest.ActivarTVsEnRadio`, `AreaTVMenu`.
- [reproductor_tele.lua](#archivo-reproductor-tele) — `ISRadioAction:performTogglePlayMedia`, `FrenarAudio`, `VigilarCintasTerminadas`, volumen y fin de reproducción.
- [Texturas y packs audiovisuales](#recursos-paquetes-audiovisuales) — paquetes `.pack` y definiciones `.txt` para `boondocks`, `joven`, `noticiero`, `ricardo_milos`, `rickroll`, `trailer` y `walkin`.
- [Audios](#recursos-audio) — recursos `.ogg` asociados a los medios.

Debe probarse en juego la relación entre el ID de cada medio, el nombre del video, el sprite de televisor admitido y los nombres de los recursos. Esta revisión estática no confirma resolución, escala ni sincronización audiovisual.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sec-8-mec-006-traducciones-y-recursos"></a>
## <span style="color:#ffff00">8. MEC-006 — Traducciones y recursos</span>

<a id="sub-8-mec-006-traducciones-y-recursos-traducciones-detectadas"></a>
### Traducciones detectadas

Hay traducciones en español (`ES`), inglés (`EN`), portugués (`PT`) y portugués brasileño (`PTBR`) dentro de [archivos de traducción](#recursos-traducciones). Los rótulos incluyen aprendizaje, acciones de cautiverio, controles de rueda y la opción “Meter dentro de rueda”. No se hizo validación automática de todos los JSON ni comparación exhaustiva de claves entre idiomas.

- [Traducciones ES](#recursos-traducciones-es)
- [Traducciones EN](#recursos-traducciones-en)
- [Traducciones PT](#recursos-traducciones-pt)
- [Traducciones PTBR](#recursos-traducciones-ptbr)

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-8-mec-006-traducciones-y-recursos-recursos-principales"></a>
### Recursos principales

| Ruta | Contenido/uso |
|---|---|
| [Portadas VHS](#recursos-portadas-vhs) | Portadas de VHS de Logan, LoganC, Ruiz y Thorne. |
| [Portadas cinéticas](#recursos-portadas-cineticas) | Portadas promocionales cuadradas y rectangulares. |
| [Texturas CatBR](#recursos-texturas-catbr), [CatBRCoto](#recursos-texturas-catbrcoto) y [Body](#recursos-texturas-body) | Texturas del módulo de cautiverio y recursos visuales. |
| [AnimSets de zombis](#recursos-animsets) | AnimSets para zombi preso y zombi en rueda. |
| [Animaciones](#recursos-modelos), [modelos](#recursos-models) y [ropa](#recursos-clothing) | Animaciones, modelos y definiciones de ropa integradas. |
| [Paquetes audiovisuales y audio](#recursos-paquetes-audiovisuales) | Secuencias y audio de las películas VHS. |
| [Entidad de rueda](#archivo-entidad-rueda) | Entidad de carpintería y receta de la rueda. |
| [fileGuidTable.xml](#archivo-guid-table) | Tabla de GUIDs asociada con los recursos. |

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sec-9-integraciones-ideas-y-tareas-de-trello"></a>
## <span style="color:#ffff00">9. Integraciones, ideas y tareas de Trello</span>

Esta sección reúne el CSV exportado el 2026-10-15 y las propuestas del GDD v6. Las tarjetas de backlog y el GDD describen trabajo futuro, no funciones implementadas. Los reportes de bugs son observaciones del equipo y deben revalidarse con la versión actual.

<a id="sub-9-integraciones-ideas-y-tareas-de-trello-integraciones-o-tareas-marcadas-como-completadas-en-el-csv"></a>
### Integraciones o tareas marcadas como completadas en el CSV

- Integración de Zombie Leash & Lead BR para animaciones y recursos del cautiverio.
- Módulo de registro y distribución VHS.
- Menú contextual de la rueda para insertar/liberar o controlar interacciones.
- Tres líneas narrativas conectadas y 48 entradas de historia en la implementación actual.
- Texturas específicas de las cintas VHS.
- Primera rueda 2D empaquetada como tiles de Build 42.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-9-integraciones-ideas-y-tareas-de-trello-bugs-reportados-en-el-csv"></a>
### <span style="color:#c00000">Bugs reportados en el CSV</span>

El CSV contiene cuatro incidencias en la lista **Bugs**. Cada tabla resume el contexto, la corrección propuesta, las referencias técnicas y el criterio para cerrar el reporte. El código sigue sin modificarse para estas correcciones. Cambia `☐ Pendiente` por `☑ Completado` después de corregir y verificar el bug en juego.

#### <span style="color:#c00000">Bug 1 — Posición dentro de la rueda</span>

| Campo | Detalle |
|---|---|
| Estado | ☐ Pendiente |
| Prioridad | Media |
| Contexto del bug | Al girar la rueda o durante otras situaciones, el zombi puede salir del punto interior y conservar la animación de movimiento fuera de la estructura. |
| Corrección propuesta | Mantener las coordenadas objetivo del cautivo y reaplicarlas mientras siga asignado a la rueda. Desactivar la búsqueda de camino (`bPathfind = false`) y conservar la animación de movimiento (`bMoving = true`). Verificar las orientaciones sur y oeste. |
| Código relacionado | [CatBR_Client.lua](#archivo-catbr-client): `CatBR.colocarEnRueda`, `CatBR.amarrarEnRueda`, `grampoAmarra`. [animacion_rueda.lua](#archivo-animacion-rueda): `AnimRueda.OnTick`. |
| Criterio de cierre | El zombi permanece en la casilla interior durante varios ciclos de animación, en ambas orientaciones y tras alejarse y volver a acercarse a la rueda. |

#### <span style="color:#c00000">Bug 2 — Tiles rotos</span>

| Campo | Detalle |
|---|---|
| Estado | ☐ Pendiente |
| Prioridad | Alta |
| Contexto del bug | Los ataques pueden romper tiles de la rueda sin que las demás piezas o el estado de la estructura se actualicen de forma coherente. |
| Corrección propuesta | Identificar cómo se aplica daño a las piezas de entidades multi-tile. Sincronizar la destrucción de una pieza con las demás y limpiar la entidad y su animación cuando la rueda ya no exista. Confirmar si hace falta modificar Lua, la entidad o ambos; no se identificó aún una función Lua de daño específica del mod. |
| Código relacionado | [entity_carpentry_estructurarueda.txt](#archivo-entidad-rueda), [rueda_tiledefinitions.tiles.txt](#archivo-tiles-rueda) y [animacion_rueda.lua](#archivo-animacion-rueda). |
| Criterio de cierre | Destruir una pieza deja todas las piezas restantes y el estado de la rueda en una condición coherente, sin referencias o animaciones huérfanas. |

#### <span style="color:#c00000">Bug 3 — La soga integrada no cambia de zombi</span>

| Campo | Detalle |
|---|---|
| Estado | ☐ Pendiente |
| Prioridad | Alta |
| Contexto del bug | Si ya hay un zombi asignado a la rueda, intentar amarrar otro con la soga integrada puede fallar o mostrar una interacción confusa. |
| Corrección propuesta | Separar el estado de la cuerda que conduce al zombi actual del estado de cada amarra existente. Asegurar que la acción sobre la rueda opere sobre el zombi seleccionado y que limpiar o reutilizar el fantasma de cuerda no borre el vínculo de otro cautivo. |
| Código relacionado | [CatBR_Client.lua](#archivo-catbr-client): `conduzirZumbi`, `amarrarZumbi`, `CatBR.amarrarEnRueda`, `CatBR.colocarEnRueda`, `fantasmaConduzir`, `fantasmasAmarra`. [CatBR_Server.lua](#archivo-catbr-server): comandos `Amarrar` y `Desamarrar`. |
| Criterio de cierre | Conducir o amarrar un segundo zombi no cambia el estado ni la interacción del zombi que ya está en la rueda. |

#### <span style="color:#c00000">Bug 4 — La rueda se detiene al cargar o descargar chunks</span>

| Campo | Detalle |
|---|---|
| Estado | ☐ Pendiente |
| Prioridad | Crítica |
| Contexto del bug | Al alejarse de la zona y regresar, la rueda o la animación del zombi puede detenerse y requerir que el jugador vuelva a meterlo. |
| Corrección propuesta | Al cargar de nuevo el área, reconstruir las ruedas activas desde el estado persistente de las amarras. Evitar depender solo de `AnimRueda.activas`, que vive en memoria del cliente, y prevenir registros duplicados. Antes de implementar, identificar el evento de carga de zona o chunk adecuado para Build 42. |
| Código relacionado | [animacion_rueda.lua](#archivo-animacion-rueda): `AnimRueda.activas`, `KineticDeadStartWheelAt`, `KineticDeadStartWheelNearSquare`, `AnimRueda.OnTick`. [CatBR_Client.lua](#archivo-catbr-client): control y restauración de `CatBR.dados().amarras`. [CatBR_Shared.lua](#archivo-catbr-shared): almacenamiento compartido. |
| Criterio de cierre | La rueda reanuda su animación al regresar al área, sin volver a meter al zombi y sin duplicar ruedas activas. |
🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-9-integraciones-ideas-y-tareas-de-trello-ideas-y-trabajo-futuro"></a>
### Ideas y trabajo futuro

| Tarjeta/idea | Área | Estado observado y siguiente decisión |
|---|---|---|
| Cuadro informativo de rueda: watts, consumo, durabilidad y estado del zombi | UI / mecánica | Idea. No se encontró cálculo de energía en el código revisado; definir primero reglas y fuente de energía. |
| Corregir receta de rueda y requerir conocimiento de electrónica | Receta/progresión | Backlog. Elegir materiales y nivel/rasgo antes de editar la definición. |
| Modelo 3D de rueda y nuevas animaciones/perspectivas | Arte | En desarrollo según Trello; la implementación examinada contiene tiles 2D y recursos de cautiverio, no confirma que el modelo 3D esté integrado. |
| Herramienta para recortar automáticamente tiles grandes | Herramientas | Pendiente de documentar y publicar en un repositorio del proyecto. |
| Crear repositorio GitHub del equipo | Organización | Idea/backlog; definir visibilidad y flujo de colaboración. |
| Bastón con soga tipo collar para conducir zombis y fijarlos en rejas | Mecánica | Idea futura; requiere diseño de alcance, equilibrio y compatibilidad con caballo/rejas. |
| Canales Discord por roles | Organización | Tarea de coordinación, fuera de las mecánicas del mod. |

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sub-9-integraciones-ideas-y-tareas-de-trello-gdd-v6-zombie-generation"></a>
### GDD v6 — Kinetic Dead: Zombie Generation

> **Estado:** propuesta de diseño; no implementada en el código revisado.  
> **Fuente:** `Kinetic_Dead_Zombie_Generation_GDD_v6.pdf`, recibido para análisis. El original no está incluido en la carpeta de Workshop.

El GDD amplía la idea de capturar zombis para convertirlos en fuerza de trabajo, energía y recursos defensivos. Sus módulos deben tratarse como propuestas que amplían el sistema actual, no como funciones disponibles en el juego.

| Área | Propuesta del GDD | Relación con el mod actual y trabajo pendiente |
|---|---|---|
| Aprendizaje y lore | Una cinta VHS de “Cazadores de Muertos: Guía Práctica (Ep. 01)” enseñaría todas las recetas del mod; aparecería raramente en videoclubes, estantes, librerías y talleres. | **Difiere de la progresión actual** ([MEC-002](#sec-4-mec-002-relatos-y-aprendizaje-progresivo)): `CazadoresMuertos01` enseña captura y `CazadoresMuertos02` enseña la rueda. Decidir si se conserva el aprendizaje progresivo o si se cambia a una sola cinta. También falta diseñar la contraportada y validar contenedores y rareza. |
| Captura, sometimiento e inventario | Derribar al zombi, atarle brazos con cuerda o cordel pesado y usar un trapo como bozal. Añadir “Someter y Atar Zombi”, abrir el inventario individual para retirar equipo y permitir cargarlo como objeto de aproximadamente 25 kg. | Amplía el cautiverio existente ([MEC-003](#sec-5-mec-003-cautiverio-de-zombis)). El código actual tiene conducción y amarras, pero el flujo de zombi derribado, el bozal, el saqueo mediante inventario y el objeto transportable deben diseñarse e implementarse. Revisar persistencia, sincronización y exploits en multijugador. |
| Generador cinético | Rueda para hasta tres zombis, con demanda y salida en watts y estado de vitalidad por cautivo. La receta propuesta usa tubos de metal (4), tornillos (10), tablas (6), engranajes (2), cuerda o correa (2), batería de auto (1) y cables (4); requiere destornillador, llave inglesa, sierra, Carpintería 2 y Electricidad 2. | **Amplía y cambia la rueda actual** ([MEC-004](#sec-6-mec-004-rueda-cinetica)): hoy existe la estructura y su animación, pero no se encontró generación eléctrica, lectura de consumo, panel de watts, vitalidad ni capacidad de tres cautivos. La receta actual también difiere; acordar materiales y niveles antes de editarla. |
| Eficiencia y mantenimiento | Aplicar aceite de motor o grasa; quitar ropa para obtener +15% de generación; fabricar un látigo de cuero que aumente temporalmente la salida entre 25% y 50%, drenando la vitalidad del zombi. El esfuerzo continuo puede matarlo. | No existe este cálculo energético ni desgaste en el código revisado. Definir fórmula de generación, ritmo de desgaste, límites de mantenimiento y balance del látigo. Aclarar si el bono por quitar ropa se acumula con otros efectos. |
| Estacas perimetrales | Crear un punto para dejar zombis encadenados como reserva, alarma o señuelo; receta propuesta: estaca de madera o metal, cadena y tornillos. | No se encontró una estructura de reserva ni comportamiento de alarma equivalente. Diseñar estados de estacionamiento, seguridad, sonido/atracción de hordas y liberación o intercambio con la rueda. |
| Transporte en vehículos | Llevar zombis sometidos como carga en camionetas, maleteros y remolques. | No se encontró integración para transportar un zombi como carga. Definir compatibilidad por tipo de vehículo, capacidad, peso, guardado y recuperación del cautivo antes de implementar. |
| Base técnica | Comprobar proximidad y estado derribado (`isProne()`); crear un ítem/entidad `CapturedZombie` con peso configurable; abrir su inventario; añadir una interfaz para la rueda. | Es una guía de trabajo, no implementación existente. Antes de crear el ítem cautivo, decidir si el zombi se convierte temporalmente en objeto o se mantiene como entidad del mundo; esa elección afecta inventario, salvado, multijugador y compatibilidad con vehículos. |

**Decisiones recomendadas antes de convertir el GDD en tareas de desarrollo:** definir la progresión VHS; cerrar receta y habilidades de la rueda; especificar cómo se calcula y conecta la electricidad a la red de la base; y acordar el modelo de persistencia/transporte del zombi sometido. Después se pueden dividir las propuestas en tareas de cautiverio, rueda/generación, estacas y vehículos.


<a id="sec-10-como-mantener-este-documento"></a>
## <span style="color:#ffff00">10. Cómo mantener este documento</span>

Cuando se añada o modifique una integración:

1. Actualizar la ficha de la mecánica afectada para describir su comportamiento actual.
2. Añadir o corregir la fila de archivo y función/evento/definición responsable.
3. Actualizar relaciones entre mecánicas si cambian sus requisitos o el flujo de progresión.
4. Añadir una entrada en el historial, enlazada al ID de mecánica.
5. Marcar como **pendiente de prueba** lo que no se haya comprobado dentro del juego.
6. Mover una idea a implementada solo después de confirmar los archivos y el comportamiento resultante.

Las funciones se identifican por nombre y archivo; no se usan números de línea como referencia estable porque cambian con las ediciones.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sec-11-historial-de-cambios"></a>
## <span style="color:#ffff00">11. Historial de cambios</span>

El registro de cambios del proyecto se mantiene en [CAMBIOS.md](CAMBIOS.md), separado de esta documentación funcional. Cada entrada enlaza la mecánica afectada con archivos y funciones modificadas.

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>

<a id="sec-12-glosario"></a>
## <span style="color:#ffff00">12. Glosario</span>

| Término | Significado en este proyecto |
|---|---|
| `RecMedia` | Tabla de medios reproducibles de Project Zomboid usada para registrar relatos y películas. |
| `MediaCategory` | Categoría declarada por el objeto VHS y por el registro multimedia para permitir asignación compatible. |
| Cinta LoganC | VHS narrativo especial de la categoría `LoganC-VHS`, seleccionado con peso 2 en la distribución documentada. |
| ModData | Datos asociados al jugador, zombi o mundo para conservar estados del mod. |
| Cautivo | Zombi dominado o amarrado que conserva datos CatBR y puede interactuar con la rueda. |
| Wheel/captive offset | Ajuste X/Y que modifica el cuadrado elegido para colocar al zombi dentro de la rueda. |
| Tile | Pieza gráfica isométrica que representa parte de la rueda construida. |
| Chunk | Región del mundo que el juego carga o descarga según proximidad y estado. |

🟡 <a href="#indice-de-secciones" style="color:#b8860b">Volver al índice</a>


