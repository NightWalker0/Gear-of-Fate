--[[
    Desc: Ai utility of navigation move, control the entity to move along the specified path.
    Author: SerDing
    Since: 2021-05-03
    Alter: 2021-05-03
]]
local _Vector2 = require("utils.vector2")
local _MATH = require("engine.math")

---@class Entity.Ai.Utils.NavMove
local _NavMove = require("core.class")()

function _NavMove:Ctor()
	self._target = _Vector2.New(0, 0)
	self._path = nil
	self._node = nil
	self._nodeIndex = 1
	self._direction = _Vector2.New(0, 0)
	self.isMoving = false
end

---@param entity Entity
---@param navigation System.Navigation
function _NavMove:Init(entity, navigation)
	self._position = entity.transform.position
	self._navigation = navigation
	self._input = entity.input
end

function _NavMove:Update(dt)
	if not self._path then
		return true
	end

	local reach = false
	local reachx = false
	local reachy = false
	local nodex, nodey = self._navigation:GetNodePosition(self._node:Get())
	if self._direction.x == 0 or
			(self._direction.x == 1 and self._position.x >= nodex) or
			(self._direction.x == -1 and self._position.x <= nodex) then
		reachx = true
	end

	if self._direction.y == 0 or
			(self._direction.y == 1 and self._position.y >= nodey) or
			(self._direction.y == -1 and self._position.y <= nodey) then
		reachy = true
	end

	reach = reachx and reachy

	if reach or self._nodeIndex == 1 then
		--print("NavMove, reach node")
		self._input:InputAction("move-left", self._input.STATE.RELEASED)
		self._input:InputAction("move-right", self._input.STATE.RELEASED)
		self._input:InputAction("move-up", self._input.STATE.RELEASED)
		self._input:InputAction("move-down", self._input.STATE.RELEASED)

		self._nodeIndex = self._nodeIndex + 1
		if self._nodeIndex > #self._path then -- reach destination node
			self.isMoving = false
			self._path = nil
			self._node = nil
			self._nodeIndex = 1
			return true
			--print("NavMove, reach dest node")
		else
			self._node = self._path[self._nodeIndex]
			local nx, ny = self._navigation:GetNodeIndexByPos(self._position:Get())
			self._direction.x = _MATH.Sign(self._node.x - nx)
			self._direction.y = _MATH.Sign(self._node.y - ny)
			local action = ""
			if self._direction.x ~= 0 then
				action = self._direction.x > 0 and "move-right" or "move-left"
				self._input:InputAction(action, self._input.STATE.PRESSED)
			end
			if self._direction.y ~= 0 then
				action = self._direction.y > 0 and "move-down" or "move-up"
				self._input:InputAction(action, self._input.STATE.PRESSED)
			end

			--self.isMoving = true
			--print("NavMove, start move to node")
		end
	end
	return false
end

function _NavMove:Run(path)
	self._path = path
	self._node = path[1]
	self._nodeIndex = 1
	self._direction:Set(0, 0)
	self.isMoving = true
end

function _NavMove:StopMove()
	self._path = nil
	self._node = nil
	self._nodeIndex = 1
	self._direction:Set(0, 0)
	self.isMoving = false
	self._input:InputAction("move-left", self._input.STATE.RELEASED)
	self._input:InputAction("move-right", self._input.STATE.RELEASED)
	self._input:InputAction("move-up", self._input.STATE.RELEASED)
	self._input:InputAction("move-down", self._input.STATE.RELEASED)
end

return _NavMove

