--[[
	Desc: Controller component, a FSM to manage action states of entity.
	Author: SerDing 
	Since: 2018-04-12
	Alter: 2021-05-04
]]
local _RESMGR = require("system.resource.resmgr")
local _Fsm = require("utils.fsm")
local _Base = require("entity.component.base")

---@class Entity.Component.State : Utils.FSM
---@field protected _entity Entity
---@field protected _states table<string, Entity.State.Base>
local _Controller = require("core.class")(_Fsm)

function _Controller.HandleData(data)
	for key, value in pairs(data) do
		if key ~= "class" then
			data[key] = _RESMGR.LoadStateData(value)
		end
	end
end

function _Controller:Ctor(entity, data, param)
	_Fsm.Ctor(self)
	_Base.Ctor(self, entity)
	
	for name, value in pairs(data) do
		if name ~= "class" then
			self:RegState(name, value.class.New(value, name))
		end
	end

	for _, state in pairs(self._states) do
		state:Init(self._entity)
	end
	
	self:SetState(param.firstState or "stay")
end

function _Controller:Init()
end

function _Controller:Update(dt)
	if self._entity.identity.isPaused or self._entity.fighter.isDead then
		return false
	end
	
	_Fsm.Update(self, dt)
end

function _Controller:RegState(name, state)
	_Fsm.RegState(self, name, state)
	state._STATE = self
end

function _Controller:SetState(name, ...)
	_Fsm.SetState(self, name, ...)
end

function _Controller:TrySwtich(name, ...)
	local transitionMap = self.curState:GetTransitions()
	if not transitionMap then
		return
	end

	local targetState = self._states[name]
	--_LOG.Debug("action try switch to: %s", name)
	if transitionMap[name] or
	(targetState:HasTag("isNormalSkill") and transitionMap.normalskills) or
	(targetState:HasTag("isDodge") and transitionMap.dodge)then
		if self.curState == targetState then
			self.preState = self.curState
			self.curState:Enter(name, ...)
		else
			self:SetState(name, ...)
		end
		--_LOG.Debug("action try switch success")
	end
end

---Auto translate to target state when animation playing end.
---@param nextState string
function _Controller:AutoTranslateAtEnd(nextState)
	local main = self._entity.render.renderObj:GetPart()
	if main:TickEnd() then
		self:SetState(nextState)
	end
end

function _Controller:ReloadAnimDatas(part)
	for _, state in pairs(self._states) do
		state:ReloadAnimData(part)
	end
end

---@return Entity.State.Base
function _Controller:GetCurState()
	return _Fsm.GetCurState(self)
end

return _Controller