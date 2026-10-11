AnimRueda = AnimRueda or {}

AnimRueda.activas = {} -- Almacena las ruedas que estÃ¡n encendidas

AnimRueda.OffsetCautivo = AnimRueda.OffsetCautivo or { x = 1, y = 0 }

-- Ajuste de prueba: se ejecuta desde el depurador Lua antes de meter el zombi.
-- Ejemplo: KineticDeadSetWheelCaptiveOffset(2, 0)
function KineticDeadSetWheelCaptiveOffset(offsetX, offsetY)
    offsetX = tonumber(offsetX)
    offsetY = tonumber(offsetY)
    if offsetX == nil or offsetY == nil then
        print("[KineticDead] Uso: KineticDeadSetWheelCaptiveOffset(x, y)")
        return false
    end
    AnimRueda.OffsetCautivo = { x = math.floor(offsetX), y = math.floor(offsetY) }
    print("[KineticDead] Desplazamiento de casilla: X=" .. AnimRueda.OffsetCautivo.x .. " Y=" .. AnimRueda.OffsetCautivo.y)
    return true
end



-- =========================================================

-- 1. MAPEO DE LOS FRAMES DE ANIMACIÃ“N

-- =========================================================

-- Definimos las secuencias exactas. Cada fila es 1 frame de animaciÃ³n (3 tiles).

AnimRueda.Secuencias = {

    -- Secuencia para la Cara SUR

    S = {

        { "rueda_0",  "rueda_1",  "rueda_2" },  -- Frame 1

        { "rueda_8",  "rueda_9",  "rueda_10" }, -- Frame 2

        { "rueda_16", "rueda_17", "rueda_18" }, -- Frame 3

        { "rueda_24", "rueda_25", "rueda_26" }, -- Frame 4

        { "rueda_32", "rueda_33", "rueda_34" }  -- Frame 5

    },

    -- Secuencia para la Cara OESTE / NORTE

    W = {

        { "rueda_3",  "rueda_4",  "rueda_5" },

        { "rueda_11", "rueda_12", "rueda_13" },

        { "rueda_19", "rueda_20", "rueda_21" },

        { "rueda_27", "rueda_28", "rueda_29" },

        { "rueda_35", "rueda_36", "rueda_37" }

    }

}



-- Diccionario inverso para saber quÃ© parte tocaste (ej: "rueda_17" -> Cara S, Frame 3, PosiciÃ³n 2)

AnimRueda.Diccionario = {}

for cara, frames in pairs(AnimRueda.Secuencias) do

    for frameIdx, tiles in ipairs(frames) do

        for posIdx, sprName in ipairs(tiles) do

            AnimRueda.Diccionario[sprName] = { cara = cara, frame = frameIdx, pos = posIdx }

        end

    end

end



-- =========================================================

-- 2. SISTEMA DE BÃšSQUEDA EXACTA (DISTANCIA ABSOLUTA Y EJES AISLADOS)

-- =========================================================

local function ObtenerPartesRueda(squareClickeado, objClickeado)

    local partes = {}

    local cell = getCell()

    

    local x = squareClickeado:getX()

    local y = squareClickeado:getY()

    local z = squareClickeado:getZ()

    

    local spriteName = objClickeado:getSprite():getName()

    local infoClickeada = AnimRueda.Diccionario[spriteName]

    

    if not infoClickeada then return partes end

    

    local cara = infoClickeada.cara 

    

    -- FunciÃ³n interna inteligente que busca una pieza especÃ­fica en lÃ­nea recta

    local function BuscarPieza(targetPos)

        -- Buscamos en una lÃ­nea de -2 a +2 casillas

        for offset = -2, 2 do

            local cx = x

            local cy = y

            

            -- Cara S tiene mÃºltiples 'row' -> VarÃ­a en el eje Y

            -- Cara E tiene un solo 'row' -> VarÃ­a en el eje X

            if cara == "S" then 

                cy = y + offset

            else 

                cx = x + offset 

            end

            

            local sq = cell:getGridSquare(cx, cy, z)

            if sq then

                local objs = sq:getObjects()

                for j = 0, objs:size() - 1 do

                    local obj = objs:get(j)

                    if obj and obj:getSprite() and obj:getSprite():getName() then

                        local spr = obj:getSprite():getName()

                        local infoPieza = AnimRueda.Diccionario[spr]

                        

                        -- Verificamos si encontramos la pieza que buscamos (Ej: la pos 1)

                        if infoPieza and infoPieza.cara == cara and infoPieza.pos == targetPos then

                            

                            -- MAGIA ANTIBUGS: Comprobamos la distancia matemÃ¡tica absoluta

                            -- Esto evita que robemos una "pos 1" de otra rueda pegada a la nuestra.

                            local distanciaReal = math.abs(offset)

                            local distanciaEsperada = math.abs(targetPos - infoClickeada.pos)

                            

                            if distanciaReal == distanciaEsperada then

                                return { objeto = obj, info = infoPieza }

                            end

                        end

                    end

                end

            end

        end

        return nil

    end

    

    -- Usamos la funciÃ³n inteligente para atrapar las 3 posiciones

    for i = 1, 3 do

        local pieza = BuscarPieza(i)

        if pieza then

            table.insert(partes, pieza)

        end

    end

    

    return partes

end

-- =========================================================

-- 3. BUCLE DE ANIMACIÃ“N (TICK)

-- =========================================================

local function KineticDeadWheelPartsId(parts)
    if not parts or #parts == 0 then return nil end
    local coords = {}
    for _, part in ipairs(parts) do
        local sq = part.objeto and part.objeto:getSquare() or nil
        if sq then coords[#coords + 1] = sq:getX() .. "," .. sq:getY() .. "," .. sq:getZ() end
    end
    table.sort(coords)
    return table.concat(coords, "|")
end

local function KineticDeadStartWheelParts(square, object, zombie)
    if not square or not object then return false end
    local parts = ObtenerPartesRueda(square, object)
    if not parts or #parts == 0 then return false end
    local id = KineticDeadWheelPartsId(parts)
    for _, active in ipairs(AnimRueda.activas) do
        if active.id == id then
            if zombie then active.prisionero = zombie end
            return true
        end
    end
    AnimRueda.activas[#AnimRueda.activas + 1] = {
        id = id, partes = parts, prisionero = zombie, frameActual = 1,
        velocidad = 200, ultimoUpdate = getTimeInMillis()
    }
    return true
end

function KineticDeadStartWheelAt(object, zombie)
    local square = object and object:getSquare() or nil
    return KineticDeadStartWheelParts(square, object, zombie)
end

function KineticDeadStartWheelNearSquare(square, zombie)
    if not square then return false end
    local cell = getCell()
    for dx = -2, 2 do
        for dy = -2, 2 do
            local nearby = cell:getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
            if nearby then
                local objects = nearby:getObjects()
                for i = 0, objects:size() - 1 do
                    local object = objects:get(i)
                    local sprite = object and object:getSprite() or nil
                    local name = sprite and sprite:getName() or nil
                    if name and AnimRueda.Diccionario[name] and KineticDeadStartWheelParts(nearby, object, zombie) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function KineticDeadStopWheelForZombie(zombie)
    if not zombie then return end
    for i = #AnimRueda.activas, 1, -1 do
        if AnimRueda.activas[i].prisionero == zombie then table.remove(AnimRueda.activas, i) end
    end
end

AnimRueda.OnTick = function()

    if #AnimRueda.activas == 0 then return end

    

    local now = getTimeInMillis()

    local isPaused = (UIManager.getSpeedControls():getCurrentGameSpeed() == 0)

    if isPaused then return end

    

    for i = #AnimRueda.activas, 1, -1 do

        local rueda = AnimRueda.activas[i]
        if rueda.prisionero then
            local captive = rueda.prisionero
            local modData = captive:getModData()
            local capture = modData and modData.CatBR or nil
            if captive:isDead() or not capture or not capture.rueda then
                table.remove(AnimRueda.activas, i)
                rueda = nil
            else
                pcall(function()
                    local x, y = capture.ruedaX, capture.ruedaY
                    if x ~= nil and y ~= nil then
                        captive:setX(x + 0.5); captive:setY(y + 0.5)
                        if captive.setLx then captive:setLx(x + 0.5) end
                        if captive.setLy then captive:setLy(y + 0.5) end
                    end
                    if captive.setUseless then captive:setUseless(true) end
                    if captive.setVariable then
                        captive:setVariable("CatBRRueda", true)
                        captive:setVariable("CatBRPreso", false)
                        captive:setVariable("bPathfind", false)
                        captive:setVariable("bMoving", true)
                    end
                end)
            end
        end

        -- Si ha pasado el tiempo necesario para el siguiente frame (ej: 150ms)
        if rueda and now - rueda.ultimoUpdate > rueda.velocidad then

            rueda.frameActual = rueda.frameActual + 1

            if rueda.frameActual > 5 then rueda.frameActual = 1 end -- Hay 5 frames totales

            

            -- Actualizamos los sprites de las 3 partes

            local partesValidas = 0

            for _, parte in ipairs(rueda.partes) do

                if parte.objeto and parte.objeto:getSquare() then

                    local nuevoSprite = AnimRueda.Secuencias[parte.info.cara][rueda.frameActual][parte.info.pos]

                    

                    -- Aplicamos el nuevo sprite de forma segura

                    pcall(function() parte.objeto:setSpriteFromName(nuevoSprite) end)

                    pcall(function() parte.objeto:transmitUpdatedSpriteToClients() end)

                    

                    partesValidas = partesValidas + 1

                end

            end

            

            -- Si la estructura fue destruida fÃ­sicamente, la borramos del bucle

            if partesValidas == 0 then

                table.remove(AnimRueda.activas, i)

            else

                rueda.ultimoUpdate = now

            end

        end

    end

end

Events.OnTick.Add(AnimRueda.OnTick)



-- =========================================================

-- 4. MENÃš CONTEXTUAL (CLICK DERECHO)

-- =========================================================

local function KineticDeadWheelTooltip(option, key)
    if not option or not ISWorldObjectContextMenu or not ISWorldObjectContextMenu.addToolTip then return end
    option.toolTip = ISWorldObjectContextMenu.addToolTip()
    option.toolTip.description = getText(key)
end

local function RuedaContextMenu(playerIndex, context, worldobjects, test)

    local ruedaClickeada = nil

    

    -- Verificamos si tocamos alguna pieza de la rueda

    for _, obj in ipairs(worldobjects) do

        if obj and obj:getSprite() and obj:getSprite():getName() then

            if AnimRueda.Diccionario[obj:getSprite():getName()] then

                ruedaClickeada = obj

                break

            end

        end

    end

    

    if ruedaClickeada then

        local optionPanel = context:addOption(getText("ContextMenu_KineticDead_WheelControl"), nil, nil)
        KineticDeadWheelTooltip(optionPanel, "ContextMenu_KineticDead_WheelControlTip")

        local subMenu = ISContextMenu:getNew(context)

        context:addSubMenu(optionPanel, subMenu)

        

        -- Identificamos si esta rueda especÃ­fica ya estÃ¡ encendida

        local idRuedaActiva = nil

        local sqClickeado = ruedaClickeada:getSquare()

        

        for i, rueda in ipairs(AnimRueda.activas) do

            for _, parte in ipairs(rueda.partes) do

                if parte.objeto:getSquare() == sqClickeado then

                    idRuedaActiva = i

                    break

                end

            end

        end

        

        -- BotÃ³n ENCENDER / APAGAR

        local textoEstado = idRuedaActiva
            and getText("ContextMenu_KineticDead_WheelStop")
            or getText("ContextMenu_KineticDead_WheelStart")
        local optionToggle = subMenu:addOption(textoEstado, nil, function()
            local player = getSpecificPlayer(playerIndex)
            if idRuedaActiva then
                table.remove(AnimRueda.activas, idRuedaActiva)
                player:setHaloNote(getText("IGUI_KineticDead_WheelStopped"), 255, 0, 0, 300)
            else
                if KineticDeadStartWheelParts(sqClickeado, ruedaClickeada, nil) then
                    player:setHaloNote(getText("IGUI_KineticDead_WheelRunning"), 0, 255, 0, 300)
                end
            end
        end)
        KineticDeadWheelTooltip(optionToggle, idRuedaActiva
            and "ContextMenu_KineticDead_WheelStopTip"
            or "ContextMenu_KineticDead_WheelStartTip")

        if idRuedaActiva then
            local optionSlow = subMenu:addOption(getText("ContextMenu_KineticDead_WheelSlow"), nil, function()
                AnimRueda.activas[idRuedaActiva].velocidad = 350
                getSpecificPlayer(playerIndex):setHaloNote(getText("IGUI_KineticDead_WheelSlowMode"), 255, 255, 255, 300)
            end)
            KineticDeadWheelTooltip(optionSlow, "ContextMenu_KineticDead_WheelSlowTip")

            local optionFast = subMenu:addOption(getText("ContextMenu_KineticDead_WheelFast"), nil, function()
                AnimRueda.activas[idRuedaActiva].velocidad = 100
                getSpecificPlayer(playerIndex):setHaloNote(getText("IGUI_KineticDead_WheelFastMode"), 255, 255, 255, 300)
            end)
            KineticDeadWheelTooltip(optionFast, "ContextMenu_KineticDead_WheelFastTip")
        end
    end

end

-- Menú de controles oculto temporalmente; se conserva RuedaContextMenu para reactivarlo.
-- Events.OnFillWorldObjectContextMenu.Add(RuedaContextMenu)













-- =========================================================

-- COMANDOS GLOBALES DE Ã�REA (CON SOPORTE DE VELOCIDAD)

-- =========================================================

-- Llama a: ToggleRuedasArea(radio, encender, velocidad_opcional)

-- Ejemplo 1: ToggleRuedasArea(20, true, 80)  -- Enciende/Modifica a velocidad RAPIDA

-- Ejemplo 2: ToggleRuedasArea(20, true, 350) -- Enciende/Modifica a velocidad LENTA

-- Ejemplo 3: ToggleRuedasArea(20, false)     -- Apaga todas

function ToggleRuedasArea(radio, encender, velocidadNueva)

    local player = getPlayer()

    if not player then return end

    local px, py, pz = player:getX(), player:getY(), player:getZ()

    local cell = getCell()

    

    local ruedasProcesadas = {} -- Evita procesar la misma rueda 3 veces

    local afectadas = 0

    

    for dx = -radio, radio do

        for dy = -radio, radio do

            local sq = cell:getGridSquare(px + dx, py + dy, pz)

            if sq then

                local objs = sq:getObjects()

                for j = 0, objs:size() - 1 do

                    local obj = objs:get(j)

                    if obj and obj:getSprite() and obj:getSprite():getName() then

                        local sprName = obj:getSprite():getName()

                        if AnimRueda.Diccionario[sprName] then

                            local partes = ObtenerPartesRueda(sq, obj)

                            

                            -- AÃ±adimos comprobaciÃ³n de seguridad extra (partes ~= nil)

                            if partes and #partes > 0 then

                                -- Usamos la Coordenada de la Pieza 1 como ID Ãºnico de la estructura

                                local idUnico = partes[1].objeto:getX() .. "_" .. partes[1].objeto:getY()

                                

                                if not ruedasProcesadas[idUnico] then

                                    ruedasProcesadas[idUnico] = true

                                    

                                    -- Comprobamos si la rueda ya estÃ¡ en la lista de animaciones activas

                                    local idxActiva = nil

                                    for i, r in ipairs(AnimRueda.activas) do

                                        if r.partes[1].objeto:getX() == partes[1].objeto:getX() and r.partes[1].objeto:getY() == partes[1].objeto:getY() then

                                            idxActiva = i

                                            break

                                        end

                                    end

                                    

                                    if encender then

                                        local vel = velocidadNueva or 200 -- 200 por defecto si no le pasas velocidad

                                        

                                        if not idxActiva then

                                            -- ESTADO 1: Estaba apagada, la encendemos con la nueva velocidad

                                            table.insert(AnimRueda.activas, {

                                                partes = partes, 

                                                frameActual = AnimRueda.Diccionario[sprName].frame, 

                                                velocidad = vel, 

                                                ultimoUpdate = getTimeInMillis()

                                            })

                                            afectadas = afectadas + 1

                                        else

                                            -- ESTADO 2: Ya estaba encendida, le actualizamos la velocidad en tiempo real

                                            if velocidadNueva and AnimRueda.activas[idxActiva].velocidad ~= velocidadNueva then

                                                AnimRueda.activas[idxActiva].velocidad = velocidadNueva

                                                afectadas = afectadas + 1

                                            end

                                        end

                                        

                                    elseif not encender and idxActiva then

                                        -- ESTADO 3: Apagar

                                        table.remove(AnimRueda.activas, idxActiva)

                                        afectadas = afectadas + 1

                                    end

                                end

                            end

                        end

                    end

                end

            end

        end

    end

    

    -- Mensaje visual en pantalla para saber quÃ© pasÃ³

    local colorR = encender and 0 or 255

    local colorG = encender and 255 or 0

    local textoAccion = encender and "encendidas/modificadas" or "apagadas"

    

    if encender and velocidadNueva then

        textoAccion = "a vel " .. velocidadNueva

    end

    

    player:setHaloNote(afectadas .. " ruedas " .. textoAccion, colorR, colorG, 0, 300)

end



--Para hacerlas girar RAPIDÃ�SIMO (Ej: 80 ms por frame):

--ToggleRuedasArea(20, true, 80)



--Para hacerlas girar LENTO (Ej: 350 ms por frame):

--ToggleRuedasArea(20, true, 350)



--Para encenderlas con la velocidad por defecto (200 ms):

--ToggleRuedasArea(20, true)



--Para apagarlas (el 3er parÃ¡metro se ignora):

--ToggleRuedasArea(20, false)

-- Opción de cautiverio: ancla un zombi ya amarrado al centro de la rueda.
function KineticDeadWheelCaptiveSquare(clickedObject)
    local clickedSquare = clickedObject and clickedObject:getSquare() or nil
    if not clickedSquare then return nil end
    local cell = getCell()
    local minX, maxX, minY, maxY
    for dx = -2, 2 do
        for dy = -2, 2 do
            local sq = cell:getGridSquare(clickedSquare:getX() + dx, clickedSquare:getY() + dy, clickedSquare:getZ())
            if sq then
                local objects = sq:getObjects()
                for i = 0, objects:size() - 1 do
                    local obj = objects:get(i)
                    local sprite = obj and obj:getSprite() or nil
                    local name = sprite and sprite:getName() or nil
                    if name and AnimRueda.Diccionario[name] then
                        minX = minX and math.min(minX, sq:getX()) or sq:getX()
                        maxX = maxX and math.max(maxX, sq:getX()) or sq:getX()
                        minY = minY and math.min(minY, sq:getY()) or sq:getY()
                        maxY = maxY and math.max(maxY, sq:getY()) or sq:getY()
                    end
                end
            end
        end
    end
    if not minX then return nil end
    local centreX = math.floor((minX + maxX) / 2 + 0.5)
    local centreY = math.floor((minY + maxY) / 2 + 0.5)
    local sprite = clickedObject:getSprite()
    local info = sprite and AnimRueda.Diccionario[sprite:getName()] or nil
    -- Punto interior, justo delante del centro visual de la rueda.
    if info and info.cara == "S" then centreY = centreY + 1 end
    if info and info.cara == "W" then centreX = centreX - 1 end
    -- Desplazamiento ajustable respecto al punto frontal de la rueda.
    local offset = AnimRueda.OffsetCautivo or { x = 1, y = 0 }
    centreX = centreX + (offset.x or 1)
    centreY = centreY + (offset.y or 0)
    return cell:getGridSquare(centreX, centreY, clickedSquare:getZ())
end

local function KineticDeadFindBoundZombie(centreSquare)
    if not CatBR or not CatBR.dados then return nil end
    local centreX, centreY, centreZ = centreSquare:getX() + 0.5, centreSquare:getY() + 0.5, centreSquare:getZ()
    for id, am in pairs(CatBR.dados().amarras or {}) do
        if am.z == centreZ and IsoUtils.DistanceTo(am.x + 0.5, am.y + 0.5, centreX, centreY) <= 6 then
            for dx = -3, 3 do
                for dy = -3, 3 do
                    local sq = getCell():getGridSquare(am.x + dx, am.y + dy, am.z)
                    local movs = sq and sq:getMovingObjects() or nil
                    if movs then
                        for i = 0, movs:size() - 1 do
                            local z = movs:get(i)
                            if z and instanceof(z, "IsoZombie") and not z:isDead() then
                                local m = z:getModData().CatBR
                                if m and m.amarraId == id then return z end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function KineticDeadWheelCaptiveMenu(playerIndex, context, worldobjects, test)
    if test then return end
    local wheelObject = nil
    for _, obj in ipairs(worldobjects) do
        local sprite = obj and obj:getSprite() or nil
        local name = sprite and sprite:getName() or nil
        if name and AnimRueda.Diccionario[name] then wheelObject = obj; break end
    end
    if not wheelObject then return end
    local player = getSpecificPlayer(playerIndex)
    local knowledge = player and player:getModData().KineticDeadKnowledge or nil
    if not player or not knowledge or not knowledge.rueda then return end
    local centre = KineticDeadWheelCaptiveSquare(wheelObject)
    if not centre then return end
    local zombie = KineticDeadFindBoundZombie(centre)
    if not zombie then return end
    context:addOption(getText("ContextMenu_KineticDead_PutZombieInWheel"), zombie, function(z)
        if CatBR and CatBR.colocarEnRueda and CatBR.colocarEnRueda(player, z, centre) then
            KineticDeadStartWheelAt(wheelObject, z)
            player:setHaloNote(getText("IGUI_KineticDead_ZombieInWheel"), 0, 255, 0, 350)
        end
    end)
end
Events.OnFillWorldObjectContextMenu.Add(KineticDeadWheelCaptiveMenu)
