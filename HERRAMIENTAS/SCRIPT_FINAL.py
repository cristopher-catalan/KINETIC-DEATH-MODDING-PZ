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