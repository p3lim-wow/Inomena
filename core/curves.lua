local _, addon = ...

addon.curves = {}

-- if the duration is < 10 seconds then we want 1 decimal point, otherwise 0
-- offset this by 0.2 because of weird calculation timings making it flash 10.x
addon.curves.DurationDecimals = C_CurveUtil.CreateCurve()
addon.curves.DurationDecimals:SetType(Enum.LuaCurveType.Step)
addon.curves.DurationDecimals:AddPoint(0.09, 0)
addon.curves.DurationDecimals:AddPoint(0.1, 1)
addon.curves.DurationDecimals:AddPoint(9.8, 1)
addon.curves.DurationDecimals:AddPoint(9.9, 0)

-- if the duration is 0 (permanent aura) or is above 90 seconds remaining then
-- we want to hide the aura. again we offset the lower numbers to avoid weird flashing
addon.curves.AuraAlpha = C_CurveUtil.CreateCurve()
addon.curves.AuraAlpha:SetType(Enum.LuaCurveType.Step)
addon.curves.AuraAlpha:AddPoint(0, 0)
addon.curves.AuraAlpha:AddPoint(0.1, 1)
addon.curves.AuraAlpha:AddPoint(9.9, 1)
addon.curves.AuraAlpha:AddPoint(89, 1)
addon.curves.AuraAlpha:AddPoint(90, 0)

-- if the percentage is < 100 then show decimal points, 2 if below 10%
-- yet again we offset the numbers to avoid weird flashing
addon.curves.PercentageDecimals = C_CurveUtil.CreateCurve()
addon.curves.PercentageDecimals:SetType(Enum.LuaCurveType.Step)
addon.curves.PercentageDecimals:AddPoint(0.0990000, 2)
addon.curves.PercentageDecimals:AddPoint(0.0990001, 1)
addon.curves.PercentageDecimals:AddPoint(0.99, 1)
addon.curves.PercentageDecimals:AddPoint(0.9900001, 0)
addon.curves.PercentageDecimals:AddPoint(1.0, 0)

-- curve that yields data for SetDesaturation based on cooldown remaining
addon.curves.ActionDesaturation = C_CurveUtil.CreateCurve()
addon.curves.ActionDesaturation:SetType(Enum.LuaCurveType.Step)
addon.curves.ActionDesaturation:AddPoint(0, 0)
addon.curves.ActionDesaturation:AddPoint(0.001, 1)

-- curve that yields data for SetAlpha based on cooldown remaining
addon.curves.ActionAlpha = C_CurveUtil.CreateCurve()
addon.curves.ActionAlpha:SetType(Enum.LuaCurveType.Step)
addon.curves.ActionAlpha:AddPoint(0, 1)
addon.curves.ActionAlpha:AddPoint(0.001, 0.33)

-- curve that yields data for SetAlpha based on cooldown remaining, except reverse(-ish)
addon.curves.ActionAlphaMinor = C_CurveUtil.CreateCurve()
addon.curves.ActionAlphaMinor:SetType(Enum.LuaCurveType.Step)
addon.curves.ActionAlphaMinor:AddPoint(0, 0)
addon.curves.ActionAlphaMinor:AddPoint(0.001, 0.66)

-- curves which will yield 0 if the power type is in an idle state, otherwise 1
addon.curves.PowerIdleAlpha = {}
for powerType, direction in next, {
	[Enum.PowerType.Energy] = 1,
	[Enum.PowerType.Focus] = 1,
	[Enum.PowerType.Fury] = 0,
	[Enum.PowerType.Insanity] = 0,
	[Enum.PowerType.LunarPower] = 0,
	[Enum.PowerType.Maelstrom] = 0,
	[Enum.PowerType.Mana] = 1,
	[Enum.PowerType.Rage] = 0,
	[Enum.PowerType.RunicPower] = 0,
} do
	local alphaCurve = C_CurveUtil.CreateCurve()
	alphaCurve:SetType(Enum.LuaCurveType.Step)

	if direction > 0 then
		-- this power type regenerates
		alphaCurve:AddPoint(0.9999999, 1)
		alphaCurve:AddPoint(1.0, 0)
	else
		-- this power type is gained
		alphaCurve:AddPoint(0.0, 0)
		alphaCurve:AddPoint(0.0000001, 1)
	end

	addon.curves.PowerIdleAlpha[powerType] = alphaCurve
end
