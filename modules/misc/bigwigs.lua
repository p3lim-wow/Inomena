local E, F, C = unpack(select(2, ...))
-- basically just a cleaner version of the MonoUI style that comes with BigWigs,
-- with scaling hard-disabled in favor for manual widget sizing

local plugin
local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = {
	bgFile = TEXTURE, edgeFile = TEXTURE, edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local defaultFont, defaultFontSize = GameFontHighlightSmallOutline:GetFont()
local defaultFontOffsetX, defaultFontOffsetY = GameFontHighlightSmallOutline:GetShadowOffset()

local function ApplyStyle(Bar)
	Bar:SetHeight(10)
	Bar:SetScale(1)

	local Background = Bar.candyBarBackdrop
	Background:ClearAllPoints()
	Background:SetPoint('TOPLEFT', -1, 1)
	Background:SetPoint('BOTTOMRIGHT', 1, -1)
	Background:SetBackdrop(BACKDROP)
	Background:SetBackdropColor(0.1, 0.1, 0.1)
	Background:SetBackdropBorderColor(0, 0, 0)
	Background:Show()

	local Label = Bar.candyBarLabel
	Label:ClearAllPoints()
	Label:SetPoint('BOTTOMLEFT', Bar, 'TOPLEFT', 2, 2)
	Label:SetPoint('BOTTOMRIGHT', Bar, 'TOPRIGHT', -2, 2)
	Label:SetShadowOffset(0, 0)

	local Duration = Bar.candyBarDuration
	Duration:ClearAllPoints()
	Duration:SetPoint('BOTTOMLEFT', Bar, 'TOPLEFT', 2, 2)
	Duration:SetPoint('BOTTOMRIGHT', Bar, 'TOPRIGHT', -2, 2)
	Duration:SetShadowOffset(0, 0)

	if(plugin.db.profile.icon) then
		local Icon = Bar.candyBarIconFrame
		local texture = Icon.icon
		Bar:SetIcon(nil)

		Icon:ClearAllPoints()
		Icon:SetPoint('BOTTOMRIGHT', Bar, 'BOTTOMLEFT', -5, 0)
		Icon:SetSize(24, 24)
		Icon:SetTexture(texture)

		Bar:Set('bigwigs:restoreicon', texture)

		local IconBackground = Bar.candyBarIconFrameBackdrop
		IconBackground:ClearAllPoints()
		IconBackground:SetPoint('TOPLEFT', Icon, -1, 1)
		IconBackground:SetPoint('BOTTOMRIGHT', Icon, 1, -1)
		IconBackground:SetBackdrop(BACKDROP)
		IconBackground:SetBackdropColor(0.1, 0.1, 0.1)
		IconBackground:SetBackdropBorderColor(0, 0, 0)
		IconBackground:Show()
	end
end

local function RemoveStyle(Bar)
	Bar.candyBarBackdrop:Hide()

	local Label = Bar.candyBarLabel
	Label:ClearAllPoints()
	Label:SetPoint('TOPLEFT', 2, 0)
	Label:SetPoint('BOTTOMRIGHT', -2, 0)
	Label:SetFont(defaultFont, defaultFontSize)
	Label:SetShadowOffset(defaultFontOffsetX, defaultFontOffsetY)

	local Duration = Bar.candyBarDuration
	Duration:ClearAllPoints()
	Duration:SetPoint('TOPLEFT', 2, 0)
	Duration:SetPoint('BOTTOMRIGHT', -2, 0)
	Duration:SetFont(defaultFont, defaultFontSize)
	Duration:SetShadowOffset(defaultFontOffsetX, defaultFontOffsetY)

	local texture = Bar:Get('bigwigs:restoreicon')
	if(texture) then
		local Icon = Bar.candyBarIconFrame
		Icon:ClearAllPoints()
		Icon:SetPoint('TOPLEFT')
		Icon:SetPoint('BOTTOMLEFT')

		Bar:SetIcon(texture)
		Bar.candyBarIconFrameBackdrop:Hide()
	end
end

local function Emphasize(_, _, Bar)
	Bar:SetHeight(14)
	Bar:SetScale(1)

	local fontSize = math.floor(plugin.db.profile.fontSize * 1.5)
	local font, _, flags = Bar.candyBarLabel:GetFont()
	Bar.candyBarLabel:SetFont(font, fontSize, flags)
	Bar.candyBarDuration:SetFont(font, fontSize, flags)
	Bar.candyBarIconFrame:SetSize(32, 32)
end

local function RegisterStyle()
	if(not BigWigs) then
		return
	end

	plugin = BigWigs:GetPlugin('Bars', true)
	if(not plugin) then
		return
	end

	plugin:RegisterBarStyle('Inomena', {
		apiVersion = 1,
		version = 1,
		ApplyStyle = ApplyStyle,
		BarStopped = RemoveStyle,
		GetSpacing = function()
			return 20
		end,
		GetStyleName = function()
			return 'Inomena'
		end,
	})

	plugin:RegisterMessage('BigWigs_BarEmphasized', Emphasize)
end

function E:ADDON_LOADED(addon)
	local reason = select(6, GetAddOnInfo('BigWigs_Plugins'))
	if((reason == 'MISSING' and addon == 'BigWigs') or addon == 'BigWigs_Plugins') then
		RegisterStyle()
		return true
	end
end

function E:PLAYER_LOGIN()
	RegisterStyle()
	return true
end
