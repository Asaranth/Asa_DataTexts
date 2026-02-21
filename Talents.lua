local _, ADT = ...

local PlayerUtil = PlayerUtil
local C_ClassTalents = C_ClassTalents
local C_Traits = C_Traits
local C_AddOns = C_AddOns
local ToggleFrame = ToggleFrame

local function GetTalentProfile()
    local spec = PlayerUtil.GetCurrentSpecID()
    if not spec then return "No Spec" end

    local configID = C_ClassTalents.GetLastSelectedSavedConfigID(spec)
    if not configID then return "No Config" end

    local configInfo = C_Traits.GetConfigInfo(configID)
    return configInfo and configInfo.name or "Unknown"
end

ADT:RegisterDataText('Talents', {
    onUpdate = GetTalentProfile,
    events = {
        'TRAIT_CONFIG_UPDATED',
    },
    onClick = function()
        if not PlayerSpellsFrame then
            C_AddOns.LoadAddOn("Blizzard_PlayerSpells")
        end
        if PlayerSpellsFrame then
            ToggleFrame(PlayerSpellsFrame)
        end
    end,
    defaultEnabled = true,
    defaultAnchor = 'Minimap',
    defaultPoint = ADT.Enums.Points.TOP,
    defaultRelativePoint = ADT.Enums.Points.BOTTOM,
    defaultX = 0,
    defaultY = -18,
    defaultAlign= ADT.Enums.Align.CENTER,
    defaultStrata = ADT.Enums.Strata.MEDIUM
})