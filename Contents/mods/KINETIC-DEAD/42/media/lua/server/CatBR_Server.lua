--***********************************************************
--**  CATIVEIRO BR - Servidor: registro global de amarras  **
--**  (pontos onde ha zumbi amarrado), sincronizado a      **
--**  todos os clientes via ModData (padrao DetencaoBR).   **
--***********************************************************

require "CatBR_Shared"

if isClient() then return end

local Cmd = {}

-- acha o zumbi mais proximo do ponto (lado do servidor)
local function zumbiNoPonto(x, y, z, raio)
    local melhor, melhorD = nil, raio or 2.5
    for dx = -3, 3 do
        for dy = -3, 3 do
            local sq = getCell():getGridSquare(math.floor(x) + dx, math.floor(y) + dy, math.floor(z))
            if sq then
                local movs = sq:getMovingObjects()
                if movs then
                    for i = 0, movs:size() - 1 do
                        local o = movs:get(i)
                        if o and instanceof(o, "IsoZombie") and not o:isDead() then
                            local d = IsoUtils.DistanceTo(o:getX(), o:getY(), x + 0.5, y + 0.5)
                            if d < melhorD then melhor, melhorD = o, d end
                        end
                    end
                end
            end
        end
    end
    return melhor
end

-- MP: o servidor e' dono do estado do zumbi; aplica useless aqui
local function estadoZumbi(x, y, z, useless)
    if not isServer() then return end  -- SP: cliente ja cuida
    pcall(function()
        local zb = zumbiNoPonto(x, y, z, 2.5)
        if zb then zb:setUseless(useless == true) end
    end)
end

local function sync()
    ModData.transmit(CatBR.MODKEY)
end

function Cmd.Amarrar(player, args)
    if not args or not args.x then return end
    local d = CatBR.dados()
    d.amarras[CatBR.idAmarra(args.x, args.y, args.z)] =
        { x = math.floor(args.x), y = math.floor(args.y), z = math.floor(args.z),
          por = player and player:getUsername() or "?", rueda = args.rueda == true }
    sync()
    estadoZumbi(args.x, args.y, args.z, true)
    CatBR.log("amarra criada em " .. args.x .. "," .. args.y)
end

function Cmd.Desamarrar(player, args)
    if not args or not args.x then return end
    local d = CatBR.dados()
    d.amarras[CatBR.idAmarra(args.x, args.y, args.z)] = nil
    sync()
    -- desamarrado: se vai conduzir, o cliente religa a coleira;
    -- aqui so garante que nao fica travado
    estadoZumbi(args.x, args.y, args.z, false)
end

function Cmd.AmarraBrava(player, args)
    if not args or not args.x then return end
    local d = CatBR.dados()
    local am = d.amarras[CatBR.idAmarra(args.x, args.y, args.z)]
    if am then
        am.bravo = args.bravo == true
        sync()
        -- bravo = ligado (persegue no raio); calmo = desligado
        estadoZumbi(args.x, args.y, args.z, not am.bravo)
    end
end
--[[
function Cmd.SemBraco(player, args)
    if not args or not args.id then return end
    local d = CatBR.dados()
    d.sembraco[tostring(args.id)] = true
    sync()
end

function Cmd.Mochila(player, args)
    if not args or not args.id then return end
    local d = CatBR.dados()
    d.mochila[tostring(args.id)] = args.tipo  -- nil = tirou
    sync()
end
]]

function Cmd.PedirEstado(player, args)
    sync()
end

Events.OnClientCommand.Add(function(module, command, player, args)
    if module ~= CatBR.MODKEY then return end
    if Cmd[command] then
        local ok, err = pcall(Cmd[command], player, args or {})
        if not ok then print("[CativeiroBR] erro no comando " .. tostring(command) .. ": " .. tostring(err)) end
    end
end)

print("[CativeiroBR] servidor carregado (v1.0)")
