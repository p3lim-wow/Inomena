local E, F, C = unpack(select(2, ...))

if(not C.isBetaClient) then
	return
end

local Button = CreateFrame('Button', (...) .. 'MountButton', nil, 'SecureActionButtonTemplate')
Button:SetAttribute('type', 'macro')

local summonMacro = [[
/cancelform [form]
/leavevehicle [canexitvehicle]
/dismount [mounted]
/run C_MountJournal.SummonByID(%s)
]]

local ownedMounts = {
	vendor = {},
	water = {},
}

local function Update()
	if(InCombatLockdown()) then
		return
	elseif(UnitOnTaxi('player')) then
		return TaxiRequestEarlyLanding()
	end

	local macro
	if(not select(13, GetAchievementInfo(891)) and ownedMounts.taxi) then
		macro = string.format(summonMacro, ownedMounts.taxi)
	elseif(IsAltKeyDown()) then
		macro = string.format(summonMacro, ownedMounts.vendor[math.random(#ownedMounts.vendor)])
	elseif(IsShiftKeyDown()) then
		macro = string.format(summonMacro, ownedMounts.water[math.random(#ownedMounts.water)])
	else
		macro = string.format(summonMacro, 0)
	end

	Button:SetAttribute('macrotext', macro)
end

local lastNumMounts = 0
local function UpdateMountsList(event)
	local collectedFlag = C_MountJournal.GetCollectedFilterSetting(1)
	local notCollectedFlag = C_MountJournal.GetCollectedFilterSetting(2)

	C_MountJournal.SetCollectedFilterSetting(1, true)
	C_MountJournal.SetCollectedFilterSetting(2, false)

	local numMounts = C_MountJournal.GetNumDisplayedMounts()

	C_MountJournal.SetCollectedFilterSetting(1, collectedFlag)
	C_MountJournal.SetCollectedFilterSetting(2, notCollectedFlag)

	if(numMounts == lastNumMounts) then
		return
	else
		lastNumMounts = numMounts
	end

	ownedMounts.taxi = nil
	table.wipe(ownedMounts.vendor)
	table.wipe(ownedMounts.water)

	for _, id in next, C_MountJournal.GetMountIDs() do
		local _, _, _, _, _, _, _, _, _, ineligible, owned = C_MountJournal.GetMountInfoByID(id)
		if(owned and not ineligible) then
			if(id == 280 or id == 284 or id == 460) then
				table.insert(ownedMounts.vendor, id)
			elseif(id == 449 or id == 488) then
				table.insert(ownedMounts.water, id)
			elseif(id == 678 or id == 679) then
				ownedMounts.taxi = id
			end
		end
	end
end

local bindingString = string.format('CLICK %s:LeftButton', Button:GetName())
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
E.PLAYER_LOGIN = UpdateMountsList
E.SPELLS_CHANGED = UpdateMountsList

Button:SetScript('PreClick', Update)
