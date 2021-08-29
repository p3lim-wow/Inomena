local _, addon = ...

local function refreshDetailsRows(instance)
	if not instance.barras or not instance.barras[1] then
		return
	end

	local font, size = _G[addon.FONT]:GetFont()
	for _, row in next, instance.barras do
		-- Details don't allow setting outline nor shadow color
		row.lineText1:SetFont(font, size, 'MONOCHROMEOUTLINE')
		row.lineText2:SetFont(font, size, 'MONOCHROMEOUTLINE')
		row.lineText3:SetFont(font, size, 'MONOCHROMEOUTLINE')
		row.lineText4:SetFont(font, size, 'MONOCHROMEOUTLINE')
		row.lineText1:SetShadowColor(0, 0, 0, 0)
		row.lineText2:SetShadowColor(0, 0, 0, 0)
		row.lineText3:SetShadowColor(0, 0, 0, 0)
		row.lineText4:SetShadowColor(0, 0, 0, 0)
	end
end

addon:HookAddOn('Details', function()
	hooksecurefunc(_detalhes, 'InstanceRefreshRows', refreshDetailsRows)
end)
