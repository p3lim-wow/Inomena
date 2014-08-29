local _, Inomena = ...

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

	-- Objectives
	autoQuestWatch = 1,

	-- Social
	chatBubbles = 1,
	chatBubblesParty = 0,

	-- Names
	UnitNameOwn = 0,
	UnitNameNPC = 0,
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
	CombatDamage = 1,
	CombatLogPeriodicSpells = 1,
	PetMeleeDamage = 1,
	CombatHealing = 1,
	CombatHealingAbsorbTarget = 1,
	fctSpellMechanics = 0,
	enableCombatText = 0,
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
	cameraDistanceMax = 12,
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
	Sound_EnableSoftwareHRTF = 0,
	Sound_EnableDSPEffects = 0,
	Sound_OutputQuality = 1,
	Sound_NumChannels = 24
}

if(Inomena.WoD) then
	cvars.UnitNameForceHideMinus = 0
	cvars.Outline = 2
	cvars.CombatDamageStyle = 2
	cvars.enablePetBattleCombatText = 1
	cvars.mapFade = 1
	cvars.trackQuestSorting = 'proximity'
else
	cvars.mapQuestDifficulty = 1
end

local function Initialize()
	for key, value in next, cvars do
		SetCVar(key, value)
	end

	SetAutoDeclineGuildInvites(true)

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
