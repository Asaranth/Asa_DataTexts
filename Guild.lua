local _, ADT = ...

local select = select

local GameTooltip = GameTooltip
local C_GuildInfo = C_GuildInfo
local IsInGuild = IsInGuild
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildRosterInfo = GetGuildRosterInfo
local GetClassInfo = GetClassInfo
local ToggleGuildFrame = ToggleGuildFrame

local guildRosterReady = false
local FRAME_NAME = 'Guild'

local function GetGuildOnlineCount()
    if not IsInGuild() then return 0 end

    -- Modern Retail API
    if C_GuildInfo and C_GuildInfo.GetNumMembers and C_GuildInfo.GetMemberInfoByIndex then
        local total = C_GuildInfo.GetNumMembers()
        if not total or total == 0 then return 0 end

        local onlineCount = 0
        for i = 1, total do
            local info = C_GuildInfo.GetMemberInfoByIndex(i)
            if info and info.isOnline then onlineCount = onlineCount + 1 end
        end

        return onlineCount
    end

    -- Legacy Fallback
    if GetNumGuildMembers and GetGuildRosterInfo then
        local total = GetNumGuildMembers() or 0
        local onlineCount = 0

        for i = 1, total do
            local online = select(9, GetGuildRosterInfo(i))
            if online then onlineCount = onlineCount + 1 end
        end

        return onlineCount
    end

    return 0
end

local function AddTooltipLines()
    GameTooltip:AddLine('Guild Members Online', 1, 1, 1)

    if not IsInGuild() then
        GameTooltip:AddLine('Not in a guild', 0.8, 0.8, 0.8)
        return
    end

    -- Modern Retail API
    if C_GuildInfo and C_GuildInfo.GetNumMembers and C_GuildInfo.GetMemberInfoByIndex then
        local total = C_GuildInfo.GetNumMembers()
        if not total or total == 0 then
            GameTooltip:AddLine('Loading...', 0.8, 0.8, 0.8)
            return
        end

        for i = 1, total do
            local info = C_GuildInfo.GetMemberInfoByIndex(i)
            if info and info.isOnline then
                local shortName = info.name and info.name:match('^[^%-]+') or 'Unknown'
                local classToken
                if info.classID then classToken = select(2, GetClassInfo(info.classID)) end

                local r, g, b = ADT:GetClassColor(classToken or info.class)
                GameTooltip:AddDoubleLine(shortName, info.zone or 'Unknown', r, g, b, 0.8, 0.8, 0.8)
            end
        end

        return
    end

    -- Legacy Fallback
    if GetNumGuildMembers and GetGuildRosterInfo then
        local total = GetNumGuildMembers() or 0

        for i = 1, total do
            local name, _, _, _, _, zone, _, _, online, _, class = GetGuildRosterInfo(i)
            if online then
                local shortName = name and name:match('^[^%-]+') or 'Unknown'
                local r, g, b = ADT:GetClassColor(class)
                GameTooltip:AddDoubleLine(shortName, zone or 'Unknown', r, g, b, 0.8, 0.8, 0.8)
            end
        end
    end
end

local function Update(forceUpdate)
    if not IsInGuild() then
        guildRosterReady = false
        ADT:ApplyFrameSettings(FRAME_NAME, ADT.Frames[FRAME_NAME], 0, forceUpdate)
        return
    end

    if not guildRosterReady and C_GuildInfo and C_GuildInfo.RequestGuildRoster then
        C_GuildInfo.RequestGuildRoster()
        ADT:ApplyFrameSettings(FRAME_NAME, ADT.Frames[FRAME_NAME], '...', forceUpdate)
        return
    end

    local value = GetGuildOnlineCount()
    ADT:ApplyFrameSettings(FRAME_NAME, ADT.Frames[FRAME_NAME], value, forceUpdate)
end

ADT:RegisterDataText(FRAME_NAME, {
    Update = Update,
    events = {
        'PLAYER_ENTERING_WORLD',
        'GUILD_ROSTER_UPDATE',
        'PLAYER_GUILD_UPDATE',
    },
    onEvent = function(_, event)
        if event == 'GUILD_ROSTER_UPDATE' then
            guildRosterReady = true
        elseif event == 'PLAYER_GUILD_UPDATE' then
            guildRosterReady = false
            if C_GuildInfo and C_GuildInfo.RequestGuildRoster then C_GuildInfo.RequestGuildRoster() end
        end

        Update(true)
    end,
    onEnter = function()
        Update()
        AddTooltipLines()
    end,
    onClick = ToggleGuildFrame,
    defaultEnabled = true,
    defaultAnchor = 'Minimap',
    defaultPoint = ADT.Enums.Points.BOTTOM,
    defaultRelativePoint = ADT.Enums.Points.BOTTOM,
    defaultX = -60,
    defaultY = 4,
    defaultAlign = ADT.Enums.Align.LEFT,
    defaultStrata = ADT.Enums.Strata.MEDIUM
})