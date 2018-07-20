local E, F, C = unpack(select(2, ...))

local Hidden = CreateFrame('Frame', nil, UIParent, 'SecureFrameTemplate')
Hidden:Hide()

for _, frame in next, {
	-- frames
	'MainMenuBarArtFrameBackground',
	'MicroButtonAndBagsBar',
	'ActionBarUpButton',
	'ActionBarDownButton',
	'PossessBarFrame',
	'StanceBarFrame',

	-- micro buttons
	'CharacterMicroButton',
	'SpellbookMicroButton',
	'TalentMicroButton',
	'AchievementMicroButton',
	'QuestLogMicroButton',
	'GuildMicroButton',
	'LFDMicroButton',
	'CollectionsMicroButton',
	'EJMicroButton',
	'StoreMicroButton',
	'MainMenuMicroButton',

	-- pet bar frames
	'SlidingActionBarTexture0',
	'SlidingActionBarTexture1',

	-- override bar frames
	'OverrideActionBarHealthBar',
	'OverrideActionBarPowerBar',
	'OverrideActionBarExpBar',
	'OverrideActionBarPitchFrame',
	'OverrideActionBarLeaveFrame',
} do
	_G[frame]:SetParent(Hidden)
	_G[frame].SetParent = nop
end

for _, region in next, {OverrideActionBar:GetRegions()} do
	region:SetAlpha(0)
end

for _, region in next, {MainMenuBarArtFrame:GetRegions()} do
	region:SetAlpha(0)
end

for _, animParents in next, {
	'MainMenuBar',
	'OverrideActionBar',
} do
	-- disable sliding
	(_G[animParents].slideOut:GetAnimations()):SetOffset(0, 0)
end

StatusTrackingBarManager:UnregisterAllEvents()
StatusTrackingBarManager:Hide()
