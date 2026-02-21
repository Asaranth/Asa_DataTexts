local addonName, ADT = ...
-- Register ADT as the AceAddon object directly
LibStub('AceAddon-3.0'):NewAddon(ADT, 'ADT', 'AceEvent-3.0', 'AceConsole-3.0')
-- Point the local ADT to the same table used by other files
local LSM = LibStub('LibSharedMedia-3.0')

local pairs, ipairs, tostring, string_format, pcall = pairs, ipairs, tostring, string.format, pcall

local CreateFrame = CreateFrame
local UIParent = UIParent
local GameTooltip = GameTooltip
local C_Timer = C_Timer
local C_FriendList = C_FriendList
local C_GuildInfo = C_GuildInfo
local GetMouseFoci = GetMouseFoci
local _G = _G

ADT.RegisteredDataTexts = {}
ADT.Frames = {}

local DEFAULT_FONT = 'Friz Quadrata TT'
local DEFAULT_ALIGN = ADT.Enums.Align.CENTER
local DEFAULT_TEXT_SIZE = 12
local DEFAULT_OUTLINE = ADT.Enums.Outline.NONE
local DEFAULT_SHADOW = true

function ADT:RegisterDataText(name, data)
    self.RegisteredDataTexts[name] = data
    if data.events then
        for _, event in ipairs(data.events) do
            self:RegisterEvent(event, 'OnEvent')
        end
    end
end

function ADT:OnEvent(event, ...)
    -- self:Print("OnEvent: " .. tostring(event)) -- Debug
    if not self.db then return end
    for name, data in pairs(self.RegisteredDataTexts) do
        if data.events then
            for _, e in ipairs(data.events) do
                if e == event then
                    if data.onEvent then
                        data.onEvent(event, ...)
                    end
                    self:UpdateTexts(name)
                    break
                end
            end
        end
    end
end

function ADT:OnInitialize()
    -- self:Print("OnInitialize started") -- Debug
    local E = ADT.Enums
    local defaults = {
        global = {
            DataTexts = {
                textSize = DEFAULT_TEXT_SIZE,
                font = DEFAULT_FONT,
                outline = DEFAULT_OUTLINE,
                shadow = DEFAULT_SHADOW,
                valueColor = { r = 1, g = 1, b = 1 },
                labelColor = { r = 1, g = 1, b = 1 },
                valueColorOverride = false,
                labelColorOverride = false,
            }
        },
    }

    for name, data in pairs(self.RegisteredDataTexts) do
        local key = name:lower()
        defaults.global.DataTexts[key .. 'Enabled'] = data.defaultEnabled ~= false
        defaults.global.DataTexts[key .. 'Anchor'] = data.defaultAnchor or 'Minimap'
        defaults.global.DataTexts[key .. 'Point'] = data.defaultPoint or E.Points.CENTER
        defaults.global.DataTexts[key .. 'RelativePoint'] = data.defaultRelativePoint or E.Points.CENTER
        defaults.global.DataTexts[key .. 'X'] = data.defaultX or 0
        defaults.global.DataTexts[key .. 'Y'] = data.defaultY or 0
        defaults.global.DataTexts[key .. 'Align'] = data.defaultAlign or DEFAULT_ALIGN
        defaults.global.DataTexts[key .. 'Strata'] = data.defaultStrata or E.Strata.MEDIUM

        defaults.global.DataTexts[key .. 'OverrideText'] = false
        defaults.global.DataTexts[key .. 'Font'] = DEFAULT_FONT
        defaults.global.DataTexts[key .. 'TextSize'] = DEFAULT_TEXT_SIZE
        defaults.global.DataTexts[key .. 'Outline'] = DEFAULT_OUTLINE
        defaults.global.DataTexts[key .. 'Shadow'] = DEFAULT_SHADOW
        defaults.global.DataTexts[key .. 'OverrideColors'] = false
        defaults.global.DataTexts[key .. 'ValueColor'] = { r = 1, g = 1, b = 1 }
        defaults.global.DataTexts[key .. 'LabelColor'] = { r = 1, g = 1, b = 1 }
        defaults.global.DataTexts[key .. 'ValueColorOverride'] = false
        defaults.global.DataTexts[key .. 'LabelColorOverride'] = false
    end

    self.db = LibStub('AceDB-3.0'):New('ADT_DB', defaults, true)
    -- self:Print("self.db initialized") -- Debug

    local options = self:GetSettings()

    -- Register the main Asa Suite category if it doesn't exist
    if not LibStub("AceConfigRegistry-3.0"):GetOptionsTable("|cFF047857Asa|r Suite") then
        LibStub("AceConfig-3.0"):RegisterOptionsTable("|cFF047857Asa|r Suite", {
            name = "|cFF047857Asa|r Suite",
            type = "group",
            args = {
                info = {
                    type = "description",
                    name = "Welcome to |cFF047857Asa|r Suite. Select a module from the menu on the left to configure its settings.",
                    order = 1,
                },
            },
        })
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions("|cFF047857Asa|r Suite", "|cFF047857Asa|r Suite")
    end

    -- Register module's options as a sub-category
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Data Texts", options)
    self.optionsFrame, self.categoryID = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Data Texts", "Data Texts", "|cFF047857Asa|r Suite")

    if not self.categoryID and self.optionsFrame and self.optionsFrame.parent then
        self.categoryID = self.optionsFrame.parent
    end

    for name, _ in pairs(self.RegisteredDataTexts) do
        self.Frames[name] = self:CreateDataTextFrame(name)
        -- self:Print("Created frame for " .. name) -- Debug
    end

    self:RegisterEvent('PLAYER_ENTERING_WORLD', function() self:UpdateTexts() end)

    -- Initial update and data requests
    C_Timer.After(1, function()
        if C_FriendList and C_FriendList.ShowFriends then C_FriendList.ShowFriends() end
        if C_GuildInfo and C_GuildInfo.GuildRoster then C_GuildInfo.GuildRoster() end
        
        self:UpdateTexts()
    end)

    self:RegisterChatCommand('adt', 'ChatCommand')

    LSM.RegisterCallback(self, 'LibSharedMedia_Registered', 'UpdateTexts')
    LSM.RegisterCallback(self, 'LibSharedMedia_SetGlobal', 'UpdateTexts')
end

function ADT:ToggleFrameStack(name)
    if not FrameStackTooltip_Toggle then
        UIParentLoadAddOn("Blizzard_DebugTools")
    end

    if FrameStackTooltip_Toggle then
        FrameStackTooltip_Toggle()
    else
        ExecuteChatCommand("fstack")
    end

    if name then
        if not self.selectionFrame then
            self.selectionFrame = CreateFrame("Frame", "Asa_DataTextsSelectionFrame", UIParent)
            self.selectionFrame:SetAllPoints(UIParent)
            self.selectionFrame:SetFrameStrata("TOOLTIP")
            self.selectionFrame:EnableMouse(true)
            self.selectionFrame:SetScript("OnMouseDown", function(_, button)
                if button == "LeftButton" then
                    self.selectionFrame:Hide()
                    C_Timer.After(0.01, function()
                        local foci = GetMouseFoci()
                        local focus = foci and foci[1]
                        if focus then
                            local focusName = focus:GetName()
                            if focusName then
                                local key = self.selectingModule:lower()
                                self.db.global.DataTexts[key .. "Anchor"] = focusName
                                self:Print(string_format("Anchored %s to %s", self.selectingModule, focusName))
                                self:UpdateTexts()
                                self:ToggleFrameStack()
                                LibStub('AceConfigRegistry-3.0'):NotifyChange('Data Texts')
                            else
                                self:Print("Selected frame has no name. Please try another.")
                                self.selectionFrame:Show()
                            end
                        else
                            self:Print("No frame found under mouse. Please try again.")
                            self.selectionFrame:Show()
                        end
                    end)
                elseif button == "RightButton" then
                    self:ToggleFrameStack()
                end
            end)
        end

        self.selectingModule = name
        self.selectionFrame:Show()
        self:Print(string_format("Select a frame to anchor %s to (Left Click to select, Right Click to cancel).", name))
    else
        if self.selectionFrame then
            self.selectionFrame:Hide()
        end
    end
end

function ADT:ChatCommand(input)
    if not input or input:trim() == "" then
        if Settings and Settings.OpenToCategory then
            if self.categoryID then
                Settings.OpenToCategory(self.categoryID)
            else
                Settings.OpenToCategory("|cFF047857Asa|r Suite")
            end
        elseif InterfaceOptionsFrame_OpenToCategory then
            InterfaceOptionsFrame_OpenToCategory("|cFF047857Asa|r Suite")
        end
    else
        LibStub('AceConfigCmd-3.0'):HandleCommand(self, 'adt', 'Data Texts', input)
    end
end

function ADT:CreateDataTextFrame(name)
    local data = self.RegisteredDataTexts[name]
    if not data then return end

    local frame = CreateFrame('Frame', 'Asa_DataText_' .. name, UIParent)
    frame.text = frame:CreateFontString(nil, 'OVERLAY')
    frame.text:SetWordWrap(false)
    frame.text:SetNonSpaceWrap(false)
    frame.name = name
    frame:EnableMouse(true)
    frame:SetMouseClickEnabled(true)
    frame:SetFrameStrata(ADT.Enums.Strata.MEDIUM)

    frame:SetScript('OnEnter', function(self_frame)
        if data.onEnter then
            GameTooltip:SetOwner(self_frame, 'ANCHOR_BOTTOM')
            GameTooltip:ClearLines()
            data.onEnter(self_frame)
            GameTooltip:Show()
        end
    end)

    frame:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)

    frame:SetScript('OnMouseUp', function(self_frame, button)
        if data.onClick then
            data.onClick(self_frame, button)
        end
    end)

    frame.text:SetAllPoints(frame)
    frame.text:SetAlpha(1)
    frame:Show()
    return frame
end

function ADT:UpdateTexts(targetName, forceUpdate)
    if not self.db then 
        -- self:Print("UpdateTexts skipped: self.db is nil") -- Debug
        return 
    end
    -- If triggered by a talent/trait event, wait a moment for the game state to update
    if targetName == 'Talents' and not self.talentUpdateInProgress then
        if not self.talentUpdatePending then
            self.talentUpdatePending = true
            C_Timer.After(0.5, function()
                self.talentUpdatePending = false
                self.talentUpdateInProgress = true
                self:UpdateTexts('Talents', true)
                self.talentUpdateInProgress = false
            end)
        end
        return
    end

    local db = self.db.global.DataTexts or {}

    for name, data in pairs(self.RegisteredDataTexts) do
        if not targetName or targetName == name then
            local frame = self.Frames[name]
            local key = name:lower()

            if frame then
                if db[key .. 'Enabled'] then
                    frame:Show()
                    local value = ""
                    local success, err = pcall(function() value = data.onUpdate and data.onUpdate() or "" end)
                    if not success then
                        value = "Error"
                        self:Print("Error updating " .. name .. ": " .. tostring(err))
                    end

                    if not (frame.lastValue == value and not forceUpdate) then
                        frame.lastValue = value

                        local anchorName = db[key .. 'Anchor']
                        local anchor = _G[anchorName]

                        if not anchor and anchorName ~= "UIParent" then
                            -- If anchor doesn't exist, fallback to UIParent and try again in 5 seconds
                            anchor = UIParent
                            if not self.retryTimerActive then
                                self.retryTimerActive = true
                                C_Timer.After(5, function()
                                    self.retryTimerActive = false
                                    self:UpdateTexts(name)
                                end)
                            end
                        end

                        anchor = anchor or UIParent
                        if frame:GetParent() ~= anchor then
                            frame:SetParent(anchor)
                            frame:ClearAllPoints()
                        end

                        local size = db[key .. 'OverrideText'] and db[key .. 'TextSize'] or db.textSize or DEFAULT_TEXT_SIZE
                        local fontName = db[key .. 'OverrideText'] and db[key .. 'Font'] or db.font or DEFAULT_FONT
                        local font = LSM:Fetch('font', fontName)

                        if not font then
                            font = [[Fonts\FRIZQT__.TTF]]
                        end

                        local outline = db[key .. 'OverrideText'] and db[key .. 'Outline'] or db.outline or DEFAULT_OUTLINE
                        local shadow = db[key .. 'OverrideText'] and db[key .. 'Shadow'] or db.shadow
                        local shadowOffset = shadow and 1 or 0

                        local currentFont, currentSize, currentOutline = frame.text:GetFont()
                        if currentFont ~= font or currentSize ~= size or currentOutline ~= outline then
                            local successSetFont, setFontErr = pcall(function() frame.text:SetFont(font, size, outline) end)
                            if not successSetFont then
                                self:Print(string.format("Error setting font %s for %s: %s", tostring(font), name, tostring(setFontErr)))
                                frame.text:SetFont([[Fonts\FRIZQT__.TTF]], size, outline)
                            end
                        end
                        
                        local align = db[key .. 'Align'] or DEFAULT_ALIGN
                        if frame.text:GetJustifyH() ~= align then
                            frame.text:SetJustifyH(align)
                        end
                        
                        local currentShadowX, currentShadowY = frame.text:GetShadowOffset()
                        if currentShadowX ~= shadowOffset or currentShadowY ~= -shadowOffset then
                            frame.text:SetShadowOffset(shadowOffset, -shadowOffset)
                        end
                        
                        self:ApplyText(frame, name, value, font, size, outline)

                        local point = db[key .. 'Point'] or DEFAULT_ALIGN
                        local relPoint = db[key .. 'RelativePoint'] or DEFAULT_ALIGN
                        local x = db[key .. 'X'] or 0
                        local y = db[key .. 'Y'] or 0
                        
                        -- Always re-anchor to avoid drift when size changes
                        frame:ClearAllPoints()
                        frame:SetPoint(point, anchor, relPoint, x, y)
                        
                        local strata = db[key .. 'Strata'] or ADT.Enums.Strata.MEDIUM
                        if frame:GetFrameStrata() ~= strata then
                            frame:SetFrameStrata(strata)
                        end
                        
                        if frame:GetFrameLevel() ~= 10 then
                            frame:SetFrameLevel(10)
                        end

                        frame.text:SetAlpha(1)
                        frame:SetAlpha(1)
                    end
                else
                    frame:Hide()
                end
            end
        end
    end
end

function ADT:ApplyText(f, label, value, font, size, outline)
    if not f or not f.text then
        return
    end

    local valHex = self:GetColorHexOrDefault(true, f.name)
    local lblHex = self:GetColorHexOrDefault(false, f.name)
    local text = string_format('|c%s%s|r |c%s%s|r', valHex, tostring(value or 0), lblHex, label)

    f.text:SetText(text)

    local width, height = self:GetTextMetrics(text, font, size, outline)

    if width == 0 then width = 10 end
    if height == 0 then height = size or 12 end

    f:SetSize(width + 8, height + 4)
end
