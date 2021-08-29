local _, addon = ...

-- automatically select the talent tab
local function talentTreeTab()
	PlayerTalentTab_OnClick(_G['PlayerTalentFrameTab' .. TALENTS_TAB])
end

addon:HookAddOn('Blizzard_TalentUI', function()
	hooksecurefunc('PlayerTalentFrame_Toggle', talentTreeTab)
end)
