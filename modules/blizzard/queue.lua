
-- move the queue button to the minimap like it was in the olden days

hooksecurefunc(QueueStatusButton, 'UpdatePosition', function()
	QueueStatusButton:SetParent(UIParent)
	QueueStatusButton:ClearAllPoints()
	QueueStatusButton:SetPoint('TOPRIGHT', Minimap, -10, -10)
	QueueStatusButton:SetFrameLevel(10) -- make sure we can click it
end)
