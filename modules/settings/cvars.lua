local E, F, C = unpack(select(2, ...))

local cvars = {
	-- Controls
	deselectOnClick = 1,
	autoDismountFlying = 1,
	autoClearAFK = 1,
	blockTrades = 0,
	blockChannelInvites = 1,
	lootUnderMouse = 0,
	autoLootDefault = 1,
	autoOpenLootHistory = 0,
	interactOnLeftClick = 0,
	spellActivationOverlayOpacity = 1,

	-- Combat
	assistAttack = 0,
	autoSelfCast = 1,
	stopAutoAttackOnTargetChange = 0,
	showVKeyCastbar = 1,
	showVKeyCastbarOnlyOnTarget = 0,
	showVKeyCastbarSpellName = 1,
	displaySpellActivationOverlays = 1,
	spellActivationOverlayOpacity = 1,
	reducedLagTolerance = 0,
	ActionButtonUseKeyDown = 1,
	lossOfControl = 1,
	lossOfControlFull = 2,
	lossOfControlSilence = 2,
	lossOfControlInterrupt = 2,
	lossOfControlDisarm = 2,
	lossOfControlRoot = 2,

	-- Display
	threatPlaySounds = 0,
	SpellTooltip_DisplayAvgValues = 1,
	movieSubtitle = 1,
	Outline = 2,

	-- Objectives
	autoQuestWatch = 1,
	mapFade = 1,
	trackQuestSorting = 'proximity',

	-- Social
	chatBubbles = 1,
	chatBubblesParty = 0,
	profanityFilter = 0,
	spamFilter = 0,
	removeChatDelay = 1,
	guildMemberNotify = 1,
	chatMouseScroll = 1,
	chatStyle = 'im',
	showTimestamps = 'none',
	whisperMode = 'inline',

	-- Names
	UnitNameOwn = 0,
	UnitNameNPC = 0,
	UnitNameForceHideMinus = 0,
	UnitNameHostleNPC = 0,
	UnitNameFriendlySpecialNPCName = 1,
	UnitNameNonCombatCreatureName = 0,
	UnitNamePlayerGuild = 1,
	UnitNameGuildTitle = 0,
	UnitNamePlayerPVPTitle = 0,
	UnitNameFriendlyPlayerName = 1,
	UnitNameFriendlyPetName = 0,
	UnitNameFriendlyGuardianName = 0,
	UnitNameFriendlyTotemName = 0,
	UnitNameEnemyPlayerName = 1,
	UnitNameEnemyPetName = 0,
	UnitNameEnemyGuardianName = 0,
	UnitNameEnemyTotemName = 0,

	-- Floating Combat Text
	showArenaEnemyFrames = 0,

	-- Battle.net
	showToastOnline = 0,
	showToastOffline = 0,
	showToastBroadcast = 0,
	showToastFriendRequest = 0,
	showToastConversation = 0,
	showToastWindow = 0,
	cameraDistanceMaxFactor = 2,

	-- Camera
	cameraBobbing = 0,
	cameraWaterCollision = 0,
	cameraPivot = 1,
	cameraDistanceMaxFactor = 4,
	cameraDistanceMax = 50,
	cameraSmoothStyle = 0,

	-- Mouse
	mouseInvertPitch = 0,
	cameraYawMoveSpeed = 180,
	mouseSpeed = 1,
	autointeract = 0,
	enableWoWMouse = 0,

	-- Help
	showTutorials = 0,
	UberTooltips = 1,
	scriptErrors = 1,
	colorblindMode = 0,
	enableMovepad = 0,

	-- Sound
	Sound_EnableAllSound = 1,
	Sound_EnableSFX = 0,
	Sound_EnableMusic = 0,
	Sound_EnableAmbience = 0,
	Sound_EnableSoundWhenGameIsInBG = 1,
	Sound_EnableReverb = 0,
	Sound_EnableDSPEffects = 0,
	Sound_NumChannels = 24,

	-- Misc
	taintLog = 1,
	screenshotQuality = 10,
	screenshotFormat = 'png',
}

if(not C.isBetaClient) then
	-- Floating Combat Text
	cvars.CombatDamage = 1
	cvars.CombatLogPeriodicSpells = 1
	cvars.PetMeleeDamage = 1
	cvars.CombatHealing = 1
	cvars.CombatHealingAbsorbTarget = 1
	cvars.fctSpellMechanics = 0
	cvars.CombatDamageStyle = 2
	cvars.enableCombatText = 0
	cvars.enablePetBattleCombatText = 1

	-- Social
	cvars.bnWhisperMode = 'inline'
	cvars.conversationMode = 'inline'

	-- Sound
	cvars.Sound_EnableSoftwareHRTF = 0
end

table.insert(C.Settings, function()
	for key, value in next, cvars do
		SetCVar(key, value)
	end

	SetAutoDeclineGuildInvites(true)
end)
