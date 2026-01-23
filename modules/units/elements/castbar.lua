local _, addon = ...

local WHITE_COLOR = addon:CreateColor(1, 1, 1)

function addon.unitShared.PostUpdateCast(element, unit)
	local colors = addon.colors.cast
	local important = C_Spell.IsSpellImportant(element.spellID)

	-- toggle shielded overlay visibility and adjust color based on spell importance
	element.Shielded:SetAlphaFromBoolean(element.notInterruptible, 1, 0) -- important: alpha last!
	element.Shielded:SetColorTextureFromBoolean(important, colors.importantshielded, colors.shielded)

	-- color based on non-shielded importance
	element:SetStatusBarColorFromBoolean(important, colors.important, colors.normal)

	-- display cast target name if it exists
	local spellTargetname = UnitSpellTargetName(unit)
	if spellTargetname ~= nil then
		local color
		local classToken = UnitSpellTargetClass(unit)
		if classToken ~= nil then
			color = C_ClassColor.GetClassColor(classToken) -- can't use oUF colors for this
		else
			color = WHITE_COLOR
		end

		element.Text:SetFormattedText('%s (|cff999999@|r%s)', element.spellName, color:WrapTextInColorCode(spellTargetname))
	end
end

function addon.unitShared.PostInterruptedCast(element, _, interruptedByGUID)
	-- try to display who interrupted the cast
	if element.holdTime and element.holdTime > 0 then
		if interruptedByGUID ~= nil then
			local _, classToken, _, _, _, name = GetPlayerInfoByGUID(interruptedByGUID)
			if name ~= nil and classToken ~= nil then -- this happens in follower dungeons
				local color = C_ClassColor.GetClassColor(classToken) -- can't use oUF colors for secrets
				name = color:WrapTextInColorCode(name)
			else
				name = UnitNameFromGUID(interruptedByGUID)
			end

			element.Text:SetFormattedText('%s (%s)', _G.INTERRUPTED, name)
		end

		element:SetStatusBarColor(0.3, 0.3, 0.3)
	end
end
