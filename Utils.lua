local _, ADT = ...
local LSM = LibStub('LibSharedMedia-3.0')

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitClass = UnitClass
local string_format = string.format

local classColorCache = {}
local classHexCache = {}
local metricCache = {}

function ADT:ClearColorCache()
    classColorCache = {}
    classHexCache = {}
    metricCache = {}
end

function ADT:GetClassColor(class)
    if not class then return 1, 1, 1 end
    class = class:gsub('%s+', ''):upper()
    
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
    if not class then return 'ffffffff' end
    class = class:gsub('%s+', ''):upper()

    if classHexCache[class] then
        return classHexCache[class]
    end

    local r, g, b = self:GetClassColor(class)
    local hex = string_format('ff%02x%02x%02x', (r or 1) * 255, (g or 1) * 255, (b or 1) * 255)
    classHexCache[class] = hex
    return hex
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
        return string_format('ff%02x%02x%02x', (customColor.r or 1) * 255, (customColor.g or 1) * 255, (customColor.b or 1) * 255)
    end
end

function ADT:GetDatabaseValue(name, key, default)
    if not self.db then return default end
    local db = self.db.global.DataTexts or {}
    local fullKey = name:lower() .. key
    if db[fullKey] ~= nil then
        return db[fullKey]
    end
    return default
end

function ADT:ApplyFrameSettings(name, frame, value, forceUpdate)
    if not self.db or not frame then return end
    local db = self.db.global.DataTexts or {}
    local key = name:lower()

    if not db[key .. 'Enabled'] then
        frame:Hide()
        return
    end

    frame:Show()
    if not (frame.lastValue == value and not forceUpdate) then
        frame.lastValue = value

        local anchorName = db[key .. 'Anchor']
        local anchor = _G[anchorName]

        if not anchor and anchorName ~= 'UIParent' then
            anchor = UIParent
            if not self.retryTimerActive then
                self.retryTimerActive = true
                C_Timer.After(2, function()
                    self.retryTimerActive = false
                    local data = self.RegisteredDataTexts[name]
                    if data and data.Update then
                        data.Update(true)
                    end
                end)
            end
        end

        anchor = anchor or UIParent
        if frame:GetParent() ~= anchor then
            frame:SetParent(anchor)
            frame:ClearAllPoints()
        end

        local size = db[key .. 'OverrideText'] and db[key .. 'TextSize'] or db.textSize or 12
        local fontName = db[key .. 'OverrideText'] and db[key .. 'Font'] or db.font or 'Friz Quadrata TT'
        local font = LSM:Fetch('font', fontName) or [[Fonts\FRIZQT__.TTF]]

        local outline = db[key .. 'OverrideText'] and db[key .. 'Outline'] or db.outline or 'NONE'
        local shadow = db[key .. 'OverrideText'] and db[key .. 'Shadow'] or db.shadow
        local shadowOffset = shadow and 1 or 0

        local currentFont, currentSize, currentOutline = frame.text:GetFont()
        if currentFont ~= font or currentSize ~= size or currentOutline ~= outline then
            local successSetFont, setFontErr = pcall(function() frame.text:SetFont(font, size, outline) end)
            if not successSetFont then
                frame.text:SetFont([[Fonts\FRIZQT__.TTF]], size, outline)
            end
        end

        local align = db[key .. 'Align'] or 'CENTER'
        if frame.text:GetJustifyH() ~= align then
            frame.text:SetJustifyH(align)
        end

        local currentShadowX, currentShadowY = frame.text:GetShadowOffset()
        if currentShadowX ~= shadowOffset or currentShadowY ~= -shadowOffset then
            frame.text:SetShadowOffset(shadowOffset, -shadowOffset)
        end

        -- Apply Text logic
        local valHex = self:GetColorHexOrDefault(true, frame.name)
        local lblHex = self:GetColorHexOrDefault(false, frame.name)
        local text = string_format('|c%s%s|r |c%s%s|r', valHex, tostring(value or 0), lblHex, name)

        frame.text:SetText(text)

        local width, height = self:GetTextMetrics(text, font, size, outline)
        if width == 0 then
            width = 50
            C_Timer.After(1, function()
                local data = self.RegisteredDataTexts[name]
                if data and data.Update then
                    data.Update(true)
                end
            end)
        end
        if height == 0 then height = size or 12 end
        frame:SetSize(width + 8, height + 4)

        local point = db[key .. 'Point'] or 'CENTER'
        local relPoint = db[key .. 'RelativePoint'] or 'CENTER'
        local x = db[key .. 'X'] or 0
        local y = db[key .. 'Y'] or 0

        frame:ClearAllPoints()
        frame:SetPoint(point, anchor, relPoint, x, y)

        local strata = db[key .. 'Strata'] or 'MEDIUM'
        if frame:GetFrameStrata() ~= strata then
            frame:SetFrameStrata(strata)
        end

        if frame:GetFrameLevel() ~= 10 then
            frame:SetFrameLevel(10)
        end

        frame.text:SetAlpha(1)
        frame:SetAlpha(1)
    end
end

function ADT:GetTextMetrics(text, font, size, outline)
    if not text then return 0, 0 end
    local cacheKey = string_format('%s:%s:%s:%s', text, tostring(font), tostring(size), tostring(outline))
    
    -- If width is 0 in cache, we should try to recalculate it
    if metricCache[cacheKey] and metricCache[cacheKey].width > 0 then
        return metricCache[cacheKey].width, metricCache[cacheKey].height
    end

    if not self.measureFrame then
        self.measureFrame = CreateFrame('Frame', 'Asa_DataTextsMeasureFrame', UIParent)
        self.measureFontString = self.measureFrame:CreateFontString(nil, 'ARTWORK')
        self.measureFrame:Hide()
    end

    self.measureFontString:SetFont(font or [[Fonts\FRIZQT__.TTF]], size or 12, outline or 'NONE')
    self.measureFontString:SetText(text)
    
    local width = self.measureFontString:GetStringWidth()
    local height = self.measureFontString:GetStringHeight()
    
    if width > 0 then
        metricCache[cacheKey] = { width = width, height = height }
    end
    
    return width, height
end
