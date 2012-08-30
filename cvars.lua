local __, Inomena = ...

function Inomena.Initialize.CVARS()
	for key, value in pairs({
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
		profanityFilter = 0,
		chatBubblesParty = 0,
		removeChatDelay = 1,
		chatStyle = 'classic',
		conversationMode = 'inline',
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
		Sound_EnableMusic = 0,
		Sound_EnableAmbience = 0,
		Sound_EnableSoundWhenGameIsInBG = 1,

		screenshotQuality = 10,
		taintLog = 1,
	}) do
		SetCVar(key, value)
	end
end
