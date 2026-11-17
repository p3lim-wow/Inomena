local _, addon = ...

if addon:IsForever() then
	-- Edit Mode handles positioning, we just have to raise it
	QueueStatusButton:SetFrameStrata('HIGH')
else
	-- move the queue button to the minimap like it was in the olden days
	hooksecurefunc(QueueStatusButton, 'UpdatePosition', function()
		QueueStatusButton:SetParent(UIParent)
		QueueStatusButton:ClearAllPoints()
		QueueStatusButton:SetPoint('TOPRIGHT', Minimap, -10, -10)
		QueueStatusButton:SetFrameStrata('HIGH') -- make sure we can click it
	end)
end
