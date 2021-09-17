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
	self.skillFinish = true
end

---@param entity Entity
---@param aic Entity.Component.AIC
function _Attack:Init(entity, aic)
	_Base.Init(self, entity, aic)

	self._targetSelector = aic.targetSelector
	self._skillSelector = aic.skillSelector
	self._attackTimer = aic.attackTimer
end

---@param skill Entity.Skill
function _Attack:Enter(skill)
	if skill then
		LOG.Debug("Enter ai_attack, skill:%s", skill.name)
		self._input:InputAction(skill.inputEvent.name, self._input.STATE.PRESSED)
		self.skill = skill
		self.skill.OnFinish:AddListener(self, self.OnSkillFinish)
		self.skillFinish = false
		self.actionState = skill.actionState ---@type Entity.State.Base
		self._aic.navmove:StopMove()
		self._entity.render.skillCollider = skill.collider
	end
end

function _Attack:Update(dt)
	if not self.skillFinish then
		return
	end

	--self._attackTimer:Tick(dt)
	--if self._attackTimer.isRunning then
	--	return
	--end

	if self._aic.target then
		if self.skill and self.skill:CanCast() and self.skill:IsInAttackRange(target) then
			self._input:InputAction(self.skill.inputEvent.name, self._input.STATE.PRESSED)
		else
			self.skill = self._aic:SelectSkill()--self._skillSelector:Run()
			if self.skill and not self._attackTimer.isRunning then
				LOG.Debug("Ai_attack, update, skill:%s", self.skill.name)
				self._input:InputAction(self.skill.inputEvent.name, self._input.STATE.PRESSED)
				self._entity.render.skillCollider = self.skill.collider
				self.skill.OnFinish:AddListener(self, self.OnSkillFinish)
				self.skillFinish = false
			else
				LOG.Debug("Ai_attack, no usable skill.")
				self.FSM:SetState("pursuit")
			end
		end
	else
		LOG.Debug("Ai_attack, no target")
		self.FSM:SetState("wander")
	end

end

function _Attack:Exit()
	self._entity.render.skillCollider = nil
end

---@param skill Entity.Skill
function _Attack:OnSkillFinish(skill)
	self.skillFinish = true
	--self._attackTimer:Start(self._attackInterval)
	skill.OnFinish:DelListener(self, self.OnSkillFinish)
	--_LOG.Debug("skill finish:%s", skill.name)
end

return _Attack