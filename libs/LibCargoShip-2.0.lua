assert(LibStub, "LibCargoShip-2.0 requires LibStub")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local lib, oldminor = LibStub:NewLibrary("LibCargoShip-2.0", 2)
if(not lib) then return end

--[[
	lib  core
]]

local obj, dataobj, unused
local _G = getfenv(0)
local defaults = {}
local objects = {}
local updateFunctions

function lib:Style(object, opt)
	-- Default dimensions
	object:SetWidth(opt.width or 70)
	object:SetHeight(opt.height or 12)
	object:SetScale(opt.scale or 1)
	object:SetAlpha(opt.alpha or 1)

	if(not opt.noIcon) then	-- Icon left side
		object.Icon = object:CreateTexture(nil, "OVERLAY")
		object.Icon:SetPoint("TOPLEFT")
		object.Icon:SetPoint("BOTTOMLEFT")
		object.Icon:SetWidth(object:GetHeight())
	end

	if(not opt.noText) then	-- Text right
		object.Text = object:CreateFontString(nil, "OVERLAY", opt.fontObject)
		if(not opt.fontObject) then
			object.Text:SetFont(opt.font or "Fonts\\FRIZQT__.TTF", opt.fontSize or 10, opt.fontStyle)
			if(not opt.noShadow) then
				object.Text:SetShadowOffset(1, -1)
			end
		end
		object.Text:SetJustifyH("CENTER")
		if(object.Icon) then	-- Don't overlap the icon!
			object.Text:SetPoint("TOPLEFT", object.Icon, "TOPRIGHT", 5, 0)
		else
			object.Text:SetPoint("TOPLEFT")
		end
		object.Text:SetPoint("BOTTOMLEFT")
	elseif(object.Icon) then	-- Only icon? Then we don't need space for labels
		object:SetWidth(object:GetHeight())
	end
end

local function updateBlock(object, attr, dataobj)
	if(updateFunctions[attr]) then
		updateFunctions[attr](object, attr, dataobj or object.DataObject)
	end
end
local function attributeChanged(object, event, name, attr, value, dataobj)
	updateBlock(object, attr, dataobj)
end

local function initBlock(self, dataobj)
	self.DataObject = dataobj
	LDB.RegisterCallback(self, "LibDataBroker_AttributeChanged_"..self.Name, attributeChanged, self)
	self:Update("icon")
	self:Update("text")
	self:Update("tooltip")
	self:Update("OnClick")
	self:Show()
	return true
end

--[[*****************************
	lib:CreateBlock(name [, noIcon, noLabel, formatting])
		Attempts to return the frame which is used by dataobject "name"
		If it does not exist, it will be created with the defined arguments
*******************************]]
function lib:Create(name, opt)
	if(type(name) == "table" and not opt) then
		opt = name
		name = opt.name
	end
	if(not name or name:len() < 1) then return end
	opt = opt or defaults

	local object = CreateFrame("Button", nil, opt.parent or UIParent)
	object:RegisterForClicks("anyUp")
	object.Formatting = opt.formatting
	object.Name = name
	objects[name] = objects[name] or {}
	tinsert(objects[name], object)
	object.Update = updateBlock
	object.Init = initBlock
	
	object:Hide()

	if(opt.style) then
		opt.style(object, opt)
	else
		self:Style(object, opt)
	end

	local dataobj = LDB:GetDataObjectByName(name)
	if(dataobj) then object:Init(dataobj) end

	return object
end

function lib:Get(name) return objects[name] end

--[[*****************************
	lib:PrintUnused()
		Prints all unused dataobjects to chatframe
*******************************]]
function lib:PrintUnused()
	local text
	for name, _ in LDB:DataObjectIterator() do
		if(not objects[name]) then text = (text and text..", " or "")..name end
	end
	print("|cffee8800cargoShip:|r "..(text or "No unused dataobjects found"))
end

--[[*****************************
	lib:GetUnused()
		Return a table of all unused dataobjects
*******************************]]
local unused = {}
function lib:GetUnused()
	for name, dataobj in LDB:DataObjectIterator() do
		if(not objects[name]) then unused[name] = dataobj else unused[name] = nil end
	end
	return unused
end

--[[##################################
	PRIVATE OBJECT FUNCTIONS
###################################]]

local function getTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

local function showTooltip(self)
	local dataobj = self.DataObject
	local frame = dataobj.tooltip or GameTooltip
	frame:SetOwner(self, getTipAnchor(self))
	if(not dataobj.tooltip and dataobj.OnTooltipShow) then
		dataobj.OnTooltipShow(frame)
	end
	frame:Show()
end

local function hideTooltip(self)
	local frame = self.DataObject.tooltip or GameTooltip
	frame:Hide()
end



--[[##################################
	UPDATE FUNCTIONS
###################################]]
updateFunctions = {
	["icon"] = function(self, attr, dataobj)
		if(not self.Icon) then return end
		self.Icon:SetTexture(dataobj.icon)
		self:Update("iconCoords")
		self:Update("iconR")
	end,
	["iconCoords"] = function(self, attr, dataobj)
		if(dataobj.iconCoords) then
			self.Icon:SetTexCoord(unpack(dataobj.iconCoords))
		else
			self.Icon:SetTexCoord(0, 1, 0, 1)
		end
	end,
	["iconR"] = function(self, attr, dataobj)
		self.Icon:SetVertexColor(dataobj.iconR or 1, dataobj.iconG or 1, dataobj.iconB or 1)
	end,
	["text"] = function(self, attr, dataobj)
		if(not self.Text) then return end
		if(self.Formatting) then
			if(self.useLabel) then
				self.Text:SetFormattedText(self.Formatting, dataobj.label or name, dataobj.value, dataobj.suffix)
			else
				self.Label:SetFormattedText(self.Formatting, dataobj.value, dataobj.suffix)
			end
		else
			local text = self.useLabel and (dataobj.label or self.Name) or ""
			if(dataobj.text) then
				if(self.useLabel) then
					text = text..": "..dataobj.text
				else
					text = dataobj.text
				end
			end
			self.Text:SetText(text)
		end
		local iconWidth = self.Icon and self.Icon:GetWidth()+5 or 0
		local textWidth = self.Text:GetWidth() or 0
		self:SetWidth(iconWidth+textWidth)
	end,
	["OnEnter"] = function(self, attr, dataobj)
		self:SetScript("OnEnter", (dataobj.tooltip and showTooltip) or dataobj.OnEnter or (dataobj.OnTooltipShow and showTooltip))
	end,
	["OnLeave"] = function(self, attr, dataobj)
		self:SetScript("OnLeave", (dataobj.tooltip and hideTooltip) or dataobj.OnLeave or (dataobj.OnTooltipShow and hideTooltip))
	end,
	["tooltip"] = function(self, attr, dataobj)
		self:Update("OnEnter")
		self:Update("OnLeave")
	end,
	["OnClick"] = function(self, attr, dataobj)
		self:SetScript("OnClick", dataobj.OnClick)
	end,
}

updateFunctions.value = updateFunctions.text
updateFunctions.suffix = updateFunctions.text
updateFunctions.iconG = updateFunctions.iconR
updateFunctions.iconB = updateFunctions.iconR
updateFunctions.OnTooltipShow = updateFunctions.tooltip

--[[##################################
	PRIVATE FUNCTIONS
###################################]]

local function dataObjectCreated(event, name, dataobj)
	if(not objects[name]) then return end
	for _, object in pairs(objects[name]) do
		object:Init(dataobj)
	end
end

lib.Objects = objects
lib.UpdateFunctions = updateFunctions
lib = setmetatable(lib, {__call = lib.Create})
LDB.RegisterCallback(lib, "LibDataBroker_DataObjectCreated", dataObjectCreated)
_G["cargoShip"] = lib