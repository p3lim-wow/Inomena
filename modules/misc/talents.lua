local _, addon = ...

-- automatically select the talent tab
local function talentTreeTab()
	if not InCombatLockdown() then
		PlayerTalentTab_OnClick(_G['PlayerTalentFrameTab' .. TALENTS_TAB])
	end
end

addon:HookAddOn('Blizzard_TalentUI', function()
	hooksecurefunc('PlayerTalentFrame_Toggle', talentTreeTab)
end)
