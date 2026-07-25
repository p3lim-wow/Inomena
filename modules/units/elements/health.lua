local _, addon = ...

function addon.unitShared.UpdateColorHealth(self, _, unit)
	if not unit or self.unit ~= unit then
		return
	end

	local color
	if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit) then
		local _, classToken = UnitClass(unit)
		if classToken ~= nil then
			color = C_ClassColor.GetClassColor(classToken)
		end
	end

	if color == nil then
		if UnitIsTapDenied(unit) then
			color = self.colors.tapped
		else
			color = self.colors.reaction[UnitReaction(unit, 'player')]
		end
	end

	if color then
		self.Health:SetStatusBarColor(color:GetRGB())
	end
end
