
local gsub = string.gsub
local format = string.format

local stamp = '|cff807070%s|r  %s'

-- No idea why blizzard havent added this
local CHAT_MSG_PARTY_GUIDE = gsub(CHAT_PARTY_GUIDE_GET, '|Hchannel:party|h%[(.-)%]|h .*', '%1')

local hooks = {}
local strings = {
	[CHAT_MSG_GUILD] = 'g',
	[CHAT_MSG_PARTY] = 'p',
	[CHAT_MSG_PARTY_GUIDE] = '|cffffff00p|r',
	[CHAT_MSG_PARTY_LEADER] = '|cffffff00p|r',
	[CHAT_MSG_RAID] = 'r',
	[CHAT_MSG_RAID_LEADER] = '|cffffff00r|r',
	[CHAT_MSG_BATTLEGROUND] = 'b',
	[CHAT_MSG_BATTLEGROUND_LEADER] = '|cffffff00b|r',
}

local function ReplaceStrings(channel, orig)
	return format('|Hchannel:%s|h%s|h', channel, strings[orig] or channel)
end

local function AddMessage(self, str, ...)
	if(not str) then return hooks[self](self, str, ...) end

	str = str:gsub('(|Hplayer.-|h)%[(.-)%]|h', '%1%2|h')
	str = str:gsub('^|Hchannel:(.-)|h%[(.-)%]|h', ReplaceStrings)

	str = str:gsub('^%[Raid Warning%]', 'w')
	str = str:gsub('(|Hplayer.-|h) has earned the achievement (.-)!', '%1 ! %2')
	str = str:gsub('^(.-|h) says', '%1')
	str = str:gsub('^(.-|h) yells', '%1')

	return hooks[self](self, str, ...)
end

local function AddStampMessage(self, str, ...)
	if(not str) then return hooks[self](self, str, ...) end

	str = str:gsub('(|Hplayer.-|h)%[(.-)%]|h', '%1%2|h')
	str = str:gsub('^To (.-|h)', '|cffffff00>|r %1')
	str = str:gsub('^(.-|h) whispers', '%1')

	str = stamp:format(date('%H%M.%S'), str)

	return hooks[self](self, str, ...)
end

local function OnMouseWheel(self, dir)
	if(dir > 0) then
		if(IsShiftKeyDown()) then
			self:ScrollToTop()
		elseif(IsControlKeyDown()) then
			self:PageUp()
		else
			self:ScrollUp()
		end
	elseif(dir < 0) then
		if(IsShiftKeyDown()) then
			self:ScrollToBottom()
		elseif(IsControlKeyDown()) then
			self:PageDown()
		else
			self:ScrollDown()
		end
	end
end

local function Poof(self)
	self.Show = self.Hide
	self:Hide()
end

for index = 1, NUM_CHAT_WINDOWS do
	local frame = _G['ChatFrame'..index]
	frame:EnableMouseWheel()
	frame:SetScript('OnMouseWheel', OnMouseWheel)
	frame:SetFont([=[Interface\AddOns\Inomena\media\vera.ttf]=], 12)

	Poof(_G['ChatFrame'..index..'UpButton'])
	Poof(_G['ChatFrame'..index..'DownButton'])
	Poof(_G['ChatFrame'..index..'BottomButton'])

	hooks[frame] = frame.AddMessage
	frame.AddMessage = index ~= 3 and AddMessage or AddStampMessage
end

do
	local editbox = ChatFrameEditBox
	editbox:ClearAllPoints()
	editbox:SetPoint('BOTTOMLEFT', ChatFrame1, 'TOPLEFT', -5, 20)
	editbox:SetPoint('BOTTOMRIGHT', ChatFrame1, 'TOPRIGHT', 5, 20)
	editbox:SetFont([=[Interface\AddOns\Inomena\media\vera.ttf]=], 14)
	editbox:SetAltArrowKeyMode(false)

	local regions = {editbox:GetRegions()}
	regions[6]:Hide()
	regions[7]:Hide()
	regions[8]:Hide()

	ChatFrameMenuButton:Hide()
end

SLASH_TellTarget1 = '/tt'
SlashCmdList.TellTarget = function(str)
	if(UnitIsPlayer('target') and UnitIsFriend('player', 'target')) then
		SendChatMessage(str, 'WHISPER', GetDefaultLanguage('player'), GetUnitName('target', true):gsub('%s', '', 2))
	end
end

hooksecurefunc('ChatEdit_OnSpacePressed', function(self)
	if(string.match(string.lower(self:GetText()), '^/tt $') and UnitIsPlayer('target') and UnitIsFriend('player', 'target')) then
		self:Hide()
		self:SetAttribute('chatType', 'WHISPER')
		self:SetAttribute('tellTarget', GetUnitName('target', true):gsub('%s', '', 2))
		ChatFrame_OpenChat('')
	end
end)
