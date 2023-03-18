local EVENT_TOAST_EXPANDED_DESCRIPTION = _G.EVENT_TOAST_EXPANDED_DESCRIPTION -- globalstring

-- make sure the dressing room is always maximized (this is a bugfix really)
DressUpFrameResetButton:HookScript('OnClick', function()
	if DressUpFrame.MaximizeMinimizeFrame:IsMinimized() then
		DressUpFrame.MaximizeMinimizeFrame:Maximize()
	end
end)

-- add extra functionality to the dressing room details slots
local function outfitSlotClick(self, button)
	if button == 'RightButton' then
		local actor = DressUpFrame.ModelScene:GetPlayerActor()
		actor:UndressSlot(self.slotID)
	else
		DressUpOutfitDetailsSlotMixin.OnMouseUp(self)
	end
end

local function outfitTooltip(self)
	if not self.isHiddenVisual then
		GameTooltip:AddLine(EVENT_TOAST_EXPANDED_DESCRIPTION)
		GameTooltip:Show() -- re-render
	end
end

hooksecurefunc(DressUpFrame.OutfitDetailsPanel, 'Refresh', function(self)
	for button in self.slotPool:EnumerateActive() do
		if not button.hooked then
			button.hooked = true
			button:SetScript('OnMouseUp', outfitSlotClick)
			button:HookScript('OnEnter', outfitTooltip)
		end
	end
end)
