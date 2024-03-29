std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'212/event', -- unused argument event
	'212/unit', -- unused argument unit
	'212/element', -- unused argument element
	'312/event', -- unused value of argument event
	'312/unit', -- unused value of argument unit
	'431', -- shadowing an upvalue
	'631', -- line is too long
}

exclude_files = {}

globals = {
	-- FrameXML objects we mutate
	'BuffFrame', -- FrameXML/BuffFrame.xml
	'ChatTypeInfo', -- FrameXML/ChatFrame.lua
	'ClickBindingFrame', -- AddOns/Blizzard_ClickBindingUI/Blizzard_ClickBindingUI.xml
	'DurabilityFrame', -- FrameXML/DurabilityFrame.xml
	'LootFrame', -- FrameXML/LootFrame.xml
	'StaticPopupDialogs', -- FrameXML/StaticPopup.lua
	'SuperTrackedFrame', -- AddOns/Blizzard_QuestNavigation/SuperTrackedFrame.xml
	'SpellbookMicroButton', -- FrameXML/MainMenuBarMicroButtons.xml

	-- savedvariables we mutate
	'OPie_SavedData',
}

read_globals = {
	string = {fields = {'split', 'trim', 'join'}},
	table = {fields = {'wipe'}},

	-- FrameXML objects
	'ActionButtonUtil', -- FrameXML/ActionButtonUtil.lua
	'CompactRaidFrameManager', -- AddOns/Blizzard_CompactRaidFrames/Blizzard_CompactRaidFrameManager.xml
	'ContainerFrame1MoneyFrame', -- FrameXML/ContainerFrame.xml
	'DressUpFrame', -- FrameXML/DressUpFrames.xml
	'DressUpFrameResetButton', -- FrameXML/DressUpFrames.xml
	'DressUpOutfitDetailsSlotMixin', -- FrameXML/DressUpFrames.lua
	'ExpansionLandingPage', -- AddOns/Blizzard_ExpansionLandingPage/Blizzard_ExpansionLandingPage.xml
	'ExpansionLandingPageMinimapButton', -- FrameXML/Minimap.xml
	'GameTooltip', -- FrameXML/GameTooltip.xml
	'GenericTraitFrame', -- AddOns/Blizzard_GenericTraitUI/Blizzard_GenericTraitFrame.xml
	'GenericTraitFrameMixin', -- AddOns/Blizzard_GenericTraitUI/Blizzard_GenericTraitFrame.lua
	'HelpTip', -- SharedXML/HelpTip.lua
	'HybridMinimap', -- AddOns/Blizzard_HybridMinimap/Blizzard_HybridMinimap.xml
	'ItemLocation', -- FrameXML/ObjectAPI/ItemLocation.lua
	'MacroFrame', -- AddOns/Blizzard_MacroUI/Blizzard_MacroUI.xml
	'MerchantFrame', -- FrameXML/MerchantFrame.xml
	'Minimap', -- FrameXML/Minimap.xml
	'MinimapMixin', -- FrameXML/Minimap.lua
	'PaperDollSidebarTab3', -- FrameXML/PaperDollFrame.xml
	'PaperDollSidebarTabs', -- FrameXML/PaperDollFrame.xml
	'PetCastingBarFrame', -- FrameXML/PetFrame.xml
	'PlayerCastingBarFrame', -- FrameXML/CastingBarFrame.xml
	'ProfessionsFrame', -- AddOns/Blizzard_Professions/Blizzard_ProfessionsFrame.xml
	'QueueStatusButton', -- FrameXML/QueueStatusFrame.xml
	'ReadyCheckListenerFrame', -- FrameXML/ReadyCheck.xml
	'SendMailMailButton', -- FrameXML/MailFrame.xml
	'SendMailMoneyCopper', -- inherited from FrameXML/MoneyInputFrame.xml
	'SendMailMoneyGold', -- inherited from FrameXML/MoneyInputFrame.xml
	'SendMailMoneySilver', -- inherited from FrameXML/MoneyInputFrame.xml
	'SendMailNameEditBox', -- FrameXML/MailFrame.xml
	'SendMailSubjectEditBox', -- FrameXML/MailFrame.xml
	'SlashCmdList', -- FrameXML/ChatFrame.lua
	'SpellBookFrame', -- FrameXML/SpellBookFrame.xml
	'SpellBookFrameTabButton1', -- FrameXML/SpellBookFrame.xml
	'UIErrorsFrame', -- FrameXML/UIErrorsFrame.xml
	'UiMapPoint', -- FrameXML/ObjectAPI/UiMapPoint.lua
	'UIParent', -- FrameXML/UIParent.xml
	'WeeklyRewardsFrame', -- AddOns/Blizzard_WeeklyRewards/Blizzard_WeeklyRewards.xml
	'WorldFrame', -- FrameXML/WorldFrame.xml
	'WorldMapFrame', -- AddOns/Blizzard_WorldMap/Blizzard_WorldMap.xml
	'WorldMapFrameTitleText', -- inherited from SharedXML/SharedUIPanelTemplates.xml

	-- FrameXML functions
	'AreaLabelDataProviderMixin', -- AddOns/Blizzard_SharedMapDataProviders/AreaLabelDataProvider.lua
	'AuraUtil', -- FrameXML/AuraUtil.lua
	'ChatEdit_ParseText', -- FrameXML/ChatFrame.lua
	'ChatFrame_AddChannel', -- FrameXML/ChatFrame.lua
	'ChatFrame_AddMessageEventFilter', -- FrameXML/ChatFrame.lua
	'ChatFrame_AddMessageGroup', -- FrameXML/ChatFrame.lua
	'ChatFrame_ReceiveAllPrivateMessages', -- FrameXML/ChatFrame.lua
	'ChatFrame_RemoveAllChannels', -- FrameXML/ChatFrame.lua
	'ChatFrame_RemoveAllMessageGroups', -- FrameXML/ChatFrame.lua
	'ChatFrame_TimeBreakDown', -- FrameXML/ChatFrame.lua
	'FCF_Close', -- FrameXML/FloatingChatFrame.lua
	'FCF_OpenNewWindow', -- FrameXML/FloatingChatFrame.lua
	'FCF_ResetChatWindows', -- FrameXML/FloatingChatFrame.lua
	'FCF_SelectDockFrame', -- FrameXML/FloatingChatFrame.lua
	'FCF_SetWindowAlpha', -- FrameXML/FloatingChatFrame.lua
	'FCF_SetWindowColor', -- FrameXML/FloatingChatFrame.lua
	'GameTooltip_Hide', -- FrameXML/GameTooltip.lua
	'GetUnitName', -- FrameXML/UnitFrame.lua
	'HideUIPanel', -- FrameXML/UIParent.lua
	'IsSecureCmd', -- FrameXML/ChatFrame.lua
	'MapLinkDataProviderMixin', -- AddOns/Blizzard_SharedMapDataProviders/MapLinkDataProvider.lua
	'RegisterAttributeDriver', -- FrameXML/SecureStateDriver.lua
	'RegisterStateDriver', -- FrameXML/SecureStateDriver.lua
	'SecureHandlerWrapScript', -- FrameXML/SecureHandlers.lua
	'SpellBookFrame_UpdateSpells', -- FrameXML/SpellBookFrame.lua
	'SpellBookFrameTabButton_OnClick', -- FrameXML/SpellBookFrame.lua
	'StaticPopup_Hide', -- FrameXML/StaticPopup.lua
	'StaticPopup_IsCustomGenericConfirmationShown', -- FrameXML/StaticPopup.lua
	'StaticPopup_Visible', -- FrameXML/StaticPopup.lua
	'ToggleCalendar', -- FrameXML/UIParent.lua
	'ToggleClickBindingFrame', -- FrameXML/UIParent.lua
	'UnregisterStateDriver', -- FrameXML/SecureStateDriver.lua
	'WeeklyRewards_ShowUI', -- FrameXML/UIParent.lua
	'nop', -- FrameXML/UIParent.lua

	-- FrameXML mutable globals
	'SELECTED_CHAT_FRAME',

	-- SharedXML functions
	'CopyTable', -- SharedXML/TableUtil.lua
	'CreateColor', -- SharedXML/Color.lua
	'CreateRectangle', -- SharedXML/Rectangle.lua
	'CreateVector2D', -- SharedXML/Vector2D.lua
	'FormatLargeNumber', -- SharedXML/FormattingUtil.lua
	'Mixin', -- SharedXML/Mixin.lua
	'SecondsToTime', -- SharedXML/TimeUtil.lua
	'WrapTextInColorCode', -- SharedXML/Color.lua

	-- namespaces
	'C_AddOns',
	'C_BattleNet',
	'C_ChallengeMode',
	'C_ClassColor',
	'C_ClassTrial',
	'C_Container',
	'C_Covenants',
	'C_CraftingOrders',
	'C_CVar',
	'C_DateAndTime',
	'C_EditMode',
	'C_EquipmentSet',
	'C_FriendList',
	'C_Garrison',
	'C_GossipInfo',
	'C_Item',
	'C_Map',
	'C_MerchantFrame',
	'C_Minimap',
	'C_MountJournal',
	'C_Navigation',
	'C_PartyInfo',
	'C_PlayerInfo',
	'C_QuestLog',
	'C_Timer',
	'C_ToyBox',
	'C_UI',
	'C_VignetteInfo',
	'Constants',
	'Enum',
	'TooltipDataProcessor',

	-- API
	'AcceptGroup',
	'AutoEquipCursorItem',
	'BNGetNumFriends',
	'CanEjectPassengerFromSeat',
	'CanGuildBankRepair',
	'CanMerchantRepair',
	'CanWithdrawGuildBankMoney',
	'ChangeChatColor',
	'ClearCursor',
	'ClearOverrideBindings',
	'ConfirmBNRequestInviteFriend',
	'ConfirmLootRoll',
	'CreateFrame',
	'CursorHasItem',
	'EjectPassengerFromSeat',
	'EquipPendingItem',
	'GetAchievementInfo',
	'GetActionBarPage',
	'GetActionInfo',
	'GetAutoCompletePresenceID',
	'GetBattlefieldStatus',
	'GetBindingKey',
	'GetBonusBarIndex',
	'GetChannelName',
	'GetGuildBankMoney',
	'GetGuildBankWithdrawMoney',
	'GetGuildInfo',
	'GetGuildRosterInfo',
	'GetInventoryAlertStatus',
	'GetInventoryItemDurability',
	'GetInventoryItemID',
	'GetInventoryItemID',
	'GetItemCooldown',
	'GetItemCount',
	'GetItemInfo',
	'GetLatestThreeSenders',
	'GetMacroInfo',
	'GetMacroSpell',
	'GetMaxLevelForPlayerExpansion',
	'GetMoney',
	'GetNumGroupMembers',
	'GetNumGuildMembers',
	'GetPlayerInfoByGUID',
	'GetRaidRosterInfo',
	'GetRealmID',
	'GetRealmName',
	'GetRepairAllCost',
	'GetScreenHeight',
	'GetSpellCooldown',
	'GetSpellInfo',
	'GetSpellLink',
	'GetSpellTexture',
	'GetTime',
	'GetTotemCannotDismiss',
	'GetTotemInfo',
	'GetWeaponEnchantInfo',
	'HasBonusActionBar',
	'HasFullControl',
	'HasNewMail',
	'InCombatLockdown',
	'IsAddOnLoaded',
	'IsControlKeyDown',
	'IsInGroup',
	'IsInGuildGroup',
	'IsInInstance',
	'IsInRaid',
	'IsShiftKeyDown',
	'IsSpellKnown',
	'PickupBagFromSlot',
	'PickupInventoryItem',
	'PlaySound',
	'PlaySoundFile',
	'PutItemInBackpack',
	'PutItemInBag',
	'RepairAllItems',
	'RequestTimePlayed',
	'SendChatMessage',
	'SetBindingClick',
	'SetChatColorNameByClass',
	'SetOverrideBinding',
	'SetOverrideBindingClick',
	'TaxiRequestEarlyLanding',
	'UnitAura',
	'UnitBattlePetLevel',
	'UnitBattlePetType',
	'UnitCanCooperate',
	'UnitClass',
	'UnitClassBase',
	'UnitClassification',
	'UnitCreatureFamily',
	'UnitCreatureType',
	'UnitEffectiveLevel',
	'UnitExists',
	'UnitGroupRolesAssigned',
	'UnitInParty',
	'UnitInRaid',
	'UnitIsFeignDeath',
	'UnitIsFriend',
	'UnitIsInMyGuild',
	'UnitIsPlayer',
	'UnitIsTapDenied',
	'UnitIsUnit',
	'UnitLevel',
	'UnitName',
	'UnitOnTaxi',
	'UnitPlayerControlled',
	'UnitRace',
	'UnitReaction',
	'UnitTokenFromGUID',
	'UnitVehicleSeatCount',
	'hooksecurefunc',

	-- exposed from other addons
	'LibStub',
	'OPie',
	'TomTomPaste',

	-- ???
	'AddonTooltip',
}
