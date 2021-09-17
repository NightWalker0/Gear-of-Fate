--[[
	Desc: Ai state base
	Author: SerDing
	Since: 2021-04-23
	Alter: 2021-04-23
]]

---@class Entity.Ai.State.Base
---@field protected _name string
---@field protected _entity Entity
---@field protected _aic Entity.Component.AIC
---@field protected _render Entity.Component.Render
---@field protected _input Entity.Component.Input
---@field protected _movement Entity.Component.Movement
---@field protected _combat Entity.Component.Combat
---@field public FSM Utils.FSM
local _State = require("core.class")()

---@param data table
---@param name string
function _State:Ctor(data, name)
	self._name = name
	--self._tags = data.tags or nil
	--self._nextState = data.nextState or nil
end

function _State:Init(entity, aic)
	self._entity = entity
	self._aic = aic
	self._input = self._entity.input
	self._render = self._entity.render
	self._movement = self._entity.movement
	self._combat = self._entity.combat
	self._controller = self._entity.state
	self._avatar = self._render.renderObj
	self._body = self._avatar:GetPart()

end

function _State:Enter()
end

function _State:Update(dt)
end

function _State:AutoTranslate()
	-- tranlate to wander state, when play die.
end

function _State:Exit()
end

function _State:HasTag(tag)
	return self._tags[tag] == true
end

function _State:GetName()
	return self._name
end

return _State