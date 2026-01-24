local ADT = LibStub('AceAddon-3.0'):GetAddon('ADT')

local TOOLTIP_TITLE_FRIENDS = 'Friends Online'

local function AddTooltipLinesForFriends()
    GameTooltip:AddLine(TOOLTIP_TITLE_FRIENDS, 1, 1, 1)
    for i = 1, C_FriendList.GetNumFriends() do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.connected then
            local r, g, b = ADT:GetClassColor(info.className)
            GameTooltip:AddDoubleLine(info.name or 'Unknown', info.area or 'Unknown', r, g, b, 0.8, 0.8, 0.8)
        end
    end
end

local function AddBattleNetFriendTooltipLines()
    for i = 1, BNGetNumFriends() do
        local friendInfo = C_BattleNet.GetFriendAccountInfo(i)
        local game = friendInfo and friendInfo.gameAccountInfo
        if game and game.isOnline and game.clientProgram == "WoW" then
            local charName = game.characterName or friendInfo.accountName or 'Unknown'
            local r, g, b = ADT:GetClassColor(game.className)
            GameTooltip:AddDoubleLine(charName, game.areaName or 'Unknown', r, g, b, 0.8, 0.8, 0.8)
        end
    end
end

local function GetFriendsOnlineCount()
    local count = 0
    for i = 1, C_FriendList.GetNumFriends() do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.connected then count = count + 1 end
    end

    for i = BNGetNumFriends(), 1, -1 do
        local info = C_BattleNet.GetFriendAccountInfo(i)
        if info and info.gameAccountInfo and info.gameAccountInfo.isOnline and info.gameAccountInfo.clientProgram == "WoW" then
            count = count + 1
        end
    end
    return count
end

ADT:RegisterDataText('Friends', {
    onUpdate = GetFriendsOnlineCount,
    onEnter = function()
        AddTooltipLinesForFriends()
        AddBattleNetFriendTooltipLines()
    end,
    onClick = function() ToggleFriendsFrame() end,
    defaultEnabled = true,
    defaultAnchor = 'Minimap',
    defaultPoint = ADT_Enums.Points.BOTTOM,
    defaultRelativePoint = ADT_Enums.Points.BOTTOM,
    defaultX = 60,
    defaultY = 4,
    defaultAlign = ADT_Enums.Align.RIGHT,
    defaultStrata = ADT_Enums.Strata.MEDIUM
})
