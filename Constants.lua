local ADT = LibStub('AceAddon-3.0'):GetAddon('ADT', true) or LibStub('AceAddon-3.0'):NewAddon('ADT', 'AceEvent-3.0', 'AceConsole-3.0')

ADT_Enums = {
    Points = {
        TOP = 'TOP',
        TOPLEFT = 'TOPLEFT',
        TOPRIGHT = 'TOPRIGHT',
        BOTTOM = 'BOTTOM',
        BOTTOMLEFT = 'BOTTOMLEFT',
        BOTTOMRIGHT = 'BOTTOMRIGHT',
        LEFT = 'LEFT',
        RIGHT = 'RIGHT',
        CENTER = 'CENTER',
    },
    Align = {
        LEFT = 'LEFT',
        CENTER = 'CENTER',
        RIGHT = 'RIGHT',
    },
    Strata = {
        BACKGROUND = 'BACKGROUND',
        LOW = 'LOW',
        MEDIUM = 'MEDIUM',
        HIGH = 'HIGH',
        DIALOG = 'DIALOG',
        FULLSCREEN = 'FULLSCREEN',
        FULLSCREEN_DIALOG = 'FULLSCREEN_DIALOG',
        TOOLTIP = 'TOOLTIP',
    },
    Outline = {
        NONE = 'NONE',
        OUTLINE = 'OUTLINE',
        THICKOUTLINE = 'THICKOUTLINE',
        MONOCHROME = 'MONOCHROME',
    }
}
