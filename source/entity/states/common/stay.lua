--[[
	Desc: stay state 
 	Author: SerDing
	Since: 2017-07-28 21:54:14
	Alter: 2017-07-30 12:40:40
]]
local _Base  = require "entity.states.base"

---@class State.Stay : Entity.State.Base
local _Stay = require("core.class")(_Base)

function _Stay:Ctor(data, ...)
	_Base.Ctor(self, data, ...) 
end 

function _Stay:Enter()
	_Base.Enter(self)
end

function _Stay:Update(dt) 
	_Base.AutoTransitionAtEnd(self)

	if self._movement.moveInput.left or self._movement.moveInput.right
	or self._movement.moveInput.up or self._movement.moveInput.down then
		self._STATE:SetState(self._nextState, self._entity)
	end
end 

function _Stay:Exit()
	_Base.Exit(self)
end

return _Stay 