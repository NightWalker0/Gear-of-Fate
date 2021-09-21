--[[
    Desc: Ai controller compoennt
    Author: SerDing
    Since: 2018-02-25
    Alter: 2021-05-04
]]
local _Fsm = require("utils.fsm")
local _Timer = require("utils.timer")
local _RESMGR = require("system.resource.resmgr")
local _ENTITYMGR = require("system.entitymgr")
local _SCENEMGR = require("system.scene.scenemgr")
local _NavMove = require("entity.ai.utils.navmove")
local _TargetSelector = require("entity.ai.utils.targetselector")
local _SkillSelector = require("entity.ai.utils.skillselector")
local _Base = require("entity.component.base")

---@class Entity.Component.AIC : Entity.Component.Base
---@field public target Entity
local _AiComponent = require("core.class")(_Base)

local _DEFAULT_STATE = "wander"
EAIState = {
	Wander = 1,
	Pursuit = 2,
	Attack = 3,
}

function _AiComponent.HandleData(data)
	--if data.states then
	--	for key, value in pairs(data.states) do
	--		data.states[key] = _RESMGR.LoadStateData(value)
	--	end
	--end
end

function _AiComponent:Ctor(entity, data)
	_Base.Ctor(self, entity)
	self.data = data
	self.moveTimer = _Timer.New()
	self.attackTimer = _Timer.New()
	self.navmove = _NavMove.New()
	--self.targetSelector = _TargetSelector.New(data.sightRange)
	--self.skillSelector = _SkillSelector.New()
	self._fsm = _Fsm.New()

	self.target = nil

	if data.states then
		for key, value in pairs(data.states) do
			local state = require("entity.ai.states." .. value).New(data, key)
			state.FSM = self._fsm
			self._fsm:RegState(key, state)
		end
	end
	self._defaultState = data.defaultState or _DEFAULT_STATE
end

function _AiComponent:Init()
	self._position = self._entity.transform.position
	self._input = self._entity.input
	self.navigation = _SCENEMGR.navigation

	self.navmove:Init(self._entity, self.navigation)
	--self.targetSelector:Init(self._entity)
	--self.skillSelector:Init(self._entity)

	for _, value in pairs(self._fsm._states) do
		value:Init(self._entity, self)
	end
	self._fsm:SetState(self._defaultState)
end

function _AiComponent:Update(dt)
	if self._entity.fighter.isDead then
		return
	end

	if not self.navmove.isMoving then
		self.moveTimer:Tick(dt)
	end

	self.attackTimer:Tick(dt)

	self._fsm:Update(dt)
end

function _AiComponent:Draw()
end

---@param planWeightArr table<int, int>
---@param planFuncArr table<int, function>
function _AiComponent:ExcuteRandomPlan(planWeightArr, planFuncArr)
	local totalWeight = 0
	local checkWeight = 0
	for i = 1, #planWeightArr do
		totalWeight = totalWeight + planWeightArr[i]
	end

	local fate = math.random(1, totalWeight)
	for i = 1, #planWeightArr do
		checkWeight = checkWeight + planWeightArr[i]
		if(fate <= checkWeight)then
			planFuncArr[i]() --execute plan
			break --or i = #planWeightArr
		end
	end
end

function _AiComponent:SearchTarget()
	if self.target and not self.target.fighter.isDead then
		return
	end

	self.target = nil
	local entityList = _ENTITYMGR.GetEntityList()
	for i = 1, #entityList do
		local e = entityList[i]
		if e.fighter and not e.fighter.isDead and e.identity.camp ~= self._entity.identity.camp then
			local epos = e.transform.position
			if self:_IsInSightRange(epos.x, epos.y) then
				self.target = e
			end
		end
	end
end

function _AiComponent:_IsInSightRange(x, y)
	local selfX, selfY = self._entity.transform.position:Get()
	local radiusX, radiusY = self.data.sightRange.x, self.data.sightRange.y
	return (x - selfX)^2 / radiusX^2 + (y - selfY)^2 / radiusY^2 < 1
	--return self.sightRect:CheckPoint(x, y)
	--local spos = self._entity.transform.position
	--return math.abs(x - spos.x) <= self._sightRange.x and math.abs(y - spos.y) <= self._sightRange.y
end

function _AiComponent:SelectSkill(entity, target)
	entity = self._entity
	target = self.target
	local skillComponent = entity.skills
	if skillComponent then
		local skills = skillComponent.skillList ---@type table<int, Entity.Skill>
		for i = 1, #skills do
			local skill = skills[i]
			--print("_SkillSelector.Run", skill.name, skill:CanCast(), skill:IsInAttackRange(self._target))
			--print("_SkillSelector.Run", skill.name, skill.stateDebug.cooldownOver, skill.stateDebug.isInPreState, skill.stateDebug.energyEnough)
			if skill:CanCast() and skill:IsInAttackRange(target) then
				--_LOG.Debug("usable skill %s", _)
				return skill
			end
		end
		LOG.Debug("No suitable skill")
		return nil
	end
end

return _AiComponent