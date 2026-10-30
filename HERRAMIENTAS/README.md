# Empaquetador de tiles isométricos

Herramientas en Python para recortar imágenes en tiles, alinear y ensamblar sus partes, y generar spritesheets para pruebas en Project Zomboid. El proyecto incluye un procesamiento por lotes y un script independiente para previsualizar animaciones por frames.

> **Estado:** proyecto de pruebas. `PIPELINE.py` conserva fases y experimentos individuales; el flujo automatizado por lote está en `SCRIPT_FINAL.py`.

## Contenido

- [Estructura del proyecto](#estructura-del-proyecto)
- [Requisitos](#requisitos)
- [Preparar las imágenes](#preparar-las-imágenes)
- [Generar el spritesheet](#generar-el-spritesheet)
- [Probar una animación](#probar-una-animación)
- [Archivos de referencia](#archivos-de-referencia)
- [Notas](#notas)

## Estructura del proyecto

```text
SUBIR DISCORD/
├── entrada_lote/                 # PNG que procesará el lote
├── fase5_resultados/
│   ├── fondo_transparente.png    # Lienzo base usado por el script final
│   ├── fondo.png                 # Fondo de referencia/prueba
│   ├── MODELO.png                # Imagen de referencia
│   └── 2x/                       # Destino de los resultados del lote
├── salida_maestra/               # Resultado de pruebas anteriores
├── VIDEO/                        # Frames y materiales para la prueba visual
│   └── VERSION ANTERIOR/         # Copia de frames de una versión previa
├── PIPELINE.py                   # Funciones y pruebas de las fases del proceso
├── SCRIPT_FINAL.py               # Procesamiento automático de imágenes por lote
├── prueba_animacion.py           # Previsualización de frames con Pygame
├── original.png                  # Imagen original de referencia
├── MODELO.png                    # Modelo visual
└── TILES.paint                   # Archivo editable con las capas de tiles
```

## Requisitos

- Python 3.
- Pillow, para leer, transformar y guardar imágenes.
- Pygame, solo para ejecutar la previsualización de animación.

Instala las dependencias desde una terminal:

```bash
python -m pip install Pillow pygame
```

Si solo vas a generar spritesheets, basta con Pillow:

```bash
python -m pip install Pillow
```

## Preparar las imágenes

1. Coloca en `entrada_lote/` los PNG que quieras procesar. El script recorre todos los archivos `.png` de esa carpeta; no necesita un nombre específico.
2. Conserva en `fase5_resultados/` el archivo `fondo_transparente.png`. Se utiliza como lienzo maestro para ensamblar los resultados.
3. Ejecuta los scripts desde la carpeta raíz `SUBIR DISCORD`, ya que las rutas de entrada y salida son relativas a esa ubicación.

## Generar el spritesheet

Desde la carpeta raíz del proyecto, ejecuta:

```bash
python SCRIPT_FINAL.py
```

El script divide cada imagen, extrae y alinea las secciones, ensambla las piezas y combina los resultados sobre el lienzo base. El archivo maestro se guarda en:

```text
fase5_resultados/2x/rueda.png
```

La salida contiene una versión normal y otra volteada para cada imagen procesada. El script genera una fila por PNG de entrada y elimina las carpetas temporales de cada imagen al terminar.

> La ruta del fondo, la carpeta de entrada y la salida están definidas al final de `SCRIPT_FINAL.py`. Si cambias la ubicación de esas carpetas, actualiza también esas rutas.

## Probar una animación

`prueba_animacion.py` abre una ventana con Pygame y reproduce los frames a 5 FPS. Ejecútalo desde la carpeta raíz:

```bash
python prueba_animacion.py
```

**Revisa los nombres de los frames antes de ejecutarlo.** El script busca `VIDEO/Rueda_01.png` hasta `VIDEO/Rueda_05.png`, pero los archivos presentes en `VIDEO/` se llaman `1_rueda.png` hasta `5_rueda.png`. Renombra los archivos o modifica la lista `ruta_frames` del script para que ambos coincidan.

## Archivos de referencia

| Archivo | Uso |
|---|---|
| `SCRIPT_FINAL.py` | Flujo completo de procesamiento por lotes y creación del spritesheet maestro. |
| `PIPELINE.py` | Funciones y pruebas manuales de las distintas fases del recorte y ensamblaje. |
| `prueba_animacion.py` | Reproducción visual de una secuencia de PNG mediante Pygame. |
| `VIDEO/renombrado_estrategico.py` | Ayuda para renombrar frames de la carpeta `VIDEO`. |
| `TILES.paint` | Proyecto editable con las capas de tiles. |
| `MODELO.png`, `original.png` | Referencias visuales para el trabajo de tiles. |
| `salida_maestra/rueda.png` | Resultado de una prueba anterior. |
| `fase5_resultados/2x/rueda.png` | Resultado generado por el script final, si ya se ejecutó. |

## Notas

- Usa PNG para conservar la transparencia de las imágenes.
- `salida_maestra/` y los archivos existentes dentro de `fase5_resultados/2x/` son resultados previos; el script final guarda su salida en `fase5_resultados/2x/rueda.png`.
- `CONTEXTO_PROYECTO.txt` contiene notas de análisis del proyecto y puede consultarse como material complementario.
