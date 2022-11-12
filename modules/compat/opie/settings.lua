local addonName, addon = ...

addon:HookAddOn('OPie', function()
	-- OPie nukes its settings after loading it and saves it during logout, we'll modify it before
	-- this happens so we get our changes applied
	if OPie_SavedData and OPie_SavedData.ProfileStorage and OPie_SavedData.ProfileStorage.default then
		if not OPie_SavedData.ProfileStorage.default.Bindings then
			OPie_SavedData.ProfileStorage.default.Bindings = {}
		end

		-- force enable nested rings
		OPie_SavedData.ProfileStorage.default.GhostMIRings = true
		-- force enable center action option
		OPie_SavedData.ProfileStorage.default.CenterAction = true
		-- use center action if mouse doesn't move
		OPie_SavedData.ProfileStorage.default.MotionAction = true

		-- disable default bindings
		OPie_SavedData.ProfileStorage.default.UseDefaultBindings = false

		-- do our own binds
		OPie_SavedData.ProfileStorage.default.Bindings[addonName .. 'SpecialMounts'] = 'ALT-HOME'
		OPie_SavedData.ProfileStorage.default.Bindings[addonName .. 'SpecialMounts'] = 'SHIFT-HOME'
		OPie_SavedData.ProfileStorage.default.Bindings[addonName .. 'Teleport'] = 'ALT-G'
		OPie_SavedData.ProfileStorage.default.Bindings[addonName .. 'Professions'] = 'ALT-T'
	end
end)
