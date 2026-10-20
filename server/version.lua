local config = lib.require('config.server')
local version = {}

local resourceId = 'lion_oxinvdiscordlogs'
local registryUrl = 'https://raw.githubusercontent.com/L0stedMrlion/lion_scripts_versions/main/versions.json'
local releasesUrl = 'https://github.com/L0stedMrlion/lion_oxinvdiscordlogs/releases'

function version.check()
    if not config.versioncheck then return end

    PerformHttpRequest(registryUrl, function(statusCode, responseData)
        if tonumber(statusCode) ~= 200 or type(responseData) ~= 'string' or responseData == '' then
            print('^1[' .. resourceId .. '] Unable to run version check.^7')
            return
        end

        local ok, versions = pcall(json.decode, responseData)
        if not ok or type(versions) ~= 'table' then
            print('^1[' .. resourceId .. '] Failed to parse versions.json.^7')
            return
        end

        local data = versions[resourceId]
        if data == nil then
            print('^3[' .. resourceId .. '] No version entry found in versions.json.^7')
            return
        end

        local latestVersion = type(data) == 'table' and data.version or data
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
        local current = tostring(currentVersion or ''):gsub('%s+', '')
        local latest = tostring(latestVersion or ''):gsub('%s+', '')

        if current == '' or latest == '' then
            print('^3[' .. resourceId .. '] Invalid current or latest version.^7')
            return
        end

        if current ~= latest then
            print('^3An update is available for ' .. resourceId .. '^7')
            print('^3Your Version: ^1' .. current .. '^3 | Latest Version: ^2' .. latest .. '^7')
            print('^3Download the latest release from ^4' .. releasesUrl .. '^7')
        else
            print('^2[' .. resourceId .. '] You are running the latest version (' .. current .. ').^7')
        end
    end, 'GET')
end

return version
