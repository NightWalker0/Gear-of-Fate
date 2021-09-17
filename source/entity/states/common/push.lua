--[[
	Desc: State of being pushed aside
	Author: SerDing 
	Since: 2018-02-26 14:25:46 
	Alter: 2018-02-26 14:25:46 
]]
local _Timer = require("utils.timer")
local _Base  = require("entity.states.base")

---@class State.Push : Entity.State.Base
local _Push = require("core.class")(_Base)

function _Push:Ctor(data, name)
	_Base.Ctor(self, data, name)
	self._timer = _Timer.New()
end

function _Push:Init(entity)
	_Base.Init(self, entity)
	-- self._combat.onAttackedEvent:AddListener(self, self.SetAttackedData)
end

function _Push:SetAttackedData(attackedData)
	
end

function _Push:Enter(time, v, a)
	_Base.Enter(self)
	local index = math.random(1, #self._animNameSet)
	self._avatar:Play(self._animNameSet[index])
	self._timer:Start(time)
	self._movement:EaseMove("x", v, a)
end

function _Push:Update(dt)
	self._timer:Tick(dt)
	if self._timer.isRunning == false then
		self._STATE:SetState(self._nextState)
	end
	self._movement:EasemoveUpdate(dt)
end

function _Push:Exit()
    
end

return _Push