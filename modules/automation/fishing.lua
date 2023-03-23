local _, addon = ...

-- while fishing the button bound to the fishing spell will be rebound to interact with the bobber,
-- and sounds are toggled to listen to the bobber while fishing

local CVARS = {
	Sound_EnableSFX = 1,
	Sound_MasterVolume = 1,
	Sound_MusicVolume = 0,
	Sound_AmbienceVolume = 0,
	Sound_SFXVolume = 1,
	SoftTargetInteract = 3, -- enables interacting with the fishing bobber
	SoftTargetInteractArc = 2, -- widens interact arc
	SoftTargetInteractRange = 30, -- increases interact range
	SoftTargetIconInteract = 1, -- show interact icons
	SoftTargetIconGameObject = 1, -- show interact icon specifically for objects, like the bobber
}

local FISHING_SPELLS = {
	[131474] = true, -- cast spell
	[131476] = true, -- cast spell
	[131490] = true, -- channel spell
	[405274] = true, -- Zskera fishing
}

-- our state and attribute handler
local handler = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate, SecureHandlerAttributeTemplate')

-- reset override bindings if entering combat
handler:SetAttribute('_onattributechanged', [[
	if name == 'state-combat' and value == 'clear' then
		self:ClearBindings()
	end
]])

local getSpellBinding
do
	local function findSpellButton(spellID)
		local slotBindings = {}

		-- use existing utilities to iterate through all action buttons to find the spell
		local button = ActionButtonUtil.GetActionButtonBySpellID(spellID)
		if button then
			local slot = button.action
			local actionType, actionID = GetActionInfo(slot)
			if (actionType == 'spell' and actionID == spellID) or (actionType == 'macro' and GetMacroSpell(actionID) == spellID) then
				-- found a button, let's find the binding
				local bindingName
				local index = ((slot % 12) == 0 and 12 or (slot % 12))
				if not button.buttonType or button.buttonType == 'ACTIONBUTTON' then
					-- handle pages and forms
					local page
					if HasBonusActionBar() and GetActionBarPage() == 1 then
						page = GetBonusBarIndex()
					else
						page = GetActionBarPage()
					end

					if ((page * 12) - 12 + index) == slot then
						bindingName = 'ACTIONBUTTON' .. index
					end
				else
					bindingName = button.buttonType .. index
				end

				table.insert(slotBindings, bindingName)
			end
		end

		return slotBindings
	end

	function getSpellBinding(spellID)
		for _, binding in next, findSpellButton(spellID) do
			local key1, key2 = GetBindingKey(binding)
			if key1 or key2 then
				return key1, key2
			end
		end
	end
end

local origCVars = {}
local activeFishingSpell

local function restoreCVars()
	for name, value in next, origCVars do
		C_CVar.SetCVar(name, value)
	end
end

local function fishingStop(_, _, _, spellID)
	if FISHING_SPELLS[spellID] then
		-- restore cvars to their previous values
		restoreCVars()

		-- clear bindings
		addon:Defer(ClearOverrideBindings, handler)
		addon:Defer(UnregisterStateDriver, handler, 'combat')

		-- unregister ourselves
		addon:UnregisterEvent('PLAYER_LOGOUT', restoreCVars)
		return true
	end
end

local function fishingStart(_, _, _, spellID)
	if FISHING_SPELLS[spellID] then
		-- iterate through the CVars we want to change
		for name, value in next, CVARS do
			-- store the original values
			origCVars[name] = C_CVar.GetCVar(name)

			-- set our values
			C_CVar.SetCVar(name, value)
		end

		if activeFishingSpell then
			-- rebind the fishing spell hotkey
			local key1, key2 = getSpellBinding(activeFishingSpell)
			if key1 then
				SetOverrideBinding(handler, true, key1, 'INTERACTTARGET')
			end
			if key2 then
				SetOverrideBinding(handler, true, key2, 'INTERACTTARGET')
			end

			-- register state driver to reset the binding when player enters combat
			RegisterStateDriver(handler, 'combat', '[combat] clear; nothing')
		end

		-- wait for fishing to end
		addon:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', 'player', fishingStop)
		addon:RegisterEvent('PLAYER_LOGOUT', restoreCVars)
	end
end

function addon:UNIT_SPELLCAST_SENT(unit, _, _, spellID)
	-- BUG: this event is not a valid unit event for whatever reason
	if unit == 'player' and FISHING_SPELLS[spellID] then
		-- this event triggers before UNIT_SPELLCAST_CHANNEL_START and holds the actual spell
		-- used to start fishing, so we'll store it and wait for that even to trigger
		activeFishingSpell = spellID
	end
end

-- some fishing starts by interacting with objects, and as such has no USS event trigger,
-- we need to listen to USCS all the time
addon:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', 'player', fishingStart)
