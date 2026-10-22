local config = lib.require('config.server')
local oxInventory = exports.ox_inventory

local formatter = {}

local function trim(value, maxLength)
    local output = tostring(value == nil and 'Unavailable' or value):gsub('\226\128\162', '')
    if #output <= maxLength then return output end

    output = output:sub(1, maxLength - 3)
    while #output > 0 and not utf8.len(output) do
        output = output:sub(1, -2)
    end

    return output .. '...'
end

local function safe(value, maxLength)
    local output = tostring(value == nil and 'Unavailable' or value)
    output = output:gsub('@', '@\226\128\139'):gsub('`', "'")
    return trim(output, maxLength)
end

local function inventoryId(inventory)
    if type(inventory) == 'table' then
        return inventory.id or inventory.dbId or inventory.name or 'Unknown inventory'
    end
    return inventory
end

local function getIdentifier(source, kind)
    local prefix = kind .. ':'
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if identifier:sub(1, #prefix) == prefix then return identifier end
    end
end

local function playerName(source)
    local id = tonumber(source)
    if not id then return 'Unknown player' end
    return safe(GetPlayerName(id) or 'Unknown player', 100)
end

local function playerDetails(source)
    local id = tonumber(source)
    if not id then return 'Unavailable' end

    local lines = {
        ('**Name:** %s'):format(playerName(id)),
        ('**Server ID:** `%s`'):format(id)
    }

    if config.appearance.showDiscord then
        local discord = getIdentifier(id, 'discord')
        lines[#lines + 1] = ('**Discord:** %s'):format(discord and ('<@%s>'):format(discord:sub(9)) or 'Not linked')
    end

    if config.appearance.showLicense then
        lines[#lines + 1] = ('**License:** `%s`'):format(safe(getIdentifier(id, 'license') or getIdentifier(id, 'license2') or 'Unavailable', 150))
    end

    if config.appearance.showCoordinates then
        local ped = GetPlayerPed(id)
        if ped and ped ~= 0 then
            local coords = GetEntityCoords(ped)
            if coords then
                lines[#lines + 1] = ('**Coords:** `%.2f, %.2f, %.2f`'):format(coords.x, coords.y, coords.z)
            end
        end
    end

    return trim(table.concat(lines, '\n'), 1024)
end

local function inventoryDetails(inventory, inventoryType)
    local id = inventoryId(inventory)

    if inventoryType == 'player' then
        local source = tonumber(id)
        if source then
            return safe(('%s [ID: %s]'):format(playerName(source), source), 300)
        end
    end

    local data = type(inventory) == 'table' and inventory or nil
    if not data then
        local ok, result = pcall(function()
            return oxInventory:GetInventory(inventory)
        end)
        if ok and type(result) == 'table' then data = result end
    end

    local label = data and data.label
    if label and tostring(label) ~= tostring(id) then
        return safe(('%s [%s]'):format(label, id), 300)
    end

    return safe(id, 300)
end

local function itemDetails(slot, count)
    local name = type(slot) == 'table' and slot.name or 'unknown'
    local metadata = type(slot) == 'table' and type(slot.metadata) == 'table' and slot.metadata or {}
    local label = metadata.label or (type(slot) == 'table' and slot.label) or name
    return ('**Item:** %s\n**Item name:** `%s`\n**Amount:** `%s`'):format(
        safe(label, 150), safe(name, 100), math.max(0, math.floor(tonumber(count) or 0))
    )
end

function formatter.inventoryId(inventory)
    return inventoryId(inventory)
end

function formatter.playerName(source)
    return playerName(source)
end

function formatter.build(payload, route, targetSource, title)
    local count = math.max(0, math.floor(tonumber(payload.count) or 0))
    local fields = {
        {
            name = 'Item',
            value = trim(itemDetails(payload.fromSlot, count), 1024),
            inline = false
        },
        {
            name = 'Inventory Transfer',
            value = trim(('**From:** %s\n**To:** %s\n**Action:** `%s`'):format(
                inventoryDetails(payload.fromInventory, payload.fromType),
                inventoryDetails(payload.toInventory, payload.toType),
                safe(payload.action or 'move', 80)
            ), 1024),
            inline = false
        },
        {
            name = 'Player',
            value = playerDetails(payload.source),
            inline = false
        }
    }

    if targetSource and config.appearance.showTargetPlayer then
        fields[#fields + 1] = { name = 'Target Player', value = playerDetails(targetSource), inline = false }
    end

    if config.appearance.showMetadata then
        local metadata = type(payload.fromSlot) == 'table' and payload.fromSlot.metadata
        if type(metadata) == 'table' and next(metadata) then
            local ok, encoded = pcall(json.encode, metadata)
            fields[#fields + 1] = {
                name = 'Item Metadata',
                value = safe(ok and encoded or 'Cannot encode metadata', 1024),
                inline = false
            }
        end
    end

    local description
    if targetSource then
        description = ('**%s** %s an item involving **%s**.'):format(
            playerName(payload.source), safe(route.verb, 100), playerName(targetSource)
        )
    else
        description = ('**%s** %s **%sx item(s)**.'):format(
            playerName(payload.source), safe(route.verb, 100), count
        )
    end

    return {
        title = safe(title, 256),
        description = trim(description, 4096),
        fields = fields
    }
end

return formatter
