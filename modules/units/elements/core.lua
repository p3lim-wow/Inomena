local addonName, addon = ...

addon.units = {}
addon.unitShared = {}
addon.unitPrefix = C_AddOns.GetAddOnMetadata(addonName, 'X-oUF')

function addon.unitShared.Tooltip(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)

	if GameTooltip:SetUnit(self.unit) then
		GameTooltip:Show()
	end
end

do
	local MACRO_ASSIST = '/cast [@%s,exists,help,%s] %s'
	local CLASS_ASSIST_SPELLS = {
		SHAMAN = 974, -- Earth Shield
		PRIEST = 10060, -- Power Infusion
		DRUID = {
			combat = 29166, -- Innervate
			nocombat = 474750, -- Symbiotic Relationship
		},
	}

	function addon.unitShared.AddShiftClick(self, unit)
		local data = CLASS_ASSIST_SPELLS[addon.PLAYER_CLASS]
		if data then
			if type(data) == 'number' then
				-- direct assign spell to shift-click
				addon:DeferMethod(self, 'SetAttribute', 'shift-type1', 'spell')
				addon:DeferMethod(self, 'SetAttribute', 'shift-spell1', data)
			else
				-- condition required for the spellID
				local macroTexts = addon:T()
				for condition, spellID in next, data do
					macroTexts:insert(MACRO_ASSIST:format(unit, condition, C_Spell.GetSpellName(spellID)))
				end

				addon:DeferMethod(self, 'SetAttribute', 'shift-type1', 'macro')
				addon:DeferMethod(self, 'SetAttribute', 'shift-macrotext1', macroTexts:concat('\n'))
			end
		end
	end
end

do
	local JUMPER_CABLES_ITEM_ID = 221954 -- Convincingly Realistic Jumper Cables @ The War Within

	local function updateMiddleClick(self)
		local macroTexts = addon:T()
		if addon.CLASS_DISPEL_SPELLS[addon.PLAYER_CLASS] then
			for _, spellID in next, addon.CLASS_DISPEL_SPELLS[addon.PLAYER_CLASS] do
				if C_SpellBook.IsSpellInSpellBook(spellID) then
					macroTexts:insert('/cast [@mouseover,exists,help,nodead] ' .. C_Spell.GetSpellName(spellID))
					break -- can only do one with the same condition set
				end
			end
		end

		local resurrectSpellID = addon.CLASS_RESURRECT_SPELLS[addon.PLAYER_CLASS]
		if resurrectSpellID and C_SpellBook.IsSpellInSpellBook(resurrectSpellID) then
			macroTexts:insert('/cast [@mouseover,exists,help,dead,nocombat] ' .. C_Spell.GetSpellName(resurrectSpellID))
		end

		local resurrectCombatSpellID = addon.CLASS_RESURRECT_COMBAT_SPELLS[addon.PLAYER_CLASS]
		if resurrectCombatSpellID and C_SpellBook.IsSpellInSpellBook(resurrectCombatSpellID) then
			macroTexts:insert('/cast [@mouseover,exists,help,dead,combat] ' .. C_Spell.GetSpellName(resurrectCombatSpellID))
		elseif JUMPER_CABLES_ITEM_ID then
			macroTexts:insert('/use [@mouseover,exists,help,dead,combat] item:' .. JUMPER_CABLES_ITEM_ID)
		end

		local macroText
		if #macroTexts > 0 then
			macroTexts:insert(1, '/stopcasting')

			macroText = macroTexts:concat('\n')
			if macroText:len() > 255 then
				error('middle click macro too long')
				macroText = nil
			end
		end

		addon:DeferMethod(self, 'SetAttribute', '*type3', 'macro')
		addon:DeferMethod(self, 'SetAttribute', 'macrotext3', macroText or '')
	end

	function addon.unitShared.AddMiddleClick(self)
		updateMiddleClick(self)

		-- we also need to update this when spells change
		addon:RegisterEvent('SPELLS_CHANGED', function()
			updateMiddleClick(self)
		end)
	end
end
