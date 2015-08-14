local E, F = unpack(select(2, ...))

local function ShipmentQueue(_, _, _, maxShipments)
	local numPending = C_Garrison.GetNumPendingShipments()
	if(C_Garrison.IsOnShipmentQuestForNPC()) then
		maxShipments = 1
	end

	local available = maxShipments - numPending
	if(available > 0) then
		C_Garrison.RequestShipmentCreation(available)
	end

	return true
end

function E:SHIPMENT_CRAFTER_OPENED()
	E:RegisterEvent('SHIPMENT_CRAFTER_INFO', ShipmentQueue)
end

function E:LOOT_CLOSED()
	if(GarrisonCapacitiveDisplayFrame and GarrisonCapacitiveDisplayFrame:IsShown()) then
		E:RegisterEvent('SHIPMENT_CRAFTER_INFO', ShipmentQueue)
	end
end
