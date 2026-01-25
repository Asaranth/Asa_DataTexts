local ADT = LibStub('AceAddon-3.0'):GetAddon('ADT')

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
        'ACTIVE_TALENT_GROUP_CHANGED',
        'PLAYER_TALENT_UPDATE',
    },
    onClick = function()
        if not PlayerSpellsFrame then
            LoadAddOn("Blizzard_PlayerSpells")
        end
        if PlayerSpellsFrame then
            ToggleFrame(PlayerSpellsFrame)
        end
    end,
    defaultEnabled = true,
    defaultAnchor = 'Minimap',
    defaultPoint = ADT_Enums.Points.TOP,
    defaultRelativePoint = ADT_Enums.Points.BOTTOM,
    defaultX = 0,
    defaultY = -18,
    defaultAlign= ADT_Enums.Align.CENTER,
    defaultStrata = ADT_Enums.Strata.MEDIUM
})