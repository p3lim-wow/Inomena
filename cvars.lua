local _, Inomena = ...

local function Initialize()
	for key, value in next, {
		deselectOnClick = 1,
		autoDismountFlying = 1,
		lootUnderMouse = 0,
		autoLootDefault = 1,
		interactOnLeftClick = 0,
		spellActivationOverlayOpacity = 1,
		showVKeyCastbar = 1,
		threatPlaySounds = 0,
		movieSubtitle = 1,
		mapQuestDifficulty = 1,
		chatBubblesParty = 0,
		UnitNameGuildTitle = 0,
		UnitNamePlayerPVPTitle = 0,
		UnitNameFriendlyPetName = 0,
		UnitNameEnemyPetName = 0,
		nameplateShowFriendlyPets = 0,
		nameplateShowFriendlyGuardians = 0,
		nameplateShowFriendlyTotems = 0,
		nameplateShowEnemyPets = 0,
		nameplateShowEnemyGuardians = 0,
		nameplateShowEnemyTotems = 0,
		ShowClassColorInNameplate = 1,
		enableCombatText = 0,
		showArenaEnemyFrames = 0,
		showToastOnline = 0,
		showToastOffline = 0,
		showToastBroadcast = 0,
		showToastConversation = 0,
		showToastWindow = 0,
		cameraDistanceMaxFactor = 2,
		cameraWaterCollision = 0,
		cameraSmoothStyle = 0,
		showTutorials = 0,
		scriptErrors = 1,

		Sound_EnableAllSound = 1,
		Sound_EnableSFX = 0,
		Sound_EnableMusic = 0,
		Sound_EnableAmbience = 0,
		Sound_EnableSoundWhenGameIsInBG = 1,

		screenshotQuality = 10,
		taintLog = 1,
	} do
		SetCVar(key, value)
	end

	print('|cffff6000Inomena:|r Successfully initialized settings')
end

local function Decline()
	print('|cffff6000Inomena:|r Settings not initialized, you can do so later with /init')
end

StaticPopupDialogs.INOMENA_INITIALIZE = {
	text = '|cffff6000Inomena:|r Load settings?',
	button1 = YES,
	button2 = NO,
	OnAccept = Initialize,
	OnCancel = Decline,
	timeout = 0
}

Inomena.RegisterEvent('PLAYER_LOGIN', function()
	if(not InomenaDB) then
		InomenaDB = true
		StaticPopup_Show('INOMENA_INITIALIZE')
	end
end)

SlashCmdList.Inomena = Initialize
SLASH_Inomena1 = '/init'
