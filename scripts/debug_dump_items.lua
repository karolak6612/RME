-- @Title: Debug dump items
-- @Description: Places all items available at coordinates 10 / 10 / 0.
-- @Author: Zbizu

if not app.hasMap() then
    app.alert({ title = "Debug dump", text = "Open a map before running this script." })
    return
end

local function dumpItems(options)
    local offsetX = options.offsetX or 10
    local offsetY = options.offsetY or 10
    local offsetZ = options.offsetZ or 0
    local itemsPerRow = options.itemsPerRow or 60

    if offsetX < 0 or offsetY < 0 or offsetZ < 0 or offsetZ > 15 then
        error("dumpItems: invalid offset values")
    end
    if itemsPerRow <= 0 or itemsPerRow > 10000 then
        error("dumpItems: itemsPerRow must be between 1 and 10000")
    end

    local inserted = 0
    local x, y = offsetX, offsetY
    app.transaction("Dump items to map", function()
        for itemId = 1, Items.getMaxId() do
            local info = Items.getInfo(itemId)
            if info and info.clientId ~= 0 then
                local tile = app.map:getOrCreateTile(x, y, offsetZ)
                tile:addItem(itemId)
                inserted = inserted + 1

                x = x + 1
                if x >= offsetX + itemsPerRow then
                    x = offsetX
                    y = y + 1
                end
            end
        end
    end)
    app.refresh()
    return inserted
end

dumpItems({
    offsetX = 10,
    offsetY = 10,
    offsetZ = 0,
    itemsPerRow = 60,
    maxZ = 15
})
app.setCameraPosition(10, 10, 0)