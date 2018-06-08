local E, F, C = unpack(select(2, ...))

local Hider = CreateFrame('Frame')
Hider:Hide()

local frames = {
	'ActionBarDownButton',
	'ActionBarUpButton',
	'OverrideActionBarExpBar',
	'OverrideActionBarHealthBar',
	'OverrideActionBarPowerBar',
	'OverrideActionBarPitchFrame',
	'OverrideActionBarLeaveFrame',
	'CharacterMicroButton',
	'SpellbookMicroButton',
	'TalentMicroButton',
	'AchievementMicroButton',
	'QuestLogMicroButton',
	'GuildMicroButton',
	'LFDMicroButton',
	'StoreMicroButton',
	'CollectionsMicroButton',
	'EJMicroButton',
	'MainMenuMicroButton',
	'StanceBarFrame',
}

if(C.BfA) then
	table.insert(frames, 'MicroButtonAndBagsBar')
	table.insert(frames, 'MainMenuBarArtFrameBackground')
else
	table.insert(frames, 'MainMenuBar')
	table.insert(frames, 'MainMenuBarPageNumber')
	table.insert(frames, 'MainMenuBarBackpackButton')
	table.insert(frames, 'CharacterBag0Slot')
	table.insert(frames, 'CharacterBag1Slot')
	table.insert(frames, 'CharacterBag2Slot')
	table.insert(frames, 'CharacterBag3Slot')
end

for _, frame in next, frames do
	_G[frame]:SetParent(Hider)
	_G[frame].SetParent = nop
end

for _, texture in next, {
	'_BG',
	'EndCapL',
	'EndCapR',
	'_Border',
	'Divider1',
	'Divider2',
	'Divider3',
	'ExitBG',
	'MicroBGL',
	'MicroBGR',
	'_MicroBGMid',
	'ButtonBGL',
	'ButtonBGR',
	'_ButtonBGMid',
} do
	OverrideActionBar[texture]:SetAlpha(0)
end

if(C.BfA) then
	for _, child in next, {
		'RightEndCap',
		'LeftEndCap',
		'PageNumber',
	} do
		MainMenuBarArtFrame[child]:SetParent(Hider)
		MainMenuBarArtFrame[child].SetParent = nop
	end

	StatusTrackingBarManager.UpdateBarsShown = nop
	StatusTrackingBarManager:UnregisterAllEvents()
	StatusTrackingBarManager:HideStatusBars()
else
	for _, texture in next, {
		'StanceBarLeft',
		'StanceBarMiddle',
		'StanceBarRight',
		'SlidingActionBarTexture0',
		'SlidingActionBarTexture1',
		'PossessBackground1',
		'PossessBackground2',
		'MainMenuBarTexture0',
		'MainMenuBarTexture1',
		'MainMenuBarTexture2',
		'MainMenuBarTexture3',
		'MainMenuBarLeftEndCap',
		'MainMenuBarRightEndCap',
	} do
		_G[texture]:SetTexture(nil)
	end
end
