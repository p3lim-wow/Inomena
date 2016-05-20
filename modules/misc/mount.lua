local E, F, C = unpack(select(2, ...))

local buttonName = (...) .. 'MountButton'
local bindingString = string.format('CLICK %s:LeftButton', buttonName)

local DISMOUNT = [[
/stopcasting
/cancelform
/leavevehicle
/dismount
]]

local Button = CreateFrame('Button', buttonName, nil, 'SecureActionButtonTemplate')
Button:SetAttribute('type', 'macro')

local function HasCorralOutpost()
	if((C.isBetaClient and HasZoneAbility or HasDraenorZoneAbility)() and not IsFlyableArea()) then
		local ability = GetSpellInfo(161691)
		local _, _, _, _, _, _, spellID = GetSpellInfo(ability)
		if(spellID == 164222 or spellID == 165803) then
			return ability
		end
	end
end

local function Update()
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
	elseif(IsControlKeyDown()) then
		-- This one is very specific to what mounts I own
		macro = '/cast [flyable] Sandstone Drake; Mechano-Hog'
	else
		local spellName = HasCorralOutpost()
		if(spellName) then
			macro = '/cast ' .. spellName
		else
			if(C.isBetaClient) then
				macro = '/run C_MountJournal.SummonByID(0)'
			else
				macro = '/run C_MountJournal.Summon(0)'
			end
		end
	end

	if(SecureCmdOptionParse('[nomod:shift]')) then
		macro = strtrim(strjoin('\n', DISMOUNT, macro))
	end

	Button:SetAttribute('macrotext', macro)
end

local function UpdateFavorites(event, newLevel)
	local taughtRiding = IsSpellKnown(33388)

	if(C.isBetaClient) then
		for index, id in next, C_MountJournal.GetMountIDs() do
			local _, spellID, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(id)
			if(spellID == 179244 and collected) then
				C_MountJournal.SetIsFavorite(index, not taughtRiding)
				break
			end
		end
	else
		for index = 1, C_MountJournal.GetNumMounts() do
			local _, spellID, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfo(index)
			if(specificellID == 179244 and collected) then
				C_MountJournal.SetIsFavorite(index, not taughtRiding)
				break
			end
		end
	end

	if(taughtRiding) then
		return true
	end
end

local function SetBindings()
	ClearOverrideBindings(Button)

	local first, second = GetBindingKey('DISMOUNT')
	if(first) then
		SetOverrideBinding(Button, false, first, bindingString)
	end

	if(second) then
		SetOverrideBinding(Button, false, second, bindingString)
	end
end

E.UPDATE_BINDINGS = SetBindings
E.PLAYER_ENTERING_WORLD = SetBindings
E.PLAYER_REGEN_DISABLED = Update
E.PLAYER_REGEN_ENABLED = Update
E.PLAYER_LOGIN = UpdateFavorites
E.SPELLS_CHANGED = UpdateFavorites

Button:SetScript('PreClick', Update)
