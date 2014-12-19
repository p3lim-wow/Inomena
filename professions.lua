local _, Inomena = ...

-- Enchanting vellum button
do
	Inomena.RegisterEvent('ADDON_LOADED', function(addon)
		if(addon ~= 'Blizzard_TradeSkillUI' or InCombatLockdown()) then return end

		if(IsSpellKnown(13262)) then
			local button = CreateFrame('Button', 'TradeSkillVellumButton', TradeSkillCreateButton, 'SecureActionButtonTemplate, MagicButtonTemplate')
			button:SetPoint('TOPRIGHT', TradeSkillCreateButton, 'TOPLEFT')
			button:SetSize(80, 22)
			button:SetText('Scroll')
			button:SetAttribute('type', 'macro')
			button:SetAttribute('macrotext', '/click TradeSkillCreateButton\n/use item:38682')

			local enchanting = GetSpellInfo(7411)
			hooksecurefunc('TradeSkillFrame_Update', function()
				if(InCombatLockdown()) then
					return
				end

				if(IsTradeSkillGuild() or IsTradeSkillLinked()) then
					button:Hide()
				elseif(CURRENT_TRADESKILL == enchanting) then
					local _, _, _, _, service = GetTradeSkillInfo(TradeSkillFrame.selectedSkill)
					if(service == ENSCRIBE) then
						button:Show()

						if(TradeSkillCreateButton:IsEnabled() and GetItemCount(38682) > 0) then
							button:Enable()
						else
							button:Disable()
						end
					else
						button:Hide()
					end
				else
					button:Hide()
				end
			end)
		end
	end)
end

-- Archaeology popup solve
do
	StaticPopupDialogs.ARCHAEOLOGY_SOLVE = {
		text = '%s',
		button1 = SOLVE,
		button2 = IGNORE,
		OnAccept = SolveArtifact,
		timeout = 0,
	}

	local fragment = {
		['384'] = 1, -- Dwarf
		['385'] = 8, -- Troll
		['393'] = 3, -- Fossil
		['394'] = 4, -- Night Elf
		['397'] = 6, -- Orc
		['398'] = 2, -- Draenei
		['399'] = 9, -- Vrykul
		['400'] = 5, -- Nerubian
		['401'] = 7, -- Tol'vir
	}

	local _CURRENCY = string.gsub(string.gsub(CURRENCY_GAINED_MULTIPLE, '%%s', '(.+)'), '%%d', '(.+)')

	Inomena.RegisterEvent('CHAT_MSG_CURRENCY', function(message)
		local link = string.match(message, _CURRENCY)
		if(not link) then return end
		local id = string.match(link, ':(%d+)|h')

		local race = fragment[id]
		if(race) then
			SetSelectedArtifact(race)

			local race, _, stone = GetArchaeologyRaceInfo(race)
			local artifact, _, rare, _, _, stones = GetSelectedArtifactInfo()

			for index = 1, math.min(stones, GetItemCount(stone)) do
				if(not ItemAddedToArtifact(index)) then
					SocketItemToArtifact()
				end
			end

			local fragments, stones, total = GetArtifactProgress()
			if(fragments + stones >= total) then
				local color
				if(rare and rare > 0) then
					color = '|cff0070dd'
				else
					color = '|cff9d9d9d'
				end

				StaticPopup_Show('ARCHAEOLOGY_SOLVE', string.format('%s %s: %s[%s]|r?', SOLVE, race, color, artifact))
			end
		end
	end)
end

-- Fishing auto-equip
do
	local hat
	local pole = select(17, GetAuctionItemSubClasses(1))

	Inomena.RegisterEvent('UNIT_INVENTORY_CHANGED', function(unit)
		if(unit ~= 'player') then return end

		local _, _, _, _, _, _, type = GetItemInfo(GetInventoryItemLink('player', 16) or 0)
		if(type == pole and not hat) then
			hat = GetInventoryItemLink('player', 1)

			if(GetItemCount(88710) and GetItemCount(88710) > 0) then
				EquipItemByName(88710)
			elseif(GetItemCount(33820) and GetItemCount(33820) > 0) then
				EquipItemByName(33820)
			elseif(GetItemCount(19972) and GetItemCount(19972) > 0) then
				EquipItemByName(19972)
			end
		elseif(type ~= pole and hat) then
			EquipItemByName(hat)
			hat = nil
		end
	end)
end

-- Cooking auto-equip and fire button
do
	local button, hat
	Inomena.RegisterEvent('TRADE_SKILL_SHOW', function()
		if(InCombatLockdown()) then
			return
		end

		if(not button) then
			button = CreateFrame('Button', 'FireButton', TradeSkillFrame, 'SecureActionButtonTemplate')
			button:SetPoint('RIGHT', TradeSkillFrameCloseButton, 'LEFT', -235, 0)
			button:SetSize(20, 20)

			local name, _, icon = GetSpellInfo(818)
			button:SetAttribute('type', 'spell')
			button:SetAttribute('spell', name)
			button:SetNormalTexture(icon)
		end

		if(IsTradeSkillGuild() or IsTradeSkillLinked()) then
			button:Hide()
		elseif(GetTradeSkillLine() == PROFESSIONS_COOKING) then
			button:Show()

			if(GetItemCount(46349) and GetItemCount(46349) > 0) then
				hat = GetInventoryItemLink('player', 1)
				EquipItemByName(46349)
			end
		else
			button:Hide()
		end
	end)

	Inomena.RegisterEvent('TRADE_SKILL_CLOSE', function()
		if(hat) then
			EquipItemByName(hat)
			hat = nil
		end
	end)

	Inomena.RegisterEvent('TRADE_SKILL_UPDATE', function()
		if(GetTradeSkillLine() ~= PROFESSIONS_COOKING) then
			if(hat) then
				EquipItemByName(hat)
				hat = nil
			end

			if(button and not InCombatLockdown()) then
				button:Hide()
			end
		end
	end)
end
