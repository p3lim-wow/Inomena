local addonName, addon = ...

local mail = addon:CreateButton('Button', addonName .. 'MailButton', Minimap, 'SecureActionButtonTemplate')
mail:SetPoint('TOPLEFT', 5, -5)
mail:SetSize(30, 30)
mail:SetAttribute('type', 'macro')

local icon = mail:CreateTexture('$parentIcon', 'OVERLAY')
icon:SetPoint('CENTER')
icon:SetAtlas('mailbox', true)
icon:SetScale(0.7)

-- show icon if there is pending mail
function addon:UPDATE_PENDING_MAIL()
	icon:SetAlpha(HasNewMail() and 1 or 0)
end

-- create an API for summonable mailboxes
local MAILBOX_SUMMON = {
	{'toy', 40768}, -- MOLL-E
	{'toy', 156833}, -- Katy's Stampwhistle
	{'toy', 194885}, -- Ohuna Perch
	{'spell', 255661}, -- Cantrips (Nightborne racial)
}

local function getCooldownRemaining(start, duration)
	return start > 0 and start - GetTime() + duration
end

local function getMailboxSummon()
	for _, info in next, MAILBOX_SUMMON do
		if info[1] == 'toy' then
			if C_ToyBox.IsToyUsable(info[2]) and not getCooldownRemaining(GetItemCooldown(info[2])) then
				return info[1], info[2]
			end
		elseif info[1] == 'spell' then
			if IsSpellKnown(info[2]) and not getCooldownRemaining(GetSpellCooldown(info[2])) then
				return info[1], info[2]
			end
		end
	end
end

-- summon mailbox on click
mail:SetScript('PreClick', function(self)
	if InCombatLockdown() then
		-- can't modify attributes in combat
		return
	end

	local kind, id = getMailboxSummon()
	if not kind then
		-- no mailbox summon available
		return
	end

	if kind == 'toy' then
		self:SetAttribute('macrotext', '/cast item:' .. id)
	elseif kind == 'spell' then
		self:SetAttribute('macrotext', '/cast ' .. (GetSpellInfo(id)))
	end
end)

-- add tooltip
mail:SetScript('OnLeave', GameTooltip_Hide)
mail:SetScript('OnEnter', function(self)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')

	local hasMail = HasNewMail()
	if hasMail then
		-- add sender names if there are any
		local sender1, sender2, sender3 = GetLatestThreeSenders()
		if sender1 then
			-- we have atleast one sender, set appropriate header line
			GameTooltip:AddLine(HAVE_MAIL_FROM)
			GameTooltip:AddLine(sender1)
		else
			-- we have mail, but don't know who from, set generic header line
			GameTooltip:AddLine(HAVE_MAIL)
		end
		if sender2 then
			GameTooltip:AddLine(sender2)
		end
		if sender3 then
			GameTooltip:AddLine(sender3)
		end
	end

	if getMailboxSummon() then
		if hasMail then
			GameTooltip:AddLine(' ')
		end

		GameTooltip:AddLine('Click to summon a mailbox', 1, 1, 1)
	end

	GameTooltip:Show()
end)
