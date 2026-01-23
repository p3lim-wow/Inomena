local _, addon = ...

-- quick access to ReloadUI

local button = addon:CreateBindButton('Reload')
button:Bind('F12')
button:SetScript('OnClick', C_UI.Reload)
