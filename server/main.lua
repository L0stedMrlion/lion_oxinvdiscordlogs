local config = lib.require('config.server')

local routes = lib.require('server.routes')
local formatter = lib.require('server.formatter')
local webhook = lib.require('server.webhook')
local oxInventory = exports.ox_inventory

lib.require('server.version').check()

local function normalizedType(inventory, inventoryType)
    if inventoryType ~= 'stash' then return inventoryType end

    local id = tostring(formatter.inventoryId(inventory) or '')
    for _, pattern in ipairs(config.inventory.evidencePatterns or {}) do
        if id:match(pattern) then return 'policeevidence' end
    end
    return inventoryType
end

local function logTransfer(payload)
    local fromType = normalizedType(payload.fromInventory, payload.fromType)
    local toType = normalizedType(payload.toInventory, payload.toType)
    local fromId = tostring(formatter.inventoryId(payload.fromInventory))
    local toId = tostring(formatter.inventoryId(payload.toInventory))

    if fromType == toType and fromId == toId then return end

    for name, route in pairs(routes) do
        if config.logs[name] and route.from == fromType and route.to == toType then
            local targetSource
            local selectedRoute = route
            local title = config.titles[name] or name
            if name == 'give' then
                local source = tonumber(payload.source)
                local fromSource = tonumber(formatter.inventoryId(payload.fromInventory))
                local toSource = tonumber(formatter.inventoryId(payload.toInventory))
                if not source or not fromSource or not toSource then return end
                targetSource = source == fromSource and toSource or fromSource
                if source == toSource then
                    selectedRoute = { verb = 'took from', webhook = route.webhook }
                    title = 'Item Taken from Player'
                elseif source == fromSource then
                    selectedRoute = { verb = 'gave to', webhook = route.webhook }
                    title = config.titles[name] or 'Item Given to Player'
                end
            end

            local ok, err = pcall(function()
                webhook.send(route.webhook, formatter.build(payload, selectedRoute, targetSource, title))
            end)

            if not ok then
                print(('^1[lion_oxinvdiscordlogs]^0 Route "%s" failed: %s'):format(name, err))
            end
            return
        end
    end
end

local function onSwap(payload)
    logTransfer(payload)

    if payload.action ~= 'swap' or type(payload.toSlot) ~= 'table' then return end
    if (tonumber(payload.toSlot.count) or 0) < 1 then return end

    logTransfer({
        source = payload.source,
        action = 'swap',
        fromInventory = payload.toInventory,
        toInventory = payload.fromInventory,
        fromType = payload.toType,
        toType = payload.fromType,
        fromSlot = payload.toSlot,
        toSlot = payload.fromSlot,
        count = payload.toSlot.count
    })
end

local hookId = oxInventory:registerHook('swapItems', function(payload)
    local ok, err = pcall(onSwap, payload)
    if not ok then
        print(('^1[lion_oxinvdiscordlogs]^0 swapItems processing failed: %s'):format(err))
    end
end, config.inventory.hookOptions or {})

if not hookId then
    print('^1[lion_oxinvdiscordlogs]^0 Failed to register swapItems hook.')
else
    print('^2[lion_oxinvdiscordlogs]^0 Inventory logging initialized.')
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and hookId then
        pcall(function() oxInventory:removeHooks(hookId) end)
    end
end)
