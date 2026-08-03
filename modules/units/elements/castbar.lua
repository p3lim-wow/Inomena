local _, addon = ...

function addon.unitShared.PostUpdateCast(element, unit, spellID, notInterruptible, spellName)
	local colors = addon.colors.cast
	local important = C_Spell.IsSpellImportant(spellID)

	-- toggle shielded overlay visibility and adjust color based on spell importance
	element.Shielded:SetColorTextureFromBoolean(important, colors.importantshielded, colors.shielded)
	element.Shielded:SetAlphaFromBoolean(notInterruptible, 1, 0) -- important: alpha last!

	-- color based on non-shielded importance
	element:SetStatusBarColorFromBoolean(important, colors.important, colors.normal)

	if spellName then
		-- display cast target name if it exists
		local spellTargetname = UnitSpellTargetName(unit)
		if spellTargetname ~= nil then
			local classToken = UnitSpellTargetClass(unit)
			if classToken ~= nil then
				local color = C_ClassColor.GetClassColor(classToken)
				spellTargetname = color:WrapTextInColorCode(spellTargetname)
			else
				spellTargetname = addon.colors.white:WrapTextInColorCode(spellTargetname)
			end

			element.Text:SetFormattedText('%s (|cff999999@|r%s)', spellName, spellTargetname)
		end
	end
end

function addon.unitShared.PostInterruptedCast(element, _, interruptedByGUID)
	-- try to display who interrupted the cast
	local name = UnitNameFromGUID(interruptedByGUID)
	local _, classToken = UnitClassFromGUID(interruptedByGUID)
	if classToken ~= nil then
		local color = C_ClassColor.GetClassColor(classToken)
		name = color:WrapTextInColorCode(name)
	end

	element.Text:SetFormattedText('%s (%s)', INTERRUPTED, name)
	element:SetStatusBarColor(addon.colors.cast.interrupted:GetRGB())
end

function addon.unitShared.PostFailedCast(element)
	element:SetStatusBarColor(addon.colors.cast.interrupted:GetRGB())
end
