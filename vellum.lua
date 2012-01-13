local _, Inomena = ...

Inomena.RegisterEvent('ADDON_LOADED', function(addon)
	if(addon ~= 'Blizzard_TradeSkillUI') then return end

	if(IsSpellKnown(13262)) then
		local button = CreateFrame('Button', nil, TradeSkillCreateButton, 'MagicButtonTemplate')
		button:SetPoint('TOPRIGHT', TradeSkillCreateButton, 'TOPLEFT')
		button:SetSize(80, 22)
		button:SetText('Scroll')
		button:Hide()

		button:SetScript('OnClick', function()
			DoTradeSkill(TradeSkillFrame.selectedSkill)
			UseItemByName(38682)
		end)

		local enchanting = GetSpellInfo(7411)
		hooksecurefunc('TradeSkillFrame_Update', function()
			if(IsTradeSkillGuild() or IsTradeSkillLinked()) then
				button:Hide()
			elseif(CURRENT_TRADESKILL == enchanting) then
				local _, _, _, _, type = GetTradeSkillInfo(TradeSkillFrame.selectedSkill)
				if(type == ENSCRIBE and GetItemCount(38682)) then
					button:Show()

					if(TradeSkillCreateButton:IsEnabled()) then
						button:Enable()
					else
						button:Disable()
					end
				else
					button:Hide()
				end
			end
		end)
	end
end)
