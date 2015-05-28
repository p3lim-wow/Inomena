local buttonName = (...) .. 'MountButton'
local bindingString = string.format('CLICK %s:LeftButton', buttonName)

local Button = CreateFrame('Button', buttonName, nil, 'SecureActionButtonTemplate')
Button:SetAttribute('type', 'macro')
Button:RegisterEvent('PLAYER_REGEN_ENABLED')
Button:RegisterEvent('PLAYER_REGEN_DISABLED')
Button:RegisterEvent('PLAYER_ENTERING_WORLD')
Button:RegisterEvent('UPDATE_BINDINGS')

Button:SetScript('OnEvent', function(self, event)
	if(event == 'PLAYER_ENTERING_WORLD' or event == 'UPDATE_BINDINGS') then
		ClearOverrideBindings(self)

		local first, second = GetBindingKey('DISMOUNT')
		if(first) then
			SetOverrideBinding(self, false, first, bindingString)
		end

		if(second) then
			SetOverrideBinding(self, false, second, bindingString)
		end
	else
		self:Update()
	end
end)

local DISMOUNT = [[
/cancelform
/leavevehicle
/dismount
]]

local function HasCorralOutpost()
	if(HasDraenorZoneAbility()) then
		local ability = GetSpellInfo(161691)
		local _, _, _, _, _, _, spellID = GetSpellInfo(ability)
		if(spellID == 164222 or spellID == 165803) then
			return ability
		end
	end
end

function Button:Update()
	if(InCombatLockdown()) then
		return
	elseif(UnitOnTaxi('player')) then
		return TaxiRequestEarlyLanding()
	end

	local macro
	if(IsAltKeyDown()) then
		macro = '/cast Traveler\'s Tundra Mammoth'
	elseif(IsShiftKeyDown()) then
		macro = '/cast Azure Water Strider'
	else
		local spellName = HasCorralOutpost()
		if(spellName) then
			macro = '/cast ' .. spellName
		else
			macro = '/run C_MountJournal.Summon(0)'
		end
	end

	if(SecureCmdOptionParse('[nomod:shift]')) then
		macro = strtrim(strjoin('\n', DISMOUNT, macro))
	end

	self:SetAttribute('macrotext', macro)
end

Button:SetScript('PreClick', Button.Update)
