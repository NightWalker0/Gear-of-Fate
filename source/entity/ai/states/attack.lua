--[[
	Desc: Ai attack state
	Author: SerDing
	Since: 2021-05-04
	Alter: 2021-05-11
]]
local _Timer = require("utils.timer")
local _Base = require("entity.ai.states.base")

---@class Entity.Ai.State.Attack : Entity.Ai.State.Base
local _Attack = require("core.class")(_Base)

function _Attack:Ctor(data, name)
	_Base.Ctor(self, data, name)
	self._attackInterval = data.attackInterval or 1300
end

---@param entity Entity
---@param aic Entity.Component.AIC
function _Attack:Init(entity, aic)
	_Base.Init(self, entity, aic)

	self._attackTimer = aic.attackTimer
end

---@param skill Entity.Skill
function _Attack:Enter(skill)
	if not skill then
		LOG.Debug("Enter ai_attack, invalid skill")
		return false
	end

	self._input:InputAction(skill.inputEvent.name, EInput.STATE.PRESSED)
	self.skill = skill
	self.skill.OnFinish:AddListener(self, self.OnSkillFinish)
	self.skillFinish = false
	self.actionState = skill.actionState ---@type Entity.State.Base
	self._aic.navmove:StopMove()
	self._entity.render.skillCollider = skill.collider

	LOG.Debug("Enter ai_attack, skill:%s", skill.name)
	return true
end

function _Attack:Update(dt)
	if self._aic.target then
		if self.skill then
			self._input:InputAction(self.skill.inputEvent.name, EInput.STATE.PRESSED)
			self._entity.render.skillCollider = self.skill.collider
			self.skill.OnFinish:AddListener(self, self.OnSkillFinish)
			self.skillFinish = false
		else
			LOG.Debug("Ai_attack, invalid skill")
			self.FSM:SetState("wander")
		end
	else
		LOG.Debug("Ai_attack, no target")
		self.FSM:SetState("wander")
	end
end

function _Attack:Exit()
	self._entity.render.skillCollider = nil
	self.skill.OnFinish:DelListener(self, self.OnSkillFinish)
end

---@param skill Entity.Skill
function _Attack:OnSkillFinish(skill)
	self._attackTimer:Start(self._attackInterval)
	self.FSM:SetState("pursuit")
	--_LOG.Debug("skill finish:%s", skill.name)
end

return _Attack