local _, addon = ...

-- automatically swap back to flight form

if addon.PLAYER_CLASS ~= 'DRUID' then
	return
end

local trySwapNext
local function swap()
	local inInstance, instanceType = IsInInstance()
	if inInstance and instanceType ~= 'neighborhood' then
		-- don't bother with this if we're in an instance
		return
	end

	local shapeshiftID = GetShapeshiftFormID()
	if trySwapNext then
		-- if the form is (ground) travel form, try to fly
		if shapeshiftID == addon.enums.DruidForms.Travel then
			-- don't attempt when we can't or shouldn't
			if not InCombatLockdown() and IsFlyableArea() and not IsSubmerged() then
				-- cancelling the form will exit the forced swap, i.e. turn back into flying
				CancelShapeshiftForm()
				trySwapNext = nil
			end
		else
			-- if it's not then give up
			trySwapNext = nil
		end
	elseif shapeshiftID == addon.enums.DruidForms.Travel then
		-- currently in (ground) travel form, try to swap next time an event triggers
		trySwapNext = true
	end
end

addon:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED', swap)
addon:RegisterEvent('UPDATE_SHAPESHIFT_FORM', swap)
addon:RegisterEvent('PLAYER_REGEN_ENABLED', swap)
