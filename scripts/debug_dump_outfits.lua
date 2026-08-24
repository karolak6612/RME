-- @Title: Debug dump outfits
-- @Description: Places all outfits available at coordinates 10 / 10 / 0 (requires at least one podium item declared).
-- @Author: Zbizu

if not app.hasMap() then
    app.alert({ title = "Debug dump", text = "Open a map before running this script." })
    return
end

local function dumpOutfits(options)
    local offsetX = options.offsetX or 10
    local offsetY = options.offsetY or 10
    local offsetZ = options.offsetZ or 0
    local itemsPerRow = options.itemsPerRow or 15

    if offsetX < 0 or offsetY < 0 or offsetZ < 0 or offsetZ > 15 then
        app.alert("invalid offset values")
		return
    end
    if itemsPerRow <= 0 or itemsPerRow > 10000 then
        app.alert("itemsPerRow must be between 1 and 10000")
		return
    end

    local podiumId
    for itemId = 1, Items.getMaxId() do
        local info = Items.getInfo(itemId)
        if info and info.isPodium then
            podiumId = itemId
            break
        end
    end
    if not podiumId then
        app.alert("no podium item definition found")
		return
    end

    local inserted = 0
    local x, y = offsetX, offsetY
    app.transaction("Dump outfits to map", function()
        for lookType = 1, app.getCreatureSpriteMaxId() do
            local tile = app.map:getOrCreateTile(x, y, offsetZ)
            local podium = tile:addItem(podiumId)
            podium:setPodiumOutfit(lookType, 2)
            inserted = inserted + 1

            x = x + 4
            if x >= offsetX + itemsPerRow * 4 then
                x = offsetX
                y = y + 4
            end
        end
    end)
    app.refresh()
    return inserted
end

dumpOutfits({
    offsetX = 10,
    offsetY = 10,
    offsetZ = 0,
    itemsPerRow = 15,
    maxZ = 15
})
app.setCameraPosition(10, 10, 0)