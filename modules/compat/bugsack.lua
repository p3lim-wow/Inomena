local _, addon = ...

-- custom minimap button for bugsack

local function onEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
	self.bugsack.dataObject.OnTooltipShow(GameTooltip)
	GameTooltip:Show()
end

local function onClick(self, ...)
	if IsAltKeyDown() then
		-- alt-click to clear errors
		BugGrabber:Reset()
		self:SetAlpha(0)
		self.indicator:Hide()

		-- update tooltip
		onEnter(self)
	else
		-- passthrough
		self.bugsack.dataObject.OnClick(nil, ...)
	end
end

local button
addon:HookAddOn('BugSack', function()
	button = addon:CreateFrame('Button', nil, UIParent)
	button:SetPoint('TOPRIGHT', UIParent)
	button:SetPoint('BOTTOMLEFT', Minimap, 'TOPRIGHT', -10, -10)
	button:SetFrameStrata('HIGH')
	button:SetScript('OnLeave', GameTooltip_Hide)
	button:SetScript('OnEnter', onEnter)
	button:SetScript('OnClick', onClick)
	button:SetAlpha(0)

	local indicator = button:CreateTexture()
	indicator:SetPoint('BOTTOMLEFT')
	indicator:SetSize(10, 10)
	indicator:SetColorTexture(1, 0, 0)
	indicator:Hide()
	button.indicator = indicator
	button:AddBackdrop(indicator)

	local session = BugGrabber:GetSessionId()
	if session then
		for _, error in next, BugGrabber:GetDB() do
			if session == error.session then
				button:SetAlpha(1)
				indicator:Show()
				break
			end
		end
	else
		if BugGrabber:GetDB() then
			button:SetAlpha(1)
			indicator:Show()
		end
	end

	BugGrabber.RegisterCallback(button, 'BugGrabber_BugGrabbed', function()
		button:SetAlpha(1)
		indicator:Show()
	end)
end)

function addon:OnLogin()
	local LDBI = LibStub and LibStub('LibDBIcon-1.0', true)
	if LDBI and LDBI:IsRegistered('BugSack') then
		button.bugsack = LDBI:GetMinimapButton('BugSack')
	end
end
