import os
import re

CARPETA = r"C:\Users\User\Desktop\prueba empaquetador\VIDEO"

# Busca:
# 1_rueda.png
# 1_rueda - copia.png
# 1_rueda - copia (2).png
# etc.
patron = re.compile(r"^(\d+)_rueda(?: - copia(?: \((\d+)\))?)?\.png$", re.IGNORECASE)

archivos = []

for nombre in os.listdir(CARPETA):
    coincidencia = patron.match(nombre)

    if coincidencia:
        numero_rueda = int(coincidencia.group(1))
        copia = coincidencia.group(2)

        # La original es la primera
        orden = 1 if copia is None and " - copia" not in nombre else (
            2 if " - copia.png" in nombre.lower() else int(copia) + 2
        )

        archivos.append((numero_rueda, orden, nombre))


# Ordenar por rueda y número de copia
archivos.sort(key=lambda x: (x[0], x[1]))

# Renombrar usando nombres temporales primero para evitar conflictos
temporales = []

for i, (rueda, orden, nombre_original) in enumerate(archivos):
    ruta_original = os.path.join(CARPETA, nombre_original)

    # Primer archivo: 1_rueda.png
    # Segundo:      1_rueda_2.png
    # Tercero:      1_rueda_3.png
    if orden == 1:
        nuevo_nombre = f"{rueda}_rueda.png"
    else:
        nuevo_nombre = f"{rueda}_rueda_{orden}.png"

    ruta_temporal = os.path.join(CARPETA, f"__TEMP__{i}.png")

    os.rename(ruta_original, ruta_temporal)
    temporales.append((ruta_temporal, nuevo_nombre))


# Renombrado definitivo
for ruta_temporal, nuevo_nombre in temporales:
    ruta_nueva = os.path.join(CARPETA, nuevo_nombre)

    if os.path.exists(ruta_nueva):
        os.remove(ruta_nueva)

    os.rename(ruta_temporal, ruta_nueva)

print("Renombrado completado.")