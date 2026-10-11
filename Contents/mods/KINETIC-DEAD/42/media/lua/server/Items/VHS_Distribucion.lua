local PELICULAS = { "boondocks", "noticiero", "walkin", "trailer", "ricardo_milos", "joven", "rickroll" }
-- La suma es 100: Logan C es una cinta mítica de aparición rara (2%).
local SERIES = {
    { item = "Base.VHS_Logan", category = "Logan-VHS", weight = 33 },
    { item = "Base.VHS_Ruiz", category = "Ruiz-VHS", weight = 33 },
    { item = "Base.VHS_Thorne", category = "Thorne-VHS", weight = 32 },
    { item = "Base.VHS_LoganC", category = "LoganC-VHS", weight = 2 },
}
local function elegirSerie()
    local tirada = ZombRand(100)
    local acumulado = 0
    for _, serie in ipairs(SERIES) do
        acumulado = acumulado + serie.weight
        if tirada < acumulado then return serie end
    end
    return SERIES[1]
end
local CONTENEDORES = { bin=true, dumpster=true, crate=true, shelves=true, sidetable=true, wardrobe=true, displaycase=true }
local function asignar(container, itemType, mediaId, expectedCategory)
    local data = getZomboidRadio():getRecordedMedia():getMediaData(mediaId)
    if not data then
        print("[KineticDead-VHS] Registro no encontrado: " .. tostring(mediaId))
        return false
    end
    if expectedCategory and data:getCategory() ~= expectedCategory then
        print(string.format("[KineticDead-VHS] Categoria incorrecta para %s: esperada=%s recibida=%s",
            tostring(mediaId), tostring(expectedCategory), tostring(data:getCategory())))
        return false
    end
    local item = container:AddItem(itemType)
    if not item then return false end
    item:setRecordedMediaData(data)
    print(string.format("[KineticDead-VHS] %s <- %s [%s]", itemType, mediaId, tostring(data:getCategory())))
    return true
end
local function elegirDeCategoria(recordedMedia, category)
    local datos = recordedMedia:getAllMediaForCategory(category)
    if not datos or datos:size() == 0 then return nil end
    local data = datos:get(ZombRand(datos:size()))
    return data and data:getId() or nil
end
local function generar(roomName, containerType, container)
    if not container or not CONTENEDORES[containerType] then return end
    local parent = container:getParent()
    if not parent then return end
    local md = parent:getModData()
    if md.kineticDeadVhsProcessed then return end
    md.kineticDeadVhsProcessed = true
    local recordedMedia = getZomboidRadio():getRecordedMedia()
    if ZombRand(100) < 100 then
        local serie = elegirSerie()
        local id = elegirDeCategoria(recordedMedia, serie.category)
        if id and asignar(container, serie.item, id, serie.category) then return end
    end
    if ZombRand(100) >= 15 then return end
    local id = PELICULAS[ZombRand(#PELICULAS) + 1]
    asignar(container, "Base.VHS_Animado", id, "Animado-VHS")
end
Events.OnFillContainer.Add(generar)
