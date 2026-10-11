RecMedia = RecMedia or {}


-- PRUEBAAAAAAAAAA

-- ======================================================================
-- MOTOR DE SINCRONIZACIÓN DE TIEMPO (LUA -> JAVA)
-- ======================================================================

-- Esta función inyecta "padding" (relleno invisible) a un VHS para estirar
-- su duración nativa y acoplarla a la de nuestro motor 3D.
local function SincronizarDuracionVHS(vhsData, maxFrames, fps)
    -- 1. Obtenemos cuánto dura tu animación en segundos reales
    local duracionVideoSegundos = maxFrames / fps
    
    -- 2. Según el motor Java de PZ, el 'minmod' de 1.5 equivale a ~1.5 segundos
    local duracionLineaVacia = 1.5
    
    -- 3. Calculamos la cantidad de líneas invisibles necesarias.
    -- Usamos math.ceil() para redondear siempre hacia arriba y tener un pequeño
    -- margen de seguridad. Nuestro "Vigilante" cortará el excedente de todos modos.
    local lineasNecesarias = math.ceil(duracionVideoSegundos / duracionLineaVacia)
    
    print(string.format("[TV-TEST] Sincronizando VHS '%s': Video dura %.1fs. Inyectando %d líneas vacías.", vhsData.title, duracionVideoSegundos, lineasNecesarias))
    
    -- 4. Inyectamos el relleno en la metadata de RecordedMedia
    for i = 1, lineasNecesarias do
        table.insert(vhsData.lines, { 
            text = " ", -- Un solo espacio fuerza la evaluación de límite inferior en Java
            r = 0, g = 0, b = 0 -- Texto totalmente negro (invisible)
        })
    end
end

-- La llave "boondocks" conecta el nombre del sonido (FMOD) con la carpeta de texturas (CustomTVTest)
RecMedia["boondocks"] = {
    itemDisplayName = "The Boondocks Apocalipsis",
    title = "The Boondocks Apocalipsis",
    subtitle = "Ellos vienen...",
    author = "Editorial JVC", -- Autor que incluimos en el condicional de REPRODUCTOR_TELE.LUA
    extra = "Una joya animada con audio y video integrados.",
    spawning = 1,
    category = "Animado-VHS",
    lines = {
        { text = "[Estática visual... comienza la reproducción]", r = 0.6, g = 0.6, b = 0.6 },
    },
};

-- 2. LLAMAMOS A LA SINCRONIZACIÓN AUTOMÁTICA
-- Le pasamos la tabla del VHS recién creado, los maxFrames (315) y los fps (2).
SincronizarDuracionVHS(RecMedia["boondocks"], 315, 2)


-- ======================================================================
-- FASE 1: FUNDAMENTOS Y CONSTRUCCIÓN (VHS 01 - 03)
-- ======================================================================

RecMedia["CazadoresMuertos01"] = {
    itemDisplayName = "Cazadores de Muertos - Guia Practica",
    title = "Cazadores de Muertos: Guia Practica",
    subtitle = "Episodio 01: Contencion",
    author = "Dr. Logan",
    extra = "Aprende los conceptos basicos de inmovilizacion.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "[Estática visual...]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Saludos, supervivientes. Soy el Dr. Logan.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Si están viendo esto, el mundo ha terminado. Pero la ciencia no.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Los infectados son una plaga, sí. Pero también son un recurso.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Paso uno: Los infectados pueden ser inmovilizados utilizando cuerda.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Deben amarrar firmemente las extremidades superiores.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "ADVERTENCIA: Un nudo suelto significa una mordida letal.", r = 1.0, g = 0.2, b = 0.2 },
    },
};

RecMedia["CazadoresMuertos02"] = {
    itemDisplayName = "Manos a la Obra: Ing. de Supervivencia",
    title = "Manos a la Obra: Ingeniería de Supervivencia",
    subtitle = "Episodio 02: El Marco",
    author = "Dr. Logan",
    extra = "Construccion de soportes para sujetos.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "Día 42. Hoy construiremos el marco de tracción.", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Necesitarán tablones robustos, clavos y conocimientos básicos de carpintería.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "El sujeto de prueba intentará caminar hacia adelante incesantemente.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Ese impulso ciego es energía cinética pura. Energía gratis.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Nota mental: la madera podrida se quiebra con la fuerza de sus espasmos.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Refuercen las uniones. No dejen que se liberen.", r = 1.0, g = 0.2, b = 0.2 }
    },
};

RecMedia["CazadoresMuertos03"] = {
    itemDisplayName = "Electricidad de Emergencia",
    title = "Electricidad de Emergencia: Energía Después del Fin",
    subtitle = "Episodio 03: Dinamos Orgánicos",
    author = "Dr. Logan",
    extra = "Conecta un infectado a un generador.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "La gasolina se acaba. Los paneles solares se rompen.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Pero los muertos... ellos nunca se cansan.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Acoplando el eje de la rueda de tracción a un alternador modificado...", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Podemos transformar su andar errático en corriente continua.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Importante: Despojen al sujeto de su ropa y equipo pesado.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Esto reduce la fricción mecánica en la rueda y aumenta la eficiencia un 15%%.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Tengan cuidado con el cableado. La carne mojada es excelente conductora.", r = 1.0, g = 0.2, b = 0.2 }
    },
};

-- ======================================================================
-- FASE 2: ENERGÍA, CADÁVERES Y MAQUINARIA (VHS 04 - 06)
-- ======================================================================

RecMedia["CazadoresMuertos04"] = {
    itemDisplayName = "Anatomia del Infectado",
    title = "Anatomía del Infectado",
    subtitle = "Episodio 04: Motor de Carne",
    author = "Dr. Logan",
    extra = "Comprendiendo la biologia muerta.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "[Sonido de moscas y un motor zumbando...]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "He estado observando el tejido muscular del espécimen 4.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "No hay acumulación de ácido láctico. Fascinante.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Para procesar los cadáveres inservibles, usaremos cuchillos de trinchar.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "La grasa licuada puede refinarse para crear lubricante mecánico.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Usen guantes. Un simple rasguño con hueso astillado y se unirán a ellos.", r = 1.0, g = 0.2, b = 0.2 }
    },
};

RecMedia["CazadoresMuertos05"] = {
    itemDisplayName = "Contencion Avanzada",
    title = "Contención Avanzada",
    subtitle = "Episodio 05: Hierro y Estacas",
    author = "Dr. Logan",
    extra = "Metodos extremos de sujecion.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "La cuerda se desgasta. La tela se rompe.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Es hora de evolucionar hacia las cadenas y el acero.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "El encadenado defensivo sobre estacas requiere herrería básica.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Atravesar la cavidad torácica con varillas de refuerzo los ancla al suelo.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Siguen retorciéndose. Sus mandíbulas chasquean sin cesar...", r = 0.8, g = 0.2, b = 0.8 },
        { text = "No se acerquen a la zona frontal del anclaje.", r = 1.0, g = 0.2, b = 0.2 }
    },
};

RecMedia["CazadoresMuertos06"] = {
    itemDisplayName = "Mecanica del Apocalipsis",
    title = "Mecanica del Apocalipsis",
    subtitle = "Episodio 06: Como Hacer Rodar un Muerto",
    author = "Dr. Logan",
    extra = "Integracion vehicular.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "Día 112. Si podemos generar electricidad, podemos generar tracción.", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Al conectar un arnés modificado a la transmisión de un vehículo ligero...", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Podemos crear vehículos de arrastre biológico.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Necesitarán piezas de motor, correas de ventilador y un cebo...", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Suelen arrancar los arneses si huelen sangre fresca. Manténganlos limpios.", r = 1.0, g = 0.2, b = 0.2 }
    },
};

-- ======================================================================
-- FASE 3: QUÍMICA, METALURGIA Y DEFENSA (VHS 07 - 09)
-- ======================================================================

RecMedia["CazadoresMuertos07"] = {
    itemDisplayName = "Quimica del Fin del Mundo",
    title = "Quimica del Fin del Mundo",
    subtitle = "Episodio 07: Fluidos y Conservación",
    author = "Dr. Logan",
    extra = "Mantenimiento organico a largo plazo.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "[Sonido de vidrio tintineando... un suspiro...]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "El problema de nuestra 'maquinaria' es la putrefacción.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "El tejido necrosado atrae plagas y debilita los músculos motrices.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Con lejía, amoníaco y ciertos compuestos farmacéuticos...", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Podemos crear una solución conservante para bañar a los sujetos.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Precaución: Inhalar los gases del baño químico causa ceguera temporal.", r = 1.0, g = 0.2, b = 0.2 }
    },
};

RecMedia["CazadoresMuertos08"] = {
    itemDisplayName = "Forja del Superviviente",
    title = "Forja del Superviviente",
    subtitle = "Episodio 08: Reforzando la Cárcel",
    author = "Dr. Logan",
    extra = "Soldadura para contencion masiva.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "Un solo espécimen genera X vatios. Pero necesitamos más.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Para los sistemas de contención en cadena, la soldadura es vital.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Sopletes, máscaras, chatarra metálica. Refuercen cada celda de tracción.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Ellos golpean el metal. Día y noche. El ruido atrae a más.", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Construyan deflectores de sonido acústicos... o se verán invadidos.", r = 1.0, g = 0.2, b = 0.2 }
    },
};

RecMedia["CazadoresMuertos09"] = {
    itemDisplayName = "Defensas del Ultimo Refugio",
    title = "Defensas del Último Refugio",
    subtitle = "Episodio 09: El Perímetro",
    author = "Dr. Logan",
    extra = "Automatizacion defensiva.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "Usar a los muertos para matar a los muertos. Poético.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "La energía cinética de la rueda ahora puede alimentar trampas rotatorias.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Conecten tubos metálicos afilados al eje de transmisión secundario.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Cuando la horda se acerque, los sujetos capturados generarán la fuerza...", r = 1.0, g = 1.0, b = 1.0 },
        { text = "...para desmembrar a los suyos. Trituradoras biológicas.", r = 1.0, g = 0.2, b = 0.2 }
    },
};

-- ======================================================================
-- FASE 4: TÉCNICAS AVANZADAS Y ENDGAME (VHS 10 - 12)
-- ======================================================================

RecMedia["CazadoresMuertos10"] = {
    itemDisplayName = "Tecnicas Prohibidas",
    title = "Técnicas Prohibidas",
    subtitle = "Episodio 10: Cruzando la Línea",
    author = "Dr. Logan",
    extra = "Metodos experimentales peligrosos.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "[Respiración agitada...]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "La moralidad murió con el último canal de noticias.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Si extraemos las glándulas suprarrenales de los sujetos recién infectados...", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Podemos sintetizar estimulantes. Para nosotros. Para no dormir nunca.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "El procedimiento es altamente tóxico. Un error en la filtración química...", r = 1.0, g = 1.0, b = 1.0 },
        { text = "...y tu propio corazón explotará en tu pecho.", r = 1.0, g = 0.2, b = 0.2 }
    },
};

RecMedia["CazadoresMuertos11"] = {
    itemDisplayName = "Ingenieria de los Muertos",
    title = "Ingeniería de los Muertos",
    subtitle = "Episodio 11: Simbiosis",
    author = "Dr. Logan",
    extra = "Sistemas completos y automatizados.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "Hemos alcanzado la cima. Granjas de energía automatizadas.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Al interconectar 5 ruedas de tracción, tenemos energía industrial.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Pero están hambrientos. La privación total los vuelve letárgicos con los meses.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "He diseñado un dispensador automatizado de biomasa.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Alimentarlos prolonga su vida útil. Mantiene los generadores girando.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Estamos cultivando monstruos. Qué Dios nos perdone.", r = 0.6, g = 0.6, b = 0.6 }
    },
};

RecMedia["CazadoresMuertos12"] = {
    itemDisplayName = "El Experimento Logan",
    title = "El Experimento Logan",
    subtitle = "Episodio 12: Alfa y Omega",
    author = "Dr. Logan",
    extra = "La grabacion final...",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "[Golpes metálicos violentos en el fondo. Alarmas sonando.]", r = 1.0, g = 0.2, b = 0.2 },
        { text = "¡Funciona! ¡El prototipo Alfa funciona!", r = 0.8, g = 0.2, b = 0.8 },
        { text = "He logrado conectar el sistema nervioso central directo a la red...", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Pero me mordieron. Fue el espécimen 1. Mi error.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "He dejado los planos de la Batería Orgánica Avanzada en esta cinta.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Si alguien encuentra esto... usen mi trabajo.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Usen mi cuerpo... pónganme en la rueda...", r = 0.8, g = 0.2, b = 0.8 },
        { text = "[Estática estruendosa. Fin de la cinta.]", r = 0.6, g = 0.6, b = 0.6 }
    },
};

-- ======================================================================
-- HISTORIA SECUNDARIA: DIARIOS DE LA INGENIERA RUIZ (CINTAS 01 - 08)
-- ======================================================================

RecMedia["DiariosRuiz01"] = {
    itemDisplayName = "Diario de Ruiz 01 - El Hallazgo",
    title = "Diarios de Ruiz: Sobreviviendo a Logan",
    subtitle = "Cinta 01: El Hallazgo",
    author = "Ing. Elena Ruiz",
    extra = "Notas sobre la escalabilidad del sistema Logan.",
    spawning = 1,
    category = "Ruiz-VHS",
    lines = {
        { text = "[Ruido de herramientas cayendo. Un motor arranca.]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Mi nombre es Elena Ruiz. Soy, o era, ingeniera electromecánica.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Encontramos las cintas de un tal Dr. Logan en un búnker saqueado.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Al principio nos pareció una atrocidad moral. Esclavizar a los muertos.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Pero anoche perdimos a tres personas buscando gasolina. La moralidad no enciende las luces.", r = 0.4, g = 0.8, b = 1.0 },
        { text = "Los diseños de Logan son crudos. Eficientes para un ermitaño, inútiles para una comunidad.", r = 0.4, g = 0.8, b = 1.0 },
        { text = "Para escalar esto, necesitamos aislar los engranajes principales. Si la sangre entra al motor...", r = 1.0, g = 0.9, b = 0.2 },
        { text = "El óxido biológico carcomerá el rotor en menos de una semana.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Hoy empezamos a construir el 'Molino'. Que Dios nos ampare.", r = 1.0, g = 1.0, b = 1.0 }
    },
};

RecMedia["DiariosRuiz02"] = {
    itemDisplayName = "Diario de Ruiz 02 - El Molino",
    title = "Diarios de Ruiz: Sobreviviendo a Logan",
    subtitle = "Cinta 02: Diseño del Molino Central",
    author = "Ing. Elena Ruiz",
    extra = "Esquemas de la rueda múltiple.",
    spawning = 1,
    category = "Ruiz-VHS",
    lines = {
        { text = "[Zumbido constante de una turbina de fondo]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Hemos interconectado a veinte infectados en una turbina de eje vertical.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Es brutal, pero la salida de voltaje es increíble. Tenemos calefacción.", r = 0.4, g = 0.8, b = 1.0 },
        { text = "Sin embargo, los sujetos varían en fuerza. Si uno tropieza, los demás lo arrastran.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Regla de diseño: Implementen un sistema de embrague de seguridad por cada celda.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Si un infectado colapsa y no lo desacoplan rápido, sus huesos se trabarán en los engranajes.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Limpiar un fémur astillado de una correa en movimiento es... asqueroso. Y peligroso.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Recomiendo amputar los brazos antes de anclarlos. Solo necesitamos las piernas.", r = 1.0, g = 0.9, b = 0.2 }
    },
};

RecMedia["DiariosRuiz03"] = {
    itemDisplayName = "Diario de Ruiz 03 - Acustica",
    title = "Diarios de Ruiz: Sobreviviendo a Logan",
    subtitle = "Cinta 03: El Problema del Ruido",
    author = "Ing. Elena Ruiz",
    extra = "Control de plagas sonoras.",
    spawning = 1,
    category = "Ruiz-VHS",
    lines = {
        { text = "Logan no advirtió lo suficiente sobre el ruido. Un solo sujeto gruñe. Veinte, rugen.", r = 0.4, g = 0.8, b = 1.0 },
        { text = "Sus vocalizaciones resuenan en la estructura metálica. Atrajeron a una horda masiva el martes.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Casi perdemos el muro oeste. Tuvimos que apagar el Molino para que perdieran interés.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Solución: Hay que recubrir las celdas con espuma aislante, colchones viejos, cualquier cosa.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Y más importante: extirpen las cuerdas vocales o fracturen la mandíbula inferior de las baterías nuevas.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Me tiemblan las manos al escribir esto. Me estoy acostumbrando demasiado a la carnicería.", r = 0.6, g = 0.6, b = 0.6 }
    },
};

RecMedia["DiariosRuiz04"] = {
    itemDisplayName = "Diario de Ruiz 04 - Desgaste",
    title = "Diarios de Ruiz: Sobreviviendo a Logan",
    subtitle = "Cinta 04: Fricción Biológica",
    author = "Ing. Elena Ruiz",
    extra = "Mantenimiento preventivo orgánico.",
    spawning = 1,
    category = "Ruiz-VHS",
    lines = {
        { text = "[Sonido de líquidos goteando. Tos seca.]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Semana 12. La carne muerta es el peor material de construcción posible.", r = 0.4, g = 0.8, b = 1.0 },
        { text = "A diferencia de las máquinas, las 'baterías biológicas' se degradan exponencialmente.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Los tobillos ceden. Los ligamentos se rompen por la fricción constante.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Para extender su vida útil, deben reforzar sus articulaciones con abrazaderas metálicas y cinta adhesiva.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "También he notado que rociarlos con desinfectante retrasa a las larvas.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Si las larvas entran en los motores eléctricos, provocan cortocircuitos masivos.", r = 1.0, g = 0.2, b = 0.2 }
    },
};

RecMedia["DiariosRuiz05"] = {
    itemDisplayName = "Diario de Ruiz 05 - Sector B",
    title = "Diarios de Ruiz: Sobreviviendo a Logan",
    subtitle = "Cinta 05: El Incidente",
    author = "Ing. Elena Ruiz",
    extra = "Riesgos de contagio cruzado.",
    spawning = 1,
    category = "Ruiz-VHS",
    lines = {
        { text = "[Golpes fuertes y alarmas a lo lejos]", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Perdimos a Marcos y a Sarah en el Sector B. Todo por un fallo de presión.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "El sistema de refrigeración de la turbina principal se rompió. Usaba agua a presión.", r = 0.4, g = 0.8, b = 1.0 },
        { text = "El agua se mezcló con los fluidos de las 'baterías' en el piso inferior...", r = 1.0, g = 1.0, b = 1.0 },
        { text = "...y los aspersores rociaron sangre infectada atomizada directamente sobre ellos.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Regla de oro: Separen herméticamente el área de contención del área de maquinaria.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Trabajen siempre con mascarilla respiratoria cerca del Molino. El aire ahí abajo es tóxico.", r = 1.0, g = 0.9, b = 0.2 }
    },
};

RecMedia["DiariosRuiz06"] = {
    itemDisplayName = "Diario de Ruiz 06 - Anomalias",
    title = "Diarios de Ruiz: Sobreviviendo a Logan",
    subtitle = "Cinta 06: Variación de Carga",
    author = "Ing. Elena Ruiz",
    extra = "Clasificación de infectados por potencia.",
    spawning = 1,
    category = "Ruiz-VHS",
    lines = {
        { text = "He descubierto algo inquietante en el rendimiento de ciertos sujetos.", r = 0.4, g = 0.8, b = 1.0 },
        { text = "No todos los infectados generan la misma energía cinética.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Capturamos a un sujeto reciente, un ex-deportista o algo así. Su nivel de agresión es anormal.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Él solo rompió un arnés de acero que soportaría a tres infectados normales.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Si logran capturar infectados 'frescos' y musculosos, conéctenlos a las turbinas pesadas.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Pero usen cadenas dobles. Si se sueltan en la sala del rotor, no habrá a dónde huir.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Logan los llamaba recursos. Yo empiezo a pensar que son motores que nos odian.", r = 0.6, g = 0.6, b = 0.6 }
    },
};

RecMedia["DiariosRuiz07"] = {
    itemDisplayName = "Diario de Ruiz 07 - Avaricia",
    title = "Diarios de Ruiz: Sobreviviendo a Logan",
    subtitle = "Cinta 07: Racionamiento y Motín",
    author = "Ing. Elena Ruiz",
    extra = "El costo social de la energía infinita.",
    spawning = 1,
    category = "Ruiz-VHS",
    lines = {
        { text = "[Voces discutiendo fuertemente de fondo, luego un portazo]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "El consejo del asentamiento está perdiendo la cabeza.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Porque tenemos energía, ahora quieren refrigeradores. Quieren televisores. Quieren lujos.", r = 0.4, g = 0.8, b = 1.0 },
        { text = "Les expliqué que el Molino está al 110%% de su capacidad. Los ejes están cediendo.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Me exigieron que traiga más 'baterías' de la ciudad. Quieren expandir a cuarenta sujetos.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Las estructuras de madera y chatarra no soportarán el torque de cuarenta cuerpos tirando a la vez.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "La avaricia nos matará antes que el virus.", r = 0.6, g = 0.6, b = 0.6 }
    },
};

RecMedia["DiariosRuiz08"] = {
    itemDisplayName = "Diario de Ruiz 08 - Ruptura",
    title = "Diarios de Ruiz: Sobreviviendo a Logan",
    subtitle = "Cinta 08: Sobrecarga del Sistema",
    author = "Ing. Elena Ruiz",
    extra = "Mensaje final. La caída de la utopía.",
    spawning = 1,
    category = "Ruiz-VHS",
    lines = {
        { text = "[Estruendo ensordecedor de metal retorciéndose. Disparos.]", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Ignoraron mis advertencias. Acoplaron diez sujetos más anoche sin mi permiso.", r = 0.4, g = 0.8, b = 1.0 },
        { text = "El torque masivo destrozó el eje central. La fricción inició un incendio en el Sector A.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "El fuego quemó las correas. Las cadenas cedieron. Están todos sueltos adentro.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Cincuenta infectados furiosos, ardiendo, dentro de nuestros muros.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "A quien encuentre esto: Los diseños de Logan funcionan, pero la ambición humana los arruina.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Mantén tu generador pequeño. Trabaja solo. Confía en las máquinas, no en la gente.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Cierro la puerta. Tengo una bala para el generador... y otra para mí.", r = 0.6, g = 0.6, b = 0.6 },
        { text = "[Estática prolongada... silencio.]", r = 0.6, g = 0.6, b = 0.6 }
    },
};


-- VHS SECRETO
RecMedia["DiariosRuiz09"] = {
    itemDisplayName = "Diario de Ruiz 09 - Escape",
    title = "Diarios de Ruiz: Sobreviviendo a Logan",
    subtitle = "Cinta Secreta: Cambio de Planes",
    author = "Ing. Elena Ruiz",
    extra = "El verdadero destino de la ingeniera.",
    spawning = 1,
    category = "Ruiz-VHS",
    lines = {
        { text = "[Tos violenta, sonido de agua corriendo.]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "No lo hice. Puse el cañón en mi sien, pero el Molino crujió...", r = 0.4, g = 0.8, b = 1.0 },
        { text = "Usé la última bala para disparar al tanque de nitrógeno a presión de la sierra industrial.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "La explosión congeló a los infectados que rompieron la puerta. Me dio cinco segundos para correr.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Muldraugh está perdida, pero aprendí la lección. La carne genera calor, y el calor destruye los motores.", r = 0.4, g = 0.8, b = 1.0 },
        { text = "Necesito un sistema de enfriamiento infinito. Necesito el Río Ohio.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Voy hacia Valley Station. Hay una destilería y barcazas abandonadas. Construiré un generador anfibio.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Si alguien sobrevive a las cenizas de este lugar... búscame donde el agua no se detiene.", r = 1.0, g = 1.0, b = 1.0 }
    },
};

-- ======================================================================
-- FASE 5: EL DESCENSO FINAL - LAS CINTAS PERDIDAS (VHS 13 - 18)
-- ======================================================================

RecMedia["CazadoresMuertos13"] = {
    itemDisplayName = "El Despertar del Muerto",
    title = "Cazadores de Muertos: Las Cintas Perdidas",
    subtitle = "Episodio 13: Limbo y Amputación",
    author = "Dr. Logan (?)",
    extra = "Notas sobre cirugía extrema y fiebre.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "[Respiración burbujeante. Un sonido de goteo incesante...]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "No me querían. La máquina me rechazó. La rueda escupió mi sangre.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Corté mi propio brazo izquierdo con una sierra radial. Doce segundos de agonía pura.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "La cauterización con ácido de batería de coche es efectiva al 98%%.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Mi sangre ahora tiene un tono... musgoso. La fiebre me ha dado claridad.", r = 0.2, g = 0.8, b = 0.2 },
        { text = "Ellos no están muertos. Están optimizados. Y yo voy a ayudarlos a mejorar.", r = 0.8, g = 0.2, b = 0.8 }
    },
};

RecMedia["CazadoresMuertos14"] = {
    itemDisplayName = "Carne y Acero",
    title = "Cazadores de Muertos: Las Cintas Perdidas",
    subtitle = "Episodio 14: Injertos Biomecánicos",
    author = "Dr. Logan",
    extra = "Fusionando herramientas con extremidades.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "Un solo brazo humano es ineficiente. Así que construí uno nuevo.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "He soldado el motor de un taladro directamente a los nervios de mi muñón.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Usa tornillos de titanio, no de acero galvanizado. El acero oxida la carne necrosada demasiado rápido.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Duele. Duele tanto que los colores tienen sabor.", r = 1.0, g= 0.2, b = 0.2 },
        { text = "He empezado a aplicar esto a las 'baterías'. Les quito las piernas débiles y les pongo ruedas de carretilla.", r = 0.2, g = 0.8, b = 0.2 },
        { text = "Corren más rápido. La producción de energía subió un 40%%. Gloria a la máquina.", r = 1.0, g = 0.9, b = 0.2 }
    },
};

RecMedia["CazadoresMuertos15"] = {
    itemDisplayName = "Frecuencias del Mas Alla",
    title = "Cazadores de Muertos: Las Cintas Perdidas",
    subtitle = "Episodio 15: El Coro",
    author = "Dr. Logan",
    extra = "Armas sónicas y control mental.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "[Una cacofonía de gemidos distorsionados por altavoces. Es ensordecedor.]", r = 1.0, g = 0.2, b = 0.2 },
        { text = "¿Los escuchan? No gruñen al azar. Es una frecuencia. Un cántico.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "He extirpado las laringes de treinta especímenes. Las he conectado a fuelles compresores.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Emitiendo su llanto a 14 hercios a través de bocinas modificadas, puedes paralizar a una horda.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "O puedes atraer a miles. Miles de piezas de repuesto caminando hacia mi puerta.", r = 0.2, g = 0.8, b = 0.2 },
        { text = "Me sangran los oídos todo el tiempo. Ya no necesito escuchar mis propios pensamientos.", r = 1.0, g = 0.2, b = 0.2 }
    },
};

RecMedia["CazadoresMuertos16"] = {
    itemDisplayName = "Fluidos Corruptos",
    title = "Cazadores de Muertos: Las Cintas Perdidas",
    subtitle = "Episodio 16: Bautismo",
    author = "Dr. Logan",
    extra = "Refinamiento de bilis infectada como combustible.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "El aceite de motor es escaso. Pero ellos... ellos rezuman lubricante natural.", r = 0.2, g = 0.8, b = 0.2 },
        { text = "La bilis negra del estómago infectado es altamente viscosa e inflamable.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Si la filtras con carbón activado, funciona como aceite para motores de dos tiempos.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Ayer me inyecté un poco. Solo unas gotas. Para sentir lo que ellos sienten.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Pude ver la red. Todos estamos conectados por hilos de carne invisible.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Filtros. Tubos. Venas. Todo es lo mismo. Todo es plomería de Dios.", r = 0.6, g = 0.6, b = 0.6 }
    },
};

RecMedia["CazadoresMuertos17"] = {
    itemDisplayName = "El Leviatan Cinetico",
    title = "Cazadores de Muertos: Las Cintas Perdidas",
    subtitle = "Episodio 17: Amalgama",
    author = "Dr. Logan",
    extra = "Construcción de generadores de carne fusionada.",
    spawning = 1,
    category = "Logan-VHS",
    lines = {
        { text = "[Sonido de carne rasgándose. Risas erráticas.]", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Por separado, son débiles. Así que dejé de separarlos.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "He cosido a seis sujetos juntos. Piel con piel. Hueso con hueso.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "El virus los sana mal, los fusiona. Ahora son un solo nódulo muscular gigante.", r = 0.2, g = 0.8, b = 0.2 },
        { text = "Para anclar el Leviatán, necesitarán vigas de acero doble T y cemento de secado rápido.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Produce 4000 vatios ininterrumpidos. Grita con seis bocas a la vez.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Es hermoso. Es mi hijo más perfecto.", r = 1.0, g = 1.0, b = 1.0 },
    },
};

RecMedia["CazadoresMuertos18"] = {
    itemDisplayName = "Singularidad",
    title = "Cazadores de Muertos: Las Cintas Perdidas",
    subtitle = "Episodio 18: Ascensión",
    author = "El Engranaje Logan",
    extra = "La mente en la máquina.",
    spawning = 1,
    category = "LoganC-VHS",
    lines = {
        { text = "[Estática pesada. Un zumbido rítmico profundo, como latidos metálicos.]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Soy el rotor. Soy la correa de transmisión. Soy el cobre y el cartílago.", r = 0.8, g = 0.2, b = 0.8 },
        { text = "Ya no necesito comida. La corriente alterna me alimenta.", r = 0.2, g = 0.8, b = 0.2 },
        { text = "He automatizado los bisturíes. Cuando termine de grabar esto, el Leviatán me devorará...", r = 1.0, g = 1.0, b = 1.0 },
        { text = "...y mi cerebro será el procesador central del generador maestro.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Si escuchas esto, construye. Conecta a los muertos. Únete a la red.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "LA CARNE SE PUDRE. LA RUEDA GIRA ETERNAMENTE.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "[Corte abrupto. Silencio sepulcral.]", r = 0.6, g = 0.6, b = 0.6 },
    },
};

-- ======================================================================
-- HISTORIA SECUNDARIA 2: BITÁCORAS DEL SARGENTO THORNE (CINTAS 01 - 13)
-- RUTAS: Irvington -> Echo Creek -> Rosewood -> March Ridge -> Muldraugh -> West Point -> Valley Station
-- ======================================================================

RecMedia["BitacorasThorne01"] = {
    itemDisplayName = "Bitacora Thorne 01 - AWOL",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 01: Irvington",
    author = "Sgt. Elias Thorne",
    extra = "Separación de la unidad y primer contacto.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "[Sonido de estática de radio de banda militar. Nadie responde.]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Aquí el Sargento Elias Thorne, 3.er Batallón. Si el mando me escucha, Irvington ha caído.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Perdí a mi escuadrón en la retirada. Me refugié en una ferretería tapiada.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Encontré un campamento abandonado en el techo. Alguien estuvo aquí. Una civil, supongo.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Dejó unas cintas VHS. Una ingeniera llamada Ruiz, documentando el trabajo de un psicópata llamado Logan.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Usan a los infectados como animales de carga para generar energía.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Es un crimen de guerra. Pero... mi radio necesita baterías. Y no hay red eléctrica.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Voy a intentar replicar el generador pequeño de Ruiz. Que Dios perdone a este soldado.", r = 1.0, g = 1.0, b = 1.0 }
    },
};

RecMedia["BitacorasThorne02"] = {
    itemDisplayName = "Bitacora Thorne 02 - Aplicacion Tactica",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 02: Triage",
    author = "Sgt. Elias Thorne",
    extra = "Perfeccionamiento militar de la rueda.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "[Golpes secos y metálicos. Un infectado gruñe amortiguado.]", r = 1.0, g = 0.2, b = 0.2 },
        { text = "El diseño de Logan es inestable, y Ruiz era demasiado amable con los anclajes.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Como militar, sé cómo inmovilizar a un prisionero hostil. El Kevlar y las bridas tácticas son clave.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Si envuelves los tobillos del infectado con cinta americana sobre el arnés, evitas que se fracturen.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Cargué mis radios. La zona de exclusión está en silencio total.", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Ruiz dejó mapas marcados apuntando hacia Echo Creek. Creo que buscaba piezas de motores pesados.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Me muevo al amanecer. Si ella tiene un asentamiento con energía, es mi único punto de extracción.", r = 0.4, g = 0.6, b = 0.3 }
    }
};

RecMedia["BitacorasThorne03"] = {
    itemDisplayName = "Bitacora Thorne 03 - Echo Creek",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 03: Rastro Frío",
    author = "Sgt. Elias Thorne",
    extra = "Investigación en la zona rural.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "Llegada a Echo Creek. El lugar es un matadero. Pero no fueron los infectados.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Hay barricadas destruidas de adentro hacia afuera. Cables arrancados.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Ruiz pasó por aquí, seguro. Encontré cajas de herramientas vacías y restos de engranajes.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Los infectados locales tienen los brazos cortados. Ruiz aplicó la doctrina de seguridad.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Sin embargo, los motores que se llevó eran de maquinaria pesada agrícola.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Nota táctica: La correa de un tractor soporta 5 veces más torque que la de un coche.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Las huellas de sus vehículos enfilan al sureste. Hacia la prisión de Rosewood.", r = 0.4, g = 0.6, b = 0.3 }
    }
};

RecMedia["BitacorasThorne04"] = {
    itemDisplayName = "Bitacora Thorne 04 - Rosewood",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 04: Celdas Activas",
    author = "Sgt. Elias Thorne",
    extra = "Defensa perimetral con prisioneros.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "[Sonido de lluvia fuerte, botas sobre concreto.]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Rosewood. La prisión penitenciaria estatal. Ruiz no se quedó, pero saqueó la armería y los talleres.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "El lugar está infestado de reclusos no muertos. Tuve que atrincherarme en la estación de bomberos.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "No tengo munición para limpiar el perímetro. Pero tengo los planos de Logan para defensas cinéticas.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "He capturado a seis infectados con trajes antidisturbios. Su armadura los hace motores invulnerables.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Acoplé sus ruedas de tracción a las sirenas de los camiones de bomberos y cuchillas de descarcelación.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "La horda se destroza contra mis muros sola. Logan estaba loco, pero esto es... eficiente.", r = 1.0, g = 1.0, b = 1.0 }
    }
};

RecMedia["BitacorasThorne05"] = {
    itemDisplayName = "Bitacora Thorne 05 - Caravana Macabra",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 05: Marcha Forzada",
    author = "Sgt. Elias Thorne",
    extra = "Tracción vehicular biológica.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "Ya no queda combustible en Rosewood. Para seguir a Ruiz hacia March Ridge, debo improvisar.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Construí el 'Carroñero'. Un Humvee militar con el motor retirado.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "En su lugar, adapté arneses de tiro. Cuatro infectados antidisturbios tirando del chasis.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Uso un palo largo con una bolsa de sangre fresca como cebo direccional. Como una zanahoria y un burro.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Avanzamos a 15 km/h. Sin ruido de motor. Silencio táctico absoluto.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Los vivos que encuentro en el camino me miran con terror. Creen que soy uno de ellos. Quizá lo sea.", r = 0.6, g = 0.6, b = 0.6 }
    }
};

RecMedia["BitacorasThorne06"] = {
    itemDisplayName = "Bitacora Thorne 06 - March Ridge",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 06: Motín en las Filas",
    author = "Sgt. Elias Thorne",
    extra = "Descubriendo los errores del grupo de Ruiz.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "Llegué a los apartamentos militares de March Ridge. Aquí hubo una guerra civil.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Encontré un campamento de avanzada del grupo de Ruiz. Sangre seca, casquillos de bala. Fuego amigo.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Las cintas de Ruiz hablaban de avaricia. Aquí la veo.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Intentaron usar cincuenta sujetos para electrificar todo un bloque de apartamentos. El eje central colapsó.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Táctico: Si la estructura excede las 3 toneladas de torque, el acero base se deforma y los engranajes saltan.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Rematé a los que estaban atrapados en los escombros. Militares y civiles. Ruiz se retiró al norte, a Muldraugh.", r = 0.4, g = 0.6, b = 0.3 }
    }
};

RecMedia["BitacorasThorne07"] = {
    itemDisplayName = "Bitacora Thorne 07 - Doctrina de Choque",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 07: Armamento Cinetico",
    author = "Sgt. Elias Thorne",
    extra = "Armas de asedio biológicas.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "[Sonido de engranajes tensándose. Un silbido mecánico agudo.]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "La carretera a Muldraugh está bloqueada por cientos. Mi escuadrón habría pedido fuego de mortero.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "No tengo artillería, así que construí mi propia balista autopropulsada.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Usando la tracción de los prisioneros, giran un torno que tensa resortes de suspensión de camiones.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Dispara barras de acero corrugado con fuerza suficiente para atravesar tres cráneos alineados.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "No es una guerra convencional. El enemigo es munición y combustible al mismo tiempo.", r = 0.4, g = 0.6, b = 0.3 }
    }
};

RecMedia["BitacorasThorne08"] = {
    itemDisplayName = "Bitacora Thorne 08 - Muldraugh",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 08: Las Cenizas del Molino",
    author = "Sgt. Elias Thorne",
    extra = "El destino final del asentamiento de Ruiz.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "Entré a los grandes almacenes de Muldraugh (McCoy Logging). O lo que queda de ellos.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Este era el 'Molino' del que hablaba Ruiz. Todo está carbonizado. Huele a cerdo asado y plástico derretido.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Los cincuenta infectados ardientes de los que habló en su cinta final... siguen aquí.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Están fundidos con la maquinaria. El fuego derritió los arneses a sus huesos, pero siguen intentando caminar.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "El calor esterilizó los motores, evitando que la sangre oxidara el cobre. Es una pesadilla funcional.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Voy a entrar a la sala de control. Si Ruiz está ahí, quiero su bitácora técnica de enfriamiento.", r = 0.4, g = 0.6, b = 0.3 }
    }
};

RecMedia["BitacorasThorne09"] = {
    itemDisplayName = "Bitacora Thorne 09 - Cenizas y Esperanza",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 09: Reevaluación",
    author = "Sgt. Elias Thorne",
    extra = "Cambio de misión en Muldraugh.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "Entré a las cenizas de McCoy Logging en Muldraugh. El Molino está destruido.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Buscaba el cadáver de Ruiz, pero encontré un cráter de nitrógeno y una cinta escondida en una caja fuerte antiincendios.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Sigue viva. Es tenaz. Y tiene razón táctica: el enfriamiento por agua fluvial es el único camino viable.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Acoplaré mis prisioneros de tracción a mi transporte y seguiré su rastro por la carretera de Dixie hacia el norte.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Misión actualizada: Localizar a la Ingeniera Ruiz. Ella es el activo estratégico más valioso de Kentucky.", r = 0.4, g = 0.6, b = 0.3 }
    }
};

RecMedia["BitacorasThorne10"] = {
    itemDisplayName = "Bitacora Thorne 10 - Carretera Dixie",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 10: Limpiando la Ruta",
    author = "Sgt. Elias Thorne",
    extra = "Despeje de caminos hacia West Point.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "La carretera hacia West Point está bloqueada por kilómetros de tráfico y hordas masivas.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Apliqué el concepto sónico de Logan. Desplegué altavoces en vehículos abandonados a lo largo del bosque.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Usando un generador cinético atado a un árbol, mantengo las baterías cargadas y el ruido a tope.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "La horda se desvió hacia los árboles, destrozándose contra los troncos buscando el origen del sonido.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Ruiz dejó marcas en los guardarraíles. Tiza reflectante. Sabe que la sigo.", r = 1.0, g = 0.6, b = 0.0 }
    }
};

RecMedia["BitacorasThorne11"] = {
    itemDisplayName = "Bitacora Thorne 11 - West Point",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 11: Centro Urbano",
    author = "Sgt. Elias Thorne",
    extra = "Tácticas de asedio urbano.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "West Point. Esta ciudad es una trampa mortal de concreto.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Ruiz pasó por la ferretería. Saqueó todos los metros de manguera industrial y bombas de agua.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Para cruzar el centro sin disparar, construí una 'Falange Biológica'.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Até a seis infectados con cascos antidisturbios frente a mi vehículo. Los uso como un quitanieves de carne.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Absorben el daño frontal mientras mi motor improvisado avanza a marcha lenta.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Es repugnante, pero el manual de supervivencia no contempla la moralidad.", r = 0.6, g = 0.6, b = 0.6 }
    }
};

RecMedia["BitacorasThorne12"] = {
    itemDisplayName = "Bitacora Thorne 12 - El Puente",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 12: Frontera de Hierro",
    author = "Sgt. Elias Thorne",
    extra = "Cruzando el río hacia Valley Station.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "[Viento helado. Crujidos de acero.]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "El puente hacia Valley Station. El ejército levantó un muro aquí. Y aquí murieron.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Ruiz logró abrir una brecha en la barricada militar usando una grúa puente alimentada por zombis.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Esa mujer es un genio táctico y no lo sabe. Su grúa sigue operativa.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Enganché mi equipo y usé a mis prisioneros para girar el cabestrante y pasar al otro lado.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Estoy oficialmente en Valley Station. El agua del río suena fuerte al fondo.", r = 1.0, g = 1.0, b = 1.0 }
    }
};

RecMedia["BitacorasThorne13"] = {
    itemDisplayName = "Bitacora Thorne 13 - Crossroads",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 13: El Centro Comercial",
    author = "Sgt. Elias Thorne",
    extra = "Cerca del objetivo, rodeado de enemigos.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "El cruce del Crossroads Mall está infestado. Miles de infectados dando vueltas sin rumbo.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Ruiz no entró al centro comercial. Es demasiado inteligente para acorralarse ahí.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Sus huellas neumáticas giran hacia el este, directo a las orillas del Río Ohio.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Mi 'Carroñero' se averió. Dos de mis sujetos de tracción colapsaron por fatiga muscular.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Tuve que sacrificarlos y ocultar mi vehículo bajo ramas. A partir de aquí, avanzo a pie.", r = 0.4, g = 0.6, b = 0.3 }
    }
};

-- THORNE EL ENCUENTRO
RecMedia["BitacorasThorne14"] = {
    itemDisplayName = "Bitacora Thorne 14 - La Orilla",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 14: Agua Helada",
    author = "Sgt. Elias Thorne",
    extra = "El sistema de enfriamiento de Ruiz.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "[Sonido constante de agua fluyendo y turbinas trabajando.]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Alcancé la costa. Ruiz construyó trincheras de drenaje desde el río hasta el interior.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Está bombeando agua fluvial directamente, usándola como un circuito de refrigeración colosal.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Táctico: Si la temperatura de los motores biológicos se mantiene baja, la carne no se degrada.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Y el olor a putrefacción se lava hacia el río. Es un camuflaje olfativo perfecto.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Sigo la tubería principal. La destilería abandonada está a un kilómetro.", r = 1.0, g = 1.0, b = 1.0 }
    }
};

RecMedia["BitacorasThorne15"] = {
    itemDisplayName = "Bitacora Thorne 15 - La Destileria",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 15: Fortaleza",
    author = "Sgt. Elias Thorne",
    extra = "Observación del perímetro de la Ingeniera.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "Estoy usando mis binoculares. La destilería ha sido transformada en un búnker industrial.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Ruiz está usando las barcazas amarradas al muelle como plataformas de generación.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Hay zombis encadenados a molinos de paletas que giran en el agua. Generan hidroelectricidad.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Tiene reflectores antiaéreos operativos. Su perímetro está protegido por cuchillas rotatorias automáticas.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Si intento acercarme sin identificarme, me triturarán igual que a un infectado.", r = 1.0, g = 0.2, b = 0.2 }
    }
};

RecMedia["BitacorasThorne16"] = {
    itemDisplayName = "Bitacora Thorne 16 - Infiltracion",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 16: Puntos Ciegos",
    author = "Sgt. Elias Thorne",
    extra = "Analizando el asedio.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "He pasado tres días observando sus patrones de seguridad.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Las cuchillas rotatorias son letales, pero sus motores se atascan si absorben demasiados cadáveres.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Ruiz tiene que apagar el perímetro oeste al mediodía para limpiar los engranajes con agua a presión.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Esa es mi ventana. Me infiltraré, la desarmaré y negociaré.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "No busco lastimarla. Busco aliarme. Ella es el cerebro, yo soy el cañón.", r = 1.0, g = 1.0, b = 1.0 }
    }
};

RecMedia["BitacorasThorne17"] = {
    itemDisplayName = "Bitacora Thorne 17 - El Asalto",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 17: Brecha",
    author = "Sgt. Elias Thorne",
    extra = "Ingresando a las instalaciones.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "[Respiración agitada. Ruido de metal contra metal.]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Estoy adentro. La sala de máquinas parece el cuarto de calderas del infierno.", r = 1.0, g = 0.2, b = 0.2 },
        { text = "Decenas de infectados pedaleando en grandes rodillos de destilación. Todos bañados por mangueras de agua fría.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "No gimen. Ruiz les colocó silenciadores de mordaza de grado industrial.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Esto es perfecto. Esto es disciplina aplicada a la muerte misma.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Escucho sus pasos. Se acerca con un rifle. Es el momento.", r = 1.0, g = 0.6, b = 0.0 }
    }
};

RecMedia["BitacorasThorne18"] = {
    itemDisplayName = "Bitacora Thorne 18 - Contacto",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 18: Armisticio",
    author = "Sgt. Elias Thorne & Ing. Ruiz",
    extra = "El primer encuentro.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "[RUIZ]: ¡Baja el arma o activo la prensa hidráulica debajo de ti!", r = 0.4, g = 0.8, b = 1.0 },
        { text = "[THORNE]: Sargento Elias Thorne. Leí sus cintas en Muldraugh, Ingeniera.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "[RUIZ]: Imposible. Eso se quemó. Deberías estar muerto.", r = 0.4, g = 0.8, b = 1.0 },
        { text = "Le mostré su cinta secreta. Bajó el arma. Tiene cicatrices de quemaduras en los brazos, pero está lúcida.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Le dije que sus defensas tenían un punto ciego de 12 grados en el flanco este.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Se rió por primera vez en años, creo. 'Pues ayúdame a soldarlo', me dijo.", r = 1.0, g = 0.6, b = 0.0 }
    }
};

RecMedia["BitacorasThorne19"] = {
    itemDisplayName = "Bitacora Thorne 19 - Sinergia",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 19: Cadena de Mando",
    author = "Sgt. Elias Thorne",
    extra = "Mejorando la base en conjunto.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "Día 14 en la base de la Destilería. El trabajo en equipo multiplica la eficiencia.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Ruiz diseñó los sistemas eléctricos. Yo enseño cómo inmovilizar especímenes sin sufrir bajas.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Implementamos mi 'Falange' para excursiones de recolección seguras.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "El Dr. Logan los veía como demonios. El grupo de Muldraugh los veía como esclavos.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Nosotros los vemos como infantería cautiva. Tratados bajo estricto protocolo militar.", r = 0.4, g = 0.6, b = 0.3 }
    }
};

RecMedia["BitacorasThorne20"] = {
    itemDisplayName = "Bitacora Thorne 20 - El Invierno",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 20: Frio Estratégico",
    author = "Sgt. Elias Thorne",
    extra = "Preparación para la caída térmica.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "Llega el invierno. La nieve es nuestra mayor aliada táctica.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "El frío ralentiza el sistema motriz de los infectados salvajes, pero no detiene a nuestros 'motores'.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "Ruiz canalizó el calor de fricción de los generadores para calentar nuestras viviendas.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Las cámaras de tracción ahora están bajo techo, operando al 80%% de capacidad para no desgastarlos.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Tenemos luz, comida enlatada y calor infinito. Sobreviviremos a Knox.", r = 1.0, g = 1.0, b = 1.0 }
    }
};

RecMedia["BitacorasThorne21"] = {
    itemDisplayName = "Bitacora Thorne 21 - Legado Conjunto",
    title = "Bitácora Thorne: Protocolo Caído",
    subtitle = "Capítulo 21: La Nación de Hierro",
    author = "Sgt. Elias Thorne",
    extra = "El mensaje final para el mundo exterior.",
    spawning = 1,
    category = "Thorne-VHS",
    lines = {
        { text = "[Ruido de motores zumbando establemente, música suave de radio de fondo.]", r = 0.6, g = 0.6, b = 0.6 },
        { text = "Si alguien encuentra esta caja de transmisiones, preste atención.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "La humanidad no tiene por qué extinguirse en la oscuridad.", r = 1.0, g = 1.0, b = 1.0 },
        { text = "El monstruo que nos destruyó es también el motor que nos reconstruirá.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "El Dr. Logan puso la idea. La Ingeniera Ruiz la escaló. Y el Ejército le dio orden.", r = 0.4, g = 0.6, b = 0.3 },
        { text = "Somos el Bastión del Río Ohio. Valley Station está asegurada.", r = 1.0, g = 0.6, b = 0.0 },
        { text = "Busquen los postes con reflectantes amarillos a orillas del río.", r = 1.0, g = 0.9, b = 0.2 },
        { text = "Acérquense con las manos vacías y a plena luz del día. Bienvenidos a casa.", r = 0.4, g = 0.6, b = 0.3 }
    }
};



RecMedia["noticiero"] = {
    itemDisplayName = "Noticiero Random", title = "Apocalipsis zombie Siberia", subtitle = "Canal N",
    author = "Editorial JVC", extra = "Recuperado de una importadora", spawning = 1,
    category = "Animado-VHS",
    lines = { { text = "[Estática visual... comienza la reproducción]", r = 0.6, g = 0.6, b = 0.6 } },
};
SincronizarDuracionVHS(RecMedia["noticiero"], 95, 2)


RecMedia["walkin"] = {
    itemDisplayName = "Walkin", title = "Grupo Acumulado de Zombies", subtitle = "Ahhhhhhhh",
    author = "Editorial JVC", extra = "Recuperado de una importadora", spawning = 1,
    category = "Animado-VHS",
    lines = { { text = "[Estática visual... comienza la reproducción]", r = 0.6, g = 0.6, b = 0.6 } },
};
SincronizarDuracionVHS(RecMedia["walkin"], 36, 2)


RecMedia["trailer"] = {
    itemDisplayName = "Trailer PZ", title = "Trailer de un Excelente Juego", subtitle = "Project Zomboid Trailer",
    author = "Editorial JVC", extra = "Recuperado de una importadora", spawning = 1,
    category = "Animado-VHS",
    lines = { { text = "[Estática visual... comienza la reproducción]", r = 0.6, g = 0.6, b = 0.6 } },
};
SincronizarDuracionVHS(RecMedia["trailer"], 319, 2)


RecMedia["ricardo_milos"] = {
    itemDisplayName = "Ricardo Milos", title = "The Goat", subtitle = "Que gozu",
    author = "Editorial JVC", extra = "Recuperado de una importadora", spawning = 1,
    category = "Animado-VHS",
    lines = { { text = "[Estática visual... comienza la reproducción]", r = 0.6, g = 0.6, b = 0.6 } },
};
SincronizarDuracionVHS(RecMedia["ricardo_milos"], 319, 2)


RecMedia["joven"] = {
    itemDisplayName = "Casset sobreviviente", title = "Relato random", subtitle = "Sobrevivió...",
    author = "Editorial JVC", extra = "Recuperado de una importadora", spawning = 1,
    category = "Animado-VHS",
    lines = { { text = "[Estática visual... comienza la reproducción]", r = 0.6, g = 0.6, b = 0.6 } },
};
SincronizarDuracionVHS(RecMedia["joven"], 95, 2)


RecMedia["rickroll"] = {
    itemDisplayName = "Rickroll", title = "Never Gonna Give You Up", subtitle = "Rick Astley",
    author = "Editorial JVC", extra = "Grabación recuperada", spawning = 1,
    category = "Animado-VHS",
    lines = { { text = "[Estática visual... comienza la reproducción]", r = 0.6, g = 0.6, b = 0.6 } },
};
SincronizarDuracionVHS(RecMedia["rickroll"], 319, 2)
