local _, addon = ...

do
	local SCALE = 768 / select(2, GetPhysicalScreenSize())
	function addon:PixelPerfect(obj)
		if obj.SetTexelSnappingBias then
			obj:SetTexelSnappingBias(0)
			obj:SetSnapToPixelGrid(false)
		elseif obj.GetObjectType then
			obj:SetIgnoreParentScale(true)
			obj:SetScale(SCALE)
		end
	end
end

function addon:IsHalloween()
	local date = C_DateAndTime.GetCurrentCalendarTime()
	local dateNum = tonumber(string.format('%02d%02d%02d', date.month, date.monthDay, date.hour))
	return dateNum >= 101810 and dateNum <= 110111
end
