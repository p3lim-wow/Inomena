local E = unpack(select(2, ...))

function E:PLAYER_LOGIN()
	if(not LibStub) then
		return
	end

	local LDB = LibStub('LibDataBroker-1.1')
	if(not LDB) then
		return
	end

	local data = LDB:GetDataObjectByName('BugSack')
	if(data) then
		local Button = CreateFrame('Button', nil, Minimap)
		Button:SetPoint('BOTTOMRIGHT', -5, 5)
		Button:SetSize(20, 20)
		Button:SetScript('OnClick', data.OnClick)
		Button:SetScript('OnLeave', GameTooltip_Hide)
		Button:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
			GameTooltip:SetClampedToScreen(true)
			pcall(data.OnTooltipShow, GameTooltip)
			GameTooltip:Show()
		end)

		if(not string.find(data.icon, 'red')) then
			Button:SetAlpha(0)
		end

		local Icon = Button:CreateTexture(nil, 'OVERLAY')
		Icon:SetTexture([[Interface\CharacterFrame\UI-Player-PlayTimeUnhealthy]])
		Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		Icon:SetAllPoints()

		LDB.RegisterCallback(Button, 'LibDataBroker_AttributeChanged_BugSack', function()
			if(string.find(data.icon, 'red')) then
				Button:SetAlpha(1)
			else
				Button:SetAlpha(0)
			end
		end)
	end
end
