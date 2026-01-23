local _, addon = ...

addon.curves = {}

-- if the duration is < 10 seconds then we want 1 decimal point, otherwise 0
-- offset this by 0.2 because of weird calculation timings making it flash 10.x
addon.curves.DurationDecimals = C_CurveUtil.CreateCurve()
addon.curves.DurationDecimals:SetType(Enum.LuaCurveType.Step)
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
