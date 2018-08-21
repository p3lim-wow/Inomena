local E, F, C = unpack(select(2, ...))

local tabs = {}
local function SelectGarrison(self)
	HideUIPanel(GarrisonLandingPage) -- to make sure it updates
	ShowGarrisonLandingPage(self.pageID)
end

hooksecurefunc('ShowGarrisonLandingPage', function(pageID)
	for _, Tab in next, tabs do
		local available = not not (C_Garrison.GetGarrisonInfo(Tab.pageID))
		Tab:SetEnabled(available)
		Tab:GetNormalTexture():SetDesaturated(not available)
		Tab:SetChecked(Tab.pageID == pageID)
	end
end)

function E:ADDON_LOADED(addon)
	if(addon == 'Blizzard_GarrisonUI') then
		for _, data in next, {
			{LE_GARRISON_TYPE_8_0, GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, [[Interface\Icons\INV_Level120]]},
			{LE_GARRISON_TYPE_7_0, ORDER_HALL_LANDING_PAGE_TITLE, [[Interface\Icons\Achievement_Level_110]]},
			{LE_GARRISON_TYPE_6_0, GARRISON_LANDING_PAGE_TITLE, [[Interface\Icons\Achievement_Level_100]]},
		} do
			local Tab = CreateFrame('CheckButton', nil, GarrisonLandingPage, 'SpellBookSkillLineTabTemplate')
			Tab:SetPoint('TOPRIGHT', 20, -(50 * (#tabs + 1)))
			Tab:SetNormalTexture(data[3])
			Tab:SetFrameStrata('LOW') -- appear behind to avoid gaps
			Tab:SetScript('OnClick', SelectGarrison)
			Tab:Show()
			Tab.pageID = data[1]
			Tab.tooltip = data[2]

			table.insert(tabs, Tab)
		end

		return true
	end
end
