# Registro de VHS en KINETIC-DEAD

Se adoptó el mismo patrón que `C:\Users\User\Zomboid\mods\VHS_VIDEO_REPRODUCTION`:

1. `media/lua/shared/recorded_media.lua` registra cada contenido como `RecMedia["id"]`, con título, líneas y `category`.
2. Cada cassette físico declara `MediaCategory` en un archivo de `media/scripts`.
3. `media/lua/server/Items/VHS_Distribucion.lua` elige un registro de esa categoría y lo enlaza al cassette con `setRecordedMediaData()`.
4. El generador ahora verifica que la categoría real del registro coincida con la categoría del tipo de cassette antes de crearlo.

Correspondencia de KINETIC-DEAD:

- `Base.VHS_Animado` → `Animado-VHS` → las siete películas integradas.
- `Base.VHS_Logan` → `Logan-VHS` → 18 cintas.
- `Base.VHS_Ruiz` → `Ruiz-VHS` → 9 cintas.
- `Base.VHS_Thorne` → `Thorne-VHS` → 21 cintas.

Los diálogos son líneas de `RecMedia`; los VHS de relatos no se tratan como películas con sonido/animación salvo que exista contenido audiovisual con el mismo ID.
