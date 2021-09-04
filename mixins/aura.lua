local _, addon = ...

local MAX_DISPLAY_DURATION = 90

local function onEnter(self)
	if GameTooltip:GetOwner() ~= self then
		return
	end

	-- replace remaining time text with something more accurate
	for index = 1, GameTooltip:NumLines() do
		local line = _G['GameTooltipTextLeft' .. index]
		if line:GetText():match('remaining$') then -- TODO: multi-locale support
			line:SetFormattedText('%s remaining', addon:FormatShortTime(self.expiration))
			break
		end
	end

	-- force the game to re-render the tooltip
	GameTooltip:Show()
end

local math_max = math.max
local function onUpdate(self, elapsed)
	if self.expiration then
		self.expiration = math_max(self.expiration - elapsed, 0)

		if self.expiration > 0 and self.expiration <= MAX_DISPLAY_DURATION then
			self.duration:SetFormattedText('%d', self.expiration)
		else
			self.duration:SetText()
		end
	end
end

function addon:CreateAura(button)
	if not button then
		-- TODO
		return
	end

	Mixin(button, addon.mixins.backdrop, addon.mixins.widget)

	button:CreateBackdrop()
	button:HookScript('OnEnter', onEnter)
	button:HookScript('OnLeave', GameTooltip_Hide)
	button:HookScript('OnUpdate', onUpdate)

	if not button.icon then
		local icon = button:CreateIcon()
		button.icon = icon
	else
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.icon:SetDrawLayer('ARTWORK')
	end

	if not button.duration then
		local duration = button:CreateText()
		button.duration = duration
	else
		button.duration:SetParent(button:CreateTextParent())
		button.duration:ClearAllPoints()
		button.duration:SetFontObject(addon.FONT)
	end
	button.duration:SetPoint('TOPLEFT', button, 0, -1)

	if not button.count then
		local count = button:CreateText()
		button.count = count
	else
		button.count:SetParent(button:CreateTextParent())
		button.count:ClearAllPoints()
		button.duration:SetFontObject(addon.FONT)
	end
	button.count:SetPoint('BOTTOMRIGHT', button, -1, 1)

	return button
end
