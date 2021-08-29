local _, addon = ...

-- auto-hide the action bar unless certain conditions are met:
-- - not controlling the player (e.g. vehicle)
-- - mouse over

local conditions = '[petbattle][overridebar][vehicleui][possessbar] show; hide'

local parent = addon:CreateFrame('ActionBar', UIParent, 'SecureHandlerEnterLeaveTemplate, SecureHandlerAttributeTemplate')
parent:SetPoint('BOTTOM')
parent:SetSize(1000, 200)
parent:Hide()

parent:SetAttribute('_onattributechanged', [[
	if name == 'visibility' then
		if value == 'show' then
			self:Show()
		else
			self:Hide()
		end
	end
]])

parent:SetAttribute('_onleave', [[
	if self:GetAttribute('visibility') ~= 'show' then
		self:Hide()
	end
]])

RegisterAttributeDriver(parent, 'visibility', conditions)

-- also show the action bar if we hover over where it's supposed to be
local hover = addon:CreateFrame('ActionBarZone', UIParent, 'SecureHandlerEnterLeaveTemplate')
hover:SetPoint('BOTTOM')
hover:SetSize(900, 150)
hover:SetFrameRef('parent', parent)

hover:SetAttribute('_onenter', [[
	local parent = self:GetFrameRef('parent')
	if parent:IsUnderMouse() then
		parent:Show()
	end
]])

hover:SetAttribute('_onleave', [[
	local parent = self:GetFrameRef('parent')
	if not parent:IsUnderMouse() and parent:GetAttribute('visibility') ~= 'show' then
		parent:Hide()
	end
]])

MainMenuBar:SetParent(parent)

-- ensure the pet battle buttons are clickable
PetBattleFrame:SetFrameStrata('HIGH')

-- send the microbuttons off the screen to avoid the help popups
MicroButtonAndBagsBar:ClearAllPoints()
MicroButtonAndBagsBar:SetPoint('BOTTOMRIGHT', UIParent, 9999, 0)
