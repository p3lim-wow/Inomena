local _, addon = ...

local paste = Mixin(addon:CreateFrame('Paste', UIParent, 'BackdropTemplate'), addon.mixins.backdrop)
paste:SetPoint('CENTER')
paste:SetSize(600, 400)
paste:Hide()
paste:CreateBackdrop()

local editbox = Mixin(CreateFrame('EditBox', nil, paste, 'BackdropTemplate'), addon.mixins.backdrop)
editbox:SetPoint('TOPLEFT', 5, -5)
editbox:SetPoint('BOTTOMRIGHT', -5, 30)
editbox:SetFontObject(ChatFontNormal)
editbox:SetMultiLine(true)
editbox:SetAutoFocus(true)
editbox:CreateBackdrop()
editbox:SetScript('OnEscapePressed', function()
	editbox:SetFocus(false)
	paste:Hide()
end)

local submit = CreateFrame('Button', nil, paste, 'UIPanelButtonTemplate')
submit:SetPoint('BOTTOM', -25, 5)
submit:SetSize(50, 20)
submit:SetText('Paste')
submit:SetScript('OnClick', function()
	for _, line in ipairs({strsplit('\n', editbox:GetText())}) do
		ChatFrame_OpenChat('')
		local editBox = ChatEdit_GetActiveWindow()
		editBox:SetText(line)
		ChatEdit_SendText(editBox, 1)
		ChatEdit_DeactivateChat(editBox)
	end

	editbox:SetText('')
	paste:Hide()
end)

local close = CreateFrame('Button', nil, paste, 'UIPanelButtonTemplate')
close:SetPoint('BOTTOM', 25, 5)
close:SetSize(50, 20)
close:SetText('Close')
close:SetScript('OnClick', function()
	paste:Hide()
end)

addon:RegisterSlash('/paste', function()
	paste:SetShown(not paste:IsShown())
end)
