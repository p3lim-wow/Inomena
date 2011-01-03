local _, Inomena = ...

local NotifySound
do
	local frame = CreateFrame('Frame')
	frame:Hide()
	frame:SetScript('OnUpdate', function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed

		if(self.elapsed > 2.5) then
			self:Hide()
			self.elapsed = nil

			SetCVar('Sound_EnableAllSound', 0)
		end
	end)

	function NotifySound()
		SetCVar('Sound_EnableAllSound', 1)
		PlaySoundFile([=[Sound\Interface\ReadyCheck.wav]=])
		frame:Show()
	end
end

Inomena.RegisterEvent('UPDATE_BATTLEFIELD_STATUS', function()
	if(StaticPopup_Visible('CONFIRM_BATTLEFIELD_ENTRY')) then
		NotifySound()
	end
end)

Inomena.RegisterEvent('LFG_PROPOSAL_SHOW', function()
	NotifySound()
end)

ReadyCheckListenerFrame:SetScript('OnShow', function()
	NotifySound()
end)
