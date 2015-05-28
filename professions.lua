local _, Inomena = ...

-- Enchanting vellum button
do
	Inomena.RegisterEvent('ADDON_LOADED', function(addon)
		if(addon ~= 'Blizzard_TradeSkillUI' or InCombatLockdown()) then return end

		if(IsSpellKnown(13262)) then
			local button = CreateFrame('Button', 'TradeSkillVellumButton', TradeSkillCreateButton, 'SecureActionButtonTemplate, MagicButtonTemplate')
			button:SetPoint('TOPRIGHT', TradeSkillCreateButton, 'TOPLEFT')
			button:SetSize(80, 22)
			button:SetText((GetSpellInfo(162250)))
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

-- Cooking and Anvil buttons
do
	local button
	Inomena.RegisterEvent('TRADE_SKILL_SHOW', function()
		if(not InCombatLockdown() and not button) then
			button = CreateFrame('Button', 'TradeSkillExtraButton', TradeSkillFrame, 'SecureActionButtonTemplate')
			button:SetPoint('RIGHT', TradeSkillFrameCloseButton, 'LEFT', -235, 0)
			button:SetSize(20, 20)
			button:Hide()
		end
	end)

	Inomena.RegisterEvent('CURRENT_SPELL_CAST_CHANGED', function()
		if(not InCombatLockdown() and TradeSkillFrame and TradeSkillFrame:IsShown()) then
			if(IsTradeSkillGuild() or IsTradeSkillLinked()) then
				button:Hide()
				return
			end

			local skillLine = GetTradeSkillLine()
			if(skillLine == PROFESSIONS_COOKING) then
				local name, _, texture = GetSpellInfo(818)
				button:SetNormalTexture(texture)
				button:SetAttribute('type', 'spell')
				button:SetAttribute('spell', name)
				button:Show()

				return
			elseif(skillLine == (GetSpellInfo(59193)) or skillLine == (GetSpellInfo(88422)) or skillLine == (GetSpellInfo(61422))) then
				local count = GetItemCount(87216)
				if(count and count > 0) then
					local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(87216)
					button:SetNormalTexture(texture)
					button:SetAttribute('type', 'item')
					button:SetAttribute('item', name)
					button:Show()

					return
				end
			end

			button:Hide()
		end
	end)
end

-- Tabs
do
	local tabs = {}
	Inomena.RegisterEvent('TRADE_SKILL_SHOW', function()
		if(InCombatLockdown()) then
			return
		end

		if(#tabs == 0) then
			for index, id in next, {GetProfessions()} do
				if(id and index ~= 4) then -- ignore fishing
					local name, texture, rank, maxRank = GetProfessionInfo(id)
					local tab = CreateFrame('CheckButton', nil, TradeSkillFrame, 'SpellBookSkillLineTabTemplate, SecureActionButtonTemplate')
					tab:SetAttribute('type', 'spell')
					tab:SetAttribute('spell', name)
					tab:SetNormalTexture(texture)
					tab:SetID(index)
					tab.name = name
					tab.tooltip = string.format(ITEM_SET_NAME, name, rank, maxRank)

					if(#tabs == 0) then
						tab:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPRIGHT', 0, -36)
					else
						tab:SetPoint('TOPLEFT', tabs[#tabs], 'BOTTOMLEFT', 0, -17)
					end
					tab:Show()

					tabs[#tabs + 1] = tab
				end
			end
		end

		for index, tab in next, tabs do
			tab:SetChecked(IsCurrentSpell(tab.name))
			if(tab:GetID() ~= 3) then
				tab:SetButtonState(tab:GetChecked() and 'DISABLED' or 'NORMAL')
			end
		end
	end)
end
