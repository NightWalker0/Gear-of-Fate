--[[
	Desc: Timer, a util class.
 	Author: SerDing
	Since: 2019-08-24 21:45
	Alter: 2019-11-5 
]]
local _MATH = require("engine.math")
---@class Utils.Timer
---@field protected _time milli
---@field protected _count milli
---@field protected _action function
---@field protected isRunning boolean
local _Timer = require("core.class")()

---@param time milli
---@param action function
function _Timer:Ctor(time, action, nonStop)
    self._count = 0
    self._time = time or 0
    self._action = action or nil
    self._nonStop = (nonStop ~= nil) and nonStop or false
    self.isRunning = false
end

---@param dt float
function _Timer:Tick(dt)
    if not self.isRunning then
        return
    end

    self._count = self._count + dt * 1000
    if self._count >= self._time then
        if self._action ~= nil then
            self._action()
        end
        if self._nonStop == false then
            self.isRunning = false
        end
    end
end

---@param time milli
---@param keepSurplus boolean
function _Timer:Start(time, keepSurplus)
    self._count = (keepSurplus and self._count > self._time) and self._count - self._time or 0
    self._time = time
    self.isRunning = true
end

function _Timer:SetAction(action)
    self._action = action
end

function _Timer:Stop()
    self.isRunning = false
end

function _Timer:Continue()
    self.isRunning = true
end

function _Timer:Reset()
    self:Stop()
    self._count = 0
end

function _Timer:GetCount()
    return self._count
end

function _Timer:GetTime()
    return self._time
end

function _Timer:GetProgress()
    return _MATH.GetFixNumber(self._count / self._time)
end

return _Timer
