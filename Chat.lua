local function poof(obj)
	obj.Show = obj.Hide
	obj:Hide()
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

	poof(_G['ChatFrame'..i..'UpButton'])
	poof(_G['ChatFrame'..i..'DownButton'])
	poof(_G['ChatFrame'..i..'BottomButton'])
end

poof(ChatFrameMenuButton)
