local _, addon = ...

-- list of all settings listed in the interface options
local CVARS = {
	-- Controls
	deselectOnClick = 1,
	autoDismountFlying = 1,
	autoClearAFK = 1,
	interactOnLeftClick = 0,
	lootUnderMouse = 0,
	autoLootDefault = 1,
	combinedBags = 0,
	empowerTapControls = 1, -- this was moved somewhere else
	softTargettingInteractKeySound = 0,
	ClipCursor = 0,
	mouseInvertPitch = 0,
	cameraPitchMoveSpeed = 45,
	cameraYawMoveSpeed = 90,
	enableMouseSpeed = 0,
	autoInteract = 0,
	cameraYawSmoothSpeed = 180,
	cameraPitchSmoothSpeed = 45,
	cameraWaterCollision = 0,
	cameraSmoothStyle = 0,

	-- Interface
	UnitNameOwn = 0,
	UnitNameNPC = 0,
	UnitNameHostleNPC = 0,
	UnitNameFriendlySpecialNPCName = 1,
	UnitNameInteractiveNPC = 0,
	ShowQuestUnitCircles = 0,
	UnitNameNonCombatCreatureName = 0,
	UnitNameFriendlyPlayerName = 1,
	UnitNameFriendlyMinionName = 0,
	UnitNameEnemyPlayerName = 1,
	UnitNameEnemyMinionName = 0,
	nameplateShowAll = 1,
	NamePlateHorizontalScale = 1,
	NamePlateVerticalScale = 1,
	NamePlateClassificationScale = 1,
	nameplateShowEnemies = 1,
	nameplateShowEnemyPets = 1,
	nameplateShowEnemyGuardians = 1,
	nameplateShowEnemyTotems = 1,
	nameplateShowEnemyMinions = 1,
	nameplateShowEnemyMinus = 1,
	nameplateShowFriends = 0,
	nameplateShowFriendlyGuardians = 0,
	nameplateShowFriendlyTotems = 0,
	nameplateShowFriendlyMinions = 0,
	nameplateShowFriendlyMinus = 0,
	ShowNamePlateLoseAggroFlash = 1,
	nameplateMotion = 1,
	nameplateShowOnlyNames = 0,
	hideAdventureJournalAlerts = 1,
	showInGameNavigation = 1,
	showTutorials = 0,
	Outline = 1,
	statusText = 1,
	statusTextDisplay = 'BOTH',
	chatBubbles = 1,
	chatBubblesParty = 0,

	-- Action Bars
	lockActionBars = 1,
	countdownForCooldowns = 1,

	-- Combat
	nameplateShowSelf = 0,
	findYourselfMode = -1,
	doNotFlashLowHealthWarning = 1,
	lossOfControl = 1,
	enableFloatingCombatText = 0,
	enableMouseoverCast = 0,
	autoSelfCast = 1,
	-- no cvar for self cast key? we want it set to "None"
	-- no cvar for focus cast key? we want it set to "None"
	spellActivationOverlayOpacity = 0.5,
	ActionButtonUseKeyHeldSpell = 0,
	SoftTargetEnemy = 0,
	occludedSilhouettePlayer = 1,

	-- Social
	excludedCensorSources = 255,
	profanityFilter = 0,
	guildMemberNotify = 1,
	blockTrades = 0,
	-- no cvar for block guild invites?
	-- no cvar for display only character achievements?
	blockChannelInvites = 0,
	restrictCalendarInvites = 1,
	showToastOnline = 0,
	showToastOffline = 0,
	showToastBroadcast = 0,
	showToastFriendRequest = 0,
	showToastWindow = 0,
	autoAcceptQuickJoinRequests = 0,
	chatStyle = 'classic',
	whisperMode = 'inline',
	showTimestamps = 'none',
	enableTwitter = 0,

	-- Ping System
	pingCategoryTutorialShown = 1,
	enablePings = 1,
	pingMode = 0,
	Sound_EnablePingSounds = 0,
	showPingsInChat = 1, -- just so CHAT_MSG_PING works

	-- Accessibility
	enableMovePad = 0,
	movieSubtitle = 1,
	overrideScreenFlash = 1,
	questTextContrast = 0,
	WorldTextMinSize = 10,
	CameraKeepCharacterCentered = 1,
	CameraReduceUnexpectedMovement = 1,
	ShakeStrengthCamera = 1,
	ShakeStrengthUI = 0,
	cursorSizePreferred = 1,
	SoftTargetInteract = 3, -- plater overrides this one, no way to stop it
	SoftTargetTooltipInteract = 0,
	SoftTargetIconFriend = 0,
	SoftTargetIconEnemy = 0,
	SoftTargetIconGameObject = 1, -- plater overrides this one, no way to stop it
	SoftTargetIconInteract = 0,
	SoftTargetLowPriorityIcons = 0,
	SoftTargetInteractArc = 0,
	SoftTargetNameplateInteract = 0,
	colorblindMode = 0,
	speechToText = 0,
	textToSpeech = 0,
	remoteTextToSpeech = 0,

	-- Sound
	-- Sound_EnableAllSound = 1,
	Sound_MasterVolume = 0.2,
	-- Sound_SFXVolume = 0.3,
	-- Sound_MusicVolume = 0.2,
	-- Sound_AmbienceVolume = 0.1,
	-- Sound_DialogVolume = 0.6,
	-- Sound_EnableMusic = 0,
	-- Sound_EnableSFX = 0,
	-- Sound_EnableDialog = 0,
	-- Sound_EnableAmbience = 0,
	-- Sound_EnableSoundWhenGameIsInBG = 1,
	-- Sound_EnableReverb = 1,
	-- Sound_EnablePositionalLowPassFilter = 1,
	VoiceOutputVolume = 0,
	VoiceChatMasterVolumeScale = 1,
	VoiceInputVolume = 0,
	VoiceVADSensitivity = 0,
	VoiceCommunicationMode = 0,
}

-- list of settings NOT listed in the interface options, but still used
local UVARS = {
	ActionButtonUseKeyDown = 1,
	-- autoQuestWatch = 1, -- unused
	-- mapFade = 1,
	-- removeChatDelay = 1, -- unused
	screenshotFormat = 'png',
	screenshotQuality = 10,
	scriptErrors = 1,
	taintLog = IsTestBuild() and 11 or 2,
	-- trackQuestSorting = 'proximity',
	-- secureAbilityToggle = 1,
	-- nameplateOtherTopInset = -1,
	-- nameplateOtherBottomInset = -1,
	minimapTrackingShowAll = 1, -- to get the full minimap tracking menu back
	AutoPushSpellToActionBar = 0,
	DisableAdvancedFlyingFullScreenEffects = 1,
	calendarShowResets = 0,
	raidOptionIsShown = 0,
	SpellQueueWindow = 70,
}

function addon:PLAYER_LOGIN()
	-- if C_CVar.GetCVarBool('autoLootDefault') then
	-- 	-- we'll use this one to check if we're set, since it's off by default
	-- 	return
	-- end

	for key, value in next, CVARS do
		C_CVar.SetCVar(key, value)
	end

	for key, value in next, UVARS do
		C_CVar.SetCVar(key, value)
	end

	if UnitLevel('player') < GetMaxLevelForPlayerExpansion() then
		-- this is nice while leveling
		C_CVar.SetCVar('AutoPushSpellToActionBar', 1)
	end

	return true
end

local lastDialogSetting
local function cinematicStart()
	lastDialogSetting = C_CVar.GetCVar('Sound_EnableDialog')
	C_CVar.SetCVar('Sound_EnableDialog', '1')

	return true -- we have to stop it because it tends to trigger more than once
end

function addon:CINEMATIC_STOP()
	if lastDialogSetting then
		C_CVar.SetCVar('Sound_EnableDialog', lastDialogSetting)
		lastDialogSetting = nil

		addon:RegisterEvent('CINEMATIC_START', cinematicStart)
	end
end

addon:RegisterEvent('CINEMATIC_START', cinematicStart)
