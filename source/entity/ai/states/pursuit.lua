--[[
	Desc: Ai wander state
	Author: SerDing
	Since: 2021-04-24
	Alter: 2021-05-11
]]
local _Vector2 = require("utils.vector2")
local _Timer = require("utils.timer")
local _Base = require("entity.ai.states.wander")

---@class Entity.Ai.State.Pursuit : Entity.Ai.State.Wander
local _Pursuit = require("core.class")(_Base)

local _RETURN_STATE = 'wander'

function _Pursuit:Ctor(data, name)
	_Base.Ctor(self, data, name)

	self._moveRange = data.moveRange.pursuit
	self._lastTargetPosition = _Vector2.New()
	self._hasFixedDirection = false
end

---@param entity Entity
---@param aic Entity.Component.AIC
function _Pursuit:Init(entity, aic)
	_Base.Init(self, entity, aic)

	self._skillSelector = aic.skillSelector
end

function _Pursuit:Enter()
	self._target = self._targetSelector.target
	self._skillSelector:SetTarget(self._aic.target)
	self._lastTargetPosition:Set(self._aic.target.transform.position:Get())
	--self._moveTimer:Start(self._moveInterval)
	--_LOG.Debug("pursuit, start move interval:%.3f", self._moveInterval)
end

function _Pursuit:Update(dt)
	if self._hasReachedDest and not self._moveTimer.isRunning then
		--self._aic:SearchTarget()
		if self._aic.target.fighter.isDead then
			self.FSM:SetState(_RETURN_STATE)
			LOG.Debug("Ai_pursuit, no target.")
		else
			self._skillSelector:SetTarget(self._aic.target)
			self._lastTargetPosition:Set(self._aic.target.transform.position:Get())
			local destx, desty = self:GetDestination()
			LOG.Debug("Ai_pursuit, get destination:%f,%f", destx, desty)
			if self._navigation:GetNodePass(self._navigation:GetNodeIndexByPos(destx, desty)) then
				self._path = self._navigation:FindPath(self._position.x, self._position.y, destx, desty)
				self._entity.render.navPath = nil
				if #self._path > 0 then
					self._navmove:Run(self._path)
					self._moveTimer:Start(math.random(0, self._moveInterval))
					self._entity.render.navPath = self._path
					self._hasReachedDest = false
					self._hasFixedDirection = false
				end
			end
		end
	end

	if self._aic.target then
		--local skill = self._skillSelector:Run()
		local skill = self._aic:SelectSkill()
		if skill and not self._aic.attackTimer.isRunning then
			self.FSM:SetState("attack", skill)
		end
	end

	self._hasReachedDest = self._navmove:Update(dt)
	if self._hasReachedDest then
		if self._aic.target and not self._hasFixedDirection then
			self._entity.transform:FaceTo(self._aic.target.transform.position)
			self._hasFixedDirection = true
		end
	end
end

function _Pursuit:Exit()
	self._path = nil
	self._hasReachedDest = true
end

function _Pursuit:GetDestination()
	local randXDir = math.random(-1, 1)
	local randYDir = math.random(-1, 1)
	randXDir = randXDir == 0 and 1 or randXDir
	randYDir = randYDir == 0 and 1 or randYDir
	local randx = math.random(self._moveRange.x.min, self._moveRange.x.max) * randXDir
	local randy = math.random(self._moveRange.y.min, self._moveRange.y.max) * randYDir

	return self._lastTargetPosition.x + randx, self._lastTargetPosition.y + randy
end

return _Pursuit