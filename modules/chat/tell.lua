hooksecurefunc('ChatEdit_OnSpacePressed', function(self)
	if(string.sub(self:GetText(), 1, 3) == '/tt' and (UnitCanCooperate('player', 'target') or UnitIsUnit('player', 'target'))) then
		self:SetText(SLASH_SMART_WHISPER1 .. ' ' .. GetUnitName('target', true):gsub(' ', '') .. ' ')
		ChatEdit_ParseText(self, 0)
	end
end)

SLASH_TELLTARGET1 = '/tt'
SlashCmdList.TELLTARGET = function(str)
	if(UnitCanCooperate('player', 'target')) then
		SendChatMessage(str, 'WHISPER', GetDefaultLanguage('player'), GetUnitName('target', true):gsub(' ', ''))
	end
end
