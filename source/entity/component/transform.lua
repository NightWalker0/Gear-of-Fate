--[[
	Desc: Transform Component
 	Author: SerDing
	Since: 2019-11-07 
	Alter: 2017-11-07 
]]
local _GRAPHICS = require("engine.graphics")
local _MATH = require("engine.math")
local _Vector2 = require("utils.vector2")
local _Vector3 = require("utils.vector3")
local _SETTING = require("setting")
local _Base = require("entity.component.base")


---@class Entity.Component.Transform : Entity.Component.Base
---@field public position Vector3
---@field public scale Vector2
---@field public rotation number @per degree
local _Transform = require("core.class")(_Base)

function _Transform:Ctor(entity, data, param)
	_Base.Ctor(self, entity)
	self.position = _Vector3.New(param.x or 0, param.y or 0, param.z or 0)
    self.scale = _Vector2.New(1, 1)
	self.rotation = data.rotation or 0
	self.direction = param.direction or 1

	if data.scale then
		self.scale:Set(data.scale.x, data.scale.y)
	end
end

function _Transform:Draw()
	if _SETTING.debug.transform then
		_GRAPHICS.Points(self.position.x, self.position.y + self.position.z)
	end
end

function _Transform:SetPosition(x, y, z)
	self.position:Set(x, y, z)
end

function _Transform:SetScale(x, y)
	self.scale:Set(x, y)
end

---check if self is in the back of another transform and keep same direction with it
---@param transform Entity.Component.Transform
function _Transform:IsInBackOf(transform)
	return self.direction == transform.direction and (transform.position.x - self.position.x) * self.direction > 0
end

---@param position Vector3
function _Transform:FaceTo(position)
	local sign = _MATH.Sign(position.x - self.position.x)
	self.direction = sign == 0 and 1 or sign
end

return _Transform