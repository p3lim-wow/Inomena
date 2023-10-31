local _, addon = ...

local TIMER_MINUTES_DISPLAY = _G.TIMER_MINUTES_DISPLAY -- globalstring

local math_abs = math.abs
local math_floor = math.floor

local lastDistance, lastUpdate
local function updateArrival(self, elapsed)
	if self.isClamped then
		self.TimeText:Hide()
		lastDistance = nil
		return
	end

	lastUpdate = (lastUpdate or 0) + elapsed
	if lastUpdate >= 0.5 then
		local distance = C_Navigation.GetDistance()
		local speed = (((lastDistance or 0) - distance) / lastUpdate) or 0
		lastDistance = distance

		if speed > 0 then
			local time = math_abs(distance / speed)
			self.TimeText:SetText(TIMER_MINUTES_DISPLAY:format(math_floor(time / 60), math_floor(time % 60)))
			-- self.TimeText:SetText(time)
			self.TimeText:Show()
		else
			self.TimeText:Hide()
		end

		lastUpdate = 0
	end
end

local function updateAlpha(self)
	if not C_Navigation.WasClampedToScreen() and C_Navigation.GetDistance() > 0 then
		self:SetAlpha(1)
	end
end

addon:HookAddOn('Blizzard_QuestNavigation', function()
	local time = SuperTrackedFrame:CreateFontString(nil, 'BACKGROUND', 'GameFontNormal')
	time:SetPoint('TOP', SuperTrackedFrame.DistanceText, 'BOTTOM', 0, -2)
	time:SetHeight(20)
	time:SetJustifyV('TOP')

	SuperTrackedFrame.TimeText = time
	SuperTrackedFrame:HookScript('OnUpdate', updateArrival)

	hooksecurefunc(SuperTrackedFrame, 'UpdateAlpha', updateAlpha)
end)
