local primalRageStart, primalRageDuration, primalRageModRate
local function updatePrimalRage(self, start, duration, _, _, modRate)
	if IsSpellKnown(264667, true) then
		primalRageStart = start
		primalRageDuration = duration
		primalRageModRate = modRate
	else
		if primalRageStart and primalRageDuration then
			self:SetCooldown(primalRageStart, primalRageDuration, primalRageModRate)
		end
	end
end

hooksecurefunc('CooldownFrame_Set', function(self, ...)
	local parent = self:GetParent()
	if parent then
		if parent.spellID and parent.spellID == 264667 then
			updatePrimalRage(self, ...)
		elseif parent.action then
			local type, id = GetActionInfo(parent.action)
			if type == 'macro' then
				id = GetMacroSpell(id)
			end

			if id and id == 264667 then
				updatePrimalRage(self, ...)
			end
		end
	end
end)
