local E, F, C = unpack(select(2, ...))

-- list of all settings listed in the interface options
local cvars = {
	-- Controls
	deselectOnClick = 1,
	autoDismountFlying = 1,
	autoClearAFK = 1,
	autoLootDefault = 1,
	interactOnLeftClick = 0,

	-- Combat
	spellActivationOverlayOpacity = 1,
	doNotFlashLowHealthWarning = 1,
	lossOfControl = 1,

	-- Display
	hideAdventureJournalAlerts = 0, -- legion
	showTutorials = 0,
	enableFloatingCombatText = 0, -- legion
	Outline = 2,
	ShowQuestUnitCircles = 0, -- legion, find the category
	findYourselfMode = -1, -- legion
	chatBubbles = 1,
	chatBubblesParty = 0,

	-- Social
	profanityFilter = 0,
	spamFilter = 0,
	guildMemberNotify = 1,
	blockTrades = 0,
	blockChannelInvites = 0,
	showToastOnline = 0,
	showToastOffline = 0,
	showToastBroadcast = 0,
	showToastFriendRequest = 0,
	showToastWindow = 0,
	enableTwitter = 0,
	showTimestamps = 'none',
	whisperMode = 'inline',

	-- ActionBars
	lockActionBars = 1,
	countdownForCooldowns = 0,

	-- Names
	UnitNameOwn = 0,
	UnitNameNPC = 0,
	UnitNameHostleNPC = 0,
	UnitNameFriendlySpecialNPCName = 1,
	UnitNameInteractiveNPC = 0,
	UnitNameNonCombatCreatureName = 0,
	UnitNameFriendlyPlayerName = 1,
	UnitNameFriendlyMinionName = 0,
	UnitNameEnemyPlayerName = 1,
	UnitNameEnemyMinionName = 0,
	nameplateShowFriends = 0,
	nameplateShowFriendlyMinions = 0,
	nameplateShowEnemies = 1,
	nameplateShowEnemyMinions = 0,
	nameplateShowEnemyMinus = 1,
	ShowNamePlateLoseAggroFlash = 1,
	nameplateShowAll = 1,
	nameplateShowSelf = 0,
	NamePlateHorizontalScale = 1,
	NamePlateVerticalScale = 1,
	nameplateMotion = 1,

	-- Camera
	cameraWaterCollision = 0,
	cameraDistanceMaxFactor = 2.6, -- 2.6 is default max
	cameraSmoothStyle = 0,

	-- Mouse
	enableMouseSpeed = 0,
	mouseInvertPitch = 0,
	autoInteract = 0,
	cameraYawMoveSpeed = 90,

	-- Accessibility
	enableMovePad = 0,
	movieSubtitle = 1,
	colorblindMode = 0,
	colorblindSimulator = 0,

	-- Sound
	Sound_EnableAllSound = 1,
	Sound_EnableSFX = 0,
	Sound_EnableMusic = 0,
	Sound_EnableAmbience = 0,
	Sound_EnableDialog = 1,
	Sound_EnableErrorSpeech = 0,
	Sound_EnableSoundWhenGameIsInBG = 1,
	Sound_EnableReverb = 0,
	Sound_EnablePositionalLowPassFilter = 1,
	Sound_EnableDSPEffects = 0,
	Sound_MasterVolume = 0.2,
	Sound_SFXVolume = 0.3,
	Sound_MusicVolume = 0.2,
	Sound_AmbienceVolume = 0.1,
	Sound_DialogVolume = 0.6,
}

-- list of settings NOT listed in the interface options, but still used
local uvars = {
	ActionButtonUseKeyDown = 1,
	autoQuestWatch = 1, -- unused
	autoSelfCast = 1, -- unused, still a keybind
	chatStyle = 'im',
	lootUnderMouse = 0,
	mapFade = 1,
	removeChatDelay = 1, -- unused
	screenshotFormat = 'png',
	screenshotQuality = 10,
	scriptErrors = 1,
	taintLog = 1,
	trackQuestSorting = 'proximity',

	nameplateOtherTopInset = -1,
	nameplateOtherBottomInset = -1,
}

table.insert(C.Settings, function()
	for key, value in next, cvars do
		SetCVar(key, value)
	end

	for key, value in next, uvars do
		SetCVar(key, value)
	end

	SetAutoDeclineGuildInvites(true)
	NamePlateDriverFrame:UpdateNamePlateOptions()
end)
