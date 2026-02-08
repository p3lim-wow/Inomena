local _, addon = ...

-- smart fishing - temporarily rebind the interact key, and emphasize relevant sound channels

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
	[131476] = true, -- cast spell (duplicate? where is this used?)
	[131490] = true, -- channel spell
	[295727] = true, -- Compressed Ocean Fishing (just for the sounds)
	[377895] = true, -- Ice Fishing (best used with interact key, which also opens the hole)
	[405274] = true, -- Zskera cauldron fishing (best used with interact key)
	[463743] = true, -- Fishing during the anniversary secret
}

local handler = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate, SecureHandlerAttributeTemplate')

-- reset override bindings if entering combat
handler:SetAttribute('_onattributechanged', [[
	if name == 'state-combat' and value == 'clear' then
		self:ClearBindings()
	end
]])

local storedCVars = {}
local function restoreCVars()
	for name, value in next, storedCVars do
		C_CVar.SetCVar(name, value)
	end
end

local function fishingStop(_, _, _, spellID)
	if FISHING_SPELLS[spellID] then
		-- restore cvars to their previous values
		restoreCVars()

		-- clear bindings
		addon:Defer('ClearOverrideBindings', handler)
		addon:Defer('UnregisterStateDriver', handler, 'combat')

		-- unregister ourselves
		addon:UnregisterEvent('PLAYER_LOGOUT', restoreCVars)
		return true
	end
end

local activeFishingSpell
addon:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', 'player', function(_, _, _, spellID)
	if FISHING_SPELLS[spellID] then
		-- iterate through CVars we want to change
		for name, value in next, CVARS do
			-- store the original values
			storedCVars[name] = C_CVar.GetCVar(name)

			-- set our values
			C_CVar.SetCVar(name, value)
		end

		if activeFishingSpell then
			-- set override bindings
			for _, barName in next, ActionButtonUtil.ActionBarButtonNames do
				for index = 1, NUM_ACTIONBAR_BUTTONS do
					local button = _G[barName .. index]
					local _, actionID = GetActionInfo(button.action)
					if actionID == activeFishingSpell then
						local key1, key2 = GetBindingKey(button.bindingAction)
						if key1 then
							SetOverrideBinding(handler, true, key1, 'INTERACTTARGET')
						end
						if key2 then
							SetOverrideBinding(handler, true, key2, 'INTERACTTARGET')
						end
					end
				end
			end

			-- register state driver to reset the binding when player enters combat
			RegisterStateDriver(handler, 'combat', '[combat] clear; nothing')
		end

		-- wait for fishing to end
		addon:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', 'player', fishingStop)

		-- make sure we restore cvars before the player logs out
		addon:RegisterEvent('PLAYER_LOGOUT', restoreCVars)
	end
end)

function addon:UNIT_SPELLCAST_SENT(unit, _, _, spellID)
	-- BUG: this event is not a valid unit event for some reason, otherwise I'd use RUE
	if unit == 'player' and FISHING_SPELLS[spellID] then
		-- this event triggers before UNIT_SPELLCAST_CHANNEL_START and holds the actual spell
		-- used to start fishing, so we'll store it and wait for that event to trigger
		activeFishingSpell = spellID
	end
end
