local _, addon = ...

local TOY_ID = 134020 -- Chef's Hat
local BUFF_ID = 67556 -- Chef's Hat

local function updateCooldown(self)
	CooldownFrame_Set(self.Cooldown, C_Item.GetItemCooldown(TOY_ID))
end

local Button
local function showButton()
	if not PlayerHasToy(TOY_ID) then
		return
	end

	if not Button then
		Button = addon:CreateButton('ItemButton', nil, UIParent, 'SecureActionButtonTemplate, SecureHandlerStateTemplate')
		Button:SetPoint('RIGHT', ProfessionsFrame.CraftingPage.CookingGear0Slot, 'LEFT', -10, 0)
		Button:SetSize(37, 37) -- SecureHandlerStateTemplate nukes the size set by the ItemButton intrinsic
		Button:SetFrameStrata('HIGH') -- above the professions frame
		Button:Hide() -- so we can trigger OnShow after creation
		Button:SetAttribute('type1', 'toy')
		Button:SetAttribute('toy', TOY_ID)
		Button:SetAttribute('type2', 'cancelaura')
		Button:SetAttribute('spell', C_Spell.GetSpellName(BUFF_ID))
		Button:SetAttribute('unit', 'player')
		Button:SetAttribute('filter', 'HELPFUL')

		Button.Cooldown = CreateFrame('Cooldown', nil, Button, 'CooldownFrameTemplate')

		Button:SetScript('OnLeave', addon.HideTooltip)
		Button:SetScript('OnEnter', function(self)
			local tooltip = addon:GetTooltip(self, 'ANCHOR_RIGHT')
			if tooltip:SetToyByItemID(TOY_ID) then
				tooltip:Show()
			end
		end)

		Button:SetScript('OnShow', function(self)
			self:RegisterEvent('BAG_UPDATE_COOLDOWN', updateCooldown)
			updateCooldown(self)
		end)

		Button:SetScript('OnHide', function(self)
			self:UnregisterEvent('BAG_UPDATE_COOLDOWN', updateCooldown)
		end)

		-- lazy-load the texture
		local item = Item:CreateFromItemID(TOY_ID)
		item:ContinueOnItemLoad(function()
			Button:SetItemButtonTexture(item:GetItemIcon())
			Button:SetItemButtonQuality(Enum.ItemQuality.Rare)
		end)

		-- hide whenever the player enters combat
		RegisterStateDriver(Button, 'visibility', '[combat] hide;')
	end

	Button:Show()
end

addon:RegisterEvent('TRADE_SKILL_DATA_SOURCE_CHANGED', function()
	local professionInfo = C_TradeSkillUI.GetBaseProfessionInfo()
	if professionInfo and professionInfo.professionID == 185 then -- cooking
		addon:Defer(showButton)
	elseif Button then
		addon:DeferMethod(Button, 'Hide')
	end
end)

addon:RegisterCallback('ProfessionsFrame.Hide', function()
	if Button then
		addon:DeferMethod(Button, 'Hide')
	end
	addon:Defer(C_Spell.CancelSpellByID, BUFF_ID) -- remove the buff
end)
