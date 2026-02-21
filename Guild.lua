local _, ADT = ...

local GameTooltip = GameTooltip
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildRosterInfo = GetGuildRosterInfo
local IsInGuild = IsInGuild
local ToggleGuildFrame = ToggleGuildFrame

local function GetGuildOnlineCount()
    local count = 0
    if IsInGuild and IsInGuild() then
        local numTotal = GetNumGuildMembers and GetNumGuildMembers() or 0
        for i = 1, numTotal do
            local _, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
            if online then count = count + 1 end
        end
    end
    return count
end

local function AddTooltipLines()
    GameTooltip:AddLine('Guild Members Online', 1, 1, 1)
    local numTotal = GetNumGuildMembers and GetNumGuildMembers() or 0
    for i = 1, numTotal do
        local name, _, _, _, _, zone, _, _, online, _, class = GetGuildRosterInfo(i)
        if online then
            local shortName = name and name:match("^[^%-]+") or 'Unknown'
            local r, g, b = ADT:GetClassColor(class)
            GameTooltip:AddDoubleLine(shortName, zone or 'Unknown', r, g, b, 0.8, 0.8, 0.8)
        end
    end
end

ADT:RegisterDataText('Guild', {
    onUpdate = GetGuildOnlineCount,
    events = {
        'GUILD_ROSTER_UPDATE',
        'PLAYER_GUILD_UPDATE',
    },
    onEnter = AddTooltipLines,
    onClick = function() ToggleGuildFrame() end,
    defaultEnabled = true,
    defaultAnchor = 'Minimap',
    defaultPoint = ADT.Enums.Points.BOTTOM,
    defaultRelativePoint = ADT.Enums.Points.BOTTOM,
    defaultX = -60,
    defaultY = 4,
    defaultAlign = ADT.Enums.Align.LEFT,
    defaultStrata = ADT.Enums.Strata.MEDIUM
})
