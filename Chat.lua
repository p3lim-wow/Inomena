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

local function addMessage(self, str, ...)
	str = str:gsub('^|Hchannel:(%d+)|h(%[([%d%. ]*)([^%]]+)%])|h', '|Hchannel:%1|h(%1)|h')
	str = str:gsub('(|Hplayer.-|h)%[(.-)%]|h', '%1%2|h')

	str = str:gsub('^To (.-|h):', '(T) %1:')
	str = str:gsub('^(.-|h) whispers:', '%1:')
	str = str:gsub('^(.-|h) says:', '%1:')
	str = str:gsub('^(.-|h) yells:', '%1:')

	str = str:gsub('^(%[(Raid Warning)%])', '(W)')

	str = str:gsub('^|Hchannel:o|h(%[(Officer)%])|h', '|Hchannel:o|h(O)|h')
	str = str:gsub('^|Hchannel:Guild|h(%[(Guild)%])|h', '|Hchannel:Guild|h(G)|h')
	str = str:gsub('^|Hchannel:Party|h(%[(Party)%])|h', '|Hchannel:Party|h(P)|h')
	str = str:gsub('^|Hchannel:Battleground|h(%[(Battleground Leader)%])|h', '|Hchannel:Battleground|h(|cffffff00B|r)|h')
	str = str:gsub('^|Hchannel:Battleground|h(%[(Battleground)%])|h', '|Hchannel:Battleground|h(B)|h')
	str = str:gsub('^|Hchannel:raid|h(%[(Raid Leader)%])|h', '|Hchannel:raid|h(|cffffff00R|r)|h')
	str = str:gsub('^|Hchannel:raid|h(%[(Raid)%])|h', '|Hchannel:raid|h(R)|h')	

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
