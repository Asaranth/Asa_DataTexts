local _, ADT = ...

local ipairs, string_format = ipairs, string.format

local GetInventoryItemDurability = GetInventoryItemDurability
local GameTooltip = GameTooltip
local ToggleCharacter = ToggleCharacter

local FRAME_NAME = 'Durability'

local function AddTooltipLines()
    GameTooltip:AddLine('Durability', 1, 1, 1)
    GameTooltip:AddLine(' ')
    
    local slots = {
        [1] = 'Head',
        [3] = 'Shoulder',
        [5] = 'Chest',
        [6] = 'Waist',
        [7] = 'Legs',
        [8] = 'Feet',
        [9] = 'Wrist',
        [10] = 'Hands',
        [16] = 'Main Hand',
        [17] = 'Off Hand',
        [18] = 'Ranged'
    }

    local sortedSlots = {1, 3, 5, 9, 10, 6, 7, 8, 16, 17, 18}
    
    for _, slotID in ipairs(sortedSlots) do
        local slotName = slots[slotID]
        local durability, maxDurability = GetInventoryItemDurability(slotID)
        if durability and maxDurability then
            local percent = (durability / maxDurability) * 100
            local color = ADT.DURABILITY_THRESHOLDS[#ADT.DURABILITY_THRESHOLDS].color
            for i = 1, #ADT.DURABILITY_THRESHOLDS do
                if (percent / 100) <= ADT.DURABILITY_THRESHOLDS[i].threshold then
                    color = ADT.DURABILITY_THRESHOLDS[i].color
                    break
                end
            end
            GameTooltip:AddDoubleLine(slotName, string_format('%.0f%%', percent), 1, 1, 1, color.r, color.g, color.b)
        end
    end
end

local function GetDurability()
    local minDurability = 100
    local hasItem = false
    
    for i = 1, 18 do
        local durability, maxDurability = GetInventoryItemDurability(i)
        if durability and maxDurability then
            local percent = (durability / maxDurability) * 100
            if percent < minDurability then minDurability = percent end
            hasItem = true
        end
    end
    
    local val = hasItem and minDurability or 100
    return string_format('%.0f%%', val)
end

local function Update(forceUpdate)
    local value = GetDurability()
    ADT:ApplyFrameSettings(FRAME_NAME, ADT.Frames[FRAME_NAME], value, forceUpdate)
end

ADT:RegisterDataText(FRAME_NAME, {
    Update = Update,
    events = {
        'PLAYER_ENTERING_WORLD',
        'UPDATE_INVENTORY_DURABILITY'
    },
    onEnter = function()
        Update()
        AddTooltipLines()
    end,
    onClick = function() ToggleCharacter('PaperDollFrame') end,
    defaultEnabled = true,
    defaultAnchor = 'Minimap',
    defaultPoint = ADT.Enums.Points.TOP,
    defaultRelativePoint = ADT.Enums.Points.BOTTOM,
    defaultX = 0,
    defaultY = -4,
    defaultAlign = ADT.Enums.Align.CENTER,
    defaultStrata = ADT.Enums.Strata.MEDIUM
})
