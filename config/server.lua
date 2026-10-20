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
        trunk = { url = '', color = '#3B82F6' },
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
        trunk_put = 'Item Placed in Trunk',
        trunk_take = 'Item Taken from Trunk',
        glovebox_put = 'Item Placed in Glovebox',
        glovebox_take = 'Item Taken from Glovebox',
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
        evidencePatterns = { '^policeevidence', '^evidence:' },
        hookOptions = {}
    },

    http = {
        retries = 3,
        retryDelayMs = 1500,
        debug = false
    }
}
