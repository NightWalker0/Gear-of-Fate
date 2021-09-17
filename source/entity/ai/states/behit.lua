--[[
	Desc: Ai behit state
	Author: SerDing
	Since: 2021-05-11
	Alter: 2021-05-11
]]

local _Base = require("entity.ai.states.base")

---@class Entity.Ai.State.BeHit : Entity.Ai.State.Base
local _BeHit = require("core.class")(_Base)

function _BeHit:Ctor(data, name)
	_Base.Ctor(self, data, name)
end

function _BeHit:Init(entity, aic)
	_Base.Init(self, entity, aic)

	self._targetSelector = aic.targetSelector
	self._skillSelector = aic.skillSelector
end

---@param skill Entity.Skill
function _BeHit:Enter()
	self._aic.navmove:StopMove()

	--self._UpdateThreat()
	--add self._UpdateThreat() to damage listening
end

function _BeHit:Update(dt)
	local actionState = self._controller:GetCurState():GetName()
	if actionState ~= "lift" and actionState ~= "push" then
		if self._targetSelector.target then
			self.FSM:SetState("pursuit")
		else
			self.FSM:SetState("wander")
		end
	end
end

function _BeHit:Exit()

end

return _BeHit