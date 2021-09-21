--[[
	Desc: Skill Object
	Author: SerDing 
	Since: 2018-08-21 02:16:12 
	Last Modified time: 2018-08-21 02:16:12
]]
local _Event = require("core.event")
local _RESOURCE = require("engine.resource")
local _Collider = require("entity.collider")
local _Timer = require("utils.timer")
---@class Entity.Skill
local _Skill = require("core.class")()

local _STATE = { USABLE = 1, UNUSABLE = 2}

function _Skill.HandleData(data)

end

---@param entity Entity
---@param data System.RESMGR.SkillData
function _Skill:Ctor(entity, data, skillComponent)
	self._data = data
	self._entity = entity
	self._skillComponent = skillComponent

	self.name = data.name
	self.icon = data.icon
	self.inputEvent = data.inputEvent
	self.actionState = data.state
	self.isCombo = data.isCombo or false
	self.aiPriority = data.aiPriority or 0
	self._cooldownTime = data.cooldownTime or 0
	self._castCost = data.actingCost
	self.cooldown = false
	self.active = false
	self.state = _STATE.USABLE
	self._timer = _Timer.New()
	self.OnFinish = _Event.New()
	if data.colliderData then
		self.collider = _Collider.New(data.colliderData)
	end
	self.debug = false
	self.stateDebug = {
		cooldownOver = false,
		isInPreState = false,
		energyEnough = false,
	}
end

function _Skill:Init()
	self._entityInput = self._entity.input
	self._entityState = self._entity.state
	local data = self._data
	if data.inputEvent.name ~= "uncertain" then
		if data.inputEvent.state == "ALL" then
			self._entityInput:BindAction(data.inputEvent.name, EInput.STATE.PRESSED, self, self._InputCallback)
			self._entityInput:BindAction(data.inputEvent.name, EInput.STATE.RELEASED, self, self._InputCallback)
		else
			self._entityInput:BindAction(data.inputEvent.name, EInput.STATE[data.inputEvent.state], self, self._InputCallback)
		end
		--_LOG.Debug("Skill BindAction:%s %s", data.inputEvent.name, data.inputEvent.state)
	end
end

function _Skill:Update(dt)
	self.state = _STATE.UNUSABLE
	local cooldownOver = false
	local isInPreState = false
	local energyEnough = false

	if self.cooldown then
		self._timer:Tick(dt)
		if not self._timer.isRunning then
			self.cooldown = false
		end
	end
	cooldownOver = not self.cooldown

	local preStates = self._data.preStates
	for i = 1, #preStates do
		local curState = self._entityState:GetCurState()
		local stateName = self._entityState:GetCurState():GetName()
		if stateName == preStates[i] or
		(preStates[i] == "normalskills" and curState:HasTag("isNormalSkill")) then
			isInPreState = true
		end
	end

	local mp = self._entity.stats.mp:GetCur()
	local actingCost = self._data.actingCost
	if mp >= actingCost then
		energyEnough = true
	end

	if cooldownOver and isInPreState and energyEnough then
		 self.state = _STATE.USABLE
	end
	self.stateDebug.cooldownOver = cooldownOver
	self.stateDebug.isInPreState = isInPreState
	self.stateDebug.energyEnough = energyEnough
end

function _Skill:_InputCallback()
	--_LOG.Debug("skill inputcallback:%s", self.name)
	if self:CanCast() then
		--_LOG.Debug("skill inputcallback:%s is usable", self.name)
		if self._entityState:GetCurState():GetName() ~= self.actionState then
			self:CostEnergy()
		end
		if self._cooldownTime > 0 then
			self._entityState:GetState(self.actionState).onExit:AddListener(self, self.Finish)
		end
		self:Cast()
	end
end

function _Skill:Cast()
	if self._data.stateArgs then
		self._entityState:TrySwtich(self.actionState, unpack(self._data.stateArgs))
	else
		self._entityState:TrySwtich(self.actionState)
	end
end

function _Skill:CostEnergy()
	if self._castCost > 0 then
		self._entity.stats.mp:Decrease(self._castCost)
	end
end

function _Skill:SetActive(active)
	self.active = active
end

function _Skill:Finish()
	self:StartCooldown()
	self.OnFinish:Notify(self)
	if self._cooldownTime > 0 then
		self._entityState:GetState(self.actionState).onExit:DelListener(self, self.Finish)
	end
	self._skillComponent:OnSkillFinish(self)
end

function _Skill:StartCooldown()
	if self._cooldownTime <= 0 then
		return
	end

	self._timer:Start(self._cooldownTime)
	self.cooldown = true
end 

function _Skill:CanCast()
	if self.debug then
		return true
	end

	return self.state == _STATE.USABLE
end

---@param target Entity
function _Skill:IsInAttackRange(target)
	if self.collider then
		local transform = self._entity.transform
		local position = transform.position
		local scale = transform.scale
		local direction = transform.direction
		self.collider:Set(position.x, position.y, position.z, scale.x * direction, scale.y)
		local targetColliders = target.render:GetColliders()--todo:获取不到colliders
		LOG.Debug("Skill.IsInAttackRange: targetColliders:" .. tostring(#targetColliders))
		for i = 1, #targetColliders do
			if self.collider:Collide(targetColliders[i], "attack", "damage") then
				return true
			end
		end
		return false
	end

	return false
end

return _Skill 