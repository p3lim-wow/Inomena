local addonName, addon = ...

addon.units = {}
addon.unitShared = {}
addon.unitPrefix = C_AddOns.GetAddOnMetadata(addonName, 'X-oUF')

function addon.unitShared.ShowTooltip(self)
	if GameTooltip:IsForbidden() then
		return
	end

	GameTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	GameTooltip:SetPoint('BOTTOMRIGHT', GameTooltipDefaultContainer)

	if GameTooltip:SetUnit(self.__unit) then
		GameTooltip:Show()
	end
end

function addon.unitShared.HideTooltip(self)
	GameTooltip:Hide()
end

do
	local MACRO_ASSIST = '/cast [@%s,exists,help,%s] %s'
	local CLASS_ASSIST_SPELLS = {
		SHAMAN = 974, -- Earth Shield
		PRIEST = 10060, -- Power Infusion
		PALADIN = 85673, -- Word of Glory (TBD Lay on Hands instead?)
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
		if addon:IsRetail() and addon.CLASS_HARMFUL_DISPEL_SPELLS[addon.PLAYER_CLASS] then
			-- this is really hard to do in Forever since there are different spells for each dispel
			-- type, need to see if we can find a good solution to that
			for spellID in next, addon.CLASS_HARMFUL_DISPEL_SPELLS[addon.PLAYER_CLASS] do
				if C_SpellBook.IsSpellInSpellBook(spellID) then
					macroTexts:insert('/cast [@mouseover,exists,help,nodead] ' .. C_Spell.GetSpellName(spellID))
					break -- can only do one with the same condition set
				end
			end
		end

		local resurrectSpellID = addon.CLASS_RESURRECT_SPELLS[addon.PLAYER_CLASS]
		if resurrectSpellID then
			local bestSpellID
			if type(resurrectSpellID) == 'table' then
				-- pick the highest rank
				for _, spellID in ipairs(resurrectSpellID) do
					if C_SpellBook.IsSpellInSpellBook(spellID) then
						bestSpellID = spellID
						break
					end
				end
			elseif C_SpellBook.IsSpellInSpellBook(resurrectSpellID) then
				bestSpellID = resurrectSpellID
			end

			if bestSpellID then
				macroTexts:insert('/cast [@mouseover,exists,help,dead,nocombat] ' .. C_Spell.GetSpellName(bestSpellID))
			end
		end

		local resurrectCombatSpellID = addon.CLASS_RESURRECT_COMBAT_SPELLS[addon.PLAYER_CLASS]
		if resurrectCombatSpellID then
			local bestSpellID
			if type(resurrectCombatSpellID) == 'table' then
				-- pick the highest rank
				for _, spellID in ipairs(resurrectCombatSpellID) do
					if C_SpellBook.IsSpellInSpellBook(spellID) then
						bestSpellID = spellID
						break
					end
				end
			elseif C_SpellBook.IsSpellInSpellBook(resurrectCombatSpellID) then
				bestSpellID = resurrectCombatSpellID
			end

			if bestSpellID then
				macroTexts:insert('/cast [@mouseover,exists,help,dead,combat] ' .. C_Spell.GetSpellName(bestSpellID))
			end
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
