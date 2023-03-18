local _, addon = ...

local function updateChecked(self)
	self:SetChecked(ClickBindingFrame and ClickBindingFrame:IsShown() and ClickBindingFrame:GetFocusedFrame() == self:GetParent())
end

local tabs = {}
local function createTab(parent)
	local icon = parent:CreateTexture()
	icon:SetAtlas('clickcast-icon-mouse')

	local tab = addon:CreateButton('CheckButton', nil, parent, 'SpellBookSkillLineTabTemplate, SecureActionButtonTemplate')
	tab:SetPoint('BOTTOMLEFT', parent, 'BOTTOMRIGHT', 0, 36)
	tab:SetNormalTexture(icon)
	tab:SetMotionScriptsWhileDisabled(true)
	tab:HookScript('OnClick', ToggleClickBindingFrame)
	tab:HookScript('OnClick', updateChecked)
	tab:HookScript('OnShow', updateChecked)
	tab.name = CLICK_CAST_BINDINGS
	tab.tooltip = CLICK_CAST_BINDINGS
	tab:Show()

	table.insert(tabs, tab)
	return tab
end

createTab(SpellBookFrame):HookScript('OnClick', function()
	ClickBindingFrame:SetFocusedFrame(SpellBookFrame)
end)

addon:HookAddOn('Blizzard_MacroUI', function()
	createTab(MacroFrame):HookScript('OnClick', function()
		ClickBindingFrame:SetFocusedFrame(MacroFrame)
	end)
end)

addon:HookAddOn('Blizzard_ClickBindingUI', function()
	-- override clearing to prevent frames being hidden
	function ClickBindingFrame:ClearFocusedFrame()
		self.focusedFrame = nil

		-- remove highlights in spellbook
		if SpellBookFrame:IsShown() then
			SpellBookFrame_UpdateSpells()
		end

		-- enable macro editing if active
		if MacroFrame and MacroFrame:IsShown() then
			MacroFrame:Update()
		end
	end

	-- update checked button
	ClickBindingFrame:HookScript('OnHide', function()
		for _, tab in next, tabs do
			updateChecked(tab)
		end
	end)
end)
