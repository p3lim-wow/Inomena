local _, addon = ...
local oUF = addon.oUF
local tags = oUF.Tags

tags.Events['inomena:absorb'] = 'UNIT_ABSORB_AMOUNT_CHANGED'
tags.Methods['inomena:absorb'] = function(unit)
	if not UnitIsDeadOrGhost(unit) then
		return C_StringUtil.TruncateWhenZero(UnitGetTotalAbsorbs(unit))
	end
end

tags.Events['inomena:hpcur'] = 'UNIT_HEALTH UNIT_MAXHEALTH'
tags.Methods['inomena:hpcur'] = function(unit)
	if not UnitIsDeadOrGhost(unit) then
		return addon:AbbreviateNumbers(UnitHealth(unit))
	end
end

tags.Events['inomena:hpdef'] = 'UNIT_HEALTH UNIT_MAXHEALTH'
tags.Methods['inomena:hpdef'] = function(unit)
	if not UnitIsDeadOrGhost(unit) then
		return C_StringUtil.TruncateWhenZero(UnitHealthMissing(unit, true))
	end
end

tags.Events['inomena:hpper'] = 'UNIT_HEALTH UNIT_MAXHEALTH'
tags.Methods['inomena:hpper'] = function(unit)
	if not UnitIsDeadOrGhost(unit) then
		local decimals = UnitHealthPercent(unit, true, addon.curves.PercentageDecimals)
		local percent = UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)
		return string.format('%.' .. decimals .. 'f', percent)
	end
end

tags.Events['inomena:hptarget'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION'
tags.Methods['inomena:hptarget'] = function(unit)
	if not UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		if UnitCanAttack('player', unit) then
			return C_StringUtil.WrapString(_TAGS['inomena:hpper'](unit), '(', '|cff0090ff%|r)')
		else
			return C_StringUtil.WrapString(addon:AbbreviateNumbers(UnitHealth(unit)), '|cff0090ff/|r ')
		end
	end
end

tags.Events['inomena:reactioncolor'] = 'UNIT_FACTION UNIT_CONNECTION UNIT_NAME_UPDATE'
tags.Methods['inomena:reactioncolor'] = function(unit)
	local reaction = UnitReaction(unit, 'player')
	if UnitIsTapDenied(unit) or not UnitIsConnected(unit) then
		return '|cff999999'
	elseif UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit) then
		local _, classToken = UnitClass(unit)
		return addon.colors.class[classToken] and Hex(addon.colors.class[classToken])
	elseif not UnitIsPlayer(unit) and reaction then
		return addon.colors.reaction[reaction] and Hex(addon.colors.reaction[reaction])
	elseif UnitFactionGroup(unit) and UnitIsEnemy(unit, 'player') and UnitIsPVP(unit) then
		return '|cffff0000'
	else
		return '|cffffffff'
	end
end

tags.Events['inomena:name'] = 'UNIT_NAME_UPDATE'
tags.Methods['inomena:name'] = function(unit)
	return UnitNameUnmodified(unit)
end

tags.Events['inomena:namecolor'] = 'UNIT_NAME_UPDATE UNIT_CLASSIFICATION_CHANGED'
tags.Methods['inomena:namecolor'] = function(unit)
	local classification = UnitClassification(unit)
	if classification == 'rare' then
		return '|cff0090ff'
	elseif classification == 'rareelite' then
		return '|cffe65fe8'
	elseif classification == 'elite' or classification == 'worldboss' then
		return '|cffffff00'
	elseif classification == 'trivial' or classification == 'minus' then
		return '|cff848484'
	end
	return '|cffffffff'
end

tags.Events['inomena:resting'] = 'PLAYER_UPDATE_RESTING'
tags.Methods['inomena:resting'] = function()
	if IsResting() then
		return [[|TInterface\HUD\UIUnitFrameRestingFlipbook:16:16:0:0:360:420:45:80:200:240|t]]
	end
end

tags.Events['inomena:resurrect'] = 'INCOMING_RESURRECT_CHANGED UNIT_HEALTH'
tags.Methods['inomena:resurrect'] = function(unit)
	if UnitHasIncomingResurrection(unit) then
		return [[|TInterface\RaidFrame\Raid-Icon-Rez:22|t]]
	end
end

tags.Events['inomena:dead'] = 'UNIT_HEALTH'
tags.Methods['inomena:dead'] = function(unit)
	if UnitIsGhost(unit) then
		return '|A:poi-soulspiritghost:18:19|a'
	elseif UnitIsDead(unit) then
		return '|A:warfront-alliancehero:32:32|a'
	end
end
