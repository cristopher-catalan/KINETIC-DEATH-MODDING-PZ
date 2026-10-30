#==================================================================================================================
import os
from PIL import Image

def fase1_recorte_asimetrico(ruta_imagen, carpeta_salida):
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    img = Image.open(ruta_imagen).convert("RGBA")
    ancho, alto = img.size

    x_derecha = ancho
    indice = 0

    while x_derecha > 0:
        # El primer corte (índice 0) es de 128px, el resto de 64px
        ancho_corte = 128 if indice == 0 else 64
        
        # Evitar valores negativos si la imagen no es múltiplo exacto
        x_izquierda = max(0, x_derecha - ancho_corte)

        # Extraer el fragmento
        fragmento = img.crop((x_izquierda, 0, x_derecha, alto))
        
        # Guardar manteniendo el orden de derecha a izquierda
        nombre_archivo = f"fragmento_{indice:03d}.png"
        ruta_guardado = os.path.join(carpeta_salida, nombre_archivo)
        fragmento.save(ruta_guardado)
        
        print(f"Corte {indice} generado: X({x_izquierda} a {x_derecha}) -> Ancho: {x_derecha - x_izquierda}px")

        # Actualizar el puntero para el siguiente ciclo
        x_derecha = x_izquierda
        indice += 1

# Ejecución de prueba
fase1_recorte_asimetrico("prueba.png", "salida")
#==================================================================================================================
import os
from PIL import Image

def fase2_traslacion_apoyo(ruta_imagen, ruta_salida, alto_lienzo_final=256):
    img = Image.open(ruta_imagen).convert("RGBA")
    ancho, alto = img.size

    # Calcular la coordenada X exacta a 64px desde la derecha
    # Si el fragmento mide 128, X será 64. Si mide 64, X será 0.
    x_linea = max(0, ancho - 64)

    # Cargar los datos de los píxeles para lectura rápida
    pixeles = img.load()
    y_choque = -1

    # Escanear de abajo hacia arriba en esa columna específica (x_linea)
    for y in range(alto - 1, -1, -1):
        alfa = pixeles[x_linea, y][3] # El índice 3 es el canal Alpha (transparencia)
        if alfa > 0:
            y_choque = y
            break

    # Si la columna entera es transparente, se guarda tal cual
    if y_choque == -1:
        print(f"[{os.path.basename(ruta_imagen)}] Columna X={x_linea} vacía. Se omite traslación.")
        img.save(ruta_salida)
        return

    # Calcular la diferencia para llegar a la base (píxel 255)
    y_base = alto_lienzo_final - 1
    desplazamiento_y = y_base - y_choque

    # Crear un lienzo nuevo y pegar la imagen desplazada
    lienzo_alineado = Image.new("RGBA", (ancho, alto_lienzo_final), (0, 0, 0, 0))
    lienzo_alineado.paste(img, (0, desplazamiento_y))

    lienzo_alineado.save(ruta_salida)
    
    print(f"[{os.path.basename(ruta_imagen)}] Píxel detectado en Y={y_choque}. "
          f"Trasladando {desplazamiento_y}px hacia abajo.")

# Ejecución de prueba
fase2_traslacion_apoyo("salida/fragmento_000.png", "salida1/fragmento_000_alineado.png")
#==================================================================================================================
import os
from PIL import Image, ImageDraw

def fase2_traslacion_y_recorte(ruta_imagen, carpeta_salida, alto_lienzo=256):
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    img = Image.open(ruta_imagen).convert("RGBA")
    ancho, alto = img.size

    # 1. Encontrar el punto de choque (x_linea está a 64px desde la derecha)
    x_linea = max(0, ancho - 64)
    pixeles = img.load()
    y_choque = -1

    # Escanear de abajo hacia arriba
    for y in range(alto - 1, -1, -1):
        if pixeles[x_linea, y][3] > 0: # Canal Alfa > 0
            y_choque = y
            break

    if y_choque == -1:
        print(f"[{os.path.basename(ruta_imagen)}] Columna vacía. Se omite.")
        return

    # 2. Trasladar la imagen para que el punto choque con el fondo (Y = 255)
    y_base = alto_lienzo - 1
    desplazamiento_y = y_base - y_choque

    lienzo_alineado = Image.new("RGBA", (ancho, alto_lienzo), (0, 0, 0, 0))
    lienzo_alineado.paste(img, (0, desplazamiento_y))

    # 3. Calcular coordenadas del rectángulo de 64 (ancho) x 32 (alto) hacia la izquierda
    x_izq_rect = x_linea - 64
    y_sup_rect = y_base - 32
    
    # Validar que exista espacio a la izquierda para hacer el corte
    if x_izq_rect < 0:
        print(f"[{os.path.basename(ruta_imagen)}] El bloque no tiene suficientes píxeles a la izquierda. Solo se alinea.")
        lienzo_alineado.save(os.path.join(carpeta_salida, f"{os.path.basename(ruta_imagen)}"))
        return

    # 4. Crear la máscara del triángulo isométrico (Relación 2x1)
    # Vértices: Punto base, esquina inferior izquierda, esquina superior izquierda del rectángulo
    mascara = Image.new("L", (ancho, alto_lienzo), 0)
    draw = ImageDraw.Draw(mascara)
    
    vertice_apoyo = (x_linea, y_base + 1)         # Ej: (64, 256)
    vertice_inf_izq = (x_izq_rect, y_base + 1)    # Ej: (0, 256)
    vertice_sup_izq = (x_izq_rect, y_sup_rect + 1)# Ej: (0, 224)
    
    # Dibujar el triángulo exacto a recortar
    draw.polygon([vertice_apoyo, vertice_inf_izq, vertice_sup_izq], fill=255)

    # 5. Extraer el triángulo a una nueva imagen (Pieza que "se pasa a la izquierda")
    pieza_extraida = Image.new("RGBA", (ancho, alto_lienzo), (0, 0, 0, 0))
    pieza_extraida.paste(lienzo_alineado, (0, 0), mascara)
    
    # Recortamos la caja exacta de 64x32 para que la imagen resultante no tenga píxeles vacíos inútiles
    pieza_final = pieza_extraida.crop((x_izq_rect, y_sup_rect + 1, x_linea, y_base + 1))

    # 6. Borrar ese triángulo del bloque principal dejando el hueco transparente
    transparente = Image.new("RGBA", (ancho, alto_lienzo), (0, 0, 0, 0))
    lienzo_alineado.paste(transparente, (0, 0), mascara)

    # 7. Guardar ambos archivos
    nombre_base = os.path.splitext(os.path.basename(ruta_imagen))[0]
    
    ruta_bloque_hueco = os.path.join(carpeta_salida, f"{nombre_base}_bloque_cortado.png")
    lienzo_alineado.save(ruta_bloque_hueco)
    
    ruta_pieza_extraida = os.path.join(carpeta_salida, f"{nombre_base}_triangulo_extraido.png")
    pieza_final.save(ruta_pieza_extraida)

    print(f"[{os.path.basename(ruta_imagen)}] Trasladado {desplazamiento_y}px abajo. Recorte de 64x32 guardado.")

# Ejecución
fase2_traslacion_y_recorte("salida/fragmento_000.png", "salida1")
#==================================================================================================================
#==================================================================================================================
#==================================================================================================================
#==================================================================================================================
#==================================================================================================================
#==================================================================================================================
#==================================================================================================================
#==================================================================================================================
#==================================================================================================================
#==================================================================================================================
#==================================================================================================================
import os
from PIL import Image, ImageDraw

def fase1_division_y_extraccion(ruta_imagen, carpeta_salida):
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    img = Image.open(ruta_imagen).convert("RGBA")
    ancho, alto = img.size

    x_derecha = ancho
    indice = 0

    while x_derecha > 0:
        ancho_corte = 128 if indice == 0 else 64
        x_izquierda = max(0, x_derecha - ancho_corte)

        # 1. Extraer el fragmento base
        fragmento = img.crop((x_izquierda, 0, x_derecha, alto))
        ancho_frag = fragmento.size[0]

        # 2. Detectar el pixel en X=64 (o el borde derecho si el fragmento es de 64)
        x_linea = 65 if ancho_frag > 65 else ancho_frag - 1
        pixeles = fragmento.load()
        y_choque = -1

        for y in range(alto - 1, -1, -1):
            if pixeles[x_linea, y][3] > 0: # Detectar pixel no transparente
                y_choque = y
                break

        # 3. Extraer el triángulo diagonal hacia la izquierda y ABAJO (64x32)
        if y_choque != -1 and x_linea >= 65:
            mascara_f1 = Image.new("L", (ancho_frag, alto), 0)
            draw = ImageDraw.Draw(mascara_f1)
            
            # Vértices: Origen (64, y), Diagonal Abajo-Izq (0, y+32), Esquina Sup-Izq (0, y)
            p_origen = (x_linea, y_choque)
            p_diag_inf = (x_linea - 64, y_choque + 32)
            p_esquina = (x_linea - 64, y_choque) 
            
            draw.polygon([p_origen, p_diag_inf, p_esquina], fill=255)

            # Recortar este fragmento específico
            fragmento_extraido_f1 = Image.new("RGBA", (ancho_frag, alto), (0, 0, 0, 0))
            fragmento_extraido_f1.paste(fragmento, (0, 0), mascara_f1)
            
            # Borrar el triángulo del bloque original para dejar el hueco
            transparente = Image.new("RGBA", (ancho_frag, alto), (0, 0, 0, 0))
            fragmento.paste(transparente, (0, 0), mascara_f1)
            
            # Guardar el triángulo extraído (recortando el recuadro exacto de 64x32)
            recorte_final_f1 = fragmento_extraido_f1.crop((x_linea - 64, y_choque, x_linea, y_choque + 32))
            recorte_final_f1.save(os.path.join(carpeta_salida, f"frag_{indice:03d}_extraido_abajo.png"))

        # --- INICIO MODIFICACIÓN: TRASLACIÓN A LA BASE ---
        alto_lienzo = 256
        if y_choque != -1:
            #y_base = alto_lienzo - 1
            desplazamiento_y = alto_lienzo - y_choque
            
            # Crear un nuevo lienzo con la altura final estandarizada
            lienzo_alineado = Image.new("RGBA", (ancho_frag, alto_lienzo), (0, 0, 0, 0))
            # Pegar el fragmento (que ya tiene el corte hecho) desplazado hacia abajo
            lienzo_alineado.paste(fragmento, (0, desplazamiento_y))
            
            # Reemplazar la variable fragmento con el nuevo lienzo alineado
            fragmento = lienzo_alineado 
        # --- FIN MODIFICACIÓN ---

        # Guardar el bloque principal (ahora alineado abajo)
        fragmento.save(os.path.join(carpeta_salida, f"frag_{indice:03d}_bloque.png"))
        
        print(f"Fase 1 - Corte {indice}: Y detectado={y_choque}. Trasladado {desplazamiento_y}px.")
        
        x_derecha = x_izquierda
        indice += 1

# Ejecución Fase 1
fase1_division_y_extraccion("1rotacion.png", "fase1_resultados")
#==================================================================================================================
import os
from PIL import Image, ImageDraw

def fase2_extraccion_y_union(carpeta_fase1, carpeta_salida, alto_lienzo=256):
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    # Buscar todos los bloques generados en la fase 1
    archivos_bloque = [f for f in os.listdir(carpeta_fase1) if f.endswith('_bloque.png')]

    for archivo_bloque in archivos_bloque:
        # Extraer el índice para encontrar el recorte correspondiente (ej: "frag_000")
        indice = archivo_bloque.split('_')[1]
        ruta_bloque = os.path.join(carpeta_fase1, archivo_bloque)
        ruta_triangulo_abajo = os.path.join(carpeta_fase1, f"frag_{indice}_extraido_abajo.png")

        bloque = Image.open(ruta_bloque).convert("RGBA")
        ancho, alto = bloque.size

        # Mantener la lógica de X adaptada a 65 píxeles de tu Script 1
        x_linea = 65 if ancho > 65 else ancho - 1

        # Si no existe el recorte de Fase 1 (no hubo choque o no dio el ancho), solo copiamos el bloque
        if not os.path.exists(ruta_triangulo_abajo) or x_linea < 65:
            bloque.save(os.path.join(carpeta_salida, f"frag_{indice}_final.png"))
            continue

        # 1. Extraer el triángulo hacia ARRIBA de la parte izquierda
        # Como el bloque ya fue trasladado a la base en la Fase 1, usamos el límite inferior del lienzo
        y_base = alto_lienzo 

        mascara_f2 = Image.new("L", (ancho, alto_lienzo), 0)
        draw = ImageDraw.Draw(mascara_f2)

        # Vértices (usando el desplazamiento de 65 de tu Script 1):
        # Origen inferior, Esquina Sup-Izq, Esquina Inf-Izq
        p_origen = (x_linea, y_base)
        p_sup_izq = (x_linea - 65, y_base - 32)
        p_inf_izq = (x_linea - 65, y_base)

        draw.polygon([p_origen, p_sup_izq, p_inf_izq], fill=255)

        triangulo_fase2 = Image.new("RGBA", (ancho, alto_lienzo), (0, 0, 0, 0))
        triangulo_fase2.paste(bloque, (0, 0), mascara_f2)

        # Recortar el recuadro exacto (ahora de 65x32 por tu modificación)
        recorte_arriba = triangulo_fase2.crop((x_linea - 65, y_base - 32, x_linea, y_base))

        # Borrar este triángulo del bloque original para dejar el segundo hueco transparente
        transparente = Image.new("RGBA", (ancho, alto_lienzo), (0, 0, 0, 0))
        bloque.paste(transparente, (0, 0), mascara_f2)

        # Guardar el bloque con ambos huecos listos (el de arriba y el de abajo)
        bloque.save(os.path.join(carpeta_salida, f"frag_{indice}_final.png"))

        # 2. UNIR LOS DOS TRIÁNGULOS (Fase 1 y Fase 2)
        triangulo_abajo = Image.open(ruta_triangulo_abajo).convert("RGBA")

        # Crear lienzo de 65x64 para acomodar ambos triángulos
        union = Image.new("RGBA", (64, 64), (0, 0, 0, 0))

        # Pegar el triángulo de la Fase 1 en la mitad superior (Y=0)
        union.paste(recorte_arriba, (0, 0))
        
        # Pegar el triángulo de la Fase 2 en la mitad inferior (Y=32)
        union.paste(triangulo_abajo, (0, 32))

        union.save(os.path.join(carpeta_salida, f"frag_{indice}_union_triangulos.png"))
        print(f"Fase 2 - Bloque {indice} procesado y uniones de 65x64 generadas.")

# Ejecución Fase 2 (Lee la carpeta donde la Fase 1 dejó sus archivos)
fase2_extraccion_y_union("fase1_resultados", "fase2_resultados")
#==================================================================================================================
import os
from PIL import Image

def fase3_traslacion_arriba(carpeta_entrada, carpeta_salida, indice_objetivo="002", desplazamiento=64):
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    # Identificar el archivo específico
    nombre_archivo = f"frag_{indice_objetivo}_final.png"
    ruta_imagen = os.path.join(carpeta_entrada, nombre_archivo)

    if not os.path.exists(ruta_imagen):
        print(f"Error: No se encontró el archivo '{nombre_archivo}' en la carpeta '{carpeta_entrada}'.")
        return

    # Cargar la imagen generada en la Fase 2
    img = Image.open(ruta_imagen).convert("RGBA")
    ancho, alto = img.size

    # Crear un nuevo lienzo transparente del mismo tamaño
    lienzo_elevado = Image.new("RGBA", (ancho, alto), (0, 0, 0, 0))

    # Para trasladar hacia arriba, usamos un valor negativo en el eje Y
    lienzo_elevado.paste(img, (0, -desplazamiento))

    # Guardar el resultado
    ruta_guardado = os.path.join(carpeta_salida, f"frag_{indice_objetivo}_elevado.png")
    lienzo_elevado.save(ruta_guardado)
    
    print(f"Fase 3 - Éxito: '{nombre_archivo}' fue trasladado {desplazamiento}px hacia arriba.")

# Ejecución Fase 3 (Lee la carpeta donde la Fase 2 dejó sus archivos)
fase3_traslacion_arriba("fase2_resultados", "fase3_resultados", indice_objetivo="002", desplazamiento=64)
#==================================================================================================================
import os
from PIL import Image

def fase4_unir_fragmentos(carpeta_entrada, carpeta_salida, archivo_izq="frag_001_final.png", archivo_der="frag_000_union_triangulos.png", offset_y=192):
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    ruta_izq = os.path.join(carpeta_entrada, archivo_izq)
    ruta_der = os.path.join(carpeta_entrada, archivo_der)

    if not os.path.exists(ruta_izq) or not os.path.exists(ruta_der):
        print(f"Error: Asegúrate de que {archivo_izq} y {archivo_der} existan en '{carpeta_entrada}'.")
        return

    # Cargar ambas imágenes
    img_izq = Image.open(ruta_izq).convert("RGBA")
    img_der = Image.open(ruta_der).convert("RGBA")

    ancho_izq, alto_izq = img_izq.size
    ancho_der, alto_der = img_der.size

    # El ancho total será la suma de ambos; el alto se mantiene en 256 (o el máximo de los dos)
    ancho_total = ancho_izq + ancho_der
    alto_total = max(alto_izq, alto_der + offset_y)

    # Crear el lienzo final
    lienzo_union = Image.new("RGBA", (ancho_total, alto_total), (0, 0, 0, 0))

    # Pegar el bloque principal a la izquierda (X=0, Y=0)
    lienzo_union.paste(img_izq, (0, 0))

    # Pegar los triángulos a la derecha (X=ancho_izq, Y=offset_y)
    # Por defecto, offset_y es 192 (256 - 64) para que la pieza de 64px de alto se asiente en la base. 
    # Si la pieza debe ir más arriba o abajo por la perspectiva isométrica, ajusta este valor.
    lienzo_union.paste(img_der, (ancho_izq, 197))#offset_y))

    # Guardar el resultado
    nombre_salida = f"frag_001_ensamblado_con_000.png"
    ruta_guardado = os.path.join(carpeta_salida, nombre_salida)
    lienzo_union.save(ruta_guardado)
    
    print(f"Fase 4 - Éxito: Se unieron {archivo_izq} (Izq) y {archivo_der} (Der).")
    print(f"Tamaño final de la pieza: {ancho_total}x{alto_total}px.")

# Ejecución Fase 4 (Lee los archivos desde la carpeta de la Fase 2)
fase4_unir_fragmentos("fase2_resultados", "fase4_resultados", offset_y=196)
#==================================================================================================================
#==================================================================================================================
"""
import os
from PIL import Image

def fase5_ensamblaje_final(carpetas_entrada, carpeta_salida, ancho_celda=128, alto_celda=256):
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    # Definir las rutas exactas de los archivos resultantes de las fases anteriores
    ruta_002 = os.path.join(carpetas_entrada['fase3'], "frag_002_elevado.png")
    ruta_001 = os.path.join(carpetas_entrada['fase4'], "frag_001_ensamblado_con_000.png")
    ruta_000 = os.path.join(carpetas_entrada['fase2'], "frag_000_final.png")

    # Validar que todas las piezas existan antes de ensamblar
    if not (os.path.exists(ruta_002) and os.path.exists(ruta_001) and os.path.exists(ruta_000)):
        print("Error en Fase 5: Faltan archivos. Asegúrate de haber ejecutado las fases 1, 2, 3 y 4.")
        return

    # Cargar las imágenes
    img_002 = Image.open(ruta_002).convert("RGBA")
    img_001 = Image.open(ruta_001).convert("RGBA")
    img_000 = Image.open(ruta_000).convert("RGBA")

    # Crear el lienzo final para 3 celdas (3 * 128 = 384px de ancho, 256px de alto)
    ancho_total = ancho_celda * 3
    lienzo_hoja = Image.new("RGBA", (ancho_total, alto_celda), (0, 0, 0, 0))

    # --- ENSAMBLAJE EN LA CUADRÍCULA ---
    
    # CELDA 1 (Izquierda): Tile 3 (frag_002). 
    # Comienza en X=0, pero se le suma 64px de offset según tu instrucción.
    lienzo_hoja.paste(img_002, (0 + 64, 0)) 

    # CELDA 2 (Centro): Tile 2 (frag_001 ensamblado con los triángulos).
    # Comienza exactamente en X=128.
    lienzo_hoja.paste(img_001, (ancho_celda * 1, 0))

    # CELDA 3 (Derecha): Tile 1 (frag_000 base).
    # Comienza exactamente en X=256.
    lienzo_hoja.paste(img_000, (ancho_celda * 2, 0))

    # Guardar la hoja de sprites final
    ruta_guardado = os.path.join(carpeta_salida, "spritesheet_final_rueda.png")
    lienzo_hoja.save(ruta_guardado)

    print(f"Fase 5 - Éxito: Hoja de sprites creada en '{ruta_guardado}'.")
    print(f"Dimensiones exactas del Spritesheet: {ancho_total}x{alto_celda}px.")

# Ejecución Fase 5 (Mapeo de las carpetas donde las fases anteriores dejaron sus archivos)
carpetas_fases = {
    'fase2': 'fase2_resultados',
    'fase3': 'fase3_resultados',
    'fase4': 'fase4_resultados'
}
fase5_ensamblaje_final(carpetas_fases, "fase5_resultados")
"""
#==================================================================================================================

#==================================================================================================================
"""
import os
from PIL import Image

def fase5_ensamblaje_final(carpetas_entrada, carpeta_salida, ancho_celda=128, alto_celda=256):
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    ruta_002 = os.path.join(carpetas_entrada['fase3'], "frag_002_elevado.png")
    ruta_001 = os.path.join(carpetas_entrada['fase4'], "frag_001_ensamblado_con_000.png")
    # Asegúrate de usar la ruta correcta según tu último flujo (puede venir de fase 2 o fase 1)
    ruta_000 = os.path.join(carpetas_entrada['fase2'], "frag_000_final.png") 

    if not (os.path.exists(ruta_002) and os.path.exists(ruta_001) and os.path.exists(ruta_000)):
        print("Error en Fase 5: Faltan archivos. Asegúrate de haber ejecutado las fases anteriores.")
        return

    img_002 = Image.open(ruta_002).convert("RGBA")
    img_001 = Image.open(ruta_001).convert("RGBA")
    img_000 = Image.open(ruta_000).convert("RGBA")

    # Lienzo total de 384x256 (3 celdas de 128)
    ancho_total = ancho_celda * 3
    lienzo_hoja = Image.new("RGBA", (ancho_total, alto_celda), (0, 0, 0, 0))
    # --- CELDA 1 (Izquierda): Lógica de conteo hacia atrás ---
    # Calculamos el borde derecho de esta celda (128) y le restamos el ancho real de la imagen.
    # Si la imagen mide 64, empezará en 64. Si mide 65, empezará en 63. Siempre pegada a la derecha.
    x_frag_002 = ancho_celda - img_002.width-64
    lienzo_hoja.paste(img_002, (x_frag_002, -5)) 

    # --- CELDA 2 (Centro) ---
    # Comienza en X=128
    lienzo_hoja.paste(img_001, (ancho_celda * 1, -6))

    # --- CELDA 3 (Derecha) ---
    # Comienza en X=256
    lienzo_hoja.paste(img_000, (ancho_celda * 2, 0))

    ruta_guardado = os.path.join(carpeta_salida, "spritesheet_final_rueda.png")
    lienzo_hoja.save(ruta_guardado)

    print(f"Fase 5 - Éxito: Hoja de sprites creada en '{ruta_guardado}'.")
    print(f"Tile 3 (frag_002) anclado dinámicamente en X={x_frag_002} (alineado a la derecha de su celda).")

# Ejecución Fase 5
carpetas_fases = {
    'fase2': 'fase2_resultados',
    'fase3': 'fase3_resultados',
    'fase4': 'fase4_resultados'
}
fase5_ensamblaje_final(carpetas_fases, "fase51_resultados")
"""
#==================================================================================================================
import os
from PIL import Image

def fase5_ensamblaje_final(carpetas_entrada, carpeta_salida, ancho_celda=128, alto_celda=256):
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    ruta_002 = os.path.join(carpetas_entrada['fase3'], "frag_002_elevado.png")
    ruta_001 = os.path.join(carpetas_entrada['fase4'], "frag_001_ensamblado_con_000.png")
    # Asegúrate de usar la ruta correcta según tu último flujo (puede venir de fase 2 o fase 1)
    ruta_000 = os.path.join(carpetas_entrada['fase2'], "frag_000_final.png") 

    if not (os.path.exists(ruta_002) and os.path.exists(ruta_001) and os.path.exists(ruta_000)):
        print("Error en Fase 5: Faltan archivos. Asegúrate de haber ejecutado las fases anteriores.")
        return

    img_002 = Image.open(ruta_002).convert("RGBA")
    img_001 = Image.open(ruta_001).convert("RGBA")
    img_000 = Image.open(ruta_000).convert("RGBA")

    # Lienzo total de 384x256 (3 celdas de 128)
    ancho_total = ancho_celda * 3
    lienzo_hoja = Image.new("RGBA", (ancho_total, alto_celda), (0, 0, 0, 0))
    
    # --- CELDA 1 (Izquierda): Lógica de conteo hacia atrás ---
    x_frag_002 = ancho_celda - img_002.width - 64
    lienzo_hoja.paste(img_002, (x_frag_002, -5)) 

    # --- CELDA 2 (Centro) ---
    lienzo_hoja.paste(img_001, (ancho_celda * 1, -6))

    # --- CELDA 3 (Derecha) ---
    lienzo_hoja.paste(img_000, (ancho_celda * 2, 0))

    ruta_guardado = os.path.join(carpeta_salida, "spritesheet_final_rueda.png")
    lienzo_hoja.save(ruta_guardado)

    print(f"Fase 5 - Éxito: Hoja de sprites creada en '{ruta_guardado}'.")
    print(f"Tile 3 (frag_002) anclado dinámicamente en X={x_frag_002} (alineado a la derecha de su celda).")

    # --- MODIFICACIÓN: VOLTEADO HORIZONTAL ---
    # Aplica el efecto espejo a todo el lienzo ensamblado justo antes de guardarlo
    lienzo_hoja = lienzo_hoja.transpose(Image.FLIP_LEFT_RIGHT)

    ruta_guardado = os.path.join(carpeta_salida, "spritesheet_final_rueda_volteada.png")
    lienzo_hoja.save(ruta_guardado)

    print(f"Fase 5 - Éxito: Hoja de sprites creada y volteada horizontalmente en '{ruta_guardado}'.")

# Ejecución Fase 5
carpetas_fases = {
    'fase2': 'fase2_resultados',
    'fase3': 'fase3_resultados',
    'fase4': 'fase4_resultados'
}
fase5_ensamblaje_final(carpetas_fases, "fase51_resultados")
#==================================================================================================================
"""
import os
from PIL import Image

def combinar_con_fondo(ruta_fondo, ruta_spritesheet, carpeta_salida):
    # Crear la carpeta de salida (2x) si no existe
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    # Validar que los archivos existan
    if not os.path.exists(ruta_fondo) or not os.path.exists(ruta_spritesheet):
        print(f"Error: Asegúrate de que '{ruta_fondo}' y '{ruta_spritesheet}' existan en el directorio.")
        return

    # Cargar ambas imágenes asegurando el canal RGBA para las transparencias
    fondo = Image.open(ruta_fondo).convert("RGBA")
    spritesheet = Image.open(ruta_spritesheet).convert("RGBA")

    # Crear una copia del fondo para trabajar sobre ella
    lienzo_final = fondo.copy()

    # Pegar el spritesheet sobre el fondo en la coordenada (0, 0)
    # El tercer parámetro (spritesheet) actúa como máscara para respetar las transparencias
    lienzo_final.paste(spritesheet, (0, 0), spritesheet)

    # Definir la ruta de guardado dentro de la carpeta 2x
    ruta_guardado = os.path.join(carpeta_salida, "spritesheet_final_rueda_r2.png")
    
    # Guardar el resultado
    lienzo_final.save(ruta_guardado)
    
    print(f"Éxito: Imágenes combinadas y guardadas en '{ruta_guardado}'.")

# Ejecución (asumiendo que estás en la ruta C:\\Users\\User\\Desktop\\prueba empaquetador\fase5_resultados)
combinar_con_fondo("fase5_resultados\\fondo_transparente.png", "fase51_resultados\\spritesheet_final_rueda.png", "fase5_resultados\\2x")
"""
#==================================================================================================================
import os
from PIL import Image

def combinar_con_fondo_multiple(ruta_fondo, ruta_normal, ruta_volteada, carpeta_salida, alto_fila=256):
    # Crear la carpeta de salida (2x) si no existe
    if not os.path.exists(carpeta_salida):
        os.makedirs(carpeta_salida)

    # Validar que los archivos existan
    if not os.path.exists(ruta_fondo) or not os.path.exists(ruta_normal) or not os.path.exists(ruta_volteada):
        print("Error: Asegúrate de que el fondo y ambos spritesheets (normal y volteado) existan.")
        return

    # Cargar las imágenes asegurando el canal RGBA para las transparencias
    fondo = Image.open(ruta_fondo).convert("RGBA")
    spritesheet_normal = Image.open(ruta_normal).convert("RGBA")
    spritesheet_volteada = Image.open(ruta_volteada).convert("RGBA")

    # Crear una copia del fondo de 1024x2560 para trabajar sobre ella
    lienzo_final = fondo.copy()

    # 1. Pegar el spritesheet normal en la PRIMERA FILA (X=0, Y=0)
    lienzo_final.paste(spritesheet_normal, (0, 0), spritesheet_normal)

    # 2. Pegar el spritesheet volteado
    # OPCIÓN A (Recomendada para PZ): En la SEGUNDA FILA (X=0, Y=256)
    lienzo_final.paste(spritesheet_volteada, (0, alto_fila), spritesheet_volteada)
    
    # OPCIÓN B: Si realmente los quieres en una SOLA FILA, comenta la línea de arriba 
    # y descomenta la siguiente línea (X=ancho_del_normal, Y=0):
    # lienzo_final.paste(spritesheet_volteada, (spritesheet_normal.width, 0), spritesheet_volteada)

    # Definir la ruta de guardado dentro de la carpeta 2x
    ruta_guardado = os.path.join(carpeta_salida, "spritesheet_final_rueda_r2.png")
    
    # Guardar el resultado
    lienzo_final.save(ruta_guardado)
    
    print(f"Éxito: Imágenes combinadas en el fondo y guardadas en '{ruta_guardado}'.")

# --- EJECUCIÓN ---
# Ajusta las rutas según dónde tengas el script original y el volteado
combinar_con_fondo_multiple(
    ruta_fondo="fase5_resultados\\fondo_transparente.png", 
    ruta_normal="fase51_resultados\\spritesheet_final_rueda.png",          # El original
    ruta_volteada="fase51_resultados\\spritesheet_final_rueda_volteada.png",        # El volteado (Fase 51)
    carpeta_salida="fase5_resultados\\2x"
)

#==================================================================================================================
# SCRIPT FINAL
import os
import shutil
from PIL import Image, ImageDraw

# ==============================================================================
# FASES DEL PIPELINE ORIGINAL (Mantenidas intactas para la lógica isométrica)
# ==============================================================================

def fase1_division_y_extraccion(ruta_imagen, carpeta_salida):
    if not os.path.exists(carpeta_salida): os.makedirs(carpeta_salida)
    img = Image.open(ruta_imagen).convert("RGBA")
    ancho, alto = img.size
    x_derecha, indice = ancho, 0

    while x_derecha > 0:
        ancho_corte = 128 if indice == 0 else 64
        x_izquierda = max(0, x_derecha - ancho_corte)
        fragmento = img.crop((x_izquierda, 0, x_derecha, alto))
        ancho_frag = fragmento.size[0]

        x_linea = 65 if ancho_frag > 65 else ancho_frag - 1
        pixeles = fragmento.load()
        y_choque = -1

        for y in range(alto - 1, -1, -1):
            if pixeles[x_linea, y][3] > 0:
                y_choque = y
                break

        if y_choque != -1 and x_linea >= 65:
            mascara_f1 = Image.new("L", (ancho_frag, alto), 0)
            draw = ImageDraw.Draw(mascara_f1)
            p_origen = (x_linea, y_choque)
            p_diag_inf = (x_linea - 64, y_choque + 32)
            p_esquina = (x_linea - 64, y_choque) 
            draw.polygon([p_origen, p_diag_inf, p_esquina], fill=255)

            fragmento_extraido_f1 = Image.new("RGBA", (ancho_frag, alto), (0, 0, 0, 0))
            fragmento_extraido_f1.paste(fragmento, (0, 0), mascara_f1)
            
            transparente = Image.new("RGBA", (ancho_frag, alto), (0, 0, 0, 0))
            fragmento.paste(transparente, (0, 0), mascara_f1)
            
            recorte_final_f1 = fragmento_extraido_f1.crop((x_linea - 64, y_choque, x_linea, y_choque + 32))
            recorte_final_f1.save(os.path.join(carpeta_salida, f"frag_{indice:03d}_extraido_abajo.png"))

        alto_lienzo = 256
        if y_choque != -1:
            desplazamiento_y = alto_lienzo - y_choque
            lienzo_alineado = Image.new("RGBA", (ancho_frag, alto_lienzo), (0, 0, 0, 0))
            lienzo_alineado.paste(fragmento, (0, desplazamiento_y))
            fragmento = lienzo_alineado 

        fragmento.save(os.path.join(carpeta_salida, f"frag_{indice:03d}_bloque.png"))
        x_derecha = x_izquierda
        indice += 1


def fase2_extraccion_y_union(carpeta_fase1, carpeta_salida, alto_lienzo=256):
    if not os.path.exists(carpeta_salida): os.makedirs(carpeta_salida)
    archivos_bloque = [f for f in os.listdir(carpeta_fase1) if f.endswith('_bloque.png')]

    for archivo_bloque in archivos_bloque:
        indice = archivo_bloque.split('_')[1]
        ruta_bloque = os.path.join(carpeta_fase1, archivo_bloque)
        ruta_triangulo_abajo = os.path.join(carpeta_fase1, f"frag_{indice}_extraido_abajo.png")

        bloque = Image.open(ruta_bloque).convert("RGBA")
        ancho, alto = bloque.size
        x_linea = 65 if ancho > 65 else ancho - 1

        if not os.path.exists(ruta_triangulo_abajo) or x_linea < 65:
            bloque.save(os.path.join(carpeta_salida, f"frag_{indice}_final.png"))
            continue

        y_base = alto_lienzo 
        mascara_f2 = Image.new("L", (ancho, alto_lienzo), 0)
        draw = ImageDraw.Draw(mascara_f2)
        p_origen = (x_linea, y_base)
        p_sup_izq = (x_linea - 65, y_base - 32)
        p_inf_izq = (x_linea - 65, y_base)
        draw.polygon([p_origen, p_sup_izq, p_inf_izq], fill=255)

        triangulo_fase2 = Image.new("RGBA", (ancho, alto_lienzo), (0, 0, 0, 0))
        triangulo_fase2.paste(bloque, (0, 0), mascara_f2)
        recorte_arriba = triangulo_fase2.crop((x_linea - 65, y_base - 32, x_linea, y_base))

        transparente = Image.new("RGBA", (ancho, alto_lienzo), (0, 0, 0, 0))
        bloque.paste(transparente, (0, 0), mascara_f2)
        bloque.save(os.path.join(carpeta_salida, f"frag_{indice}_final.png"))

        triangulo_abajo = Image.open(ruta_triangulo_abajo).convert("RGBA")
        union = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        union.paste(recorte_arriba, (0, 0))
        union.paste(triangulo_abajo, (0, 32))
        union.save(os.path.join(carpeta_salida, f"frag_{indice}_union_triangulos.png"))


def fase3_traslacion_arriba(carpeta_entrada, carpeta_salida, indice_objetivo="002", desplazamiento=64):
    if not os.path.exists(carpeta_salida): os.makedirs(carpeta_salida)
    ruta_imagen = os.path.join(carpeta_entrada, f"frag_{indice_objetivo}_final.png")
    if not os.path.exists(ruta_imagen): return
    
    img = Image.open(ruta_imagen).convert("RGBA")
    lienzo_elevado = Image.new("RGBA", img.size, (0, 0, 0, 0))
    lienzo_elevado.paste(img, (0, -desplazamiento))
    lienzo_elevado.save(os.path.join(carpeta_salida, f"frag_{indice_objetivo}_elevado.png"))


def fase4_unir_fragmentos(carpeta_entrada, carpeta_salida, archivo_izq="frag_001_final.png", archivo_der="frag_000_union_triangulos.png", offset_y=196):
    if not os.path.exists(carpeta_salida): os.makedirs(carpeta_salida)
    ruta_izq = os.path.join(carpeta_entrada, archivo_izq)
    ruta_der = os.path.join(carpeta_entrada, archivo_der)
    if not os.path.exists(ruta_izq) or not os.path.exists(ruta_der): return

    img_izq = Image.open(ruta_izq).convert("RGBA")
    img_der = Image.open(ruta_der).convert("RGBA")
    
    ancho_total = img_izq.size[0] + img_der.size[0]
    alto_total = max(img_izq.size[1], img_der.size[1] + offset_y)
    
    lienzo_union = Image.new("RGBA", (ancho_total, alto_total), (0, 0, 0, 0))
    lienzo_union.paste(img_izq, (0, 0))
    lienzo_union.paste(img_der, (img_izq.size[0], 192))
    lienzo_union.save(os.path.join(carpeta_salida, "frag_001_ensamblado_con_000.png"))


def fase5_ensamblaje_final(carpetas_entrada, carpeta_salida, ancho_celda=128, alto_celda=256):
    if not os.path.exists(carpeta_salida): os.makedirs(carpeta_salida)
    ruta_002 = os.path.join(carpetas_entrada['fase3'], "frag_002_elevado.png")
    ruta_001 = os.path.join(carpetas_entrada['fase4'], "frag_001_ensamblado_con_000.png")
    ruta_000 = os.path.join(carpetas_entrada['fase2'], "frag_000_final.png") 

    img_002 = Image.open(ruta_002).convert("RGBA")
    img_001 = Image.open(ruta_001).convert("RGBA")
    img_000 = Image.open(ruta_000).convert("RGBA")

    lienzo_hoja = Image.new("RGBA", (ancho_celda * 3, alto_celda), (0, 0, 0, 0))
    x_frag_002 = ancho_celda - img_002.width - 64
    
    lienzo_hoja.paste(img_002, (x_frag_002, -3)) 
    lienzo_hoja.paste(img_001, (ancho_celda * 1, -6))
    lienzo_hoja.paste(img_000, (ancho_celda * 2, -6))

    # Guardar Normal
    ruta_normal = os.path.join(carpeta_salida, "spritesheet_final_rueda.png")
    lienzo_hoja.save(ruta_normal)

    # Voltear y Guardar Volteada
    lienzo_hoja_volteada = lienzo_hoja.transpose(Image.FLIP_LEFT_RIGHT)
    ruta_volteada = os.path.join(carpeta_salida, "spritesheet_final_rueda_volteada.png")
    lienzo_hoja_volteada.save(ruta_volteada)

    return ruta_normal, ruta_volteada


# ==============================================================================
# ORQUESTADOR AUTOMÁTICO EN LOTE
# ==============================================================================

def procesar_lote_completo(carpeta_imagenes, ruta_fondo, carpeta_salida_final):
    if not os.path.exists(carpeta_salida_final):
        os.makedirs(carpeta_salida_final)

    archivos = [f for f in os.listdir(carpeta_imagenes) if f.lower().endswith('.png')]
    if not archivos:
        print(f"No se encontraron imágenes en {carpeta_imagenes}")
        return

    # Cargar fondo maestro
    fondo = Image.open(ruta_fondo).convert("RGBA")
    lienzo_maestro = fondo.copy()

    # Cada bloque resultante de 3 tiles ocupa 384px (3 * 128)
    ancho_bloque_tiles = 384 
    alto_fila = 256

    print(f"Iniciando procesamiento de {len(archivos)} imágenes...\n")

    for idx, archivo in enumerate(archivos):
        nombre_base = os.path.splitext(archivo)[0]
        ruta_imagen = os.path.join(carpeta_imagenes, archivo)
        print(f"[{idx+1}/{len(archivos)}] Procesando: {archivo}...")

        # Crear estructura de carpetas temporales para esta imagen específica
        temp_dir = os.path.join(carpeta_salida_final, f"temp_{nombre_base}")
        c_f1 = os.path.join(temp_dir, "fase1")
        c_f2 = os.path.join(temp_dir, "fase2")
        c_f3 = os.path.join(temp_dir, "fase3")
        c_f4 = os.path.join(temp_dir, "fase4")
        c_f5 = os.path.join(temp_dir, "fase5")

        # Ejecutar cadena del pipeline
        fase1_division_y_extraccion(ruta_imagen, c_f1)
        fase2_extraccion_y_union(c_f1, c_f2)
        fase3_traslacion_arriba(c_f2, c_f3)
        fase4_unir_fragmentos(c_f2, c_f4)
        
        carpetas_fases = {'fase2': c_f2, 'fase3': c_f3, 'fase4': c_f4}
        ruta_normal, ruta_volteada = fase5_ensamblaje_final(carpetas_fases, c_f5)

        # Cargar los resultados listos
        img_normal = Image.open(ruta_normal).convert("RGBA")
        img_volteada = Image.open(ruta_volteada).convert("RGBA")

        # --- LÓGICA DE POSICIONAMIENTO EN EL LIENZO MAESTRO ---
        # Coordenada Y: Baja 256px por cada nueva imagen (una imagen por fila)
        coord_y = idx * alto_fila 

        # Coordenada X (Normal): Alineado a la izquierda (Columnas 0, 1, 2)
        coord_x_normal = 0
        lienzo_maestro.paste(img_normal, (coord_x_normal, coord_y), img_normal)

        # Coordenada X (Volteada): Empieza justo después de la normal (Columnas 3, 4, 5) -> X=384
        coord_x_volteada = ancho_bloque_tiles
        lienzo_maestro.paste(img_volteada, (coord_x_volteada, coord_y), img_volteada)

        # Limpiar la carpeta temporal para ahorrar espacio
        shutil.rmtree(temp_dir)
        print(f"-> Ensamblado en Y={coord_y}. Temporales limpiados.\n")

    # Guardar el spritesheet final de PZ
    ruta_guardado_final = os.path.join(carpeta_salida_final, "rueda.png")
    lienzo_maestro.save(ruta_guardado_final)
    print(f"¡Proceso finalizado! Hoja de sprites maestra guardada en: {ruta_guardado_final}")


# ==============================================================================
# EJECUCIÓN DEL ORQUESTADOR
# ==============================================================================
# 1. 'carpeta_input_imagenes' debe contener tus 3 imágenes base (ej: rueda_madera.png, rueda_metal.png, etc).
# 2. 'ruta_fondo' es el PNG vacío de 1024x2560 (el grid de Zomboid).
# 3. 'carpeta_output' es donde se guardará el spritesheet final unificado.

procesar_lote_completo(
    carpeta_imagenes="entrada_lote", 
    ruta_fondo="fase5_resultados/fondo_transparente.png", 
    carpeta_salida_final="fase5_resultados/2x"
)
#==================================================================================================================