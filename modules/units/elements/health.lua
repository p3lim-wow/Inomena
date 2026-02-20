local _, addon = ...

function addon.unitShared.UpdateColorHealth(self, _, unit)
	if not unit or self.unit ~= unit then
		return
	end

	local color
	if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit) then
		local _, classToken = UnitClass(unit)
		color = self.colors.class[classToken]
	elseif UnitIsTapDenied(unit) then
		color = self.colors.tapped
	else
		color = self.colors.reaction[UnitReaction(unit, 'player')]
	end

	if color then
		self.Health:SetStatusBarColor(color:GetRGB())
	end
end
