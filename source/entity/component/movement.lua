--[[
    Desc: Movement Component
	Author: SerDing 
	Since: 2018-08-29 
	Alter: 2020-03-13 
]]
local _TIME = require("engine.time")
local _Vector2 = require("utils.vector2")
local _Event = require("core.event")
local _Base = require("entity.component.base")

---@class Entity.Component.Movement : Entity.Component.Base
---@field public eventMap table<string, Event>
---@field protected _g number
---@field protected _vz number
---@field protected _directionZ number
---@field protected _fallCondition function
---@field public _easemoveParam table
local _Movement = require("core.class")(_Base)

local _stableFPS = 60
local _DIRECTION_Z = {
	UP = 1,
	NONE = 0,
	DOWN = -1,
}

local _navigation ---@type System.Navigation

---@param navigation System.Navigation
function _Movement.SetNavigation(navigation)
	_navigation = navigation
end

function _Movement:Ctor(entity, data)
	_Base.Ctor(self, entity)
	self._position = entity.transform.position
	self._input = entity.input
	self._dt = 0
	self._g = 0
	self._vz = 0
	self._directionZ = _DIRECTION_Z.NONE
	self._easemoveParam = {
		type = "",
		v = 0,
		a = 0,
		addRate = 0.5,
		dir = 0,
		isRunning = false,
	}
	self.eventMap = {
		topped = _Event.New(),
		touchdown = _Event.New(),
		onMove = _Event.New(),
	}
	self.moveInput = { left = false, right = false, up = false, down = false }
	self.moveSignalTime = { left = 0, right = 0, up = 0, down = 0 }
	self.ignoreObstacle = data.ignoreObstacle or false
end 

function _Movement:Update(dt)
	self._dt = dt
	if self._entity.identity.isPaused == false then
		self:EasemoveUpdate(dt)
		self:Gravity(dt)
	end
end

function _Movement:Move(axis, offset)
	local ox, oy = self._position:Get()
	self._dt = self._dt == 0 and _TIME.GetStandardDelta() or self._dt
	self._position[axis] = self._position[axis] + offset * self._dt
	if self.ignoreObstacle == false and (axis == "x" or axis == "y") then
		local x, y, collisionType = _navigation:AmendMovePosition(ox, oy, self._position.x, self._position.y, axis)
		if axis == "x" then
			self.eventMap.onMove:Notify(axis, collisionType == "none", x - ox)
		elseif axis == "y" then
			self.eventMap.onMove:Notify(axis, collisionType == "none", y - oy)
		end
		self._position:Set(x, y)
		return collisionType
	end
end

function _Movement:Set_g(g)
    self._g = g
end 

---@param vz number @ velocity of z axis
---@param g number @ acceleration of gravity
---@param fallCond function @ condition of falling
function _Movement:StartJump(vz, g, fallCond)
	vz = vz or 0
	g = g or 0
	self._vz = vz
	self._g = (g == 0) and self._g or g
	self._directionZ = _DIRECTION_Z.UP
	self._fallCondition = fallCond
end

function _Movement:Gravity(dt)
	if self._directionZ == _DIRECTION_Z.UP then
		self._vz = self._vz - dt * self._g * _stableFPS
        if self._vz < 0 then
            self._vz = 0 
		end
		
		self:Move("z", -self._vz)
		local fall = (self._vz <= 0) and true or false
		if self._fallCondition then
			fall = self._fallCondition()
		end
        if fall then
			self._directionZ = _DIRECTION_Z.DOWN
			self.eventMap.topped:Notify()
		end
    elseif self._directionZ == _DIRECTION_Z.DOWN then
		self._vz = self._vz + dt * self._g * _stableFPS
		if self._position.z < 0 then
			self:Move("z", self._vz)
		end
		if self._position.z >= 0 then
			self._position.z = 0
			self._directionZ = _DIRECTION_Z.NONE
			self._g = 0
			self._vz = 0
			self.eventMap.touchdown:Notify()
			self._fallCondition = nil
		end
    end  
end 

---@param type string
---@param v int
---@param a int
---@param addRate float
function _Movement:EaseMove(type, v, a, addRate)
	self._easemoveParam.type = type
	self._easemoveParam.v = v --* self._entity.transform.direction
	self._easemoveParam.a = a --* self._entity.transform.direction
	self._easemoveParam.addRate = addRate or 0
	self._easemoveParam.isRunning = true
	-- if self._easemoveParam.a < 0 then
	-- 	self._easemoveParam.dir = -1
	-- elseif self._easemoveParam.a > 0 then
	-- 	self._easemoveParam.dir = 1
	-- else
	-- 	self._easemoveParam.dir = 0
	-- end
end

function _Movement:EasemoveUpdate(dt)
	if self._easemoveParam.isRunning == true then
		local entityDirection = self._entity.transform.direction
		if self._easemoveParam.type == "x" then
			self:Move('x', self._easemoveParam.v * entityDirection)
		elseif self._easemoveParam.type == "y" then
			self:Move('y', self._easemoveParam.v * entityDirection)
		end

		self._easemoveParam.v = self._easemoveParam.v + self._easemoveParam.a * dt
		if self._easemoveParam.a < 0 then
			if self._easemoveParam.v <= 0 then
				self._easemoveParam.v = 0
				self._easemoveParam.isRunning = false
			end
		elseif self._easemoveParam.a > 0 then
			if self._easemoveParam.v >= 0 then
				self._easemoveParam.v = 0
				self._easemoveParam.isRunning = false
			end
		end

		if self._entity.transform.direction == -1 then
			if self.moveInput.left then
				self:Move('x', self._easemoveParam.v * entityDirection * self._easemoveParam.addRate)
			end
		elseif self._entity.transform.direction == 1 then
			if self.moveInput.right then
				self:Move('x', self._easemoveParam.v * entityDirection * self._easemoveParam.addRate)
			end
		end

	end
end

function _Movement:StopEasemove()
	self._easemoveParam.isRunning = false
end

function _Movement:IsEasemoving()
	return self._easemoveParam.isRunning
end

function _Movement:IsFalling()
	return self._directionZ == _DIRECTION_Z.DOWN
end

function _Movement:IsRising()
	return self._directionZ == _DIRECTION_Z.UP
end

return _Movement 