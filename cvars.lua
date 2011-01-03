local _, Inomena = ...

Inomena:RegisterEvent('PLAYER_LOGIN', function()
	for key, value in pairs({
		deselectOnClick = 1,
		autoDismountFlying = 1,
		lootUnderMouse = 0,
		autoLootDefault = 1,
		threatWarning = 0,
		mapQuestDifficulty = 1,
		advancedWorldMap = 1,
		chatStyle = 'classic',
		conversationMode = 'inline',
		chatBubblesParty = 0,
		guildMemberNotify = 0,
		UnitNamePlayerGuild = 0,
		UnitNamePlayerPVPTitle = 0,
		UnitNameFriendlyPetName = 0,
		UnitNameEnemyPetName = 0,
		nameplateShowFriendlyPets = 0,
		nameplateShowFriendlyGuardians = 0,
		nameplateShowFriendlyTotems = 0,
		nameplateShowEnemyPets = 0,
		nameplateShowEnemyGuardians = 0,
		nameplateShowEnemyTotems = 0,
		enableCombatText = 0,
		showToastOnline = 0,
		showToastOffline = 0,
		showToastBroadcast = 0,
		showToastWindow = 0,
		cameraDistanceMaxFactor = 2,
		cameraWaterCollision = 0,
		cameraSmoothStyle = 0,
		showTutorials = 0,
		showNewbieTips = 0,

		Sound_EnableAllSound = 0,
		Sound_EnableErrorSpeech = 0,
		Sound_EnableEmoteSounds = 0,
		Sound_EnablePetSounds = 0,
		Sound_EnableMusic = 0,
		Sound_EnableAmbience = 0,
		Sound_EnableSoundWhenGameIsInBG = 1,
		Sound_NumChannels = 64,
		
		synchronizeSettings = 0,
		processAffinityMask = 15,
		screenshotQuality = 10,
		taintLog = 1,
	}) do
		SetCVar(key, value)
	end
end)
