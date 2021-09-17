--[[
	Desc: Time Module
	Author: SerDing
	Since: 2021-02-05
	Alter: 2021-02-05
]]
local _MATH = require("engine.math")
local _SETTING = require("setting")

---@class Engine.Time
local _TIME = {
	shouldUpdate = true,
}
local _FRAME_MAX = 1000000000
local _fps = 0
local _frame = 0
local _time = 0
local _lastFrameTime = love.timer.getTime()
local _STANDARD_DT = _MATH.GetFixNumber(1 / _SETTING.fps)
LOG.Debug("TIME _STANDARD_DT:%.3f", _STANDARD_DT)

function _TIME.Update(dt)
	_frame = _frame > _FRAME_MAX and 0 or _frame + 1
	_fps = love.timer.getFPS()
	_time = love.timer.getTime()

	_TIME.shouldUpdate = (_time - _lastFrameTime >= _STANDARD_DT) and true or false
	if _TIME.shouldUpdate then
		_lastFrameTime = _lastFrameTime + _STANDARD_DT
	end

	--return _MATH.GetFixNumber(dt)
	return _STANDARD_DT
end

function _TIME.GetFrame()
	return _frame
end

---@param real boolean
function _TIME.GetStandardDelta(real)
	return real and _MATH.GetFixNumber(love.timer.getDelta()) or _STANDARD_DT
end

--- Return the time when this frame began
---@param real boolean
function _TIME.GetTime(real)
	return real and love.timer.getTime() or _time
end

function _TIME.GetFPS()
	return _fps
end

return _TIME