-- no clue why this isn't a thing
hooksecurefunc('AddonTooltip_Update', function(owner)
	local version = C_AddOns.GetAddOnMetadata(owner:GetID(), 'version')
	if version then
		AddonTooltip:AddLine('Version: ' .. version)
	end
end)
