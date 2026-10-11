import os

# Carpeta donde están los archivos
carpeta = r"C:\Users\User\Zomboid\mods\VHS_VIDEO_REPRODUCTION\42\media\textures\rickroll"

# Texto que quieres agregar al inicio
prefijo = "rickroll_"

for archivo in os.listdir(carpeta):
    ruta_actual = os.path.join(carpeta, archivo)

    # Solo archivos
    if os.path.isfile(ruta_actual):
        nombre_nuevo = prefijo + archivo
        ruta_nueva = os.path.join(carpeta, nombre_nuevo)

        os.rename(ruta_actual, ruta_nueva)

print("Archivos renombrados correctamente.")