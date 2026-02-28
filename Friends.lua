local _, ADT = ...

local GameTooltip = GameTooltip
local C_FriendList = C_FriendList
local BNGetNumFriends = BNGetNumFriends
local ToggleFriendsFrame = ToggleFriendsFrame
local C_BattleNet = C_BattleNet

local FRAME_NAME = 'Friends'
local GetFriendAccountInfo = C_BattleNet and (C_BattleNet.GetFriendAccountInfo or C_BattleNet.GetFriendAccountInfoByIndex)

local function GetFriendsOnlineCount()
    local count = C_FriendList and C_FriendList.GetNumOnlineFriends and C_FriendList.GetNumOnlineFriends() or 0

    local numBNFriends, numOnline = 0, 0
    if BNGetNumFriends then
        numBNFriends, numOnline = BNGetNumFriends()
    end

    if numBNFriends > 0 and numOnline > 0 then
        for i = 1, numBNFriends do
            local info = GetFriendAccountInfo and GetFriendAccountInfo(i)
            if info and info.gameAccountInfo and info.gameAccountInfo.isOnline and info.gameAccountInfo.clientProgram == 'WoW' then
                count = count + 1
            end
        end
    end
    return count
end

local function AddTooltipLines()
    GameTooltip:AddLine('Friends Online', 1, 1, 1)
    local numFriends = C_FriendList and C_FriendList.GetNumFriends and C_FriendList.GetNumFriends() or 0
    for i = 1, numFriends do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.connected then
            local r, g, b = ADT:GetClassColor(info.className)
            GameTooltip:AddDoubleLine(info.name or 'Unknown', info.area or 'Unknown', r, g, b, 0.8, 0.8, 0.8)
        end
    end
end

local function AddBattleNetFriendTooltipLines()
    local numBNFriends, numOnline = 0, 0
    if BNGetNumFriends then
        numBNFriends, numOnline = BNGetNumFriends()
    end

    if numBNFriends > 0 and numOnline > 0 then
        for i = 1, numBNFriends do
            local friendInfo = GetFriendAccountInfo and GetFriendAccountInfo(i)
            local game = friendInfo and friendInfo.gameAccountInfo
            if game and game.isOnline and game.clientProgram == 'WoW' then
                local charName = game.characterName or friendInfo.accountName or 'Unknown'
                local r, g, b = ADT:GetClassColor(game.className)
                GameTooltip:AddDoubleLine(charName, game.areaName or 'Unknown', r, g, b, 0.8, 0.8, 0.8)
            end
        end
    end
end

local function Update(forceUpdate)
    local value = GetFriendsOnlineCount()
    if forceUpdate then
        ADT:UpdateFrameSettings(FRAME_NAME)
    else
        ADT:UpdateDataTextValue(FRAME_NAME, value)
    end
end

ADT:RegisterDataText(FRAME_NAME, {
    throttle = 3,
    Update = Update,
    events = {
        'PLAYER_ENTERING_WORLD',
        'FRIENDLIST_UPDATE',
        'BN_FRIEND_INFO_CHANGED',
    },
    onEnter = function()
        ADT:UpdateDataText(FRAME_NAME, true)
        AddTooltipLines()
        AddBattleNetFriendTooltipLines()
    end,
    onClick = function() ToggleFriendsFrame() end,
    defaultEnabled = true,
    defaultAnchor = 'Minimap',
    defaultPoint = ADT.Enums.Points.BOTTOM,
    defaultRelativePoint = ADT.Enums.Points.BOTTOM,
    defaultX = 60,
    defaultY = 4,
    defaultAlign = ADT.Enums.Align.RIGHT,
    defaultStrata = ADT.Enums.Strata.MEDIUM
})