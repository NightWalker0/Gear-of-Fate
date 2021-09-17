--[[
	Desc: Ai wander state
	Author: SerDing
	Since: 2021-04-23
	Alter: 2021-05-11
]]
local _Vector2 = require("utils.vector2")
local _Timer = require("utils.timer")
local _MATH = require("engine.math")
local _Base = require("entity.ai.states.base")

---@class Entity.Ai.State.Wander : Entity.Ai.State.Base
local _Wander = require("core.class")(_Base)

local _emptyTable = {}

function _Wander:Ctor(data, name)
    _Base.Ctor(self, data, name)

    self._moveRange = data.moveRange.wander
    self._moveInterval = data.moveInterval --moveInterval
    self._path = {}
    self._hasReachedDest = false
    --self._moveTimer = _Timer.New()
end

---@param entity Entity
---@param aic Entity.Component.AIC
function _Wander:Init(entity, aic)
    _Base.Init(self, entity, aic)

    self._position = entity.transform.position
    self._navigation = aic.navigation
	self._navmove = aic.navmove
	self._targetSelector = aic.targetSelector
	self._moveTimer = aic.moveTimer
	self._moveTimer:Start(self._moveInterval)
end

function _Wander:Enter()
    self._hasReachedDest = true
	LOG.Debug("Enter ai_wander, start move interval:%.3f", self._moveInterval)
end

function _Wander:Update(dt)
    --self._moveTimer:Tick(dt)
    if self._hasReachedDest and not self._moveTimer.isRunning then
		self._aic:SearchTarget()
		if self._aic.target then
			self.FSM:SetState("pursuit", self._target)
			LOG.Debug("Ai_wander, find target.")
		else
			local destx, desty = self:GetDestination()
			if self._navigation:GetNodePass(self._navigation:GetNodeIndexByPos(destx, desty)) then
				LOG.Debug("Ai_wander, destnation is passable: %.2f %.2f", destx, desty)
				self._path = self._navigation:FindPath(self._position.x, self._position.y, destx, desty)
				self._entity.render.navPath = nil
				if #self._path > 0 then
					self._navmove:Run(self._path)
					self._moveTimer:Start(math.random(0, self._moveInterval))
					self._entity.render.navPath = self._path
					self._hasReachedDest = false
				end
			end
		end
    end

	self._hasReachedDest = self._navmove:Update(dt)
end

function _Wander:Exit()
    self._path = _emptyTable
end

function _Wander:GetDestination()
	local x = self._position.x + math.random(-self._moveRange.x, self._moveRange.x)
	local y = self._position.y + math.random(-self._moveRange.y, self._moveRange.y)

	return x, y
end

return _Wander