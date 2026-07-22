local _, addon = ...

-- misc addons with custom tooltips

for tooltip, addonName in next, {
	InteractiveWormholesTooltip = 'InteractiveWormholes',
	NotGameTooltip1 = 'OPie',
	RematchGameTooltip = 'Rematch',
	WQT_GameTooltip = 'WorldQuestTab',
	WQT_ShoppingTooltip1 = 'WorldQuestTab',
	WQT_ShoppingTooltip2 = 'WorldQuestTab',
} do
	addon:HookAddOn(addonName, function()
		addon:SkinTooltip(_G[tooltip])
	end)
end
