--[[
	Desc: Dash state (run)
 	Author: SerDing
	Since: 2017-07-28 21:54:14
	Alter: 2017-07-30 12:40:40
]]
local _TIME = require('engine.time')
local _Vector2 = require("utils.vector2")
local _MATH = require("engine.math")
local _SETTING = require("setting")
local _Base  = require "entity.states.base"

---@class State.Move : Entity.State.Base
local _Move = require("core.class")(_Base)

function _Move:Ctor(data, ...)
    _Base.Ctor(self, data, ...)
    self.name = "move"
    self._timeUp = 0
    self._timeDown = 0
    self._timeLeft = 0
    self._timeRight = 0
    self._speed = _Vector2.New()
end

function _Move:Init(entity)
    _Base.Init(self, entity)
    self._input:BindAction("move-left", self._input.STATE.PRESSED, nil, function()
        self._movement.moveInput.left = true
        self._movement.moveSignalTime.left = _TIME.GetTime(true)
    end)
    self._input:BindAction("move-right", self._input.STATE.PRESSED, nil, function()
        self._movement.moveInput.right = true
        self._movement.moveSignalTime.right = _TIME.GetTime(true)
    end)
    self._input:BindAction("move-up", self._input.STATE.PRESSED, nil, function()
        self._movement.moveInput.up = true
        self._movement.moveSignalTime.down = _TIME.GetTime(true)
    end)
    self._input:BindAction("move-down", self._input.STATE.PRESSED, nil, function()
        self._movement.moveInput.down = true
        self._movement.moveSignalTime.up = _TIME.GetTime(true)
    end)

    self._input:BindAction("move-left", self._input.STATE.RELEASED, nil, function()
        self._movement.moveInput.left = false
    end)
    self._input:BindAction("move-right", self._input.STATE.RELEASED, nil, function()
        self._movement.moveInput.right = false
    end)
    self._input:BindAction("move-up", self._input.STATE.RELEASED, nil, function()
        self._movement.moveInput.up = false
    end)
    self._input:BindAction("move-down", self._input.STATE.RELEASED, nil, function()
        self._movement.moveInput.down = false
    end)
end

function _Move:Enter()
    _Base.Enter(self)
    if self._movement.moveInput.left then
        self._entity.transform.direction = -1
    elseif self._movement.moveInput.right then
        self._entity.transform.direction = 1
    end
end

function _Move:Update(dt, timeScale)
    timeScale = timeScale or 1.0
    local up = self._movement.moveInput.up
    local down = self._movement.moveInput.down
    local left = self._movement.moveInput.left
    local right = self._movement.moveInput.right
    
    self._render.timeScale = self._entity.stats.moveRate * timeScale
    local moveSpeed = self._entity.stats.moveSpeed * timeScale
    self._speed:Set(moveSpeed, moveSpeed * _SETTING.scene.AXIS_RATIO_Y)
    local axisX, axisY = 0, 0
    self._timeLeft = self._movement.moveSignalTime.left
    self._timeRight = self._movement.moveSignalTime.right
    self._timeUp = self._movement.moveSignalTime.up
    self._timeDown = self._movement.moveSignalTime.down

    if up or down then
        if up and down then
            if self._timeUp > self._timeDown then
                axisY = -1
            else
                axisY = 1
            end 
        elseif up then
            axisY = -1
        else 
            axisY = 1
        end 
    end 
    
    if left or right then
        if left and right then
            if self._timeLeft > self._timeRight then
                axisX = -1
            else 
                axisX = 1
            end 
        elseif left then
            axisX = -1
        else 
            axisX = 1
        end
    end

    if axisX ~= 0 and self._entity.transform.direction ~= axisX then
        self._entity.transform.direction = axisX
    end
    self._movement:Move('x', axisX * self._speed.x)
    self._movement:Move('y', axisY * self._speed.y)

    if not up and not down and not left and not right then 
        self._STATE:SetState(self._nextState)
    end 
    
end 

function _Move:Exit()
    self._render.timeScale = 1.0
end

return _Move 