local config = lib.require('config.server')
local webhook = {}
local warned = {}

local function cleanUrl(value)
    if type(value) ~= 'string' or value == '' then return nil end
    if not value:match('^https://[%w%.%-]+/api/webhooks/%d+/[%w%-%_]+') then return nil end
    local domain = value:match('^https://([^/]+)')
    if domain ~= 'discord.com' and domain ~= 'discordapp.com' and domain ~= 'canary.discord.com' and domain ~= 'ptb.discord.com' then
        return nil
    end
    return value
end

local function optionalText(value)
    return type(value) == 'string' and value ~= '' and value or nil
end

local function color(value)
    if type(value) == 'number' then
        return math.max(0, math.min(16777215, math.floor(value)))
    end
    if type(value) == 'string' then
        local hex = value:match('^#?(%x%x%x%x%x%x)$')
        if hex then return tonumber(hex, 16) end
    end
    return 5793266
end

local function printWarning(key, message)
    if warned[key] then return end
    warned[key] = true
    print(('^3[lion_oxinvdiscordlogs]^0 %s'):format(message))
end

local function buildEmbed(embed, settings)
    local appearance = config.appearance
    local result = {
        title = embed.title,
        description = embed.description,
        fields = embed.fields,
        color = color(settings.color or appearance.defaultColor)
    }

    local authorName = optionalText(settings.authorName) or optionalText(appearance.authorName)
    if authorName then
        result.author = {
            name = authorName,
            icon_url = optionalText(settings.authorIconUrl) or optionalText(appearance.authorIconUrl),
            url = optionalText(settings.authorUrl) or optionalText(appearance.authorUrl)
        }
    end

    local thumbnail = optionalText(settings.thumbnailUrl) or optionalText(appearance.thumbnailUrl)
    if thumbnail then result.thumbnail = { url = thumbnail } end

    local footerText = optionalText(settings.footerText) or optionalText(appearance.footerText)
    if footerText then
        result.footer = {
            text = footerText,
            icon_url = optionalText(settings.footerIconUrl) or optionalText(appearance.footerIconUrl)
        }
    end

    if appearance.timestamp then result.timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ') end
    return result
end

local function request(url, body, attempt)
    PerformHttpRequest(url, function(status, response, headers)
        status = tonumber(status) or 0
        if status >= 200 and status < 300 then return end

        local maxRetries = math.max(0, math.min(10, tonumber(config.http.retries) or 3))
        if attempt >= maxRetries or (status ~= 429 and (status < 500 or status > 599)) then
            printWarning(('http:%s'):format(status), ('Discord returned HTTP %s (webhook URL hidden).'):format(status))
            return
        end

        local delay = math.max(1000, tonumber(config.http.retryDelayMs) or 1500) * (2 ^ attempt)
        if status == 429 then
            local ok, decoded = pcall(json.decode, response or '')
            local retry = ok and type(decoded) == 'table' and tonumber(decoded.retry_after) or nil
            if not retry and type(headers) == 'table' then
                retry = tonumber(headers['retry-after'] or headers['Retry-After'])
            end
            if retry then delay = retry * 1000 end
        end

        delay = math.floor(math.max(1000, math.min(delay, 60000)))
        SetTimeout(delay, function() request(url, body, attempt + 1) end)
    end, 'POST', body, { ['Content-Type'] = 'application/json' })
end

function webhook.send(key, embed)
    local settings = config.webhooks[key]
    if type(settings) ~= 'table' then
        printWarning('category:' .. tostring(key), ('Unknown webhook category: %s'):format(key))
        return false
    end

    local url = cleanUrl(settings.url)
    if not url then
        printWarning('missing:' .. key, ('Webhook "%s" is missing or invalid; this category is skipped.'):format(key))
        return false
    end

    local body = json.encode({
        username = optionalText(settings.username) or optionalText(config.appearance.username),
        avatar_url = optionalText(settings.avatarUrl) or optionalText(config.appearance.avatarUrl),
        allowed_mentions = { parse = {} },
        embeds = { buildEmbed(embed, settings) }
    })

    if config.http.debug then print(('[lion_oxinvdiscordlogs] Posting category: %s'):format(key)) end
    request(url, body, 0)
    return true
end

return webhook
