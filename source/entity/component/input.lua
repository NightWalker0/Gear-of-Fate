--[[
	Desc: Input component
	Author: SerDing
	Since: 2018-04-06 16:11:06 
	Last Modified time: 2018-04-06 16:11:06 
	Docs: 
        * Receive and cache input messages for entity, implement input handler interface.
        * When you create an instance for a entity, it will register itself to the input module of engine.
        * skillInputMap is used to map some skill shortcut messages to concrete skill messages(e.g:"skill_1"->"gorecross")
]]
local _Event = require("core.event")
local _INPUT = require("engine.input") ---@type Engine.Input
local _Base = require("entity.component.base")

---@class Entity.Component.Input : Engine.Input.InputHandler
---@field protected _actionBindings table<string, table<string, Event>>
---@field protected _axisBindings table<string, Event>
---@field protected _actionState table @ map of actions
---@field public skillInputMap table<string, string>
local _InputComponent = require("core.class")(_Base)

function _InputComponent:Ctor(entity, data)
    _Base.Ctor(self, entity)
    self._actionState = {}
    self._actionBindings = {
        [EInput.STATE.PRESSED] = {},
        [EInput.STATE.DOWN] = {},
        [EInput.STATE.RELEASED] = {},
    }
    self._axisBindings = {
        movex = _Event.New(),
    }
    self.skillInputMap = data.skillInputMap or {}
    _INPUT.Register(self)
end

function _InputComponent:BindAction(action, state, obj, callback)
    if not self._actionBindings[state][action] then
        self._actionBindings[state][action] = _Event.New()
    end
    self._actionBindings[state][action]:AddListener(obj, callback)
    --print("BindAction", action, state, self._actionBindings[state][action])
end

---@param axis string
---@param callback fun(value:number):void
function _InputComponent:BindAxis(axis, obj, callback)
    if not self._axisBindings[axis] then
        self._axisBindings[axis] = _Event.New()
    end
    self._axisBindings[axis]:AddListener(obj, callback)
end

function _InputComponent:UnBindAction(action, state, obj, callback)
    local event = self._actionBindings[state][action]
    if event then
        event:DelListener(obj, callback)
    end
end

function _InputComponent:UnBindAxis(axis, obj, callback)
    local event = self._axisBindings[axis]
    if event then
        event:DelListener(obj, callback)
    end
end

function _InputComponent:InputAction(action, state)
    local event = self._actionBindings[state][action]
    --print("InputAction: ", action, state, event)
    if event then
        event:Notify()
    end
end

function _InputComponent:InputAxis(axis, value)
    local event = self._axisBindings[axis]
    if event then
        event:Notify(value)
    end
end

function _InputComponent:HandleAction(action, state)
    if not self._entity.aic.enable then
        self:InputAction(action, state)
    end
end

function _InputComponent:HandleAxis(axis, value)
    if not self._entity.aic.enable then
        self:InputAxis(axis, value)
    end
end

return _InputComponent