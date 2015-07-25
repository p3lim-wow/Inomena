local function TimerCallback(self)
	local parent = self.parent
	parent.icon:SetAlpha(1)
	parent._timer = nil
end

local hooked = {}
hooksecurefunc('CooldownFrame_SetTimer', function(self, start, duration, enabled, forceShowDrawEdge)
	local parent = self:GetParent()
	if(not hooked[parent]) then
		return
	end

	local _timer = parent._timer
	if(duration > 2) then
		if(not forceShowDrawEdge) then
			self:SetSwipeColor(0, 0, 0)
			parent.icon:SetAlpha(1/5)
		end

		if(_timer) then
			_timer:Cancel()
		end

		_timer = C_Timer.NewTimer(math.max(0, start - GetTime() + duration), TimerCallback)
		_timer.parent = parent

		parent._timer = _timer
	elseif(_timer) then
		_timer:Cancel()
		parent.icon:SetAlpha(1)
	end
end)

hooksecurefunc('StartChargeCooldown', function(parent, start, duration)
	if(hooked[parent] and not parent._chargeStyle) then
		local cooldown = parent.chargeCooldown
		cooldown:SetDrawEdge(false)
		cooldown:SetDrawSwipe(true)
		cooldown:SetSwipeColor(0, 0, 0, 0.9)
		parent._chargeStyle = true
	end
end)

if(ActionBarButtonEventsFrame.frames) then
	for index, Button in next, ActionBarButtonEventsFrame.frames do
		hooked[Button] = true
	end
end
