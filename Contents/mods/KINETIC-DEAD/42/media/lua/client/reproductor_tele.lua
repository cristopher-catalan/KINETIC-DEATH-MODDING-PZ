print("ARCHIVO REPRODUCTOR_TELE CARGADO")
_G.TV_Specs = {
    -- El nombre del sprite actÃºa como llave. Cada direcciÃ³n (N, S, E, O) tiene un sprite distinto.
    -- AquÃ­ configuramos los cÃ¡lculos matemÃ¡ticos para cada tipo de TV.
    
    -- =====================================
    -- TV ANTIGUA (TvAntique)
    -- =====================================
    ["appliances_television_02_1"] = { tipo = "TvAntique", dir = "S", offsetX = 64, offsetY = 192, escala = 1.0 },
    ["appliances_television_02_0"] = { tipo = "TvAntique", dir = "E", offsetX = 64, offsetY = 192, escala = 1.0 },
    -- =====================================
    -- TV MODERNA / WIDESCREEN (TvWideScreen)
    -- =====================================
    ["appliances_television_01_1"] = { tipo = "TvWideScreen", dir = "S", offsetX = 64, offsetY = 192, escala = 1.5 },
    ["appliances_television_01_0"] = { tipo = "TvWideScreen", dir = "E", offsetX = 64, offsetY = 192, escala = 1.5 },
    -- =====================================
    -- TV NEGRA (TvBlack)
    -- =====================================
    ["appliances_television_01_4"] = { tipo = "TvBlack", dir = "S", offsetX = 64, offsetY = 192, escala = 1.2 },
    ["appliances_television_01_5"] = { tipo = "TvBlack", dir = "E", offsetX = 64, offsetY = 192, escala = 1.2 },
}
_G.CintasActivasTV = {}
local CintasActivas = _G.CintasActivasTV
local MAX_DIST = 15.0 -- Distancia mÃ¡xima en casillas para escuchar la TV
local function IniciarControladorAudioVHS()
    print("[KINETIC-DEBUG] Inicializando controlador de audio VHS y Enlace Visual...")
    -- ==========================================
    -- FunciÃ³n para silenciar la estÃ¡tica y voces desde la raÃ­z de Java
    -- ==========================================
    local function SilenciarEstatica(silenciar)
        local volumen = silenciar and 0.0 or 1.0
        
        -- Lista de todos los ruidos y voces nativas de TV/Radio
        local sonidosMute = {
            "TelevisionTestBeep", 
            "TelevisionZap", 
            "RadioStatic",
            "RadioTalk", 
            "VehicleRadioProgram", 
            "BroadcastEmergency"
        }
        
        for _, nombre in ipairs(sonidosMute) do
            local s = GameSounds.getSound(nombre)
            if s then s:setUserVolume(volumen) end
        end
    end
    local function FrenarAudio(deviceData)
        if not deviceData then return end
        --local emitter = deviceData:getEmitter()
        local emitter = CintasActivas[deviceData] and CintasActivas[deviceData].freeEmitter or deviceData:getEmitter()
        if emitter and CintasActivas[deviceData] then
            local datosAudio = CintasActivas[deviceData]
            if datosAudio.id and type(emitter.stopSound) == "function" then 
                emitter:stopSound(datosAudio.id) 
            end
            if datosAudio.nombre and type(emitter.stopSoundByName) == "function" then 
                emitter:stopSoundByName(datosAudio.nombre) 
                
                -- Restauramos el volumen maestro del sonido al expulsar la cinta
                local s = GameSounds.getSound(datosAudio.nombre)
                if s then s:setUserVolume(1.0) end
            end
        end
        
        CintasActivas[deviceData] = nil 
        
        -- Verificar si quedan cintas sonando en el mundo; si no, restaurar la estÃ¡tica
        local quedanCintas = false
        for k, v in pairs(CintasActivas) do
            quedanCintas = true
            break
        end
        
        if not quedanCintas then 
            SilenciarEstatica(false) 
        end
        
        local tvObject = deviceData:getParent()
        if tvObject and _G.CustomTVTest then
            for i = #_G.CustomTVTest.active, 1, -1 do
                if _G.CustomTVTest.active[i].tv == tvObject then
                    _G.CustomTVTest.Stop(_G.CustomTVTest.active[i])
                    table.remove(_G.CustomTVTest.active, i)
                    break
                end
            end
        end
    end
    -- ==========================================
    -- 1. SECUESTRO DEL BOTÃ“N "PLAY / STOP"
    -- ==========================================
    local original_TogglePlayMedia = ISRadioAction.performTogglePlayMedia
    
    function ISRadioAction:performTogglePlayMedia()
        local deviceData = self.deviceData
        if not deviceData then 
            original_TogglePlayMedia(self)
            return 
        end
        
        local tvObject = deviceData:getParent()
        
        -- 1. IDENTIFICACIÃ“N Y FILTRADO DEL MODELO (BLINDADO ANTI-CRASH)
        local spriteName = "Desconocido"
        
        -- Verificamos que tvObject exista y que ADEMÃ�S tenga la funciÃ³n getSprite (Solo los IsoObjects la tienen, los Items de inventario no)
        if tvObject and type(tvObject.getSprite) == "function" then
            local sprite = tvObject:getSprite()
            if sprite and sprite:getName() then
                spriteName = sprite:getName()
            end
        end
        
        local calculos = TV_Specs[spriteName]
        local esTVModerna = (calculos ~= nil)
        local yaEstabaSonando = CintasActivas[deviceData] ~= nil
        
        if yaEstabaSonando then
            print("[KINETIC-DEBUG] Apagando VHS...")
            FrenarAudio(deviceData) 
            original_TogglePlayMedia(self)
            
            if esTVModerna and tvObject and _G.CustomTVTest then
                for i = #_G.CustomTVTest.active, 1, -1 do
                    if _G.CustomTVTest.active[i].tv == tvObject then
                        _G.CustomTVTest.Stop(_G.CustomTVTest.active[i])
                        table.remove(_G.CustomTVTest.active, i)
                        print("[TV-DETECTOR] Animacion visual Widescreen apagada y destruida.")
                        break
                    end
                end
            end
        else
            original_TogglePlayMedia(self)
            
            if deviceData:isPlayingMedia() then
                local mediaData = deviceData:getMediaData()
                if mediaData then
                    -- BLINDAJE ANTI-CRASH PARA CD PLAYERS U OTROS MODS
                    if type(mediaData.getAuthorEN) ~= "function" or type(mediaData.getId) ~= "function" then
                        return
                    end
                    
                    local author = mediaData:getAuthorEN()
                    local nombreDelSonido = mediaData:getId()
                    
                    if nombreDelSonido and self.character then
                        _G.KineticDeadTrackedMedia = _G.KineticDeadTrackedMedia or {}
                        _G.KineticDeadTrackedMedia[deviceData] = { player = self.character or getPlayer(), media = mediaData }
                    end
                    if not author or not nombreDelSonido then return end
                    
                    -- ESTA LÃ�NEA ES CLAVE PARA LOS AUTORES SI ES DIFERENTE NO SE REPRODUCE
                    --if author == "Dr. Logan" or author == "Animaciones Custom" then 
                    if author == "Editorial JVC" then
                        -- NUEVO: Emisor independiente de la destrucciÃ³n de la TV
                        local tvObject = deviceData:getParent()
                        local emitter = getWorld():getFreeEmitter(tvObject:getX(), tvObject:getY(), tvObject:getZ())
                        local nombreDelSonido = mediaData:getId()
                        if emitter then
                            SilenciarEstatica(true)
                            
                            local soundID = 0
                            if type(emitter.playSound) == "function" then
                                soundID = emitter:playSound(nombreDelSonido)
                            end
                            
                            -- Guardamos el freeEmitter en la memoria
                            CintasActivas[deviceData] = { 
                                id = soundID, 
                                nombre = nombreDelSonido, 
                                volumenUI = deviceData:getDeviceVolume(),
                                freeEmitter = emitter
                            }
                        end
                        -- === INYECCIÃ“N VISUAL Y RESTRICCIONES SEGÃšN EL TIPO DE TV ===
                        if calculos then
                            if calculos.tipo == "TvWideScreen" and tvObject and _G.CustomTVTest then
                                print(string.format("[TV-DETECTOR] TV Compatible (%s) detectada. Calibrando coordenadas...", calculos.tipo))
                                
                                local elevacion = 0
                                local square = tvObject:getSquare()
                                
                                if square then
                                    local objects = square:getObjects()
                                    for i = 0, objects:size() - 1 do
                                        local sqObj = objects:get(i)
                                        if sqObj ~= tvObject then
                                            local okProp, hasProp = pcall(function() return sqObj:hasProperty("IsSurface") or sqObj:hasProperty("IsTable") or sqObj:hasProperty("Surface") end)
                                            if okProp and hasProp then
                                                local okHeight, h = pcall(function() return sqObj:getSurfaceOffsetNoTable() end)
                                                if okHeight and h then elevacion = h end
                                                break 
                                            end
                                        end
                                    end
                                end
                                
                                local finalOffsetY = calculos.offsetY + (2 * elevacion)
                                --local factorCompensacionX = 0.5 
                                local finalOffsetX = calculos.offsetX -- math.floor(elevacion * factorCompensacionX)
                                
                                _G.CustomTVTest.Start(tvObject, calculos.dir, 1, nombreDelSonido, finalOffsetX, finalOffsetY)
                            elseif calculos.tipo == "TvBlack" then
                                if self.character then self.character:setHaloNote("Formato no soportado. Mejor busco un Tv Premium", 255, 50, 50, 300) end
                                print("[TV-DETECTOR] TV Negra detectada. Formato visual no soportado. Reproduciendo solo audio.")
                            else
                                print(string.format("[TV-DETECTOR] TV tipo '%s' detectada. Reproduciendo solo audio nativo.", calculos.tipo))
                            end
                        else
                            print("[TV-DETECTOR] TV Incompatible o no registrada. Reproduciendo solo audio nativo.")
                        end
                    end
                end
            end
        end
    end
    -- =========================================================
    -- FUNCIÃ“N PARA INICIAR EL SONIDO (Llamar al encender el VHS)
    -- =========================================================
    local function IniciarSonidoTV(deviceData, tvX, tvY, tvZ, videoName, initialVolume)
        local emitter = getWorld():getFreeEmitter(tvX, tvY, tvZ)
        local soundID = emitter:playSound(videoName)
        if soundID then
            -- Guardamos la informaciÃ³n especÃ­fica de ESTA televisiÃ³n
            CintasActivas[deviceData] = {
                emitter = emitter,
                soundID = soundID,
                x = tvX,
                y = tvY,
                z = tvZ,
                volumenUI = initialVolume or 0.5
            }
            emitter:setVolume(soundID, CintasActivas[deviceData].volumenUI)
        end
    end
    -- ==========================================
    -- INTERCEPTAR MENSAJE DE VOLUMEN DE LA TV
    -- ==========================================
    -- 1. Cuando cambias el volumen con la perilla
    local original_performSetVolume = ISRadioAction.performSetVolume
    function ISRadioAction:performSetVolume()
        original_performSetVolume(self)
        
        local nuevoVolumen = self.secondaryItem
        
        -- Actualizamos SOLO el volumen de la TV que estamos tocando
        if self.deviceData and CintasActivas[self.deviceData] then
            CintasActivas[self.deviceData].volumenUI = nuevoVolumen
        end
        
        if self.character then self.character:setHaloNote("Volumen: " .. tostring(nuevoVolumen)) end
    end
    -- 2. Cuando presionas el botÃ³n de MUTE (Silenciar)
    local original_performMuteVolume = ISRadioAction.performMuteVolume
    function ISRadioAction:performMuteVolume()
        original_performMuteVolume(self)
        
        if self.deviceData and CintasActivas[self.deviceData] then
            CintasActivas[self.deviceData].volumenUI = 0.0
        end
        
        if self.character then self.character:setHaloNote("Volumen: MUTE") end
    end
    -- 3. Cuando quitas el MUTE (Restaurar volumen)
    local original_performUnMuteVolume = ISRadioAction.performUnMuteVolume
    function ISRadioAction:performUnMuteVolume()
        original_performUnMuteVolume(self)
        
        local volumenRestaurado = self.secondaryItem
        
        if self.deviceData and CintasActivas[self.deviceData] then
            CintasActivas[self.deviceData].volumenUI = volumenRestaurado
        end
        
        if self.character then self.character:setHaloNote("Volumen: " .. tostring(volumenRestaurado)) end
    end
    local original_ToggleOnOff = ISRadioAction.performToggleOnOff
    function ISRadioAction:performToggleOnOff()
        if self.deviceData and self.deviceData:getIsTurnedOn() and CintasActivas[self.deviceData] then
            FrenarAudio(self.deviceData)
        end
        original_ToggleOnOff(self)
    end
    -- ==========================================
    -- 3. EL VIGILANTE DE AUDIO DINÃ�MICO (CÃ¡lculo de Distancia Per-TV)
    -- ==========================================
    local function VigilarCintasTerminadas()
        local p = getPlayer()
        if not p then return end
        
        -- Capturamos la posiciÃ³n actual del jugador
        local px = p:getX()
        local py = p:getY()
        local pz = p:getZ()
        for deviceData, datosAudio in pairs(CintasActivas) do
            if deviceData then
                -- Si se acabÃ³ la cinta, expulsaron o apagaron
                if not deviceData:isPlayingMedia() or not deviceData:hasMedia() or not deviceData:getIsTurnedOn() then
                    FrenarAudio(deviceData)
                else
                    --local emitter = deviceData:getEmitter()
                    local emitter = datosAudio.freeEmitter or deviceData:getEmitter()
                    if emitter then
                        -- 1. Asesinamos la estÃ¡tica de Java permanentemente
                        if deviceData:getIsTelevision() then
                            if type(emitter.stopSoundByName) == "function" then
                                emitter:stopSoundByName("TelevisionTestBeep")
                                emitter:stopSoundByName("TelevisionZap")
                                emitter:stopSoundByName("RadioStatic")
                                emitter:stopSoundByName("RadioTalk")
                                emitter:stopSoundByName("VehicleRadioProgram")
                                emitter:stopSoundByName("BroadcastEmergency")
                            end
                        else
                            if type(emitter.stopSoundByName) == "function" then
                                emitter:stopSoundByName("RadioStatic")
                            end
                        end
                        
                        -- 2. CÃ¡lculo de atenuaciÃ³n segÃºn distancia para ESTA televisiÃ³n en particular
                        local volTV = datosAudio.volumenUI or deviceData:getDeviceVolume() -- Leemos el volumen de su interfaz
                        local finalVolume = 0.0
                        local tvObject = deviceData:getParent()
                        
                        -- Solo calculamos sonido si la tele tiene el volumen mayor a 0
                        if tvObject and volTV > 0 then
                            local tx = tvObject:getX()
                            local ty = tvObject:getY()
                            local tz = tvObject:getZ()
                            
                            -- Requisito: que el jugador estÃ© en la misma altura (piso) que la TV
                            if math.floor(pz) == math.floor(tz) then
                                local dx = px - tx
                                local dy = py - ty
                                local distancia = math.sqrt(dx * dx + dy * dy)
                                
                                if distancia < MAX_DIST then
                                    local factor = 1.0 - (distancia / MAX_DIST)
                                    finalVolume = volTV * factor
                                end
                            end
                        end
                        
                        -- Clamping de seguridad (nunca menor a 0 ni mayor a 1)
                        finalVolume = math.max(0.0, math.min(1.0, finalVolume))
                        
                        -- 3. Aplicamos el volumen final atenuado SOLO AL EMISOR (LÃ­neas de GameSounds eliminadas)
                        if type(emitter.setVolumeAll) == "function" then
                            emitter:setVolumeAll(finalVolume)
                        elseif datosAudio.id and type(emitter.setVolume) == "function" then
                            emitter:setVolume(datosAudio.id, finalVolume)
                        end
                    end
                end
            end
        end
    end
    
    Events.OnTick.Add(VigilarCintasTerminadas)
end
Events.OnGameStart.Add(IniciarControladorAudioVHS)
-- Desbloquea la contención tras el primer relato y la rueda tras el segundo.
_G.KineticDeadTrackedMedia = _G.KineticDeadTrackedMedia or {}
local function KineticDeadGrantLearning(player, mediaId)
    if not player or not mediaId then return end
    local data = player:getModData()
    data.KineticDeadKnowledge = data.KineticDeadKnowledge or {}
    local known = data.KineticDeadKnowledge
    if mediaId == "CazadoresMuertos01" and not known.captura then
        known.captura = true
        player:Say(getText("IGUI_KineticDead_LearnedCapture"))
    elseif mediaId == "CazadoresMuertos02" and not known.rueda then
        known.rueda = true
        local ok, recipes = pcall(function() return player:getKnownRecipes() end)
        if ok and recipes then
            pcall(function() recipes:add("Rueda_Estructura") end)
            pcall(function() recipes:add("Base.Rueda_Estructura") end)
        end
        player:Say(getText("IGUI_KineticDead_LearnedWheel"))
    end
end
Events.OnTick.Add(function()
    local tracked = _G.KineticDeadTrackedMedia
    if not tracked then return end
    local recordedMedia = getZomboidRadio():getRecordedMedia()
    for device, session in pairs(tracked) do
        local ok, complete = pcall(function()
            return recordedMedia:hasListenedToAll(session.player, session.media)
        end)
        if ok and complete then
            KineticDeadGrantLearning(session.player, session.media:getId())
            tracked[device] = nil
        elseif not session.player or session.player:isDead() then
            tracked[device] = nil
        end
    end
end)
