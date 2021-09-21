--[[
	Desc: Sprite class
 	Author: SerDing
	Since: 2017-07-26 23:41:15
	Alter: 2020-02-10 02:11:12
]]
local _SETTING = require("setting")
local _RESOURCE = require('engine.resource')
local _Rect = require("engine.graphics.drawable.rect")
local _Base = require("engine.graphics.drawable.base") 

---@class Engine.Graphics.Drawable.Sprite:Engine.Graphics.Drawable.Base 
---@field protected _data Engine.Graphics.Drawable.SpriteData
---@field protected _rect Engine.Graphics.Drawable.Rect
local _Sprite = require("core.class")(_Base)

---@class Engine.Graphics.Drawable.SpriteData
---@field public image string | Image
---@field public ox float
---@field public oy float
---@field public sx float
---@field public sy float
---@field public blendMode string
--[[
	---@field public angle float 
	---@field public color Engine.Graphics.Config.Color
]]
local _SpriteData = require("core.class")()

local _emptyTable = {}

---@param data Engine.Graphics.Drawable.SpriteData
function _Sprite:Ctor(data)
	_Base.Ctor(self)
	self._quad = love.graphics.newQuad(0, 0, 1, 1, 1,1)
	self._rect = _Rect.New(0, 0, 1, 1)
	-- self._rect:SetColor(255, 255, 255, 150)

	self.eventMap.setPosition:AddListener(self, self._UpdateRect)
	self.eventMap.setScale:AddListener(self, self._UpdateRect)
	self.eventMap.setOrigin:AddListener(self, self._UpdateRect)
	
	self:SetData(data)
end

function _Sprite:_OnDraw()
	_Base.DrawObj(self, self._image)
	if _SETTING.debug.sprite then
		self._rect:Draw(_, "line")
	end
end

---@param data Engine.Graphics.Drawable.SpriteData
function _Sprite:SetData(data)
	data = data or _emptyTable
	self._data = data
	
	local ox = data.ox or 0
	local oy = data.oy or 0
	local sx = data.sx or 1
	local sy = data.sy or 1
	local angle = data.angle or 0
	local blendmode = data.blendmode or "alpha"

	self:SetImage(data.image)
	self:SetRenderValue("blendmode", blendmode)
	self:SetRenderValue("origin", ox, oy)
	self:SetRenderValue("scale", sx, sy)
	self:SetRenderValue("radian", angle)

end

function _Sprite:_UpdateRect()
	local px, py = self:GetRenderValue("position")
	local sx, sy = self:GetRenderValue("scale")
	local ox, oy = self:GetRenderValue("origin")
	local iw = self:GetWidth()
	local ih = self:GetHeight()
	local b1 = (sx < 0) and 1 or 0
	local b2 = (sy < 0) and 1 or 0
	local x = px - ox * sx - iw * b1
	local y = py - oy * sy - ih * b2
	self._rect:SetDrawData(x, y, iw * math.abs(sx), ih * math.abs(sy))
end

function _Sprite:SetImage(image)
	if image == nil then
		self._image = _RESOURCE.nullImg
		return
	end

	if image == self._image then
		return
	end

	self._image = type(image) == "string" and _RESOURCE.LoadImage(image) or image
	self:SetQuad(0, 0, self._image:getDimensions())
end

---@param x number @ drawing area x
---@param y number @ drawing area y
---@param w number @ drawing area w
---@param h number @ drawing area h
function _Sprite:SetQuad(x, y, w, h)
	self._quad:setViewport(x, y, w, h, self._image:getDimensions())
	self._rect:SetSize(w, h)
end

function _Sprite:SetOrigin(x, y)
	self:SetRenderValue("origin", x, y)
end

function _Sprite:GetImage()
	return self._image
end

function _Sprite:GetRect()
	return self._rect
end

function _Sprite:GetWidth()
	return self._image:getWidth()
end

function _Sprite:GetHeight()
	return self._image:getHeight()
end

return _Sprite