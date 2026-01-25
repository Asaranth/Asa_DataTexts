local ADT = LibStub('AceAddon-3.0'):GetAddon('ADT', true) or LibStub('AceAddon-3.0'):NewAddon('ADT', 'AceEvent-3.0', 'AceConsole-3.0')
local LSM = LibStub('LibSharedMedia-3.0')

function ADT:GetSettings()
    local E = ADT_Enums
    local pointValues = {
        [E.Points.TOP] = 'Top',
        [E.Points.TOPLEFT] = 'Top Left',
        [E.Points.TOPRIGHT] = 'Top Right',
        [E.Points.BOTTOM] = 'Bottom',
        [E.Points.BOTTOMLEFT] = 'Bottom Left',
        [E.Points.BOTTOMRIGHT] = 'Bottom Right',
        [E.Points.LEFT] = 'Left',
        [E.Points.RIGHT] = 'Right',
        [E.Points.CENTER] = 'Center',
    }

    local pointOrder = {
        E.Points.TOPLEFT, E.Points.TOP, E.Points.TOPRIGHT,
        E.Points.LEFT, E.Points.CENTER, E.Points.RIGHT,
        E.Points.BOTTOMLEFT, E.Points.BOTTOM, E.Points.BOTTOMRIGHT,
    }

    local strataValues = {
        [E.Strata.TOOLTIP] = 'Tooltip',
        [E.Strata.FULLSCREEN_DIALOG] = 'Fullscreen Dialog',
        [E.Strata.FULLSCREEN] = 'Fullscreen',
        [E.Strata.DIALOG] = 'Dialog',
        [E.Strata.HIGH] = 'High',
        [E.Strata.MEDIUM] = 'Medium',
        [E.Strata.LOW] = 'Low',
        [E.Strata.BACKGROUND] = 'Background',
    }

    local strataOrder = {
        E.Strata.TOOLTIP,
        E.Strata.FULLSCREEN_DIALOG,
        E.Strata.FULLSCREEN,
        E.Strata.DIALOG,
        E.Strata.HIGH,
        E.Strata.MEDIUM,
        E.Strata.LOW,
        E.Strata.BACKGROUND,
    }

    local options = {
        name = 'ADT',
        type = 'group',
        childGroups = 'tab',
        args = {
            general = {
                type = 'group',
                name = 'General',
                order = 1,
                args = {
                    appearance = {
                        type = 'group',
                        name = 'Appearance',
                        order = 1,
                        inline = true,
                        args = {
                            font = {
                                type = 'select',
                                dialogControl = 'LSM30_Font',
                                name = 'Font',
                                desc = 'Font used for the texts.',
                                values = LSM:HashTable('font'),
                                set = function(_, val) self.db.global.DataTexts.font = val; self:UpdateTexts() end,
                                get = function() return self.db.global.DataTexts.font end,
                                order = 1,
                            },
                            textSize = {
                                type = 'range',
                                name = 'Text Size',
                                desc = 'Size of the text.',
                                min = 8, max = 32, step = 1,
                                set = function(_, val) self.db.global.DataTexts.textSize = val; self:UpdateTexts() end,
                                get = function() return self.db.global.DataTexts.textSize end,
                                order = 2,
                            },
                            outline = {
                                type = 'select',
                                name = 'Outline',
                                desc = 'Outline of the text.',
                                values = {
                                    [E.Outline.NONE] = 'None',
                                    [E.Outline.OUTLINE] = 'Outline',
                                    [E.Outline.THICKOUTLINE] = 'Thick Outline',
                                    [E.Outline.MONOCHROME] = 'Monochrome',
                                },
                                set = function(_, val) self.db.global.DataTexts.outline = val; self:UpdateTexts() end,
                                get = function() return self.db.global.DataTexts.outline end,
                                order = 3,
                            },
                            shadow = {
                                type = 'toggle',
                                name = 'Shadow',
                                desc = 'Show shadow under the text.',
                                set = function(_, val) self.db.global.DataTexts.shadow = val; self:UpdateTexts() end,
                                get = function() return self.db.global.DataTexts.shadow end,
                                order = 4,
                            },
                        },
                    },
                    colors = {
                        type = 'group',
                        name = 'Colors',
                        order = 2,
                        inline = true,
                        args = {
                            headerValues = {
                                type = 'header',
                                name = 'Value Colors',
                                order = 1,
                            },
                            valueColorOverride = {
                                type = 'toggle',
                                name = 'Class Color Values',
                                desc = 'Use your current class color for the values.',
                                set = function(_, val) self.db.global.DataTexts.valueColorOverride = val; self:UpdateTexts() end,
                                get = function() return self.db.global.DataTexts.valueColorOverride end,
                                order = 2,
                            },
                            valueColor = {
                                type = 'color',
                                name = 'Custom Value Color',
                                desc = 'Color of the numeric values.',
                                hasAlpha = false,
                                set = function(_, r, g, b)
                                    self.db.global.DataTexts.valueColor = { r = r, g = g, b = b }
                                    self:UpdateTexts()
                                end,
                                get = function()
                                    local c = self.db.global.DataTexts.valueColor
                                    return c.r, c.g, c.b
                                end,
                                disabled = function() return self.db.global.DataTexts.valueColorOverride end,
                                order = 3,
                            },
                            headerLabels = {
                                type = 'header',
                                name = 'Label Colors',
                                order = 10,
                            },
                            labelColorOverride = {
                                type = 'toggle',
                                name = 'Class Color Labels',
                                desc = 'Use your current class color for the labels.',
                                set = function(_, val) self.db.global.DataTexts.labelColorOverride = val; self:UpdateTexts() end,
                                get = function() return self.db.global.DataTexts.labelColorOverride end,
                                order = 11,
                            },
                            labelColor = {
                                type = 'color',
                                name = 'Custom Label Color',
                                desc = 'Color of the text labels.',
                                hasAlpha = false,
                                set = function(_, r, g, b)
                                    self.db.global.DataTexts.labelColor = { r = r, g = g, b = b }
                                    self:UpdateTexts()
                                end,
                                get = function()
                                    local c = self.db.global.DataTexts.labelColor
                                    return c.r, c.g, c.b
                                end,
                                disabled = function() return self.db.global.DataTexts.labelColorOverride end,
                                order = 12,
                            },
                        },
                    },
                },
            },
        },
    }

    local order = 10
    -- Sort names for consistent order
    local sortedNames = {}
    for name in pairs(self.RegisteredDataTexts) do
        table.insert(sortedNames, name)
    end
    table.sort(sortedNames)

    for _, name in ipairs(sortedNames) do
        local key = name:lower()
        options.args[key] = {
            type = 'group',
            name = name,
            order = order,
            args = {
                enabled = {
                    type = 'toggle',
                    name = 'Enabled',
                    desc = 'Show/Hide the ' .. name .. ' DataText.',
                    set = function(_, val) self.db.global.DataTexts[key .. 'Enabled'] = val; self:UpdateTexts() end,
                    get = function() return self.db.global.DataTexts[key .. 'Enabled'] end,
                    order = 1,
                    width = 'full',
                },
                anchoring = {
                    type = 'group',
                    name = 'Anchoring',
                    order = 2,
                    inline = true,
                    args = {
                        anchor = {
                            type = 'input',
                            name = 'Anchor Frame',
                            desc = 'The name of the frame to anchor to (e.g., Minimap, UIParent).',
                            set = function(_, val) self.db.global.DataTexts[key .. 'Anchor'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'Anchor'] end,
                            order = 1,
                            width = 1.5,
                        },
                        fstack = {
                            type = 'execute',
                            name = 'Select Frame',
                            desc = 'Click to open the FrameStack tool, then click on the frame you want to anchor to. Right click to cancel.',
                            func = function() self:ToggleFrameStack(name) end,
                            order = 1.1,
                            width = 0.5,
                        },
                        strata = {
                            type = 'select',
                            name = 'Frame Strata',
                            desc = 'The layer the DataText is drawn on.',
                            values = strataValues,
                            sorting = strataOrder,
                            set = function(_, val) self.db.global.DataTexts[key .. 'Strata'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'Strata'] end,
                            order = 2,
                        },
                    },
                },
                positioning = {
                    type = 'group',
                    name = 'Positioning',
                    order = 3,
                    inline = true,
                    args = {
                        point = {
                            type = 'select',
                            name = 'Anchor Point',
                            desc = 'The point on the DataText to anchor from.',
                            values = pointValues,
                            sorting = pointOrder,
                            set = function(_, val) self.db.global.DataTexts[key .. 'Point'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'Point'] end,
                            order = 1,
                        },
                        relativePoint = {
                            type = 'select',
                            name = 'Relative Point',
                            desc = 'The point on the Anchor Frame to anchor to.',
                            values = pointValues,
                            sorting = pointOrder,
                            set = function(_, val) self.db.global.DataTexts[key .. 'RelativePoint'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'RelativePoint'] end,
                            order = 2,
                        },
                        x = {
                            type = 'range',
                            name = 'X Offset',
                            min = -1000, max = 1000, step = 1,
                            set = function(_, val) self.db.global.DataTexts[key .. 'X'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'X'] end,
                            order = 3,
                        },
                        y = {
                            type = 'range',
                            name = 'Y Offset',
                            min = -1000, max = 1000, step = 1,
                            set = function(_, val) self.db.global.DataTexts[key .. 'Y'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'Y'] end,
                            order = 4,
                        },
                    },
                },
                text = {
                    type = 'group',
                    name = 'Text',
                    order = 4,
                    inline = true,
                    args = {
                        align = {
                            type = 'select',
                            name = 'Text Alignment',
                            values = {
                                [E.Align.LEFT] = 'Left',
                                [E.Align.CENTER] = 'Center',
                                [E.Align.RIGHT] = 'Right',
                            },
                            set = function(_, val) self.db.global.DataTexts[key .. 'Align'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'Align'] end,
                            order = 1,
                        },
                        headerStyle = {
                            type = 'header',
                            name = 'Style Overrides',
                            order = 10,
                        },
                        overrideText = {
                            type = 'toggle',
                            name = 'Override General Style',
                            desc = 'Override the font, size, and shadow settings from the General tab.',
                            set = function(_, val) self.db.global.DataTexts[key .. 'OverrideText'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'OverrideText'] end,
                            order = 11,
                            width = 'full',
                        },
                        font = {
                            type = 'select',
                            dialogControl = 'LSM30_Font',
                            name = 'Font',
                            values = LSM:HashTable('font'),
                            set = function(_, val) self.db.global.DataTexts[key .. 'Font'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'Font'] end,
                            disabled = function() return not self.db.global.DataTexts[key .. 'OverrideText'] end,
                            order = 12,
                        },
                        textSize = {
                            type = 'range',
                            name = 'Text Size',
                            min = 8, max = 32, step = 1,
                            set = function(_, val) self.db.global.DataTexts[key .. 'TextSize'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'TextSize'] end,
                            disabled = function() return not self.db.global.DataTexts[key .. 'OverrideText'] end,
                            order = 13,
                        },
                        outline = {
                            type = 'select',
                            name = 'Outline',
                            values = {
                                [E.Outline.NONE] = 'None',
                                [E.Outline.OUTLINE] = 'Outline',
                                [E.Outline.THICKOUTLINE] = 'Thick Outline',
                                [E.Outline.MONOCHROME] = 'Monochrome',
                            },
                            set = function(_, val) self.db.global.DataTexts[key .. 'Outline'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'Outline'] end,
                            disabled = function() return not self.db.global.DataTexts[key .. 'OverrideText'] end,
                            order = 14,
                        },
                        shadow = {
                            type = 'toggle',
                            name = 'Shadow',
                            set = function(_, val) self.db.global.DataTexts[key .. 'Shadow'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'Shadow'] end,
                            disabled = function() return not self.db.global.DataTexts[key .. 'OverrideText'] end,
                            order = 15,
                        },
                        headerColors = {
                            type = 'header',
                            name = 'Color Overrides',
                            order = 20,
                        },
                        overrideColors = {
                            type = 'toggle',
                            name = 'Override General Colors',
                            desc = 'Override the color settings from the General tab.',
                            set = function(_, val) self.db.global.DataTexts[key .. 'OverrideColors'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'OverrideColors'] end,
                            order = 21,
                            width = 'full',
                        },
                        valueColorOverride = {
                            type = 'toggle',
                            name = 'Class Color Values',
                            set = function(_, val) self.db.global.DataTexts[key .. 'ValueColorOverride'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'ValueColorOverride'] end,
                            disabled = function() return not self.db.global.DataTexts[key .. 'OverrideColors'] end,
                            order = 22,
                        },
                        valueColor = {
                            type = 'color',
                            name = 'Custom Value Color',
                            hasAlpha = false,
                            set = function(_, r, g, b)
                                self.db.global.DataTexts[key .. 'ValueColor'] = { r = r, g = g, b = b }
                                self:UpdateTexts()
                            end,
                            get = function()
                                local c = self.db.global.DataTexts[key .. 'ValueColor']
                                return c.r, c.g, c.b
                            end,
                            disabled = function() return not self.db.global.DataTexts[key .. 'OverrideColors'] or self.db.global.DataTexts[key .. 'ValueColorOverride'] end,
                            order = 23,
                        },
                        labelColorOverride = {
                            type = 'toggle',
                            name = 'Class Color Labels',
                            set = function(_, val) self.db.global.DataTexts[key .. 'LabelColorOverride'] = val; self:UpdateTexts() end,
                            get = function() return self.db.global.DataTexts[key .. 'LabelColorOverride'] end,
                            disabled = function() return not self.db.global.DataTexts[key .. 'OverrideColors'] end,
                            order = 24,
                        },
                        labelColor = {
                            type = 'color',
                            name = 'Custom Label Color',
                            hasAlpha = false,
                            set = function(_, r, g, b)
                                self.db.global.DataTexts[key .. 'LabelColor'] = { r = r, g = g, b = b }
                                self:UpdateTexts()
                            end,
                            get = function()
                                local c = self.db.global.DataTexts[key .. 'LabelColor']
                                return c.r, c.g, c.b
                            end,
                            disabled = function() return not self.db.global.DataTexts[key .. 'OverrideColors'] or self.db.global.DataTexts[key .. 'LabelColorOverride'] end,
                            order = 25,
                        },
                    },
                },
            },
        }
        order = order + 1
    end

    return options
end
