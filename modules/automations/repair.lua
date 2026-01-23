local _, addon = ...

-- automatically repair when interacting with a vendor that can do so

local SPENT_SPLIT = 'Repaired for: %s (%s using guild funds)'
local SPENT_GUILD = 'Repaired for: %s with guild funds'
local SPENT_POCKET = 'Repaired for: %s'

local function formatCoin(coin, value)
	return CreateAtlasMarkup('Coin-' .. coin, 10, 10) .. FormatLargeNumber(value)
end

local function formatMoney(copper)
	local str = ''
	if copper >= COPPER_PER_GOLD then
		str = str .. formatCoin('Gold', math.floor(copper / COPPER_PER_GOLD)) .. ' '
	end
	if copper >= COPPER_PER_SILVER then
		str = str .. formatCoin('Silver', math.floor((copper / SILVER_PER_GOLD) % COPPER_PER_SILVER)) .. ' '
	end
	if copper > 0 then
		str = str .. formatCoin('Copper', copper % COPPER_PER_SILVER) .. ' '
	end
	return str:sub(1, -2)
end

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
					chatMessage(SPENT_SPLIT:format(formatMoney(spent), formatMoney(cost - spent)))
				else
					chatMessage(SPENT_POCKET:format(formatMoney(spent)))
				end
			else
				chatMessage(SPENT_GUILD:format(formatMoney(cost)))
			end
		end
	end
end
