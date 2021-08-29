local _, addon = ...

-- summon a mailbox by clicking the mail icon on the minimap
local TOYS = {
	[40768] = true, -- MOLL-E
	[156833] = true, -- Katy's Stampwhistle
}

local function getCooldownRemaining(start, duration)
	return start > 0 and start - GetTime() + duration
end

local mail = addon:CreateButton('MailButton', MiniMapMailFrame, 'SecureActionButtonTemplate')
mail:SetAllPoints()
mail:SetAttribute('type', 'macro')
mail:SetScript('PreClick', function(self)
	if InCombatLockdown() then
		return
	end

	for itemID in next, TOYS do
		if not getCooldownRemaining(GetItemCooldown(itemID)) and C_ToyBox.IsToyUsable(itemID) then
			self:SetAttribute('macrotext', '/cast item:' .. itemID)
			return
		end
	end

	if IsSpellKnown(255661) and not getCooldownRemaining(GetSpellCooldown(255661)) then
		-- Nightborne, use Cantrips
		self:SetAttribute('macrotext', '/cast ' .. (GetSpellInfo(255661)))
		return
	end

	if C_Covenants.GetActiveCovenantID() == 1 and C_QuestLog.IsQuestFlaggedCompleted(62970) and not getCooldownRemaining(GetSpellCooldown(324739)) then
		-- personal
		-- Kyrian, summon steward
		self:SetAttribute('macrotext', '/cast ' .. (GetSpellInfo(324739)))
		return
	end

	if select(13, GetAchievementInfo(3736)) then
		-- personal
		-- Argent Pony Bridle, summon Argent Squire/Gruntling
		local petName
		local faction = UnitFactionGroup('player')
		for index = 1, C_PetJournal.GetNumPets() do
			local petID, _, owned, customName  = C_PetJournal.GetPetInfoByIndex(index)
			if petID == 214 and faction == 'Alliance' then
				if owned then
					petName = customName or GetSpellInfo(62609)
				end
				break
			elseif petID == 216 and faction == 'Horde' then
				if owned then
					petName = customName or GetSpellInfo(62746)
				end
				break
			end
		end

		if petName then
			-- TODO: can we get the cooldown on accessing mailbox without summoning?
			self:SetAttribute('macrotext', '/summonpet ' .. petName)
			return
		end
	end
end)

mail:SetScript('PostClick', function(self)
	if InCombatLockdown() then
		return
	end

	self:SetAttribute('macrotext', nil)
end)

mail:SetScript('OnEnter', function(self)
	self:GetParent():GetScript('OnEnter')(self)

	GameTooltip:AddLine(' ')
	GameTooltip:AddLine('Click to summon a mailbox', 1, 1, 1)
	GameTooltip:Show()
end)

mail:SetScript('OnLeave', function(self)
	self:GetParent():GetScript('OnLeave')(self)
end)
