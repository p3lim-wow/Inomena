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
end
