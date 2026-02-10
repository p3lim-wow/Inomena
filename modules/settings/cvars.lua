local _, addon = ...

-- set preferred console variables on login

local CVARS = { -- exposed settings from the interface options
	-- Gameplay Controls
	deselectOnClick = 1,
	autoDismountFlying = 1,
	autoClearAFK = 1, -- (default)
	interactOnLeftClick = 0,
	lootUnderMouse = 0,
	autoLootDefault = 1,
	SoftTargetInteract = 3,
	softTargettingInteractKeySound = 0, -- (default)
	ClipCursor = 0, -- (default)
	mouseInvertPitch = 0, -- (default)
	cameraYawMoveSpeed = 90,
	cameraPitchMoveSpeed = 45,
	enableMouseSpeed = 0, -- (default)
	autoInteract = 0, -- (default)
	cameraWaterCollision = 0, -- (default)
	cameraYawSmoothSpeed = 180, -- (default)
	cameraPitchSmoothSpeed = 45, -- (default)
	cameraSmoothStyle = 0,

	-- Gameplay Interface
	showInGameNavigation = 1, -- (default)
	showTutorials = 0,
	Outline = 1,
	chatBubbles = 1, -- (default)
	chatBubblesParty = 0,
	chatBubblesRaid = 0, -- (default)

	-- Gameplay Action Bars
	enableMultiActionBars = 15,
	lockActionBars = 1,
	countdownForCooldowns = 1,

	-- Gameplay Combat
	nameplateShowSelf = 0, -- (default)
	doNotFlashLowHealthWarning = 1,
	lossOfControl = 1, -- (default)
	enableFloatingCombatText = 0, -- (default)
	enableMouseoverCast = 0, -- (default)
	autoSelfCast = 1,
	empowerTapControls = 1,
	spellActivationOverlayOpacity = 0,
	displaySpellActivationOverlays = 0,
	ActionButtonUseKeyHeldSpell = 0,
	SoftTargetEnemy = 1, -- (default)

	-- Gameplay Social
	excludedCensorSources = 255,
	profanityFilter = 0,
	guildMemberNotify = 1, -- (default)
	blockTrades = 0, -- (default)
	restrictCalendarInvites = 1, -- (default)
	blockChannelInvites = 0, -- (default)
	showToastOnline = 0,
	showToastOffline = 0,
	showToastBroadcast = 0, -- (default)
	showToastFriendRequest = 0,
	showToastWindow = 0,
	autoAcceptQuickJoinRequests = 0, -- (default)
	chatStyle = 'classic',
	whisperMode = 'inline',
	showTimestamps = 'none', -- (default)

	-- Gameplay Ping System
	enablePings = 1, -- (default)
	pingMode = 0, -- (default)
	Sounds_EnablePingSounds = 1, -- (default)
	showPingsInChat = 0,

	-- Gameplay Enhancements
	assistedCombatHighlight = 0, -- (default)
	combatWarningsEnabled = 1, -- (default)
	encounterWarningsEnabled = 1, -- (default)
	encounterWarningsLevel = 0, -- (default)
	encounterWarningsHideIfNotTargetingPlayer = 0, -- (default)
	encounterWarningsTimelineEnabled = 1, -- (default)
	encounterWarningsTimelineHideLongCountdowns = 0, -- (default)
	encounterWarningsTimelineHideForOtherRoles = 0, -- (default)
	encounterWarningsTimelineIconographyEnabled = 1, -- (default)
	-- encounterWarningsTimelineIconographyHiddenMask = ------, TODO: bitfield
	cooldownViewerEnabled = 1,
	externalDefensivesEnabled = 0, -- (default)
	damageMeterEnabled = 1,
	spellDiminishPVPEnemiesEnabled = 0,
	spellDiminishPVPOnlyTriggerableByMe = 0, -- (default)

	-- Gameplay Nameplates
	UnitNameOwn = 0, -- (default)
	UnitNameHostleNPC = 0,
	ShowQuestUnitCircles = 0,
	UnitNameNonCombatCreatureName = 0, -- (default)
	UnitNameFriendlyPlayerName = 1, -- (default)
	UnitNameFriendlyPetName = 0,
	UnitNameFriendlyGuardianName = 0,
	UnitNameFriendlyTotemName = 0,
	UnitNameFriendlyMinionName = 0,
	UnitNameEnemyPlayerName = 1, -- (default)
	UnitNameEnemyPetName = 0,
	UnitNameEnemyGuardian = 0,
	UnitNameEnemyTotem = 0,
	UnitNameEnemyMinion = 0,

	-- Accessibility Interface
	userFontScale = 1, -- (default)
	questTextContrast = 0, -- (default)

	-- Accessibility General
	enableMovePad = 0, -- (default)
	overrideScreenFlash = 1,
	WorldTextMinSize = 10,
	CameraKeepCharacterCentered = 1, -- (default)
	CameraReduceUnexpectedMovement = 1,
	ShakeStrengthCamera = 0.25,
	ShakeStrengthUI = 0,
	cursorSizePreferred = 1,
	findYourselfAnywhere = 0, -- (default)
	findYourselfModeIcon = 0, -- (default)
	findYourselfModeOutline = 0, -- (default)
	findYourselfModeCircle = 0, -- (default)
	occludedSilhouettePlayer = 1,
	SoftTargetTooltipEnemy = 0, -- (default)
	SoftTargetTooltipInteract = 0, -- (default)
	SoftTargetIconEnemy = 0, -- (default)
	SoftTargetIconInteract = 0,
	SoftTargetIconGameObject = 0, -- (default)
	SoftTargetLowPriorityIcons = 0, -- (default)
	arachnophobiaMode = 0, -- (default)

	-- Accessibility Colors
	colorblindMode = 0, -- (default)

	-- Accessibility Audio Assist
	speechToText = 0, -- (default)
	textToSpeech = 0, -- (default)
	remoteTextToSpeech = 0, -- (default)
	CAAEnabled = 0, -- (default)

	-- Accessibility Mounts
	motionSicknessLandscapeDarkening = 0, -- (default)
	DisableAdvancedFlyingFullScreenEffects = 1,
	DisableAdvancedFlyingVelocityVFX = 1,
	advFlyPitchControl = 3, -- (default)
	advFlyPitchControlGroundDebounce = 0, -- (default)
	advFlyPitchControlCameraChase = 20, -- (default)
	advFlyKeyboardMinPitchFactor = 2.5, -- (default)
	advFlyKeyboardMaxPitchFactor = 5, -- (default)
	advFlyKeyboardMinTurnFactor = 5, -- (default)
	advFlyKeyboardMaxTurnFactor = 8, -- (default)

	-- Accessibility Subtitles
	movieSubtitle = 1, -- (default)
	movieSubtitleBackground = 1, -- (default)

	-- Sound
	Sound_EnableAllSound = 1, -- (default)
	Sound_MasterVolume = 0.25,
	Sound_MusicVolume = 0,
	Sound_SFXVolume = 0,
	Sound_AmbienceVolume = 0,
	Sound_DialogVolume = 1,
	Sound_EnableMusic = 0,
	Sound_ZoneMusicNoDelay = 0, -- (default)
	Sound_EnablePetBattleMusic = 0,
	Sound_EnableSFX = 0,
	Sound_EnablePetSounds = 0,
	Sound_EnableEmoteSounds = 0,
	Sound_EnableGameplaySFX = 1, -- (default)
	Sound_GameplaySFX = 1, -- (default)
	Sound_EnableDialog = 0,
	Sound_EnableErrorSpeech = 0,
	Sound_EnableAmbience = 0,
	Sound_EnableSoundWhenGameIsInBG = 1,
	Sound_EnableReverb = 1, -- (default)
	Sound_EnablePositionalLowPassFilter = 1, -- (default)
	Sound_EnableEncounterWarningsSounds = 1, -- (default)
	VoiceOutputVolume = 0,
	VoiceInputVolume = 0,
	VoiceCommunicationMode = 0, -- (default)
}

local UVARS = { -- unexposed (hidden) settings
	ActionButtonUseKeyDown = 1,
	screenshotFormat = 'png',
	screenshotQuality = 10,
	scriptErrors = 1,
	taintLog = IsTestBuild() and 11 or 2, -- TODO: new stuff coming in 12.0.1?
	minimapTrackingShowAll = 1, -- to get the full minimap tracking menu back
	AutoPushSpellToActionBar = 0,
	calendarShowResets = 0,
	raidOptionIsShown = 0,
	autoUnshift = 1,
	alwaysCompareItems = 0,
	cameraDistanceMaxZoomFactor = 2.6,
	rawMouseEnable = 1,
}

function addon:OnLogin()
	for key, value in next, CVARS do
		C_CVar.SetCVar(key, value)
	end

	for key, value in next, UVARS do
		C_CVar.SetCVar(key, value)
	end

	if UnitLevel('player') < GetMaxLevelForPlayerExpansion() then
		-- this is kinda nice while leveling
		C_CVar.SetCVar('AutoPushSpellToActionBar', 1)
	end

	return true
end
