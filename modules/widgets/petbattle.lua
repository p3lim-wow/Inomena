local _, addon = ...

-- pop-up button to heal battle pets after a battle

local REVIVE_SPELL = 125439
local REVIVE_ITEM = 86143

local button = addon:CreateButton('ItemButton', nil, UIParent, 'SecureActionButtonTemplate, ActionButtonSpellAlertTemplate')
button:SetPoint('TOP', 0, -200)
button:SetSize(37, 37)
button:SetScale(1.5)
button:Hide()

-- adjust glow
button.ProcStartFlipbook:SetAlpha(0)
button.ProcLoopFlipbook:ClearAllPoints()
button.ProcLoopFlipbook:SetPoint('CENTER', button)
button.ProcLoopFlipbook:SetSize(55, 55)
button.NormalTexture:SetDrawLayer('ARTWORK', 1) -- render above glow because it looks pretty cool

local wrapper = CreateFrame('Frame', nil, nil, 'SecureHandlerBaseTemplate')
wrapper:WrapScript(button, 'PostClick', [[self:Hide()]])

function addon:PET_BATTLE_CLOSE()
	local spellCooldown = C_Spell.GetSpellCooldown(REVIVE_SPELL)
	if spellCooldown and spellCooldown.startTime > 0 then
		if C_Item.GetItemCount(REVIVE_ITEM) > 0 then
			local itemCooldown = C_Item.GetItemCooldown(REVIVE_ITEM)
			if not (itemCooldown and itemCooldown > 0) then
				button:SetAttribute('type1', 'item')
				button:SetAttribute('item', 'item:' .. REVIVE_ITEM)
				button:SetAttribute('spell', nil)
				button:SetItemButtonTexture(C_Item.GetItemIconByID(REVIVE_ITEM))
				button:Show()
				button.ProcLoop:Play()
			end
		end
	else
		button:SetAttribute('type1', 'spell')
		button:SetAttribute('spell', REVIVE_SPELL)
		button:SetAttribute('item', nil)
		button:SetItemButtonTexture(C_Spell.GetSpellTexture(REVIVE_SPELL))
		button:Show()
		button.ProcLoop:Play()
	end
end

function addon:PET_BATTLE_OPEN()
	addon:DeferMethod(button, 'Hide')
	button.ProcLoop:Stop()
end
