local ADT = LibStub('AceAddon-3.0'):GetAddon('ADT')

local function GetDurabilityColor(percent)
    if percent > 50 then
        return 0, 1, 0
    elseif percent > 20 then
        return 1, 1, 0
    else
        return 1, 0, 0
    end
end

local function GetDurability()
    local minDurability = 100
    local hasItem = false
    
    for i = 1, 18 do
        local durability, maxDurability = GetInventoryItemDurability(i)
        if durability and maxDurability then
            local percent = (durability / maxDurability) * 100
            if percent < minDurability then
                minDurability = percent
            end
            hasItem = true
        end
    end
    
    return hasItem and minDurability or 100
end

local function AddTooltipLinesForDurability()
    GameTooltip:AddLine("Durability", 1, 1, 1)
    GameTooltip:AddLine(" ")
    
    local slots = {
        [1] = "Head",
        [3] = "Shoulder",
        [5] = "Chest",
        [6] = "Waist",
        [7] = "Legs",
        [8] = "Feet",
        [9] = "Wrist",
        [10] = "Hands",
        [16] = "Main Hand",
        [17] = "Off Hand",
        [18] = "Ranged"
    }
    
    for slotID, slotName in pairs(slots) do
        local durability, maxDurability = GetInventoryItemDurability(slotID)
        if durability and maxDurability then
            local percent = (durability / maxDurability) * 100
            local r, g, b = GetDurabilityColor(percent)
            GameTooltip:AddDoubleLine(slotName, string.format("%.0f%%", percent), 1, 1, 1, r, g, b)
        end
    end
end

ADT:RegisterDataText('Durability', {
    onUpdate = function()
        local percent = GetDurability()
        return string.format("%.0f%%", percent)
    end,
    onEnter = AddTooltipLinesForDurability,
    onClick = function() ToggleCharacter("PaperDollFrame") end,
    defaultEnabled = true,
    defaultAnchor = 'Minimap',
    defaultPoint = ADT_Enums.Points.TOP,
    defaultRelativePoint = ADT_Enums.Points.BOTTOM,
    defaultX = 0,
    defaultY = -4,
    defaultAlign = ADT_Enums.Align.CENTER,
    defaultStrata = ADT_Enums.Strata.MEDIUM
})
