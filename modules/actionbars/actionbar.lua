local E, F, C = unpack(select(2, ...))

local SPACING = C.BUTTON_SPACING
local SIZE = C.BUTTON_SIZE

local Parent = CreateFrame('Frame', C.Name .. 'ActionParent', UIParent, 'SecureHandlerStateTemplate')
Parent:SetPoint('BOTTOM', 0, 50)
Parent:SetWidth((NUM_ACTIONBAR_BUTTONS * (SIZE + SPACING)) - SPACING)

local bars = {}
for row, buttonName in next, {
	'ActionButton',
	'MultiBarBottomLeftButton',
	'MultiBarBottomRightButton',
	'MultiBarRightButton',
	'MultiBarLeftButton',
} do
	local Bar = CreateFrame('Frame', '$parentBar' .. row, Parent)
	Bar:SetWidth(Parent:GetWidth())
	bars[row] = Bar

	for col = 1, NUM_ACTIONBAR_BUTTONS do
		local Button = _G[buttonName .. col]
		F:SkinActionButton(Button)

		Button:ClearAllPoints()
		Button:SetPoint('BOTTOMLEFT', Bar, (Button:GetHeight() + SPACING) * (col - 1), 0)
		Bar:SetHeight(Button:GetHeight())
	end
end

bars[1]:SetPoint('BOTTOM', Parent)

local function PositionBar(barIndex, prevIndex)
	local Bar = bars[barIndex]
	Bar:ClearAllPoints()
	Bar:SetPoint('BOTTOM', bars[prevIndex], 'TOP', 0, SPACING)
end

hooksecurefunc('SetActionBarToggles', function(bar2, bar3, bar4, bar5)
	-- this is so messy
	local prevBar = 1
	local numBars = 1

	if(bar2) then
		PositionBar(2, prevBar)
		prevBar = 2
		numBars = numBars + 1
	end

	if(bar3) then
		PositionBar(3, prevBar)
		prevBar = 3
		numBars = numBars + 1
	end

	if(bar4) then
		PositionBar(4, prevBar)
		prevBar = 4
		numBars = numBars + 1
	end

	if(bar5) then
		PositionBar(5, prevBar)
		prevBar = 5
		numBars = numBars + 1
	end

	if(not bar4 and bar5) then
		numBars = numBars - 1
	end

	Parent:SetHeight(((SIZE + SPACING) * numBars) - SPACING)
end)
