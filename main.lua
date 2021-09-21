love.filesystem.setRequirePath("source/?.lua;source/?/init.lua")

require("engine.log")
require("engine.graphics")
require("engine.resource")
require("engine.audio")
local _INPUT = require("engine.input")
local _TIME = require("engine.time")
local _GAME = require("game")

local _lastSecondTime = 0
local _updateCount = 0

function love.load()
	math.randomseed(tostring(os.time()):reverse():sub(1, 7))

	--_GRAPHICS.SetWindowMode(_SETTING.window.w, _SETTING.window.h)
	love.window.setPosition(0, 0)
	_INPUT.Init()
	_GAME.Start()
	_lastSecondTime = love.timer.getTime()
end

function love.update(dt)
	dt = _TIME.Update(dt)
	if _TIME.shouldUpdate then
		--print(dt)
		_GAME.Update(dt)
		_INPUT.Update(dt)
		_updateCount = _updateCount + 1
	else
		--print("no update")
	end

	if _TIME.GetTime(true) - _lastSecondTime >= 1.0 then
		--print("update count this second:", _updateCount)
		_updateCount = 0
		_lastSecondTime = _lastSecondTime + 1.0
	end

end

function love.draw()
	_GAME.Draw()
end
