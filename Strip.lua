local function onClick()
	-- todo
end

local nekkid = CreateFrame('Button', nil, PaperDollFrame, 'UIPanelButtonTemplate')
nekkid:SetPoint('TOP', CharacterTrinket1Slot, 'BOTTOM', 0, -5)
nekkid:SetHeight(27)
nekkid:SetWidth(36)
nekkid:SetNormalTexture([=[Interface\Buttons\UI-Panel-Button-Disabled]=])
nekkid:SetScript('OnClick', onClick)

local undress = CreateFrame('Button', nil, DressUpFrame, 'UIPanelButtonTemplate')
undress:SetPoint('RIGHT', DressUpFrameResetButton, 'LEFT')
undress:SetHeight(22)
undress:SetWidth(80)
undress:SetText('Undress')
undress:SetScript('OnClick', function() DressUpModel:Undress() end)
