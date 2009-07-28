local orig = {}
local gsub = string.gsub

local function poof(obj)
	obj.Show = obj.Hide
	obj:Hide()
end

local function tellTarget(str)
	if(UnitIsPlayer('target') and UnitIsFriend('player', 'target')) then
		SendChatMessage(str, 'WHISPER', GetDefaultLanguage('player'), GetUnitName('target', 'true'):gsub('%s', '', 2))
	end
end

_G.CHAT_GUILD_GET = '|Hchannel:Guild|h(G)|h %s:\32'
_G.CHAT_OFFICER_GET = '|Hchannel:o|h(O)|h %s:\32'
_G.CHAT_PARTY_GET = '|Hchannel:Party|h(P)|h %s:\32'
_G.CHAT_RAID_GET = '|Hchannel:raid|h(R)|h %s:\32'
_G.CHAT_RAID_LEADER_GET = '|Hchannel:raid|h(|cff00ffffR|r)|h %s:\32'
_G.CHAT_RAID_WARNING_GET = '(W) %s:\32'
_G.CHAT_BATTLEGROUND_GET = '|Hchannel:Battleground|h(B)|h %s:\32'
_G.CHAT_BATTLEGROUND_LEADER_GET = '|Hchannel:Battleground|h(|cff00ffffB|r)|h %s:\32'
_G.CHAT_WHISPER_INFORM_GET = '(T) %s:\32'
_G.CHAT_WHISPER_GET = '%s:\32'
_G.CHAT_YELL_GET = '%s:\32'
_G.CHAT_SAY_GET = '%s:\32'

local function addMessage(self, str, ...)
	str = str:gsub('|Hchannel:(%d+)|h%[?(.-)%]?|h.+(|Hplayer.+)', '(%1)|h %3')

	return orig[self](self, str, ...)
end

local function onSpacePressed(self)
	local text = string.lower(self:GetText())
	if(string.sub(text, 1, 1) == '/' and string.match(text, '^/tt $')) then
		if(UnitIsPlayer('target') and UnitIsFriend('player', 'target')) then
			self:Hide()
			self:SetAttribute('chatType', 'WHISPER')
			self:SetAttribute('tellTarget', GetUnitName('target', 'true'):gsub('%s', '', 2))
			ChatFrame_OpenChat('')
		end
	end
end

local function onMouseWheel(self, dir)
	if(dir > 0) then
		if(IsShiftKeyDown()) then
			self:ScrollToTop()
		elseif(IsControlKeyDown()) then
			self:ScrollUp(); self:ScrollUp(); self:ScrollUp()
		else
			self:ScrollUp()
		end
	elseif(dir < 0) then
		if(IsShiftKeyDown()) then
			self:ScrollToBottom()
		elseif(IsControlKeyDown()) then
			self:ScrollDown(); self:ScrollDown(); self:ScrollDown()
		else
			self:ScrollDown()
		end
	end
end

for i = 1, NUM_CHAT_WINDOWS do
	local frame = _G['ChatFrame'..i]
	frame:EnableMouseWheel()
	frame:SetScript('OnMouseWheel', onMouseWheel)
	frame:SetFont([=[Interface\AddOns\Inomena\media\font.ttf]=], 12)

	poof(_G['ChatFrame'..i..'UpButton'])
	poof(_G['ChatFrame'..i..'DownButton'])
	poof(_G['ChatFrame'..i..'BottomButton'])

	orig[frame] = frame.AddMessage
	frame.AddMessage = addMessage
end

poof(ChatFrameMenuButton)

CHAT_TELL_ALERT_TIME = 0

local regions = {ChatFrameEditBox:GetRegions()}
poof(regions[6]); poof(regions[7]); poof(regions[8])

ChatFrameEditBox:ClearAllPoints()
ChatFrameEditBox:SetPoint('BOTTOMLEFT', ChatFrame1, 'TOPLEFT', -5, 20)
ChatFrameEditBox:SetPoint('BOTTOMRIGHT', ChatFrame1, 'TOPRIGHT', -5, 20)
ChatFrameEditBox:SetAltArrowKeyMode(nil)
ChatFrameEditBox:SetFont([=[Interface\AddOns\Inomena\media\font.ttf]=], 14)

SLASH_TellTarget1 = '/tt'
SlashCmdList.TellTarget = tellTarget

hooksecurefunc('ChatEdit_OnSpacePressed', onSpacePressed)
