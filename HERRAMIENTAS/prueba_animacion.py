import pygame
import sys
import os
def probar_animacion_zomboid_escalable():
    # ============================================================
    # INICIALIZAR PYGAME
    # ============================================================
    pygame.init()
    pygame.mixer.init()
    # Tamaño inicial de la ventana
    ancho, alto = 224, 250
    pantalla = pygame.display.set_mode(
        (ancho, alto),
        pygame.RESIZABLE
    )
    pygame.display.set_caption(
        "Preview Zomboid TV - Rueda (Escalable)"
    )
    # ============================================================
    # FRAMES DE LA ANIMACIÓN
    # ============================================================
    # SOLO se reproducen estos archivos y en este orden:
    #
    # 1_rueda.png
    # 2_rueda.png
    # 3_rueda.png
    #
    # Las copias existentes en la carpeta son ignoradas.
    ruta_frames = [
        "VIDEO/Rueda_01.png",
        "VIDEO/Rueda_02.png",
        "VIDEO/Rueda_03.png",
        "VIDEO/Rueda_04.png",
        "VIDEO/Rueda_05.png"
    ]
    # ============================================================
    # COMPROBAR QUE EXISTAN LOS FRAMES
    # ============================================================
    for ruta in ruta_frames:
        if not os.path.exists(ruta):
            print(f"ERROR: No se encontró el archivo:")
            print(f"       {ruta}")
            print()
            print("Los archivos deben estar en la misma carpeta")
            print("que este script.")
            pygame.quit()
            sys.exit()
    # ============================================================
    # CARGAR LOS FRAMES
    # ============================================================
    print(f"Cargando {len(ruta_frames)} frames...")
    frames = []
    for ruta in ruta_frames:
        print(f"  -> {ruta}")
        imagen = pygame.image.load(ruta).convert_alpha()
        frames.append(imagen)
    print("Frames cargados correctamente.")
    # ============================================================
    # AUDIO
    # ============================================================
    ruta_audio = "audio/audio_tv.ogg"
    if os.path.exists(ruta_audio):
        pygame.mixer.music.load(ruta_audio)
        pygame.mixer.music.play()
        print("Reproduciendo audio_tv.ogg...")
    else:
        print(
            "Advertencia: No se encontró "
            "'audio/audio_tv.ogg'."
        )
    # ============================================================
    # CONTROL DE FPS
    # ============================================================
    reloj = pygame.time.Clock()
    # 2 frames por segundo
    #
    # Cada imagen permanece 0.5 segundos.
    #
    # 1_rueda -> 0.5 s
    # 2_rueda -> 0.5 s
    # 3_rueda -> 0.5 s
    #
    # Ciclo completo = 1.5 segundos.
    fps = 5
    # ============================================================
    # CONTROL DE LA ANIMACIÓN
    # ============================================================
    indice_frame = 0
    corriendo = True
    # ============================================================
    # BUCLE PRINCIPAL
    # ============================================================
    while corriendo:
        # --------------------------------------------------------
        # EVENTOS
        # --------------------------------------------------------
        for evento in pygame.event.get():
            # Cerrar ventana
            if evento.type == pygame.QUIT:
                corriendo = False
            # Redimensionar ventana
            elif evento.type == pygame.VIDEORESIZE:
                ancho = evento.w
                alto = evento.h
                pantalla = pygame.display.set_mode(
                    (ancho, alto),
                    pygame.RESIZABLE
                )
        # --------------------------------------------------------
        # LIMPIAR PANTALLA
        # --------------------------------------------------------
        pantalla.fill((0, 0, 0))
        # --------------------------------------------------------
        # OBTENER FRAME ACTUAL
        # --------------------------------------------------------
        frame_actual = frames[indice_frame]
        # --------------------------------------------------------
        # ESCALAR FRAME A LA VENTANA
        # --------------------------------------------------------
        frame_escalado = pygame.transform.scale(
            frame_actual,
            (ancho, alto)
        )
        # --------------------------------------------------------
        # DIBUJAR FRAME
        # --------------------------------------------------------
        pantalla.blit(
            frame_escalado,
            (0, 0)
        )
        # --------------------------------------------------------
        # ACTUALIZAR PANTALLA
        # --------------------------------------------------------
        pygame.display.flip()
        # --------------------------------------------------------
        # SIGUIENTE FRAME
        # --------------------------------------------------------
        indice_frame += 1
        # --------------------------------------------------------
        # VOLVER AL PRIMER FRAME
        #
        # 1 -> 2 -> 3 -> 1 -> 2 -> 3 -> ...
        # --------------------------------------------------------
        if indice_frame >= len(frames):
            indice_frame = 0
        # --------------------------------------------------------
        # CONTROLAR FPS
        # --------------------------------------------------------
        reloj.tick(fps)
    # ============================================================
    # CERRAR PYGAME
    # ============================================================
    pygame.quit()
# ================================================================
# EJECUTAR
# ================================================================
if __name__ == "__main__":
    probar_animacion_zomboid_escalable()