local _, addon = ...

-- automatically repair when interacting with a vendor that can do so

local SPENT_SPLIT = 'Repaired for: %s (%s using guild funds)'
local SPENT_GUILD = 'Repaired for: %s with guild funds'
local SPENT_POCKET = 'Repaired for: %s'

local function chatMessage(msg)
	local info = ChatTypeInfo.SYSTEM
	DEFAULT_CHAT_FRAME:AddMessage(msg, info.r, info.g, info.b, info.id)
end

function addon:MERCHANT_SHOW()
	if not IsShiftKeyDown() and CanMerchantRepair() then
		local cost, isAvailable = GetRepairAllCost()
		if isAvailable and cost > 0 then
			-- store current amount of money before we repair
			local money = GetMoney()

			-- repair using guild bank funds if we can
			RepairAllItems(CanGuildBankRepair() and GetGuildBankMoney() >= cost)

			local spent = money - GetMoney()
			if spent > 0 then
				if spent ~= cost then
					chatMessage(SPENT_SPLIT:format(GetMoneyString(spent), GetMoneyString(cost - spent)))
				else
					chatMessage(SPENT_POCKET:format(GetMoneyString(spent)))
				end
			else
				chatMessage(SPENT_GUILD:format(GetMoneyString(cost)))
			end
		end
	end
end
