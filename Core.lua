local AddonName, ADT = ...
LibStub('AceAddon-3.0'):NewAddon(ADT, AddonName, 'AceEvent-3.0', 'AceConsole-3.0')

local LSM = LibStub('LibSharedMedia-3.0')

local pairs, ipairs = pairs, ipairs
local LibStub = LibStub
local Settings = Settings
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory

ADT.RegisteredDataTexts = {}
ADT.Frames = {}
ADT.EventHandlers = {}

local DEFAULT_FONT = 'Friz Quadrata TT'
local DEFAULT_ALIGN = ADT.Enums.Align.CENTER
local DEFAULT_TEXT_SIZE = 12
local DEFAULT_OUTLINE = ADT.Enums.Outline.NONE
local DEFAULT_SHADOW = true

function ADT:RegisterDataText(name, data)
    self.RegisteredDataTexts[name] = data
    if self.db then self:UpdateEvents() end
end


function ADT:UpdateDataTexts(force)
    for _, data in pairs(self.RegisteredDataTexts) do
        if data.Update then data.Update(force) end
    end
end


function ADT:UpdateDataText(name, force)
    local data = self.RegisteredDataTexts[name]
    if data and data.Update then data.Update(force) end
end


function ADT:OnInitialize()
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

    local options = self:GetSettings()

    -- Register the main Asa Suite category if it doesn't exist
    if not LibStub('AceConfigRegistry-3.0'):GetOptionsTable('|cFF047857Asa|r Suite') then
        LibStub('AceConfig-3.0'):RegisterOptionsTable('|cFF047857Asa|r Suite', {
            name = '|cFF047857Asa|r Suite',
            type = 'group',
            args = {
                info = {
                    type = 'description',
                    name = 'Welcome to |cFF047857Asa|r Suite. Select a module from the menu on the left to configure its settings.',
                    order = 1,
                },
            },
        })
        LibStub('AceConfigDialog-3.0'):AddToBlizOptions('|cFF047857Asa|r Suite', '|cFF047857Asa|r Suite')
    end

    -- Register module's options as a sub-category
    LibStub('AceConfig-3.0'):RegisterOptionsTable('Data Texts', options)
    self.optionsFrame, self.categoryID = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('Data Texts', 'Data Texts', '|cFF047857Asa|r Suite')

    if not self.categoryID and self.optionsFrame and self.optionsFrame.parent then
        self.categoryID = self.optionsFrame.parent
    end

    self:RegisterChatCommand('adt', 'ChatCommand')

    LSM.RegisterCallback(self, 'LibSharedMedia_Registered', function()
        self:UpdateDataTexts(true)
    end)
    LSM.RegisterCallback(self, 'LibSharedMedia_SetGlobal', function()
        self:UpdateDataTexts(true)
    end)
end

function ADT:OnEnable()
    local db = self.db.global.DataTexts or {}
    for name, _ in pairs(self.RegisteredDataTexts) do
        local key = name:lower()
        if db[key .. 'Enabled'] and not self.Frames[name] then
            self.Frames[name] = self:CreateDataTextFrame(name)
        end
    end

    self:UpdateEvents()
    self:UpdateDataTexts(true)
end

function ADT:ChatCommand(input)
    if not input or input:trim() == '' then
        if Settings and Settings.OpenToCategory then
            if self.categoryID then
                Settings.OpenToCategory(self.categoryID)
            else
                Settings.OpenToCategory('|cFF047857Asa|r Suite')
            end
        elseif InterfaceOptionsFrame_OpenToCategory then
            InterfaceOptionsFrame_OpenToCategory('|cFF047857Asa|r Suite')
        end
    else
        LibStub('AceConfigCmd-3.0'):HandleCommand(self, 'adt', 'Data Texts', input)
    end
end

function ADT:UpdateEvents()
    local db = self.db.global.DataTexts or {}
    local neededEvents = {}
    self.EventHandlers = {}

    for name, data in pairs(self.RegisteredDataTexts) do
        local key = name:lower()
        if db[key .. 'Enabled'] and data.events then
            for _, event in ipairs(data.events) do
                neededEvents[event] = true
                self.EventHandlers[event] = self.EventHandlers[event] or {}
                self.EventHandlers[event][name] = data
            end
        end
    end

    local allPossibleEvents = {}
    for _, data in pairs(self.RegisteredDataTexts) do
        if data.events then
            for _, event in ipairs(data.events) do
                allPossibleEvents[event] = true
            end
        end
    end

    for event in pairs(allPossibleEvents) do
        if neededEvents[event] then
            self:RegisterEvent(event, 'OnEvent')
        else
            self:UnregisterEvent(event)
        end
    end
end

function ADT:OnEvent(event, ...)
    local handlers = self.EventHandlers[event]
    if handlers then
        for _, data in pairs(handlers) do
            if data.onEvent then
                data.onEvent(event, ...)
            end
            if data.Update then
                data.Update()
            end
        end
    end
end

