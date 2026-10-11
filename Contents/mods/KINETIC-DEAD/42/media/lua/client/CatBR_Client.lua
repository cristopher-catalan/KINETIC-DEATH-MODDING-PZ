--***********************************************************
--**  CATIVEIRO BR - Cliente: dominar, conduzir, amarrar   **
--**  v0.1 TESTE. Nucleo: setUseless (liga/desliga zumbi). **
--**  Coleira por histerese: longe=ligado (persegue),      **
--**  perto=desligado (nao morde).                         **
--***********************************************************

require "CatBR_Shared"

------------------------------------------------------------
-- sync do estado global (amarras)
------------------------------------------------------------
Events.OnReceiveGlobalModData.Add(function(key, data)
    local ok, err = pcall(function()
        if key ~= CatBR.MODKEY or type(data) ~= "table" then return end
        local d = ModData.getOrCreate(CatBR.MODKEY)
        for k in pairs(d) do d[k] = nil end
        for k, v in pairs(data) do d[k] = v end
        d.amarras = d.amarras or {}
    end)
    if not ok then print("[CativeiroBR] erro no OnReceiveGlobalModData: " .. tostring(err)) end
end)

Events.OnGameStart.Add(function()
    if isClient() then
        pcall(function() ModData.request(CatBR.MODKEY) end)
        pcall(function() sendClientCommand(getPlayer(), CatBR.MODKEY, "PedirEstado", {}) end)
    end
end)

------------------------------------------------------------
-- estado local
------------------------------------------------------------
local conduzindo = nil       -- zumbi na corda agora
local dominados = {}         -- lista de refs de zumbis dominados (local)

local function md(z)
    return z:getModData()
end

local function ehDominado(z)
    local m = md(z)
    return m.CatBR and m.CatBR.dominado
end

-- CARGA REGISTRADA: na morte MP o servidor apaga o inventario do
-- zumbi ANTES do evento chegar no cliente; mantemos nosso proprio
-- registro de tudo que entrou/saiu (toda movimentacao passa por nos)
local cargaZumbi = {}   -- [trueID do zumbi] = { [item] = true }

-- id persistente (objeto de IsoZombie e' RECICLADO pelo motor no MP;
-- chavear pelo objeto perde o registro. trueID sobrevive)
local function idCarga(z)
    local tid = nil
    pcall(function()
        local pID = z:getPersistentOutfitID()
        local bits = string.split(string.reverse(Long.toUnsignedString(pID, 2)), "")
        while #bits < 16 do bits[#bits + 1] = 0 end
        bits[16] = 0
        tid = tostring(Long.parseUnsignedLong(string.reverse(table.concat(bits, "")), 2))
    end)
    return tid
end

local function registrarCarga(z, it)
    if not z or not it then return end
    local tid = idCarga(z)
    if not tid then return end
    cargaZumbi[tid] = cargaZumbi[tid] or {}
    cargaZumbi[tid][it] = true
end

local function desregistrarCarga(z, it)
    if not z or not it then return end
    local tid = idCarga(z)
    if tid and cargaZumbi[tid] then cargaZumbi[tid][it] = nil end
end

local function zumbiDoContainer(c)
    local achado = nil
    pcall(function()
        if not c then return end
        local parent = c:getParent()
        if parent and instanceof(parent, "IsoZombie") and parent:getModData().CatBR then
            achado = parent
            return
        end
        local ci = c:getContainingItem()
        if ci then
            local cont = ci:getContainer()
            local zp = cont and cont:getParent() or nil
            if zp and instanceof(zp, "IsoZombie") and zp:getModData().CatBR then
                achado = zp
            end
        end
    end)
    return achado
end


local function mandar(cmd, args)
    local p = getPlayer()
    if isClient() then
        sendClientCommand(p, CatBR.MODKEY, cmd, args or {})
    else
        -- solo: aplica direto
        local d = CatBR.dados()
        if cmd == "Amarrar" then
            d.amarras[CatBR.idAmarra(args.x, args.y, args.z)] =
                { x = math.floor(args.x), y = math.floor(args.y), z = math.floor(args.z), por = p:getUsername(), rueda = args.rueda == true }
        elseif cmd == "Desamarrar" then
            d.amarras[CatBR.idAmarra(args.x, args.y, args.z)] = nil
        elseif cmd == "AmarraBrava" then
            local am = d.amarras[CatBR.idAmarra(args.x, args.y, args.z)]
            if am then am.bravo = args.bravo == true end
        elseif cmd == "SemBraco" then
            d.sembraco[tostring(args.id)] = true
        elseif cmd == "Mochila" then
            d.mochila[tostring(args.id)] = args.tipo
        end
    end
end

------------------------------------------------------------
-- visuais: algema/corda penduradas no zumbi (sistema de
-- attachments "Human" — o mesmo da faca na cabeca de zumbi
-- e que o HorseMod usa no cavalo) e corda na mao do condutor
------------------------------------------------------------
local SLOT_ALGEMA = "Stomach"
local SLOT_CORDA = "Belt Right"
local CORDA_VISUAL = "Base.CatBR_Corda"  -- corda COM modelo (a vanilla nao tem)
local cordaNaMao = false

local function visualZumbi(z, comCorda)
    -- v0.8: SEM props pendurados no corpo (algema/corda flutuavam);
    -- a pose de maos presas + corda fantasma ja contam a historia.
    -- Mantido apenas para limpar attachments antigos.
    pcall(function()
        z:setAttachedItem(SLOT_ALGEMA, nil)
        z:setAttachedItem(SLOT_CORDA, nil)
    end)
end

local function visualLimpar(z)
    pcall(function()
        z:setAttachedItem(SLOT_ALGEMA, nil)
        z:setAttachedItem(SLOT_CORDA, nil)
    end)
end

local function maoCorda(p, segurar)
    pcall(function()
        local inv = p:getInventory()
        if segurar and not cordaNaMao then
            -- item-visual (peso 0) na mao; a Rope de verdade fica no inventario
            local it = inv:getFirstTypeRecurse(CORDA_VISUAL)
            if not it then
                it = inv:AddItem(CORDA_VISUAL)
                if it and isClient() then
                    pcall(function() sendAddItemToContainer(inv, it) end)
                end
            end
            if it then
                p:setPrimaryHandItem(it)
                cordaNaMao = true
                if isClient() then pcall(function() sendEquip(p) end) end
            end
        elseif not segurar and cordaNaMao then
            cordaNaMao = false
            local it = inv:getFirstTypeRecurse(CORDA_VISUAL)
            if it then
                if p:getPrimaryHandItem() == it then p:removeFromHands(it) end
                if isClient() then
                    pcall(function() sendEquip(p) end)
                    pcall(function() sendRemoveItemFromContainer(inv, it) end)
                end
                inv:DoRemoveItem(it)
            end
        end
    end)
end

------------------------------------------------------------
-- CORDA FANTASMA: um animal invisivel (rato bebe) carrega a
-- corda vanilla com fisica. O engine so desenha corda esticada
-- player<->animal (drawRope no IsoAnimal), entao grudamos um
-- animal alpha-zero no zumbi: a corda liga o player ao zumbi.
-- Amarrado em arvore: setAttachedTree desenha corda na arvore.
------------------------------------------------------------
local fantasmaConduzir = nil
local fantasmasAmarra = {}   -- amarraId -> animal

local function novoFantasma(x, y, z)
    local a = nil
    pcall(function()
        -- RATO fantasma: rato NAO tem ropeBone nas AnimalDefinitions,
        -- entao a ponta da corda cai na POSICAO exata do animal (nada
        -- de osso de pescoco girando = corda nao entorta). A altura vem
        -- do proprio rato flutuando no ponto do pescoco do zumbi.
        a = IsoAnimal.new(getCell(), x, y, z, "rat", "grey")
        if a then
            a:setWild(false)
            -- NO GANCHO: IsoAnimal.update() retorna direto com isOnHook()
            -- (bytecode) -> nao cai (fix do crash fallenOnKnees/addHole),
            -- nao tem IA, nao faz som; flutua onde a gente puser
            pcall(function()
                if a.setOnHook then a:setOnHook(true) end
            end)
            -- fora das listas de alvo de combate (o PISAO que o player
            -- dava era mirando o rato invisivel; calcHitListShove filtra
            -- por isGodMod, verificado no bytecode)
            pcall(function()
                if a.setGodMod then a:setGodMod(true) end
            end)
            a:getModData().CatBRGhost = true
            -- pele 100% transparente = invisivel de verdade
            -- (setInvisible/alpha nao funcionam em animal; textura sim)
            pcall(function() a:getAnimalVisual():setSkinTextureName("CatBR_Invisivel") end)
            pcall(function() a:resetModel() end)
            pcall(function() a:setInvisible(true) end)
            pcall(function() a:getBehavior():setBlockMovement(true) end)
            pcall(function() a:getEmitter():stopAll() end)
        end
    end)
    return a
end

local function matarFantasma(a)
    if not a then return end
    pcall(function()
        if a.setOnHook then a:setOnHook(false) end
        local p = getPlayer()
        if p then pcall(function() p:removeAttachedAnimal(a) end) end
        a:getData():setAttachedPlayer(nil)
        a:getData():setAttachedTree(nil)
    end)
    pcall(function() a:removeFromWorld() end)
    pcall(function() a:removeFromSquare() end)
end

local function fantasmaSegue(a, z, alvoFace)
    if not a or not z then return end
    pcall(function()
        -- o ponto da corda e o PESCOCO da vaca (a frente dela); vira a
        -- vaca pro alvo e recua o corpo pra o pescoco cair NO zumbi --
        -- sem isso a corda flutuava ao lado
        local zx, zy = z:getX(), z:getY()
        local rec = CatBR.Config.FANTASMA_RECUO or 0.15
        if alvoFace then
            local dx = alvoFace:getX() - zx
            local dy = alvoFace:getY() - zy
            local len = math.sqrt(dx * dx + dy * dy)
            if len > 0.01 then
                dx, dy = dx / len, dy / len
                a:setX(zx + dx * rec)   -- ponto DA FRENTE do peito
                a:setY(zy + dy * rec)
            else
                a:setX(zx)
                a:setY(zy)
            end
            pcall(function() a:faceThisObject(alvoFace) end)
        else
            a:setX(zx)
            a:setY(zy)
        end
        -- pendura o rato na altura do pescoco do zumbi (z fracionario;
        -- re-fixado todo tick, gravidade nao ganha)
        a:setZ(z:getZ() + (CatBR.Config.FANTASMA_ALTURA or 0.55))
        a:getEmitter():stopAll()  -- mudo todo frame
    end)
end

local function marcarPreso(z, preso)
    -- sem bracos = animacao natural agressiva sempre (Michonne)
    pcall(function()
        local m = md(z).CatBR
        if preso and m and m.sembraco then preso = false end
        z:setVariable("CatBRPreso", preso == true)
    end)
end

------------------------------------------------------------
-- CORTE MICHONNE: bracos decepados (visual por mascaras de
-- clothing, tecnica do The Only Cure; id persistente do zumbi
-- via getPersistentOutfitID — credito Chuck & Sir Doggy Jvla)
------------------------------------------------------------
-- BORRADO DE PRUEBA
-- local ROUPA_SEMBRACO = "Base.CatBR_SemBracos"
local sangrando = {}   -- [zumbi] = respingos restantes

local function trueIDZumbi(zombie)
    local pID = zombie:getPersistentOutfitID()
    local bits = string.split(string.reverse(Long.toUnsignedString(pID, 2)), "")
    while #bits < 16 do bits[#bits + 1] = 0 end
    bits[16] = 0
    return tostring(Long.parseUnsignedLong(string.reverse(table.concat(bits, "")), 2))
end
-- BORRADO DE PRUEBA
--[[
local function temArmaDeCorte(playerObj)
    local w = playerObj:getPrimaryHandItem()
    if not w or not instanceof(w, "HandWeapon") then return false end
    -- API vanilla B42 (padrao do XpUpdate.lua):
    -- weapon:getScriptItem():containsWeaponCategory(WeaponCategory.X)
    local corta = false
    pcall(function()
        local si = w:getScriptItem()
        if si:containsWeaponCategory(WeaponCategory.AXE)
            or si:containsWeaponCategory(WeaponCategory.LONG_BLADE)
            or si:containsWeaponCategory(WeaponCategory.SMALL_BLADE) then
            corta = true
        end
    end)
    return corta
end

-- Cotos EMBUTIDOS no mod (modelos/texturas do The Only Cure, GPL-3,
-- com autorizacao do ZioPao — creditos no mod.info)
local COTO_L = "Base.CatBR_CotoL"
local COTO_R = "Base.CatBR_CotoR"

-- indice de textura p/ pele de zumbi: nossa lista tem SO as 12 de
-- zumbi (4 peles x 3 niveis), 0-based
local function texturaCotoZumbi(z)
    local idx = nil
    pcall(function()
        local x = z:getHumanVisual():getSkinTexture()
        local m = tonumber(x:match("ZedBody0(%d)"))
        local lvl = tonumber(x:match("%d$"))
        if m and lvl then idx = (m - 1) * 3 + (lvl - 1) end
    end)
    return idx
end

local function aplicarVisualMochila(z, tipo)
    pcall(function()
        local vis = z:getItemVisuals()
        if not vis then return end
        for i = 0, vis:size() - 1 do
            local iv = vis:get(i)
            if iv and iv:getItemType() == tipo then return end
        end
        local iv = ItemVisual:new()
        iv:setItemType(tipo)
        vis:add(iv)
        z:resetModelNextFrame()
    end)
end

local function removerVisualMochila(z, tipo)
    pcall(function()
        local vis = z:getItemVisuals()
        if not vis then return end
        for i = vis:size() - 1, 0, -1 do
            local iv = vis:get(i)
            if iv and iv:getItemType() == tipo then vis:remove(iv) end
        end
        z:resetModelNextFrame()
    end)
end

local function aplicarVisualSemBraco(z)
    pcall(function()
        local vis = z:getItemVisuals()
        if not vis then return end
        -- ja tem? (e remove visuais legados: mascaras / TOC externo)
        for i = vis:size() - 1, 0, -1 do
            local iv = vis:get(i)
            local t = iv and iv:getItemType() or nil
            if t == COTO_L then return end
            if t == ROUPA_SEMBRACO or t == "TOC.Amputation_UpperArm_L"
                or t == "TOC.Amputation_UpperArm_R" then
                vis:remove(iv)
            end
        end
        local idx = texturaCotoZumbi(z)
        for _, tipo in ipairs({ COTO_L, COTO_R }) do
            local iv = ItemVisual:new()
            iv:setItemType(tipo)
            if idx then pcall(function() iv:setTextureChoice(idx) end) end
            vis:add(iv)
        end
        z:resetModelNextFrame()
    end)
end

local function cortarBracos(playerObj, z)
    local m = md(z).CatBR
    if not m then return end
    m.sembraco = true
    aplicarVisualSemBraco(z)
    marcarPreso(z, false)  -- volta a animacao agressiva natural
    local id = trueIDZumbi(z)
    mandar("SemBraco", { id = id })
    local d = CatBR.dados()
    d.sembraco[id] = true
    sangrando[z] = 8
    pcall(function()
        addBloodSplat(getCell():getGridSquare(z:getX(), z:getY(), z:getZ()), 12)
    end)
    playerObj:Say(getText("IGUI_CatBR_Corte"))
end
]]

-- prender a corda ao player exige as DUAS metades (padrao vanilla
-- de ISAttachAnimalToTree): lista do player + attachedPlayer do animal
local function cordaAoPlayer(p, a)
    pcall(function()
        a:getData():setAttachedTree(nil)
        p:getAttachedAnimals():add(a)
        a:getData():setAttachedPlayer(p)
    end)
end

local function cordaNaArvore(p, a, arvore)
    pcall(function()
        p:removeAttachedAnimal(a)
        a:getData():setAttachedPlayer(nil)
        a:getData():setAttachedTree(arvore)
    end)
end

------------------------------------------------------------
-- acoes
------------------------------------------------------------
local function dominarZumbi(playerObj, z)
    local algema = CatBR.acharAlgema(playerObj)
    if not algema then return end
    local tipo = algema:getFullType()
    playerObj:getInventory():DoRemoveItem(algema)
    md(z).CatBR = { dominado = true, item = tipo }
    z:setUseless(true)
    table.insert(dominados, z)
    marcarPreso(z, true)
    visualZumbi(z, false)
    playerObj:playSound("AttachRopeTree")
    playerObj:Say(getText("IGUI_CatBR_Dominado"))
end

local function conduzirZumbi(playerObj, z)
    if not playerObj:getInventory():getFirstTypeRecurse(CatBR.Config.CORDA) then
        playerObj:Say(getText("IGUI_CatBR_PrecisoCorda"))
        return
    end
    conduzindo = z
    local m = md(z).CatBR
    if m and m.amarraId then
        -- Remove a amarra/roda antes de voltar a conduzir o zumbi.
        local am = CatBR.dados().amarras[m.amarraId]
        if m.rueda and KineticDeadStopWheelForZombie then KineticDeadStopWheelForZombie(z) end
        if am then mandar("Desamarrar", am) end
        m.amarraIdVelha = m.amarraId
        m.amarraId = nil
        m.rueda = nil
        m.ruedaX, m.ruedaY, m.ruedaZ = nil, nil, nil
        pcall(function() z:setVariable("CatBRRueda", false) end)
        marcarPreso(z, false)
        playerObj:getInventory():AddItem(CatBR.Config.CORDA)
        playerObj:playSound("DetachRopeTree")
    end
    visualZumbi(z, true)
    maoCorda(playerObj, true)
    -- corda fantasma: se o zumbi vinha de uma amarra, reaproveita o
    -- fantasma dela; senao cria um novo grudado no zumbi
    local mz = md(z).CatBR
    local reuso = mz and mz.amarraIdVelha and fantasmasAmarra[mz.amarraIdVelha]
    if reuso then
        fantasmasAmarra[mz.amarraIdVelha] = nil
        mz.amarraIdVelha = nil
        fantasmaConduzir = reuso
    elseif not fantasmaConduzir then
        fantasmaConduzir = novoFantasma(z:getX(), z:getY(), z:getZ())
    end
    if fantasmaConduzir then
        cordaAoPlayer(playerObj, fantasmaConduzir)
    end
    playerObj:Say(getText("IGUI_CatBR_Vem"))
end

local function soltarCorda(playerObj)
    if conduzindo then visualZumbi(conduzindo, false) end
    conduzindo = nil
    maoCorda(playerObj, false)
    matarFantasma(fantasmaConduzir)
    fantasmaConduzir = nil
    playerObj:Say(getText("IGUI_CatBR_FicaAi"))
end

local function amarrarZumbi(playerObj, z, sq, arvore)
    local corda = playerObj:getInventory():getFirstTypeRecurse(CatBR.Config.CORDA)
    if not corda then
        playerObj:Say(getText("IGUI_CatBR_PrecisoCorda"))
        return
    end
    local x, y, zz = sq:getX(), sq:getY(), sq:getZ()
    playerObj:getInventory():DoRemoveItem(corda)
    mandar("Amarrar", { x = x, y = y, z = zz })
    md(z).CatBR.amarraId = CatBR.idAmarra(x, y, zz)
    z:setX(x + 0.5)
    z:setY(y + 0.5)
    z:setUseless(true)
    if conduzindo == z then conduzindo = nil end
    visualZumbi(z, true)
    maoCorda(playerObj, false)
    -- corda fantasma na arvore (fisica vanilla de animal amarrado)
    local id = CatBR.idAmarra(x, y, zz)
    if fantasmaConduzir then
        if arvore then
            cordaNaArvore(playerObj, fantasmaConduzir, arvore)
            fantasmasAmarra[id] = fantasmaConduzir
        else
            matarFantasma(fantasmaConduzir)
        end
        fantasmaConduzir = nil
    end
    playerObj:playSound("AttachRopeTree")
    playerObj:Say(getText("IGUI_CatBR_Amarrado"))
end

-- Amarra directamente en la rueda al zombi que el jugador lleva con la cuerda.
function CatBR.amarrarEnRueda(playerObj, z, square)
    if not playerObj or not z or not square or z:isDead() then return false end
    local corda = playerObj:getInventory():getFirstTypeRecurse(CatBR.Config.CORDA)
    if not corda then playerObj:Say(getText("IGUI_CatBR_PrecisoCorda")); return false end
    local x, y, zz = square:getX(), square:getY(), square:getZ()
    local m = md(z).CatBR or { dominado = true }
    md(z).CatBR = m
    local id = CatBR.idAmarra(x, y, zz)
    local ocupado = CatBR.dados().amarras[id]
    if ocupado then return false end
    playerObj:getInventory():DoRemoveItem(corda)
    if fantasmasAmarra[id] then matarFantasma(fantasmasAmarra[id]); fantasmasAmarra[id] = nil end
    if fantasmaConduzir then matarFantasma(fantasmaConduzir); fantasmaConduzir = nil end
    if conduzindo == z then conduzindo = nil end
    maoCorda(playerObj, false)
    mandar("Amarrar", { x = x, y = y, z = zz, rueda = true })
    m.amarraId = id
    m.amarraIdVelha = nil
    m.rueda = true
    m.ruedaX, m.ruedaY, m.ruedaZ = x, y, zz
    z:setX(x + 0.5); z:setY(y + 0.5)
    pcall(function()
        if z.setLx then z:setLx(x + 0.5) end
        if z.setLy then z:setLy(y + 0.5) end
        if z.setUseless then z:setUseless(true) end
        if z.setVariable then
            z:setVariable("CatBRPreso", false); z:setVariable("CatBRRueda", true)
            z:setVariable("bPathfind", false); z:setVariable("bMoving", true)
        end
        z:resetModelNextFrame()
    end)
    visualZumbi(z, true)
    playerObj:playSound("AttachRopeTree")
    playerObj:Say(getText("IGUI_KineticDead_ZombieInWheel"))
    if KineticDeadStartWheelNearSquare then pcall(KineticDeadStartWheelNearSquare, square, z) end
    return true
end

-- Reubica un zombi ya amarrado al punto central elegido de la rueda.
function CatBR.colocarEnRueda(playerObj, z, square)
    if not playerObj or not z or not square or z:isDead() then return false end
    local m = md(z).CatBR
    if not m or not m.amarraId then return false end
    local d = CatBR.dados()
    local oldId = m.amarraId
    local oldAm = d.amarras[oldId]
    if not oldAm then return false end
    local x, y, zz = square:getX(), square:getY(), square:getZ()
    local newId = CatBR.idAmarra(x, y, zz)
    local ocupado = d.amarras[newId]
    if ocupado and newId ~= oldId then return false end

    -- Quita la cuerda de la amarra anterior y la cuerda de conduccion.
    if fantasmasAmarra[oldId] then
        matarFantasma(fantasmasAmarra[oldId])
        fantasmasAmarra[oldId] = nil
    end
    if conduzindo == z then
        conduzindo = nil
        maoCorda(playerObj, false)
        matarFantasma(fantasmaConduzir)
        fantasmaConduzir = nil
    end
    if newId ~= oldId then mandar("Desamarrar", oldAm) end
    mandar("Amarrar", { x = x, y = y, z = zz, rueda = true })

    m.amarraId = newId
    m.amarraIdVelha = nil
    m.rueda = true
    m.ruedaX, m.ruedaY, m.ruedaZ = x, y, zz
    z:setX(x + 0.5)
    z:setY(y + 0.5)
    pcall(function()
        if z.setLx then z:setLx(x + 0.5) end
        if z.setLy then z:setLy(y + 0.5) end
        if z.setUseless then z:setUseless(true) end
        if z.setVariable then
            z:setVariable("CatBRPreso", false)
            z:setVariable("CatBRRueda", true)
            z:setVariable("bPathfind", false)
            z:setVariable("bMoving", true)
        end
        z:resetModelNextFrame()
    end)
    playerObj:Say(getText("IGUI_KineticDead_ZombieInWheel"))
    return true
end

local function libertarZumbi(playerObj, z)
    local m = md(z).CatBR
    if m then
        if m.amarraId then
            local am = CatBR.dados().amarras[m.amarraId]
            if am then mandar("Desamarrar", am) end
            playerObj:getInventory():AddItem(CatBR.Config.CORDA)
            if fantasmasAmarra[m.amarraId] then
                matarFantasma(fantasmasAmarra[m.amarraId])
                fantasmasAmarra[m.amarraId] = nil
            end
        end
        if m.item then playerObj:getInventory():AddItem(m.item) end
    end
    md(z).CatBR = nil
    if conduzindo == z then conduzindo = nil end
    marcarPreso(z, false)
    pcall(function() z:setVariable("CatBRRueda", false) end)
    if KineticDeadStopWheelForZombie then pcall(KineticDeadStopWheelForZombie, z) end
    visualLimpar(z)
    maoCorda(playerObj, false)
    if conduzindo == nil and fantasmaConduzir then
        matarFantasma(fantasmaConduzir)
        fantasmaConduzir = nil
    end
    z:setUseless(false)
    playerObj:playSound("DetachRopeTree")
    playerObj:Say(getText("IGUI_CatBR_Corre"))
end

------------------------------------------------------------
-- controle por tick
------------------------------------------------------------
local tickAmarras = 0
local tickOrfaos = 0
local tickChama = 0
local tickVisuais = 0
local tickDbgAmarra = 0
local tickRepath = {}   -- amarraId -> contador de repath do guarda
local adotados = {}   -- amarraId -> zumbi adotado (p/ grampo por tick)

-- grampo na BORDA do raio (esticao de corda, sem teleporte pro centro)
local function grampoAmarra(z, am)
    local cx, cy = am.x + 0.5, am.y + 0.5
    if am.rueda then
        -- Mantiene la raíz del zombi en el mismo punto mientras el nodo
        -- Zombie_Walk reproduce pasos sin desplazamiento real.
        z:setX(cx); z:setY(cy)
        pcall(function() if z.setLx then z:setLx(cx) end end)
        pcall(function() if z.setLy then z:setLy(cy) end end)
        pcall(function() if z.setUseless then z:setUseless(true) end end)
        pcall(function()
            if z.setVariable then
                z:setVariable("CatBRPreso", false)
                z:setVariable("CatBRRueda", true)
                z:setVariable("bPathfind", false)
                z:setVariable("bMoving", true)
            end
        end)
        return
    end
    local dx = z:getX() - cx
    local dy = z:getY() - cy
    local d = math.sqrt(dx * dx + dy * dy)
    local r = CatBR.Config.RAIO_AMARRA
    if d > r and d > 0.01 then
        z:setX(cx + dx / d * r)
        z:setY(cy + dy / d * r)
    end
end

-- mata fantasmas orfaos (de acoes/sessoes antigas) que ficam com
-- corda bugada flutuando; roda de vez em quando ao redor do player
local function varrerOrfaos(p)
    local vivos = {}
    if fantasmaConduzir then vivos[fantasmaConduzir] = true end
    for _, a in pairs(fantasmasAmarra) do vivos[a] = true end
    for dx = -8, 8 do
        for dy = -8, 8 do
            local sq = getCell():getGridSquare(p:getX() + dx, p:getY() + dy, p:getZ())
            if sq then
                local movs = sq:getMovingObjects()
                if movs then
                    for i = movs:size() - 1, 0, -1 do
                        local o = movs:get(i)
                        if o and instanceof(o, "IsoAnimal") and not vivos[o] then
                            local ehGhost = false
                            pcall(function() ehGhost = o:getModData().CatBRGhost == true end)
                            if ehGhost then matarFantasma(o) end
                        end
                    end
                end
            end
        end
    end
end

local function controlar(p)
    -- 1) coleira (conduzir)
    if conduzindo then
        local z = conduzindo
        if z:isDead() or not ehDominado(z) then
            conduzindo = nil
        else
            local dist = IsoUtils.DistanceTo(z:getX(), z:getY(), p:getX(), p:getY())
            if dist > CatBR.Config.CORDA_MAX then
                conduzindo = nil
                z:setUseless(true)
                visualZumbi(z, false)
                maoCorda(p, false)
                p:Say(getText("IGUI_CatBR_CordaEscapou"))
            elseif dist > CatBR.Config.SEGUE then
                if z:isUseless() then z:setUseless(false) end
                -- de costas o zumbi perdia o alvo e a corda esticava:
                -- forca ele a "ver" o condutor (guardado contra nil)
                pcall(function()
                    local f = z.spotted
                    if f then z:spotted(p, true) end
                end)
                tickChama = tickChama + 1
                if tickChama >= 40 then
                    tickChama = 0
                    -- fallback: som mundial curto na posicao do condutor
                    -- (addSound vanilla, raio pequeno pra nao atrair horda)
                    pcall(function()
                        addSound(p, math.floor(p:getX()), math.floor(p:getY()), math.floor(p:getZ()), 10, 12)
                    end)
                end
            elseif dist < CatBR.Config.PARA then
                if not z:isUseless() then z:setUseless(true) end
            end
            -- fantasma da corda gruda no zumbi, pescoco virado pra mim
            if conduzindo and fantasmaConduzir then
                fantasmaSegue(fantasmaConduzir, z, p)
            end
        end
    end
    if not conduzindo and fantasmaConduzir then
        matarFantasma(fantasmaConduzir)
        fantasmaConduzir = nil
    end

    -- sangue escorrendo dos cotos recem-cortados
    for z, resta in pairs(sangrando) do
        if not z or z:isDead() or resta <= 0 then
            sangrando[z] = nil
        elseif ZombRand(30) == 0 then
            sangrando[z] = resta - 1
            pcall(function()
                addBloodSplat(getCell():getGridSquare(z:getX(), z:getY(), z:getZ()), 3)
            end)
        end
    end

    tickOrfaos = tickOrfaos + 1
    if tickOrfaos >= 300 then
        tickOrfaos = 0
        pcall(varrerOrfaos, p)
    end

    -- MP: aplica visuais (corte/mochila) em zumbis marcados que este
    -- cliente esta vendo (estado global via ModData)
    tickVisuais = tickVisuais + 1
    if tickVisuais >= 120 then
        tickVisuais = 0
        pcall(function()
            local d = CatBR.dados()
            local temCorte = false
            for _ in pairs(d.sembraco) do temCorte = true break end
            local temMochila = false
            for _ in pairs(d.mochila) do temMochila = true break end
            if not temCorte and not temMochila then return end
            for dx = -12, 12, 2 do
                for dy = -12, 12, 2 do
                    local sq = getCell():getGridSquare(p:getX() + dx, p:getY() + dy, p:getZ())
                    if sq then
                        local movs = sq:getMovingObjects()
                        if movs then
                            for i = 0, movs:size() - 1 do
                                local o = movs:get(i)
                                if o and instanceof(o, "IsoZombie") and not o:isDead() then
                                    local mo = md(o)
                                    if not mo.CatBRTid then
                                        local okT, tid = pcall(trueIDZumbi, o)
                                        mo.CatBRTid = (okT and tid) or "?"
                                    end
                                    local tid = mo.CatBRTid
                                    if tid ~= "?" then
                                        if d.sembraco[tid] then
                                            mo.CatBR = mo.CatBR or { dominado = true }
                                            if not mo.CatBR.sembraco then
                                                mo.CatBR.sembraco = true
                                                marcarPreso(o, false)
                                            end
                                            aplicarVisualSemBraco(o)
                                        end
                                        if d.mochila[tid] then
                                            aplicarVisualMochila(o, d.mochila[tid])
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 2) dominados soltos: ficam desligados (estatua)
    for i = #dominados, 1, -1 do
        local z = dominados[i]
        if not z or z:isDead() or not ehDominado(z) then
            table.remove(dominados, i)
        elseif z ~= conduzindo then
            local m = md(z).CatBR
            if not m.amarraId and not z:isUseless() then
                z:setUseless(true)
            end
            if m.sembraco then aplicarVisualSemBraco(z) end
        end
    end

    -- grampo POR TICK nos zumbis adotados (bravo estica a corda suave,
    -- sem clipar pra frente e teleportar pra tras)
    local d0 = CatBR.dados()
    for id, zz in pairs(adotados) do
        local am0 = d0.amarras[id]
        if not am0 or not zz or zz:isDead() then
            adotados[id] = nil
        else
            pcall(grampoAmarra, zz, am0)
            -- fantasma colado no zumbi TODO tick (senao fica pra tras)
            if fantasmasAmarra[id] then
                fantasmaSegue(fantasmasAmarra[id], zz)
            end
            -- GUARDA enfurecido: o grampo por tick mata o pathfinding
            -- no MP (teleporte constante). Chacoalhao periodico: re-avista
            -- o player e recalcula rota pro ponto do circulo da corda
            -- mais proximo dele (APIs vanilla: spotted / pathToLocation)
            if am0.bravo then
                tickRepath[id] = (tickRepath[id] or 0) + 1
                if tickRepath[id] >= 15 then
                    tickRepath[id] = 0
                    pcall(function()
                        local cx, cy = am0.x + 0.5, am0.y + 0.5
                        local dx = p:getX() - cx
                        local dy = p:getY() - cy
                        local len = math.sqrt(dx * dx + dy * dy)
                        if len > 0.01 and len <= 15 then
                            local r = math.min((CatBR.Config.RAIO_AMARRA or 1.5) - 0.1, len)
                            local tx = cx + dx / len * r
                            local ty = cy + dy / len * r
                            local fs = zz.spotted
                            if fs then zz:spotted(p, true) end
                            local fp = zz.pathToLocation
                            if fp then zz:pathToLocation(tx, ty, am0.z) end
                        end
                    end)
                end
            end
        end
    end

    -- 3) amarras: zumbi preso no ponto (verifica a cada 10 ticks)
    tickAmarras = tickAmarras + 1
    if tickAmarras >= 10 then
        tickAmarras = 0
        local d = CatBR.dados()
        for id, am in pairs(d.amarras) do
            local perto, melhor = nil, 999
            -- procura zumbi dominado/adotavel perto do ponto
            for dx = -3, 3 do
                for dy = -3, 3 do
                    local sq = getCell():getGridSquare(am.x + dx, am.y + dy, am.z)
                    if sq then
                        local movs = sq:getMovingObjects()
                        if movs then
                            for i = 0, movs:size() - 1 do
                                local o = movs:get(i)
                                if o and instanceof(o, "IsoZombie") and not o:isDead() then
                                    local dd = IsoUtils.DistanceTo(o:getX(), o:getY(), am.x + 0.5, am.y + 0.5)
                                    if dd < melhor and (ehDominado(o) or dd <= CatBR.Config.RAIO_AMARRA) then
                                        perto, melhor = o, dd
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if perto then
                local m = md(perto)
                m.CatBR = m.CatBR or { dominado = true }
                m.CatBR.dominado = true
                m.CatBR.amarraId = id
                -- reaplica corte (reload/MP): estado global manda
                if not m.CatBR.sembraco then
                    local okT, tid = pcall(trueIDZumbi, perto)
                    if okT and tid and CatBR.dados().sembraco[tid] then
                        m.CatBR.sembraco = true
                        aplicarVisualSemBraco(perto)
                        marcarPreso(perto, false)
                    end
                end
                if m.CatBR.sembraco then aplicarVisualSemBraco(perto) end
                if am.rueda then
                    -- Camina visualmente en el sitio, anclado a la casilla.
                    if not perto:isUseless() then perto:setUseless(true) end
                    pcall(function()
                        if perto.setVariable then
                            perto:setVariable("CatBRPreso", false)
                            perto:setVariable("CatBRRueda", true)
                            perto:setVariable("bPathfind", false)
                            perto:setVariable("bMoving", true)
                        end
                    end)
                    if KineticDeadStartWheelNearSquare then
                        pcall(KineticDeadStartWheelNearSquare, perto:getSquare(), perto)
                    end
                elseif am.bravo then
                    -- ZUMBI DE GUARDA: agressivo, tenta pegar quem chega,
                    -- mas a corda nao deixa sair do raio
                    if perto:isUseless() then perto:setUseless(false) end
                    pcall(function()
                        if perto:getVariableBoolean("CatBRPreso") == true then
                            marcarPreso(perto, false)
                        end
                    end)
                else
                    if not perto:isUseless() then perto:setUseless(true) end
                    pcall(function()
                        if perto:getVariableBoolean("CatBRRueda") == true then
                            perto:setVariable("CatBRRueda", false)
                        end
                        if perto:getVariableBoolean("CatBRPreso") ~= true then
                            marcarPreso(perto, true)
                        end
                    end)
                end
                adotados[id] = perto
                grampoAmarra(perto, am)
                -- fantasma da amarra gruda no zumbi preso, virado
                -- pro ponto da amarra
                if fantasmasAmarra[id] then
                    local fa = fantasmasAmarra[id]
                    fantasmaSegue(fa, perto)
                    pcall(function()
                        local f = fa.faceLocationF
                        if f then fa:faceLocationF(am.x + 0.5, am.y + 0.5) end
                    end)
                end
            end
        end
    end
end

Events.OnPlayerUpdate.Add(function(playerObj)
    if not playerObj or not playerObj:isLocalPlayer() then return end
    local ok, err = pcall(controlar, playerObj)
    if not ok then print("[CativeiroBR] erro no controle: " .. tostring(err)) end
end)

------------------------------------------------------------
-- menu de contexto
------------------------------------------------------------
local function zumbisPerto(sq)
    local achados = {}
    for dx = -2, 2 do
        for dy = -2, 2 do
            local s = getCell():getGridSquare(sq:getX() + dx, sq:getY() + dy, sq:getZ())
            if s then
                local movs = s:getMovingObjects()
                if movs then
                    for i = 0, movs:size() - 1 do
                        local o = movs:get(i)
                        if o and instanceof(o, "IsoZombie") and not o:isDead() then
                            local d = IsoUtils.DistanceTo(o:getX(), o:getY(),
                                sq:getX() + 0.5, sq:getY() + 0.5)
                            if d <= CatBR.Config.DIST_MENU then
                                table.insert(achados, o)
                            end
                        end
                    end
                end
            end
        end
    end
    return achados
end

local function onMenu(playerNum, context, worldobjects, test)
    if test then return end
    local playerObj = getSpecificPlayer(playerNum)
    if playerObj == nil then return end

    local sq = nil
    for _, o in ipairs(worldobjects) do
        if o and o.getSquare then
            sq = o:getSquare()
            if sq then break end
        end
    end
    if sq == nil then return end

    -- amarrar o zumbi que esta na corda (clicando num tile perto)
    if conduzindo and not conduzindo:isDead() then
        local distP = IsoUtils.DistanceTo(sq:getX() + 0.5, sq:getY() + 0.5,
            playerObj:getX(), playerObj:getY())
        if distP <= 3.0 then
            -- Se o clique foi numa roda aprendida, oferece a colocação direta
            -- e não interpreta os sprites da roda como árvore/cerca.
            local ruedaClickeada = nil
            local function detectarPiezaRueda(objeto)
                local sprite = objeto and objeto:getSprite() or nil
                local nombre = sprite and sprite:getName() or nil
                if nombre and AnimRueda and AnimRueda.Diccionario and AnimRueda.Diccionario[nombre] then
                    ruedaClickeada = objeto
                    return true
                end
                return false
            end
            for _, objeto in ipairs(worldobjects) do
                if detectarPiezaRueda(objeto) then break end
            end
            -- Algunas piezas grandes no llegan en worldobjects: revisa también
            -- los objetos reales de la casilla seleccionada.
            if not ruedaClickeada then
                pcall(function()
                    local objetosCasilla = sq:getObjects()
                    for i = 0, objetosCasilla:size() - 1 do
                        if detectarPiezaRueda(objetosCasilla:get(i)) then break end
                    end
                end)
            end
            local squareRueda = ruedaClickeada and KineticDeadWheelCaptiveSquare and KineticDeadWheelCaptiveSquare(ruedaClickeada) or nil
            if ruedaClickeada and squareRueda then
                local zumbiParaRueda = conduzindo
                context:addOption(getText("ContextMenu_KineticDead_PutZombieInWheel"), playerObj, function(po)
                    local okR, errR = pcall(CatBR.amarrarEnRueda, po, zumbiParaRueda, squareRueda)
                    if not okR then print("[CativeiroBR] error al meter en rueda: " .. tostring(errR)) end
                end)
            else
            -- En otros tiles conserva el anclaje normal a árbol, poste o cerca.
            local arvore = nil
            for _, o in ipairs(worldobjects) do
                if o and instanceof(o, "IsoTree") then arvore = o break end
            end
            if not arvore then
                pcall(function()
                    if sq.getTree and sq:getTree() then arvore = sq:getTree() end
                end)
            end
            if not arvore then
                pcall(function()
                    local objs = sq:getObjects()
                    if objs then
                        for i = objs:size() - 1, 1, -1 do
                            local o = objs:get(i)
                            if o and o:getSprite() then
                                arvore = o
                                break
                            end
                        end
                    end
                end)
            end
            local rotulo = arvore and getText("ContextMenu_CatBR_AmarrarAncora") or getText("ContextMenu_CatBR_Amarrar")
            context:addOption(rotulo, playerObj, function(po)
                local okA, errA = pcall(amarrarZumbi, po, conduzindo, sq, arvore)
                if not okA then print("[CativeiroBR] erro amarrar: " .. tostring(errA)) end
            end)
            end
            context:addOption(getText("ContextMenu_CatBR_SoltarCorda"), playerObj, function(po)
                pcall(soltarCorda, po)
            end)
        end
    end

    local zumbis = zumbisPerto(sq)
    if #zumbis == 0 then return end

    -- so o primeiro zumbi achado (evita menu gigante em horda)
    local z = zumbis[1]
    if not ehDominado(z) then
        local conocimientos = playerObj:getModData().KineticDeadKnowledge or {}
        if not conocimientos.captura then
            local opt = context:addOption(getText("ContextMenu_KineticDead_LearnCapture"), nil, nil)
            opt.notAvailable = true
            opt.toolTip = ISWorldObjectContextMenu.addToolTip()
            opt.toolTip.description = getText("ContextMenu_KineticDead_LearnCaptureTip")
        elseif CatBR.acharAlgema(playerObj) then
            -- exige STEALTH: agachado e a <= 1.3 tile do zumbi (mesmo
            -- espirito da execucao furtiva com faca)
            local distZ = IsoUtils.DistanceTo(z:getX(), z:getY(),
                playerObj:getX(), playerObj:getY())
            local agachado = false
            pcall(function() agachado = playerObj:isSneaking() end)
            if agachado and distZ <= 1.3 then
                context:addOption(getText("ContextMenu_CatBR_Dominar"), playerObj, function(po)
                    local okD, errD = pcall(dominarZumbi, po, z)
                    if not okD then print("[CativeiroBR] erro dominar: " .. tostring(errD)) end
                end)
            else
                local opt = context:addOption(getText("ContextMenu_CatBR_Dominar"), nil, nil)
                opt.notAvailable = true
                opt.toolTip = ISWorldObjectContextMenu.addToolTip()
                opt.toolTip.description = getText("ContextMenu_CatBR_DominarTip")
            end
        end
    else
        local m = md(z).CatBR
        local am = m and m.amarraId and CatBR.dados().amarras[m.amarraId] or nil
        if am then
            -- zumbi amarrado: modo guarda
            if am.bravo then
                context:addOption(getText("ContextMenu_CatBR_Acalmar"), playerObj, function(po)
                    pcall(function() mandar("AmarraBrava", { x = am.x, y = am.y, z = am.z, bravo = false }) end)
                    po:Say(getText("IGUI_CatBR_Calma"))
                end)
            else
                context:addOption(getText("ContextMenu_CatBR_Enfurecer"), playerObj, function(po)
                    pcall(function() mandar("AmarraBrava", { x = am.x, y = am.y, z = am.z, bravo = true }) end)
                    po:Say(getText("IGUI_CatBR_Pega"))
                end)
            end
        end
        local mm = md(z).CatBR
        if mm and not mm.sembraco then
            --[[
            if temArmaDeCorte(playerObj) then
                context:addOption(getText("ContextMenu_CatBR_Cortar"), playerObj, function(po)
                    local okC, errC = pcall(cortarBracos, po, z)
                    if not okC then print("[CativeiroBR] erro cortar: " .. tostring(errC)) end
                end)
            else
                local opt = context:addOption(getText("ContextMenu_CatBR_Cortar"), nil, nil)
                opt.notAvailable = true
                opt.toolTip = ISWorldObjectContextMenu.addToolTip()
                opt.toolTip.description = getText("ContextMenu_CatBR_CortarTip")
            end]]
            print("-- BORRADO DE PRUEBA")
        end
        -- mochila nas costas do zumbi (burro de carga)
        local temMochilaVestida = false
        local mochilaVestida = nil
        pcall(function()
            local worn = z:getWornItems()
            for i = 0, worn:size() - 1 do
                local it = worn:getItemByIndex(i)
                if it and instanceof(it, "InventoryContainer") then
                    mochilaVestida = it
                    temMochilaVestida = true
                    break
                end
            end
        end)
        if not temMochilaVestida then
            -- procura mochila em 3 lugares: DENTRO do zumbi (arrastada
            -- pela janela de loot), nas COSTAS do player, ou solta na
            -- bolsa principal
            local bolsa, origem = nil, nil
            pcall(function()
                local zi = z:getInventory():getItems()
                for i = 0, zi:size() - 1 do
                    local it = zi:get(i)
                    if it and instanceof(it, "InventoryContainer")
                        and it:canBeEquipped() ~= nil and it:canBeEquipped() ~= "" then
                        bolsa = it
                        origem = "zumbi"
                        break
                    end
                end
            end)
            if not bolsa then
                pcall(function()
                    local worn = playerObj:getWornItems()
                    for i = 0, worn:size() - 1 do
                        local it = worn:getItemByIndex(i)
                        if it and instanceof(it, "InventoryContainer")
                            and it:canBeEquipped() ~= nil and it:canBeEquipped() ~= "" then
                            bolsa = it
                            origem = "costas"
                            break
                        end
                    end
                end)
            end
            if not bolsa then
                pcall(function()
                    local itens = playerObj:getInventory():getItems()
                    for i = 0, itens:size() - 1 do
                        local it = itens:get(i)
                        if it and instanceof(it, "InventoryContainer")
                            and it:canBeEquipped() ~= nil and it:canBeEquipped() ~= "" then
                            bolsa = it
                            origem = "inv"
                            break
                        end
                    end
                end)
            end
            if bolsa then
                --[[context:addOption(getText("ContextMenu_CatBR_ColocarMochila"), playerObj, function(po)
                    local okM, errM = pcall(function()
                        if origem == "costas" then
                            pcall(function() po:setWornItem(bolsa:canBeEquipped(), nil) end)
                            po:getInventory():Remove(bolsa)
                            z:getInventory():AddItem(bolsa)
                        elseif origem == "inv" then
                            po:getInventory():Remove(bolsa)
                            z:getInventory():AddItem(bolsa)
                        end
                        -- padrao vanilla p/ BOLSAS (ISWearClothing.lua:118):
                        -- setWornItem(canBeEquipped(), item) — getBodyLocation()
                        -- e' vazio em InventoryContainer e da NPE
                        if isClient() then
                            -- MP: avisa a rede das transferencias (receita DetencaoBR)
                            pcall(function() sendRemoveItemFromContainer(po:getInventory(), bolsa) end)
                            pcall(function() sendAddItemToContainer(z:getInventory(), bolsa) end)
                        end
                        z:setWornItem(bolsa:canBeEquipped(), bolsa)
                        registrarCarga(z, bolsa)
                        aplicarVisualMochila(z, bolsa:getFullType())
                        -- broadcast: outros clientes vestem o visual ao ver o zumbi
                        local okT, tid = pcall(trueIDZumbi, z)
                        if okT and tid then
                            CatBR.dados().mochila[tid] = bolsa:getFullType()
                            mandar("Mochila", { id = tid, tipo = bolsa:getFullType() })
                        end
                    end)
                    if not okM then print("[CativeiroBR] erro mochila: " .. tostring(errM)) end
                end)]]
                print("-- BORRADO DE PRUEBA")
            end
        else
            --[[
            context:addOption(getText("ContextMenu_CatBR_TirarMochila"), playerObj, function(po)
                local okM, errM = pcall(function()
                    local w = mochilaVestida
                    if w then
                        pcall(function() z:setWornItem(w:canBeEquipped(), nil) end)
                        removerVisualMochila(z, w:getFullType())
                        if isClient() then
                            pcall(function() sendRemoveItemFromContainer(z:getInventory(), w) end)
                        end
                        z:getInventory():Remove(w)
                        desregistrarCarga(z, w)
                        po:getInventory():AddItem(w)
                        if isClient() then
                            pcall(function() sendAddItemToContainer(po:getInventory(), w) end)
                        end
                        local okT, tid = pcall(trueIDZumbi, z)
                        if okT and tid then
                            CatBR.dados().mochila[tid] = nil
                            mandar("Mochila", { id = tid, tipo = nil })
                        end
                        z:resetModelNextFrame()
                    end
                end)
                if not okM then print("[CativeiroBR] erro mochila: " .. tostring(errM)) end
            end)
            ]]
            print("El de tirar mochila era para dejarlo")
        end
        if conduzindo ~= z and not (am and am.bravo) then
            context:addOption(getText("ContextMenu_CatBR_Conduzir"), playerObj, function(po)
                pcall(conduzirZumbi, po, z)
            end)
        end
        if not (am and am.bravo) then
            context:addOption(getText("ContextMenu_CatBR_Libertar"), playerObj, function(po)
                pcall(libertarZumbi, po, z)
            end)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(function(a, b, c, d)
    local ok, err = pcall(onMenu, a, b, c, d)
    if not ok then print("[CativeiroBR] erro no menu: " .. tostring(err)) end
end)

-- morte do zumbi cativo: despeja a carga no chao (o corpo gera loot
-- padrao e descarta o inventario do vivo). Receita MP do vanilla
-- ISDropWorldItemAction: AddWorldInventoryItem + transmitCompleteItemToClients
Events.OnZombieDead.Add(function(z)
    local ok, err = pcall(function()
        if not z then return end
        local m = z:getModData().CatBR
        if not m then return end
        if isClient() then
            -- so o cliente cujo player esta mais perto despeja
            local meu = getPlayer()
            if not meu then return end
            local minhaD = IsoUtils.DistanceTo(z:getX(), z:getY(), meu:getX(), meu:getY())
            local souMaisPerto = true
            pcall(function()
                local ops = getOnlinePlayers()
                if ops then
                    for i = 0, ops:size() - 1 do
                        local op = ops:get(i)
                        if op and op ~= meu then
                            local d2 = IsoUtils.DistanceTo(z:getX(), z:getY(), op:getX(), op:getY())
                            if d2 < minhaD - 0.01 then souMaisPerto = false end
                        end
                    end
                end
            end)
            if not souMaisPerto then return end
        end
        local tid = idCarga(z)
        local reg = tid and cargaZumbi[tid] or nil
        if not reg then return end
        cargaZumbi[tid] = nil
        -- a carga volta pro inventario do jogador mais proximo
        -- (container de player e' sincronizado de verdade no MP;
        -- world items criados no cliente o servidor nao reconhece)
        local meu = getPlayer()
        if not meu then return end
        local inv = meu:getInventory()
        local recuperou = 0
        -- cada item volta INDIVIDUALMENTE (no MP o servidor zera o
        -- conteudo da bolsa ao re-sincronizar; bolsa volta vazia)
        for it, _ in pairs(reg) do
            pcall(function()
                local c = it:getContainer()
                if c then
                    c:Remove(it)
                    if isClient() then
                        pcall(function() sendRemoveItemFromContainer(c, it) end)
                    end
                end
            end)
            local entrou = false
            pcall(function()
                inv:AddItem(it)
                if isClient() then
                    pcall(function() sendAddItemToContainer(inv, it) end)
                end
                entrou = inv:contains(it)
            end)
            if not entrou then
                -- objeto ficou invalido (roupa vestida e' destruida na
                -- morte); repoe um novo do mesmo tipo
                pcall(function()
                    local novo = inv:AddItem(it:getFullType())
                    if novo and isClient() then
                        pcall(function() sendAddItemToContainer(inv, novo) end)
                    end
                end)
            end
            recuperou = recuperou + 1
        end
        if recuperou > 0 then
            meu:Say(getText("IGUI_CatBR_Recuperei", recuperou))
        end
    end)
    if not ok then print("[CativeiroBR] erro na morte: " .. tostring(err)) end
end)

------------------------------------------------------------
-- BURRO DE CARGA: inventario do zumbi dominado na janela de
-- loot (padrao vanilla: OnRefreshInventoryWindowContainers +
-- page:addContainerButton) e mochila vestida nas costas
------------------------------------------------------------
local function zumbisCativosPerto(playerObj)
    local achados = {}
    local px, py, pz = playerObj:getX(), playerObj:getY(), playerObj:getZ()
    for dx = -2, 2 do
        for dy = -2, 2 do
            local sq = getCell():getGridSquare(px + dx, py + dy, pz)
            if sq then
                local movs = sq:getMovingObjects()
                if movs then
                    for i = 0, movs:size() - 1 do
                        local o = movs:get(i)
                        if o and instanceof(o, "IsoZombie") and not o:isDead()
                            and ehDominado(o)
                            and IsoUtils.DistanceTo(o:getX(), o:getY(), px, py) <= 2.2 then
                            table.insert(achados, o)
                        end
                    end
                end
            end
        end
    end
    return achados
end

-- MP: arrastar item de/para o zumbi travava (servidor nao aprova
-- transacao p/ inventario de zumbi vivo). Intercepta a acao e faz a
-- troca NA HORA, cancelando a timed action pendente.
local function ehContainerCativo(c)
    local eh = false
    pcall(function()
        if not c then return end
        local parent = c:getParent()
        if parent and instanceof(parent, "IsoZombie") then
            local m = parent:getModData().CatBR
            if m then eh = true return end
        end
        local ci = c:getContainingItem()
        if ci then
            local cont = ci:getContainer()
            local zp = cont and cont:getParent() or nil
            if zp and instanceof(zp, "IsoZombie") and zp:getModData().CatBR then
                eh = true
            end
        end
    end)
    return eh
end
-- BORRADO DE PRUEBA
--[[
local _isValidOrig = ISInventoryTransferAction.isValid
function ISInventoryTransferAction:isValid()
    if isClient() and self.item and self.srcContainer and self.destContainer
        and (ehContainerCativo(self.srcContainer) or ehContainerCativo(self.destContainer)) then
        local ok, err = pcall(function()
            local it = self.item
            self.srcContainer:Remove(it)
            pcall(function() sendRemoveItemFromContainer(self.srcContainer, it) end)
            self.destContainer:AddItem(it)
            pcall(function() sendAddItemToContainer(self.destContainer, it) end)
            -- livro-caixa da carga
            local zDest = zumbiDoContainer(self.destContainer)
            local zSrc = zumbiDoContainer(self.srcContainer)
            if zDest then registrarCarga(zDest, it) end
            if zSrc and not zDest then desregistrarCarga(zSrc, it) end
        end)
        if not ok then print("[CativeiroBR] erro transf: " .. tostring(err)) end
        return false  -- item ja transferido; cancela a acao pendente
    end
    return _isValidOrig(self)
end

Events.OnRefreshInventoryWindowContainers.Add(function(page, state)
    local ok, err = pcall(function()
        if state ~= "buttonsAdded" then return end
        if page.onCharacter then return end  -- so na janela de LOOT
        local playerObj = getSpecificPlayer(page.player)
        if not playerObj then return end
        local tex = getTexture("media/ui/Container_Mannequin.png")
        for _, z in ipairs(zumbisCativosPerto(playerObj)) do
            page:addContainerButton(z:getInventory(), tex, getText("ContextMenu_CatBR_ZumbiCativo"), nil)
            -- mochilas dentro do zumbi tambem viram botao
            local inv = z:getInventory()
            local itens = inv:getItems()
            for i = 0, itens:size() - 1 do
                local it = itens:get(i)
                if it and instanceof(it, "InventoryContainer") then
                    page:addContainerButton(it:getItemContainer(), tex,
                        getText("ContextMenu_CatBR_MochilaZumbi"), nil)
                end
            end
        end
    end)
    if not ok then print("[CativeiroBR] erro no loot: " .. tostring(err)) end
end)
]]
print("[CativeiroBR] cliente carregado (v1.0)")
