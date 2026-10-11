--***********************************************************
--**      CATIVEIRO BR v0.1 - Zumbi na Corda (TESTE)       **
--**  Dominar zumbi com algema/corda, conduzir na corda    **
--**  e amarrar em arvores/grades. Mod separado do         **
--**  DetencaoBR (mas usa as algemas dele se presente).    **
--**                                                       **
--**  Nucleo tecnico: zombie:setUseless(true/false) --     **
--**  mecanismo vanilla (menu debug) que liga/desliga o    **
--**  zumbi. Coleira: longe = ligado (persegue o condutor),**
--**  perto = desligado (nao morde).                       **
--***********************************************************

CatBR = CatBR or {}

CatBR.Config = {
    -- distancia maxima do clique para achar o zumbi
    DIST_MENU = 2.5,

    -- coleira (conduzir): zumbi liga quando mais longe que SEGUE,
    -- desliga quando mais perto que PARA (histerese anti-mordida)
    SEGUE = 1.7,
    PARA = 1.1,

    -- corda "arrebenta" (para de conduzir) alem dessa distancia
    CORDA_MAX = 12.0,

    -- fantasma da corda (RATO invisivel; sem ropeBone a ponta da corda
    -- e a POSICAO dele): altura acima do chao onde a corda prende no
    -- zumbi (0.55 ~= pescoco; 1 nivel = altura de 1 andar) e avanco
    -- na frente do peito (na direcao do condutor)
    FANTASMA_ALTURA = 0.45,
    FANTASMA_RECUO = 0.02,

    -- raio da amarra: zumbi teleporta de volta se passar disso
    RAIO_AMARRA = 1.5,

    -- itens aceitos para dominar o zumbi (o primeiro achado e usado
    -- e volta pro inventario ao libertar)
    ALGEMAS = {
        "Base.DetBR_Algemas",
        "Base.DetBR_AlgemasPlastico",
        "Base.DetBR_Cordas",
        "Base.DetBR_AlgemasCouro",
        "Base.Rope",
        "Base.Wire",
        "Base.Zipties",
    },

    -- item necessario no inventario para conduzir
    CORDA = "Base.Rope",

    Verbose = false,
}

CatBR.MODKEY = "CativeiroBR"

function CatBR.log(msg)
    if CatBR.Config.Verbose then print("[CativeiroBR] " .. tostring(msg)) end
end

function CatBR.dados()
    local d = ModData.getOrCreate(CatBR.MODKEY)
    d.amarras = d.amarras or {}
    d.sembraco = d.sembraco or {}
    d.mochila = d.mochila or {}
    return d
end

function CatBR.idAmarra(x, y, z)
    return math.floor(x) .. "_" .. math.floor(y) .. "_" .. math.floor(z)
end

-- acha o primeiro item de "algema" no inventario
function CatBR.acharAlgema(playerObj)
    local inv = playerObj:getInventory()
    for _, ft in ipairs(CatBR.Config.ALGEMAS) do
        local it = inv:getFirstTypeRecurse(ft)
        if it then return it end
    end
    return nil
end

print("[CativeiroBR] shared carregado (v0.1)")
