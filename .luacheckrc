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
	-- FrameXML objects we mutate (taint city)
	'ChatTypeInfo',
	'StaticPopupDialogs',

	-- globals we expose
	'GetMinimapShape',

	-- savedvariables
	'InomenaPlayed',
}

read_globals = {
	-- stdlib
	string = {
		fields = {
			'split',
		},
	},

	-- FrameXML frames and widgets
	'BuffFrame',
	'CalendarFrame',
	'ChatFrame1EditBox',
	'ChatFrame1EditBoxHeader',
	'CooldownViewerSettings',
	'CreateFrame',
	'DressUpFrame',
	'EventToastManagerFrame',
	'GameTooltip',
	'HybridMinimap',
	'MainActionBar',
	'Minimap',
	'MinimapCluster',
	'SendMailMailButton',
	'SendMailMoneyCopper',
	'SendMailMoneyGold',
	'SendMailMoneySilver',
	'SendMailNameEditBox',
	'SendMailSubjectEditBox',
	'UIErrorsFrame',
	'UIParent',
	'WeeklyRewardsFrame',
	'WorldMapFrame',
	'WorldMapFrameTitleText',

	-- FrameXML constants
	'COPPER_PER_GOLD',
	'COPPER_PER_SILVER',
	'DEFAULT_CHAT_FRAME',
	'FACTION_BAR_COLORS',
	'NUM_ACTIONBAR_BUTTONS',
	'NUM_CHAT_WINDOWS',
	'PAPERDOLL_STATCATEGORIES',
	'SILVER_PER_GOLD',

	-- FrameXML mixins
	'DressUpCustomSetDetailsSlotMixin',
	'MinimapMixin',

	-- FrameXML misc objects
	'ChatTypeInfo',
	'CVarCallbackRegistry',
	'PowerBarColor',
	'SlashCmdList',
	'CHAT_FRAMES',
	'INVENTORY_ALERT_STATUS_SLOTS',
	'SELECTED_CHAT_FRAME',

	-- FrameXML utils
	'AnchorUtil',
	'ChatFrameUtil',

	-- FrameXML functions
	'CreateAtlasMarkup',
	'CreateColor',
	'FormatLargeNumber',
	'GameTooltip_Hide',
	'GenerateClosure',
	'HideUIPanel',
	'RegisterAttributeDriver',
	'RegisterStateDriver',
	'ShowUIPanel',
	'WrapTextInColorCode',
	'nop',

	-- SharedXML constants
	'SOUNDKIT',

	-- GlobalStrings
	'DASH_WITH_TEXT',
	'ERR_MAIL_INVALID_ATTACHMENT_SLOT',
	'EVENT_TOAST_EXPANDED_DESCRIPTION',
	'HAVE_MAIL',
	'MINIMAP_TRACKING_MAILBOX',
	'MINIMAP_TRACKING_REPAIR',
	'MONEY',
	'PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME',
	'TIME_DAYHOURMINUTESECOND',
	'UNAVAILABLE',
	'UNKNOWN',
	'WEEKLY_REWARDS_COMPLETED_ENCOUNTER',

	-- namespaces
	'C_AddOns',
	'C_ClassColor',
	'C_CraftingOrders',
	'C_CurveUtil',
	'C_DateAndTime',
	'C_DurationUtil',
	'C_GossipInfo',
	'C_Item',
	'C_Map',
	'C_MerchantFrame',
	'C_Minimap',
	'C_MountJournal',
	'C_QuestLog',
	'C_Spell',
	'C_SpellBook',
	'C_UI',
	'C_UnitAuras',
	'Enum',

	-- API
	'AbbreviateNumbers',
	'CanEjectPassengerFromSeat',
	'CanGuildBankRepair',
	'CanMerchantRepair',
	'ConfirmLootSlot',
	'EjectPassengerFromSeat',
	'GetAchievementInfo',
	'GetBattlefieldStatus',
	'GetClassInfo',
	'GetGuildBankMoney',
	'GetInstanceInfo',
	'GetInventoryAlertStatus',
	'GetInventoryItemTexture',
	'GetLatestThreeSenders',
	'GetMoney',
	'GetNumClasses',
	'GetNumGroupMembers',
	'GetPhysicalScreenSize',
	'GetRaidRosterInfo',
	'GetRealmName',
	'GetRepairAllCost',
	'GetServerTime',
	'GetSpecializationInfoForClassID',
	'GetTime',
	'GetWeaponEnchantInfo',
	'HasFullControl',
	'HasNewMail',
	'InCombatLockdown',
	'IsControlKeyDown',
	'IsGUIDInGroup',
	'IsInRaid',
	'IsShiftKeyDown',
	'Mixin',
	'PlaySound',
	'RepairAllItems',
	'RequestTimePlayed',
	'TaxiRequestEarlyLanding',
	'UnitClass',
	'UnitClassBase',
	'UnitCreatureID',
	'UnitExists',
	'UnitFactionGroup',
	'UnitGroupRolesAssigned',
	'UnitGUID',
	'UnitInVehicle',
	'UnitIsUnit',
	'UnitName',
	'UnitOnTaxi',
	'UnitTokenFromGUID',
	'UnitVehicleSeatCount',
	'hooksecurefunc',

	-- exposed from other addons
	'LibStub',
}
