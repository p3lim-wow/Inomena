local addonName, addon = ...

local LEMO = LibStub and LibStub('LibEditModeOverride-1.0', true)
if not LEMO then
	return
end

local SETTINGS = {
	MainActionBar = { -- Action Bar 1
		anchor = {'BOTTOM', UIParent, 0, 15},
		settings = {
			[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
			[Enum.EditModeActionBarSetting.NumRows] = 1,
			[Enum.EditModeActionBarSetting.NumIcons] = 12,
			[Enum.EditModeActionBarSetting.IconSize] = 80,
			[Enum.EditModeActionBarSetting.IconPadding] = 2,
			[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 0,
			[Enum.EditModeActionBarSetting.HideBarArt] = 1,
			[Enum.EditModeActionBarSetting.HideBarScrolling] = 1,
		},
	},
	MultiBarBottomLeft = { -- Action Bar 2
		anchor = {'BOTTOM', MainActionBar, 'TOP', 0, 2},
		settings = {
			[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
			[Enum.EditModeActionBarSetting.NumRows] = 1,
			[Enum.EditModeActionBarSetting.NumIcons] = 12,
			[Enum.EditModeActionBarSetting.IconSize] = 80,
			[Enum.EditModeActionBarSetting.IconPadding] = 2,
			[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 0,
		},
	},
	MultiBarBottomRight = { -- Action Bar 3
		anchor = {'BOTTOM', MultiBarBottomLeft, 'TOP', 0, 1.5}, -- Y offset weirdness
		settings = {
			[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
			[Enum.EditModeActionBarSetting.NumRows] = 1,
			[Enum.EditModeActionBarSetting.NumIcons] = 12,
			[Enum.EditModeActionBarSetting.IconSize] = 80,
			[Enum.EditModeActionBarSetting.IconPadding] = 2,
			[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 0,
		},
	},
	MultiBarRight = { -- Action Bar 4
		-- TODO: change Y to -10 if we get totem support in CDM
		anchor = {'TOPRIGHT', Minimap, 'BOTTOMRIGHT', 1, -30}, -- account for border on X offset
		settings = {
			[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Vertical,
			[Enum.EditModeActionBarSetting.NumRows] = 1,
			[Enum.EditModeActionBarSetting.NumIcons] = 12,
			[Enum.EditModeActionBarSetting.IconSize] = 80,
			[Enum.EditModeActionBarSetting.IconPadding] = 2,
			[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 0,
		},
	},
	MultiBarLeft = { -- Action Bar 5
		anchor = {'RIGHT', MultiBarRight, 'LEFT', -2, 0},
		settings = {
			[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Vertical,
			[Enum.EditModeActionBarSetting.NumRows] = 1,
			[Enum.EditModeActionBarSetting.NumIcons] = 12,
			[Enum.EditModeActionBarSetting.IconSize] = 80,
			[Enum.EditModeActionBarSetting.IconPadding] = 2,
			[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 0,
		},
	},
	MultiBar7 = { -- Action Bar 8
		anchor = {'TOPLEFT', UIParent},
		settings = {
			[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
			[Enum.EditModeActionBarSetting.NumRows] = 1,
			[Enum.EditModeActionBarSetting.NumIcons] = 12,
			[Enum.EditModeActionBarSetting.IconSize] = 50,
			[Enum.EditModeActionBarSetting.IconPadding] = 2,
			[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Hidden,
			[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 0,
		},
	},
	PetActionBar = {
		anchor = {'BOTTOMLEFT', MultiBarBottomRight, 'TOPLEFT', 1, 2.5}, -- account for border on X offset, Y offset weirdness
		settings = {
			[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
			[Enum.EditModeActionBarSetting.NumRows] = 1,
			[Enum.EditModeActionBarSetting.NumIcons] = 12,
			[Enum.EditModeActionBarSetting.IconSize] = 80,
			[Enum.EditModeActionBarSetting.IconPadding] = 2,
			[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 0,
		},
	},
	ExtraAbilityContainer = {
		anchor = {'BOTTOMRIGHT', UIParent, 'BOTTOM', -230, 160},
	},
	PossessActionBar = {
		anchor = {'BOTTOMLEFT', MainActionBar, 'BOTTOMRIGHT', 30, 0},
	},
	MinimapCluster = {
		-- we manipulate anchor in modules/blizzard/minimap.lua instead
		settings = {
			[Enum.EditModeMinimapSetting.HeaderUnderneath] = 1,
			[Enum.EditModeMinimapSetting.RotateMinimap] = 0,
			[Enum.EditModeMinimapSetting.Size] = 100,
			[Enum.EditModeMinimapSetting.IconScale] = 100,
		},
	},
	MicroMenuContainer = {
		-- we hide this but reanchor the LFG eye
		settings = {
			[Enum.EditModeMicroMenuSetting.EyeSize] = 70,
		},
	},
	ChatFrame1 = {
		anchor = {'BOTTOMLEFT', UIParent},
		settings = {
			[Enum.EditModeChatFrameSetting.WidthHundreds] = 5,
			[Enum.EditModeChatFrameSetting.WidthTensAndOnes] = 1,
			[Enum.EditModeChatFrameSetting.HeightHundreds] = 2,
			[Enum.EditModeChatFrameSetting.HeightTensAndOnes] = 46,
		},
	},
	ObjectiveTrackerFrame = {
		anchor = {'TOPLEFT', UIParent, 35, -15}, -- weird X offset
		settings = {
			[Enum.EditModeObjectiveTrackerSetting.Height] = 800,
			[Enum.EditModeObjectiveTrackerSetting.Opacity] = 0,
			[Enum.EditModeObjectiveTrackerSetting.TextSize] = 12,
		},
	},
	MainStatusTrackingBarContainer = {
		anchor = {'TOP', UIParent},
		settings = {
			[Enum.EditModeStatusTrackingBarSetting.Size] = 80,
		},
	},
	SecondaryStatusTrackingBarContainer = {
		anchor = {'TOP', UIParent, 0, -10},
		settings = {
			[Enum.EditModeStatusTrackingBarSetting.Size] = 80,
		}
	},
	LootFrame = {
		anchor = {'TOPLEFT', UIParent, 400, -300},
	},
	GameTooltipDefaultContainer = {
		anchor = {'BOTTOMRIGHT', UIParent, -330, 15},
	},
	EssentialCooldownViewer = {
		anchor = {'BOTTOM', UIParent, 0, 380},
		settings = {
			[Enum.EditModeCooldownViewerSetting.Orientation] = Enum.CooldownViewerOrientation.Horizontal,
			[Enum.EditModeCooldownViewerSetting.IconLimit] = 20,
			[Enum.EditModeCooldownViewerSetting.IconDirection] = Enum.CooldownViewerIconDirection.Right,
			[Enum.EditModeCooldownViewerSetting.IconSize] = 80,
			[Enum.EditModeCooldownViewerSetting.IconPadding] = 9,
			[Enum.EditModeCooldownViewerSetting.Opacity] = 100,
			[Enum.EditModeCooldownViewerSetting.VisibleSetting] = Enum.CooldownViewerVisibleSetting.InCombat,
			[Enum.EditModeCooldownViewerSetting.ShowTimer] = 0,
			[Enum.EditModeCooldownViewerSetting.ShowTooltips] = 0,
		},
	},
	BuffIconCooldownViewer = {
		anchor = {'BOTTOM', UIParent, 0, 425}, -- can't set this relative to EssentialCooldownViewer
		settings = {
			[Enum.EditModeCooldownViewerSetting.Orientation] = Enum.CooldownViewerOrientation.Horizontal,
			[Enum.EditModeCooldownViewerSetting.IconDirection] = Enum.CooldownViewerIconDirection.Right,
			[Enum.EditModeCooldownViewerSetting.IconSize] = 80,
			[Enum.EditModeCooldownViewerSetting.IconPadding] = 9,
			[Enum.EditModeCooldownViewerSetting.Opacity] = 100,
			[Enum.EditModeCooldownViewerSetting.VisibleSetting] = Enum.CooldownViewerVisibleSetting.Always,
			[Enum.EditModeCooldownViewerSetting.HideWhenInactive] = 1,
			[Enum.EditModeCooldownViewerSetting.ShowTimer] = 0,
			[Enum.EditModeCooldownViewerSetting.ShowTooltips] = 0,
		},
	},
	UtilityCooldownViewer = {
		anchor = {'BOTTOM', UIParent, 0, 290},
		settings = {
			[Enum.EditModeCooldownViewerSetting.Orientation] = Enum.CooldownViewerOrientation.Horizontal,
			[Enum.EditModeCooldownViewerSetting.IconLimit] = 20,
			[Enum.EditModeCooldownViewerSetting.IconDirection] = Enum.CooldownViewerIconDirection.Right,
			[Enum.EditModeCooldownViewerSetting.IconSize] = 90,
			[Enum.EditModeCooldownViewerSetting.IconPadding] = 9,
			[Enum.EditModeCooldownViewerSetting.Opacity] = 100,
			[Enum.EditModeCooldownViewerSetting.VisibleSetting] = Enum.CooldownViewerVisibleSetting.Always,
			[Enum.EditModeCooldownViewerSetting.ShowTimer] = 0,
			[Enum.EditModeCooldownViewerSetting.ShowTooltips] = 0,
		},
	},
}

function addon:OnLogin()
	LEMO:LoadLayouts()

	if not LEMO:DoesLayoutExist(addonName) then
		LEMO:AddLayout(Enum.EditModeLayoutType.Account, addonName)
	elseif LEMO:GetActiveLayout() ~= addonName then
		LEMO:SetActiveLayout(addonName)
	end

	for frame, info in next, SETTINGS do
		if info.anchor then
			LEMO:ReanchorFrame(_G[frame], unpack(info.anchor))
		end

		if info.settings then
			for setting, value in next, info.settings do
				LEMO:SetFrameSetting(_G[frame], setting, value)
			end
		end
	end

	LEMO:ApplyChanges()
end
