local ADT = LibStub('AceAddon-3.0'):GetAddon('ADT', true) or LibStub('AceAddon-3.0'):NewAddon('ADT', 'AceEvent-3.0', 'AceConsole-3.0')

function ADT:GetClassColor(class)
    if not class then return 1, 1, 1 end
    class = class:gsub("%s+", ""):upper()
    local c = RAID_CLASS_COLORS[class]
    if not c then return 1, 1, 1 end
    return c.r, c.g, c.b
end

function ADT:CalculateTextWidthForFont(text, size)
    return string.len(text) * size * 0.6
end

function ADT:GetClassColorOrDefault(isValue, name)
    local db = self.db.global.DataTexts or {}
    local _, class = UnitClass('player')
    local key = name:lower()
    local colorOverride, customColor
    
    if db[key .. 'OverrideColors'] then
        if isValue then
            colorOverride = db[key .. 'ValueColorOverride']
            customColor = db[key .. 'ValueColor']
        else
            colorOverride = db[key .. 'LabelColorOverride']
            customColor = db[key .. 'LabelColor']
        end
    else
        if isValue then
            colorOverride = db.valueColorOverride
            customColor = db.valueColor
        else
            colorOverride = db.labelColorOverride
            customColor = db.labelColor
        end
    end

    if colorOverride then
        return self:GetClassColor(class)
    else
        customColor = customColor or { r = 1, g = 1, b = 1 }
        return customColor.r or 1, customColor.g or 1, customColor.b or 1
    end
end
