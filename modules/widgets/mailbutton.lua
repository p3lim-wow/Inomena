local _, addon = ...

-- summon a mailbox by clicking the mail icon on the minimap
local TOYS = {
	[40768] = true, -- MOLL-E
	[156833] = true, -- Katy's Stampwhistle
}

local function getCooldownRemaining(start, duration)
	return start > 0 and start - GetTime() + duration
end

local function getMailboxToy()
	for itemID in next, TOYS do
		if not getCooldownRemaining(GetItemCooldown(itemID)) and C_ToyBox.IsToyUsable(itemID) then
			return itemID
		end
	end
end

local mail = addon:CreateButton('MailButton', Minimap, 'SecureActionButtonTemplate')
mail:SetPoint('TOPLEFT')
mail:SetSize(33, 33)
mail:SetAttribute('type', 'macro')
MiniMapMailFrame:UnregisterAllEvents()

local icon = mail:CreateTexture(nil, 'OVERLAY')
icon:SetPoint('CENTER')
icon:SetAtlas('mailbox', true)
icon:SetScale(0.6)

mail:RegisterEvent('UPDATE_PENDING_MAIL', function()
	icon:SetAlpha(HasNewMail() and 1 or 0)
end)

mail:SetScript('PreClick', function(self)
	if InCombatLockdown() then
		return
	end

	local itemID = getMailboxToy()
	if not itemID then
		return
	end
	self:SetAttribute('macrotext', '/cast item:' .. itemID)

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
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')

	local sender1, sender2, sender3 = GetLatestThreeSenders()
	if sender1 then
		GameTooltip:AddLine(HAVE_MAIL_FROM)
		GameTooltip:AddLine(sender1)
	elseif HasNewMail() then
		GameTooltip:AddLine(HAVE_MAIL)
	else
		GameTooltip:AddLine(MINIMAP_TRACKING_MAILBOX)
	end

	if sender2 then
		GameTooltip:AddLine(sender2)
	end
	if sender3 then
		GameTooltip:AddLine(sender3)
	end

	if getMailboxToy() then
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine('Click to summon a mailbox', 1, 1, 1)
	end

	GameTooltip:Show()
end)

mail:SetScript('OnLeave', GameTooltip_Hide)
