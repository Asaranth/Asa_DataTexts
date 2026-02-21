local _, ADT = ...

ADT.Enums = {
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

ADT.DURABILITY_THRESHOLDS = {
    { threshold = 0.25, color = { r = 1, g = 0, b = 0 } },
    { threshold = 0.50, color = { r = 1, g = 0.5, b = 0 } },
    { threshold = 0.75, color = { r = 1, g = 1, b = 0 } },
    { threshold = 1.00, color = { r = 0, g = 1, b = 0 } },
}
