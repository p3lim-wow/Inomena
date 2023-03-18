-- resize the loot window to avoid scroll bars
hooksecurefunc(LootFrame, 'Resize', function(self)
	local height = self:CalculateElementsHeight() + 38 -- adjusted from the original (46)
	self:SetSize(self.panelWidth, math.min(height, GetScreenHeight() * 2/3))
	self.ScrollBar:Hide()
end)

LootFrame:HookScript('OnEvent', function(self, event, slotIndex)
	if event == 'LOOT_SLOT_CLEARED' then
		local frame = self.ScrollBox:FindFrameByPredicate(function(frame)
			return frame:GetSlotIndex() == slotIndex
		end)

		if frame and frame.SlideOutRightAnim then
			frame.SlideOutRightAnim:Stop()
			frame:Hide()
		end
	end
end)
