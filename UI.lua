local _, ADT = ...

local CreateFrame = CreateFrame
local UIParent = UIParent
local GameTooltip = GameTooltip
local C_Timer = C_Timer
local GetMouseFoci = GetMouseFoci
local string_format = string.format

function ADT:ToggleFrameStack(name)
    if not FrameStackTooltip_Toggle then
        UIParentLoadAddOn('Blizzard_DebugTools')
    end

    if FrameStackTooltip_Toggle then
        FrameStackTooltip_Toggle()
    else
        ExecuteChatCommand('fstack')
    end

    if name then
        if not self.selectionFrame then
            self.selectionFrame = CreateFrame('Frame', 'Asa_DataTextsSelectionFrame', UIParent)
            self.selectionFrame:SetAllPoints(UIParent)
            self.selectionFrame:SetFrameStrata('TOOLTIP')
            self.selectionFrame:EnableMouse(true)
            self.selectionFrame:SetScript('OnMouseDown', function(_, button)
                if button == 'LeftButton' then
                    self.selectionFrame:Hide()
                    C_Timer.After(0.01, function()
                        local foci = GetMouseFoci()
                        local focus = foci and foci[1]
                        if focus then
                            local focusName = focus:GetName()
                            if focusName then
                                local key = self.selectingModule:lower()
                                self.db.global.DataTexts[key .. 'Anchor'] = focusName
                                self:Print(string_format('Anchored %s to %s', self.selectingModule, focusName))
                                local data = self.RegisteredDataTexts[self.selectingModule]
                                if data and data.Update then
                                    data.Update(true)
                                end
                                self:ToggleFrameStack()
                                LibStub('AceConfigRegistry-3.0'):NotifyChange('Data Texts')
                            else
                                self:Print('Selected frame has no name. Please try another.')
                                self.selectionFrame:Show()
                            end
                        else
                            self:Print('No frame found under mouse. Please try again.')
                            self.selectionFrame:Show()
                        end
                    end)
                elseif button == 'RightButton' then
                    self:ToggleFrameStack()
                end
            end)
        end

        self.selectingModule = name
        self.selectionFrame:Show()
        self:Print(string_format('Select a frame to anchor %s to (Left Click to select, Right Click to cancel).', name))
    else
        if self.selectionFrame then
            self.selectionFrame:Hide()
        end
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

    if data.Update then
        data.Update(true)
    end

    return frame
end
