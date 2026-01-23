
-- add extra functionality to the dressing room slots

local function outfitSlotClick(self, button)
	if button == 'RightButton' then
		-- right-click to undress the slot
		local actor = DressUpFrame.ModelScene:GetPlayerActor()
		actor:UndressSlot(self.slotID)
	else
		-- call the original handler
		DressUpCustomSetDetailsSlotMixin.OnMouseUp(self)
	end
end

local function outfitTooltip(self)
	-- add tooltip line to indicate the right-click functionality
	if not self.isHiddenVisual then
		GameTooltip:AddLine(EVENT_TOAST_EXPANDED_DESCRIPTION) -- not quite accurate but w/e
		GameTooltip:Show() -- re-render
	end
end

local hooked = {}
hooksecurefunc(DressUpFrame.CustomSetDetailsPanel, 'Refresh', function(self)
	for button in self.slotPool:EnumerateActive() do
		if not hooked[button] then
			hooked[button] = true

			button:SetScript('OnMouseUp', outfitSlotClick) -- override existing handler
			button:HookScript('OnEnter', outfitTooltip)
		end
	end
end)
