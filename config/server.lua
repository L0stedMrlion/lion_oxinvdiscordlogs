return {
    -- Check for updates when the resource starts. Set to false to disable the check.
    versioncheck = true,

    -- Add Discord webhook URLs below. Leave empty to disable a category.
    -- This file is loaded server-side only. Never publish real webhook URLs to GitHub.
    webhooks = {
        -- Example: customize one webhook without changing the default appearance for other categories.
        -- Remove the -- prefix on individual options that you want to use.
        evidence = {
            url = '',
            color = '#F59E0B',
            -- username = 'Police Evidence Logs',
            -- avatarUrl = 'https://example.com/webhook-avatar.png',
            -- authorName = 'Evidence Management',
            -- authorIconUrl = 'https://example.com/author-icon.png',
            -- authorUrl = 'https://example.com',
            -- thumbnailUrl = 'https://example.com/thumbnail.png',
            -- footerText = 'My FiveM Server',
            -- footerIconUrl = 'https://example.com/footer-icon.png'
        },
        -- Both vehicle trunks and gloveboxes use this webhook.
        vehicle = { url = '', color = '#3B82F6' },
        drop = { url = '', color = '#EF4444' },
        pickup = { url = '', color = '#22C55E' },
        give = { url = '', color = '#A855F7' },
        stash = { url = '', color = '#06B6D4' },
        container = { url = '', color = '#EAB308' }
    },

    -- Global Discord embed appearance. Individual webhooks can override these fields.
    appearance = {
        username = 'Inventory Logs',
        avatarUrl = '',
        authorName = 'Inventory Activity',
        authorIconUrl = '',
        authorUrl = '',
        thumbnailUrl = '',
        footerText = 'Inventory Logs',
        footerIconUrl = '',
        defaultColor = '#5865F2',
        timestamp = true,
        showDiscord = true,
        showLicense = true,
        showCoordinates = true,
        showMetadata = true,
        showTargetPlayer = true
    },

    -- Enable or disable individual inventory events.
    logs = {
        evidence_put = true,
        evidence_take = true,
        trunk_put = true,
        trunk_take = true,
        glovebox_put = true,
        glovebox_take = true,
        drop = true,
        pickup = true,
        stash_put = true,
        stash_take = true,
        container_put = true,
        container_take = true,
        container_transfer = true,
        give = true
    },

    titles = {
        evidence_put = 'Item Placed in Evidence',
        evidence_take = 'Item Taken from Evidence',
        trunk_put = 'Item Placed in Vehicle Trunk',
        trunk_take = 'Item Taken from Vehicle Trunk',
        glovebox_put = 'Item Placed in Vehicle Glovebox',
        glovebox_take = 'Item Taken from Vehicle Glovebox',
        drop = 'Item Dropped',
        pickup = 'Item Picked Up',
        stash_put = 'Item Put into Stash',
        stash_take = 'Item Taken from Stash',
        container_put = 'Item Put into Container',
        container_take = 'Item Taken from Container',
        container_transfer = 'Item Moved Between Containers',
        give = 'Player-to-Player Item Transfer'
    },

    inventory = {
        -- Stash ID prefixes that should be logged under the evidence category.
        -- These are Lua patterns. Other stashes are logged as normal stashes.
        evidencePatterns = { '^policeevidence', '^evidence:' },

        -- Native ox_inventory swapItems hook filters.
        -- The default {} applies NO filters and allows logging of all supported transfers.
        -- Keep this empty unless you specifically want to reduce which transfers are logged.
        -- These filters do NOT block item movements; they only filter log events.
        --
        -- Available options:
        -- itemFilter:      Only trigger for listed item names, e.g. water or WEAPON_PISTOL.
        -- inventoryFilter: Only trigger if a source/destination inventory ID matches
        --                  at least one Lua pattern, e.g. '^trunk' or '^glove'.
        -- typeFilter:      Only trigger for matching SOURCE inventory types (fromType),
        --                  e.g. player, stash, trunk or glovebox. This can miss
        --                  transfers in the opposite direction, so use carefully.
        -- print:           Print ox_inventory hook diagnostics in the server console.
        --                  This does not control Discord webhook messages.
        --
        -- IMPORTANT: Multiple enabled filters are combined (all must match).
        -- Example: uncomment the example below INSTEAD of hookOptions = {} to
        -- log only selected items when a vehicle trunk or glovebox is involved.
        --
        -- hookOptions = {
        --     itemFilter = {
        --         water = true,
        --         WEAPON_PISTOL = true
        --     },
        --     inventoryFilter = { '^trunk', '^glove' },
        --     print = false
        -- },
        --
        -- To log every supported item/transfer (recommended):
        hookOptions = {}
    },

    http = {
        retries = 3,
        retryDelayMs = 1500,
        debug = false
    }
}
