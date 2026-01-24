local ADT = LibStub('AceAddon-3.0'):GetAddon('ADT')

local TOOLTIP_TITLE_GUILD = 'Guild Members Online'

local function AddTooltipLinesForGuild()
    GameTooltip:AddLine(TOOLTIP_TITLE_GUILD, 1, 1, 1)
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

ADT:RegisterDataText('Guild', {
    onUpdate = GetGuildOnlineCount,
    onEnter = AddTooltipLinesForGuild,
    onClick = function() ToggleGuildFrame() end,
    defaultEnabled = true,
    defaultAnchor = 'Minimap',
    defaultPoint = ADT_Enums.Points.BOTTOM,
    defaultRelativePoint = ADT_Enums.Points.BOTTOM,
    defaultX = -60,
    defaultY = 4,
    defaultAlign = ADT_Enums.Align.LEFT,
    defaultStrata = ADT_Enums.Strata.MEDIUM
})
