local _, Inomena = ...

Inomena.RegisterEvent('ADDON_LOADED', function(addon)
	if(addon ~= 'Blizzard_TradeSkillUI') then return end

	if(IsSpellKnown(13262)) then
		local button = CreateFrame('Button', 'TradeSkillVellumButton', TradeSkillCreateButton, 'MagicButtonTemplate')
		button:SetPoint('TOPRIGHT', TradeSkillCreateButton, 'TOPLEFT')
		button:SetSize(80, 22)
		button:SetText('Scroll')
		button:SetScript('OnClick', function()
			DoTradeSkill(TradeSkillFrame.selectedSkill)
			UseItemByName(38682)
		end)

		local enchanting = GetSpellInfo(7411)
		hooksecurefunc('TradeSkillFrame_Update', function()
			if(IsTradeSkillGuild() or IsTradeSkillLinked()) then
				button:Hide()
			elseif(CURRENT_TRADESKILL == enchanting) then
				local _, _, _, _, service = GetTradeSkillInfo(TradeSkillFrame.selectedSkill)
				if(service == ENSCRIBE) then
					button:Show()

					if(TradeSkillCreateButton:IsEnabled() and GetItemCount(38682)) then
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
