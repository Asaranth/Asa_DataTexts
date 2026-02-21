local _, ADT = ...

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitClass = UnitClass
local string_format = string.format

local classColorCache = {}
local classHexCache = {}
local widthCache = {}

function ADT:ClearColorCache()
    classColorCache = {}
    classHexCache = {}
    widthCache = {}
end

function ADT:GetClassColor(class)
    if not class then return 1, 1, 1 end
    class = class:gsub("%s+", ""):upper()
    
    if classColorCache[class] then
        local c = classColorCache[class]
        return c.r, c.g, c.b
    end

    local c = RAID_CLASS_COLORS[class]
    if not c then return 1, 1, 1 end
    
    classColorCache[class] = { r = c.r, g = c.g, b = c.b }
    return c.r, c.g, c.b
end

function ADT:GetClassColorHex(class)
    if not class then return "ffffffff" end
    class = class:gsub("%s+", ""):upper()

    if classHexCache[class] then
        return classHexCache[class]
    end

    local r, g, b = self:GetClassColor(class)
    local hex = string_format("ff%02x%02x%02x", (r or 1) * 255, (g or 1) * 255, (b or 1) * 255)
    classHexCache[class] = hex
    return hex
end

local widthCache = {}

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

function ADT:GetColorHexOrDefault(isValue, name)
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
        return self:GetClassColorHex(class)
    else
        customColor = customColor or { r = 1, g = 1, b = 1 }
        return string_format("ff%02x%02x%02x", (customColor.r or 1) * 255, (customColor.g or 1) * 255, (customColor.b or 1) * 255)
    end
end
