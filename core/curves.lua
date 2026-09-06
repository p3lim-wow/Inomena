local _, addon = ...

local E = 0.000001 -- epsilon

addon.curves = {}

-- if the percentage is < 100 then show decimal points, 2 if below 10%
addon.curves.PercentageDecimals = C_CurveUtil.CreateCurve()
addon.curves.PercentageDecimals:SetType(Enum.LuaCurveType.Step)
addon.curves.PercentageDecimals:AddPoint(0, 2)
addon.curves.PercentageDecimals:AddPoint(0.1, 1)
addon.curves.PercentageDecimals:AddPoint(1, 0)

-- curve that yields data for SetDesaturation based on cooldown remaining
addon.curves.DesaturateCooldown = C_CurveUtil.CreateCurve()
addon.curves.DesaturateCooldown:SetType(Enum.LuaCurveType.Step)
addon.curves.DesaturateCooldown:AddPoint(0, 0)
addon.curves.DesaturateCooldown:AddPoint(E, 1)

-- curve that yields data for SetAlpha based on cooldown remaining
addon.curves.AlphaCooldown = C_CurveUtil.CreateCurve()
addon.curves.AlphaCooldown:SetType(Enum.LuaCurveType.Step)
addon.curves.AlphaCooldown:AddPoint(0, 1)
addon.curves.AlphaCooldown:AddPoint(E, 0.33)

-- curve that yields data for SetAlpha based on cooldown remaining, except opposite
addon.curves.AlphaCooldownMinor = C_CurveUtil.CreateCurve()
addon.curves.AlphaCooldownMinor:SetType(Enum.LuaCurveType.Step)
addon.curves.AlphaCooldownMinor:AddPoint(0, 0)
addon.curves.AlphaCooldownMinor:AddPoint(E, 0.66)

-- curves which will yield 0 if the power type is in an idle state, otherwise 1
addon.curves.PowerIdle = {}
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
	local curve = C_CurveUtil.CreateCurve()
	curve:SetType(Enum.LuaCurveType.Step)

	if direction > 0 then
		-- this power type regenerates
		curve:AddPoint(1-E, 1)
		curve:AddPoint(1, 0)
	else
		-- this power type is gained
		curve:AddPoint(0, 0)
		curve:AddPoint((UnitPowerMax('player', powerType, false) / 100) / 100, 1)
	end

	addon.curves.PowerIdle[powerType] = curve
end

-- curve for durability percentage color
addon.curves.Durability = C_CurveUtil.CreateColorCurve()
addon.curves.Durability:SetType(Enum.LuaCurveType.Linear)
addon.curves.Durability:AddPoint(0, addon.colors.durability[2])
addon.curves.Durability:AddPoint(0.5, addon.colors.durability[1])
addon.curves.Durability:AddPoint(1, addon.colors.durability[0])
