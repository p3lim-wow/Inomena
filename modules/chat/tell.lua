hooksecurefunc('ChatEdit_OnSpacePressed', function(self)
	if(string.sub(self:GetText(), 1, 3) == '/tt' and (UnitCanCooperate('player', 'target') or UnitIsUnit('player', 'target'))) then
		ChatFrame_SendTell(GetUnitName('target', true):gsub(' ', ''))
	end
end)

SLASH_TELLTARGET1 = '/tt'
SlashCmdList.TELLTARGET = function(str)
	if(UnitCanCooperate('player', 'target')) then
		SendChatMessage(str, 'WHISPER', GetDefaultLanguage('player'), GetUnitName('target', true):gsub(' ', ''))
	end
end
