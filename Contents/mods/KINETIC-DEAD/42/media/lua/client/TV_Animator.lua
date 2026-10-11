print("ARCHIVO TV_ANIMATOR CARGADO")
local CustomTVTest = {}

-- =========================================================
-- ESTADOS Y MEMORIA GLOBAL (Gestión interna del script)
-- =========================================================
CustomTVTest.active = {}            -- Almacena las instancias independientes de cada televisión encendida
CustomTVTest.spriteCache = {}       -- Caché tridimensional de texturas: [VideoName][Direccion][Frame]
CustomTVTest.isPreloaded = false    -- Control de seguridad para que la lectura de carpetas ocurra solo 1 vez
CustomTVTest.lastTickTime = 0       -- Reloj global del motor para calcular el Delta Time (tiempo real)

-- =========================================================
-- CONFIGURACIÓN PRINCIPAL (Ajustes y Catálogo)
-- =========================================================
CustomTVTest.AvailableVideos = {    -- Lista de carpetas a escanear (y nombre del Sound Event asociado)
    "boondocks", 
    "joven", 
    "noticiero",
    "trailer",
    "walkin",
    "ricardo_milos",
    "rickroll"
}
CustomTVTest.maxFrames = 315        -- Límite máximo de frames por cada video
CustomTVTest.fps = 2                -- Velocidad objetivo de la reproducción (Frames per second)
CustomTVTest.timePerFrameMs = 1000 / CustomTVTest.fps -- Calcula automáticamente cuánto dura un frame en ms
CustomTVTest.offsetX = 64           -- Ajuste visual en el eje X para alinear el video con el modelo 3D
CustomTVTest.offsetY = 160        -- Ajuste visual en el eje Y para alinear el video con el modelo 3D
-- =========================================================
-- FUNCIÓN DE APAGADO Y LIMPIEZA
-- =========================================================
function CustomTVTest.Stop(screen)
    -- 1. Eliminar el sprite fantasma del mundo
    if screen.dummy and screen.square then
        screen.square:RemoveTileObject(screen.dummy)
        
        -- Invalidar el chunk para forzar la actualización visual
        local chunk = screen.square:getChunk()
        if chunk then
            pcall(chunk.setCacheInvalid, chunk, true)
        end
    end
    
    -- 2. Detener el audio
    --if screen.emitter then
    --    screen.emitter:stopAll()
    --end
end

function CustomTVTest.PreloadAll()
    if CustomTVTest.isPreloaded then return end
    print("[TV-TEST] Iniciando vinculación de texturas desde memoria compartida (.pack)...")
    
    for _, videoName in ipairs(CustomTVTest.AvailableVideos) do
        CustomTVTest.spriteCache[videoName] = { E = {}, S = {} }
        local suffixes = { E = "izq", S = "der" }
        
        -- Prueba rápida: Buscamos el nombre del frame 1 en el registro global de Java
        -- Ejemplo: "ricardo_milos_frame_0001_izq" (El nombre exacto del archivo sin .png)
        local testTexName = videoName .. "_frame_0001_izq"
        local testTex = Texture.getSharedTexture(testTexName)
        
        if testTex then
            print("[TV-TEST] Texturas encontradas en memoria para: " .. videoName)
            for dir, suffix in pairs(suffixes) do
                for frame = 1, CustomTVTest.maxFrames do
                    -- Generamos el string de búsqueda
                    local texName = string.format("%s_frame_%04d_%s", videoName, frame, suffix)
                    
                    -- Intentamos extraer la textura de la VRAM
                    local tex = Texture.getSharedTexture(texName)
                    
                    if tex then
                        local newSprite = IsoSprite.new()
                        -- Cargamos la textura explícita en el sprite sin I/O de disco
                        newSprite:LoadFrameExplicit(texName) 
                        CustomTVTest.spriteCache[videoName][dir][frame] = newSprite
                    end
                end
            end
        else
            print("[TV-TEST] ADVERTENCIA: No se encontró textura en el .pack para: " .. videoName)
        end
    end
    
    CustomTVTest.isPreloaded = true
end
-- =========================================================
-- CREAR PANTALLA Y AUDIO (Instanciación de la TV)
-- =========================================================
function CustomTVTest.Start(isoObject, dirStr, initialFrame, videoName, customOffsetX, customOffsetY)
    if not isoObject then
        print("[TV-TEST] ERROR: isoObject nil.")
        return
    end
    
    local square = isoObject:getSquare()
    if not square then return end

    if not dirStr then
        local okDir, dirResult = pcall(function()
            local sprite = isoObject:getSprite()
            if sprite and sprite:getProperties() and sprite:getProperties():has("Facing") then
                return sprite:getProperties():get("Facing")
            end
            return "N"
        end)
        if okDir and dirResult then dirStr = tostring(dirResult) else dirStr = "N" end
    end
    --[[
    if dirStr ~= "E" and dirStr ~= "S" then
        print("[TV-TEST] TV apuntando a " .. dirStr .. " - No se mostraran frames.")
        return
    end
    ]]
    
    videoName = videoName or CustomTVTest.AvailableVideos[1]
    
    CustomTVTest.PreloadAll()
    
    local okDummy, dummy = pcall(IsoObject.new, getCell(), square, "invisible_01_0")
    if not okDummy or not dummy then return end
    
    local okAdd, resultAdd = pcall(square.AddSpecialObject, square, dummy)
    if not okAdd then return end
    
    --[[
    local emitter = getWorld():getFreeEmitter()
    if emitter then
        emitter:setPos(square:getX(), square:getY(), square:getZ())
        local playRes = emitter:playSound(videoName)
        print("[TV-TEST] Audio lanzado: " .. videoName .. " | ID: " .. tostring(playRes))
    end]]
    
    -- AQUÍ ESTÁ LA MAGIA: Guardamos las coordenadas individualmente
    local screen = {
        tv = isoObject,
        dummy = dummy,
        square = square,
        --emitter = emitter,
        dir = dirStr,
        currentFrame = initialFrame or 1,
        accumulatedTime = 0,
        videoName = videoName,
        -- Si no se pasan coordenadas, usa las base por defecto
        offsetX = customOffsetX or CustomTVTest.offsetX,
        offsetY = customOffsetY or CustomTVTest.offsetY
    }
    
    table.insert(CustomTVTest.active, screen)
    
    CustomTVTest.LoadFrame(screen, screen.currentFrame)
    print("[TV-TEST] Pantalla iniciada en direccion " .. dirStr .. " | Video: " .. videoName .. " | OffsetY Asignado: " .. tostring(screen.offsetY))
end
-- =========================================================
-- CAMBIAR FRAME (AHORA SACA DE LA MEMORIA RAM O SE OCULTA)
-- =========================================================
function CustomTVTest.LoadFrame(screen, frame)
    if not screen or not screen.dummy or not screen.dir or not screen.videoName then return end
    
    -- Si la TV mira a la pared (N o W), la volvemos invisible y abortamos la carga
    if screen.dir == "N" or screen.dir == "W" then
        pcall(screen.dummy.setSpriteFromName, screen.dummy, "invisible_01_0")
        local chunk = screen.square:getChunk()
        if chunk then pcall(chunk.setCacheInvalid, chunk, true) end
        return
    end
    
    -- Si mira al Sur o Este, cargamos su textura normalmente
    local currentSprite = CustomTVTest.spriteCache[screen.videoName][screen.dir][frame]
    if currentSprite then
        pcall(screen.dummy.setOffsetX, screen.dummy, screen.offsetX)
        pcall(screen.dummy.setOffsetY, screen.dummy, screen.offsetY)
        pcall(screen.dummy.setSprite, screen.dummy, currentSprite)
        
        local chunk = screen.square:getChunk()
        if chunk then pcall(chunk.setCacheInvalid, chunk, true) end
    end
end
-- =========================================================
-- ANIMACIÓN (SINCRONIZADA Y PROTEGIDA CONTRA PAUSAS)
-- =========================================================
function CustomTVTest.OnTick()
    local currentTime = getTimeInMillis()
    if CustomTVTest.lastTickTime == 0 then CustomTVTest.lastTickTime = currentTime end
    local deltaTime = currentTime - CustomTVTest.lastTickTime
    CustomTVTest.lastTickTime = currentTime
    
    -- === 1. ESCUDO DE PAUSA (Menú ESC) ===
    -- Si la velocidad del juego es 0 (Pausa), el audio se congela.
    -- Por lo tanto, no avanzamos los frames del video.
    local speedControls = UIManager.getSpeedControls()
    if speedControls and speedControls:getCurrentGameSpeed() == 0 then
        return 
    end
    
    -- === 2. ESCUDO DE ALT-TAB (Salto de tiempo) ===
    -- Al volver al juego, el deltaTime será enorme. 
    -- Si es mayor a 250ms (un cuarto de segundo en 1 frame), lo consideramos un salto 
    -- y lo limitamos a un frame normal (16ms) para mantener la sincronía con el audio.
    if deltaTime > 250 then
        deltaTime = 16
    end
    
    if #CustomTVTest.active == 0 then return end

    -- Procesamos cada televisión encendida por separado
    for i = #CustomTVTest.active, 1, -1 do
        local screen = CustomTVTest.active[i]
        
        if screen and screen.dummy and screen.square then
            -- Sumar el tiempo filtrado a esta TV
            screen.accumulatedTime = screen.accumulatedTime + deltaTime
            
            if screen.accumulatedTime >= CustomTVTest.timePerFrameMs then
                local framesToAdvance = math.floor(screen.accumulatedTime / CustomTVTest.timePerFrameMs)
                screen.accumulatedTime = screen.accumulatedTime - (framesToAdvance * CustomTVTest.timePerFrameMs)
                
                -- Avanzar el frame de esta TV
                screen.currentFrame = screen.currentFrame + framesToAdvance
                
                if screen.currentFrame > CustomTVTest.maxFrames then
                    screen.currentFrame = ((screen.currentFrame - 1) % CustomTVTest.maxFrames) + 1
                end
                
                CustomTVTest.LoadFrame(screen, screen.currentFrame)
            end
        else
            -- Si la TV dejó de existir en el mundo, la limpiamos
            table.remove(CustomTVTest.active, i)
        end
    end
end
Events.OnTick.Add(CustomTVTest.OnTick)
-- =========================================================
-- MENÚ DE PRUEBA
-- =========================================================
local function TVTestMenu(playerIndex, context, worldobjects, test)
    local player = getSpecificPlayer(playerIndex)
    for _, obj in ipairs(worldobjects) do
        if obj and obj.getObjectName and obj:getObjectName() == "Television" then
            
            -- [NUEVO CÓDIGO AQUÍ] Forzamos el escaneo de carpetas antes de armar el menú
            if not CustomTVTest.isPreloaded then
                CustomTVTest.PreloadAll()
            end
            
            -- Botón para Analizar Altura, Muebles y Dirección
            context:addOption("[DEBUG] Analizar Altura y Direccion", obj, function(clickedObj)
                if not clickedObj then return end
                
                local square = clickedObj:getSquare()
                if not square then return end
                
                -- 1. Obtener la Dirección (Orientación) de la TV
                local directionStr = "Desconocida"
                
                -- Intento A: getFacing() (El motor a veces devuelve 'N' por defecto en objetos estáticos)
                local okFacing, facing = pcall(function() return clickedObj:getFacing() end)
                if okFacing and facing then
                    directionStr = tostring(facing)
                end
                -- 2. Obtener la elevación visual del televisor
                local renderYOffset = 0
                if clickedObj.getRenderYOffset then
                    renderYOffset = clickedObj:getRenderYOffset()
                end
                
                -- 3. Variables para el mueble
                local furnitureName = "Ninguno"
                local surfaceHeight = 0
                
                -- 4. Recorrer los objetos para buscar la mesa
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local sqObj = objects:get(i)
                    
                    if sqObj ~= clickedObj then
                        local okProp, hasProp = pcall(function() 
                            return sqObj:hasProperty("IsSurface") or sqObj:hasProperty("IsTable") or sqObj:hasProperty("Surface")
                        end)
                        
                        if okProp and hasProp then
                            local okHeight, h = pcall(function() return sqObj:getSurfaceOffsetNoTable() end)
                            if okHeight and h then
                                surfaceHeight = h
                            end
                            
                            local okName, name = pcall(function() return sqObj:getObjectName() end)
                            if okName and name and name ~= "IsoObject" then
                                furnitureName = tostring(name)
                            else
                                furnitureName = "Mesa"
                            end
                            
                            break
                        end
                    end
                end
                
                -- 5. Mostrar Resultados
                local spriteName = clickedObj:getSprite():getName()
                print("[TV-DEBUG] Sprite detectado: " .. tostring(spriteName))
                
                local msg1 = string.format("TV Dir: %s | RenderY: %d", directionStr, renderYOffset)
                local msg2 = string.format("Mueble: %s | Elevacion: %d", furnitureName, surfaceHeight)
                
                print("[TV-TEST-DEBUG] " .. msg1)
                print("[TV-TEST-DEBUG] " .. msg2)
                
                local player = getSpecificPlayer(playerIndex)
                if player then
                    player:setHaloNote(msg1 .. " | " .. msg2, 255, 255, 0, 600)
                end
            end)
            break
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(TVTestMenu)
_G.CustomTVTest = CustomTVTest
print("[TV-TEST] CustomTVTest cargado correctamente.")




-- 1. INTERCEPTAR EL INICIO DE LA ROTACIÓN
local original_ISMoveablesAction_start = ISMoveablesAction.start

function ISMoveablesAction:start()
    print("PRIMERA FUNCION")
    -- Ejecutamos la función original del juego primero
    original_ISMoveablesAction_start(self)
    
    -- Verificamos si la acción es "rotación"
    if self.mode == "rotate" and self.object then
        local objName = ""
        local okName, name = pcall(function() return self.object:getObjectName() end)
        if okName and name then
            objName = tostring(name)
        end
        
        -- Si es un televisor, mostramos el aviso inicial
        if objName == "Television" then
            if self.character then
                self.character:setHaloNote("Iniciando rotacion de TV...", 255, 150, 0, 300)
            end
        end
    end
end
-- =========================================================
-- INTERCEPCIÓN DE MUEBLES (RECOGER Y ROTAR INTELIGENTE)
-- =========================================================
local original_ISMoveablesAction_complete = ISMoveablesAction.complete

function ISMoveablesAction:complete()
    local isRotate = (self.mode == "rotate")
    local isPickup = (self.mode == "pickup")
    
    -- === 1. SECUESTRO PRE-ROTACIÓN (Salvar el audio) ===
    local oldDevice = nil
    local backupAudio = nil
    
    if isRotate and self.object then
        oldDevice = self.object:getDeviceData()
        -- Si la TV estaba sonando, guardamos su audio y la borramos de la mira del apagador
        if oldDevice and _G.CintasActivasTV and _G.CintasActivasTV[oldDevice] then
            backupAudio = _G.CintasActivasTV[oldDevice]
            _G.CintasActivasTV[oldDevice] = nil 
        end
    end

    -- === 2. RECOGER (Destrucción total) ===
    if isPickup and self.object then
        -- ESCUDO: Solo le pedimos datos si el objeto es un transmisor de ondas (TV o Radio)
        if instanceof(self.object, "IsoWaveSignal") then
            local okData, deviceData = pcall(function() return self.object:getDeviceData() end)
            
            if okData and deviceData then
                -- En Zomboid, preguntar 'if deviceData.metodo then' puede causar crashes. 
                -- Es mucho más seguro forzar la acción dentro de pcalls individuales.
                pcall(function() deviceData:setIsTurnedOn(false) end)
                --pcall(function() deviceData:stopPlayMedia() end)
            end
        end
        
        -- Limpiamos nuestra animación de la pantalla y la memoria
        for i = #CustomTVTest.active, 1, -1 do
            local screen = CustomTVTest.active[i]
            if screen.square == self.square then
                CustomTVTest.Stop(screen)
                table.remove(CustomTVTest.active, i)
                break
            end
        end
    end
    -- ERROR DE INSTANCIA INEXISTENTE DE OBJETOS
    --[[
    -- === 2. RECOGER (Destrucción total) ===
    if isPickup and self.object then
        local okData, deviceData = pcall(function() return self.object:getDeviceData() end)
        if okData and deviceData then
            if deviceData.setIsTurnedOn then deviceData:setIsTurnedOn(false) end
            if deviceData.stopPlayMedia then deviceData:stopPlayMedia() end
        end
        
        for i = #CustomTVTest.active, 1, -1 do
            local screen = CustomTVTest.active[i]
            if screen.square == self.square then
                CustomTVTest.Stop(screen)
                table.remove(CustomTVTest.active, i)
                break
            end
        end
    end]]
    
    -- Ejecutamos la acción nativa de Java (Aquí se destruye la TV vieja y nace la nueva)
    local result = original_ISMoveablesAction_complete(self)
    
    -- === 3. RESTAURACIÓN POST-ROTACIÓN (Reconectar audio y video) ===
    if isRotate and self.square then
        local tvObject = nil
        local objects = self.square:getObjects()
        
        for i = 0, objects:size() - 1 do
            local sqObj = objects:get(i)
            local okName, name = pcall(function() return sqObj:getObjectName() end)
            if okName and name and (string.match(name, "Tv") or string.match(name, "Television")) then
                tvObject = sqObj
                break
            end
        end

        if tvObject then
            -- A. Restaurar el Enlace de Audio a la nueva TV nativa
            local newDevice = tvObject:getDeviceData()
            if newDevice and backupAudio then
                newDevice:setIsTurnedOn(true)
                -- Engañamos a Java para que empiece a reproducir y el OnTick no lo mate
                if type(newDevice.startPlayMedia) == "function" then
                    newDevice:startPlayMedia() 
                end
                _G.CintasActivasTV[newDevice] = backupAudio -- Le devolvemos el audio salvado
            end

            -- B. Restaurar la Animación Visual
            local directionStr = "N"
            local okDir, dirResult = pcall(function() 
                return tvObject:getSprite():getProperties():get("Facing") 
            end)
            if okDir and dirResult then directionStr = tostring(dirResult) end
            
            for i = 1, #CustomTVTest.active do
                if CustomTVTest.active[i].square == self.square then
                    CustomTVTest.active[i].tv = tvObject 
                    CustomTVTest.active[i].dir = directionStr
                    -- Refresca la imagen instantáneamente sin perder el segundo actual
                    CustomTVTest.LoadFrame(CustomTVTest.active[i], CustomTVTest.active[i].currentFrame)
                    break
                end
            end
        end
    end
    
    return result
end
-- GIJSAW
--[[
-- =========================================================
-- COMANDO MASIVO: ENCENDER TVs EN RADIO
-- =========================================================
function CustomTVTest.ActivarTVsEnRadio(player, videoName, radius)
    -- 1. Validar que la carpeta de video exista en el catálogo
    local videoValido = false
    for _, v in ipairs(CustomTVTest.AvailableVideos) do
        if v == videoName then
            videoValido = true
            break
        end
    end

    if not videoValido then
        player:setHaloNote("Error: Carpeta de video no encontrada", 255, 0, 0, 300)
        return
    end

    -- 2. Asegurar precarga
    if not CustomTVTest.isPreloaded then
        CustomTVTest.PreloadAll()
    end

    local cell = getCell()
    local px = math.floor(player:getX())
    local py = math.floor(player:getY())
    local pz = math.floor(player:getZ())

    local tvsEncendidas = 0

    -- 3. Escanear el radio (Ej: 10x10)
    for x = px - radius, px + radius do
        for y = py - radius, py + radius do
            local square = cell:getGridSquare(x, y, pz)
            if square then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local sqObj = objects:get(i)
                    local okName, name = pcall(function() return sqObj:getObjectName() end)
                    
                    if okName and name and (string.match(name, "Tv") or string.match(name, "Television")) then
                        -- Extraer dirección de la TV
                        local directionStr = "N"
                        local okDir, dirResult = pcall(function()
                            local sprite = sqObj:getSprite()
                            if sprite and sprite:getProperties() and sprite:getProperties():has("Facing") then
                                return sprite:getProperties():get("Facing")
                            end
                            return nil
                        end)
                        if okDir and dirResult then directionStr = tostring(dirResult) end
                        
                        -- Solo encendemos si la TV permite frames (E o S)
                        if directionStr == "E" or directionStr == "S" then
                            
                            -- Si la tele ya estaba encendida con otra cosa, la apagamos primero
                            for j = #CustomTVTest.active, 1, -1 do
                                if CustomTVTest.active[j].tv == sqObj then
                                    CustomTVTest.Stop(CustomTVTest.active[j])
                                    table.remove(CustomTVTest.active, j)
                                    break
                                end
                            end
                            
                            -- Encendemos la TV enviándole el objeto, la dirección, frame 1 y el video
                            CustomTVTest.Start(sqObj, directionStr, 1, videoName)
                            tvsEncendidas = tvsEncendidas + 1
                        end
                    end
                end
            end
        end
    end
    
    player:setHaloNote("Seal de origen: " .. tvsEncendidas .. " TVs reproduciendo " .. videoName, 0, 255, 100, 400)
end



-- =========================================================
-- MENÚ GLOBAL PARA ACTIVACIÓN EN ÁREA
-- =========================================================
local function AreaTVMenu(playerIndex, context, worldobjects, test)
    local player = getSpecificPlayer(playerIndex)
    if not player then return end

    -- Opción principal en el click derecho
    local masiveOption = context:addOption("[DEBUG] TRANSMISION MASIVA (10x10)", nil, nil)
    local subMenuMasive = context:getNew(context)
    context:addSubMenu(masiveOption, subMenuMasive)

    -- Leemos la tabla AvailableVideos para armar el submenú dinámico
    for _, videoName in ipairs(CustomTVTest.AvailableVideos) do
        -- Al hacer clic en un video, llamamos a la función de radio pasándole el nombre de la carpeta
        subMenuMasive:addOption("Activar: " .. videoName, player, function(p)
            CustomTVTest.ActivarTVsEnRadio(p, videoName, 10)
        end)
    end
    
    -- Botón de pánico para apagar todas las TVs en el radio
    subMenuMasive:addOption("APAGAR TODAS", player, function(p)
        for i = #CustomTVTest.active, 1, -1 do
            CustomTVTest.Stop(CustomTVTest.active[i])
            table.remove(CustomTVTest.active, i)
        end
        p:setHaloNote("Todas las TVs forzadas a apagarse.", 255, 0, 0, 300)
    end)
end

Events.OnFillWorldObjectContextMenu.Add(AreaTVMenu)

]]