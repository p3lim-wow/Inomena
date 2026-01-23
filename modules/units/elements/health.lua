local _, addon = ...

function addon.unitShared.UpdateColorHealth(self, _, unit)
	local element = self.Health
	if not unit or self.unit ~= unit then
		return
	end

	local color
	if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit) then
		local _, classToken = UnitClass(unit)
		color = self.colors.class[classToken]
	elseif addon:IsInDungeon() and not addon:IsInRaid() then
		local classification = UnitClassification(unit)
		if classification == 'elite' or classification == 'rareelite' then
			local playerLevel = UnitEffectiveLevel('player')
			local level = UnitEffectiveLevel(unit)
			if level >= (playerLevel + 2) then
				color = addon.colors.creature.boss
			elseif level >= (playerLevel + 1) then
				color = addon.colors.creature.lieutenant
			elseif level >= playerLevel then
				if UnitClassBase(unit) == 'PALADIN' then
					color = addon.colors.creature.caster
				else
					color = addon.colors.creature.melee
				end
			else
				color = addon.colors.creature.trivial
			end
		else
			color = addon.colors.creature.trivial
		end
	elseif UnitIsTapDenied(unit) then
		color = self.colors.tapped
	else
		color = self.colors.reaction[UnitReaction(unit, 'player')]
	end

	if color then
		element:SetStatusBarColor(color:GetRGB())
	end
end
