--[[
	Desc: A singleton to manage game flow.
 	Author: SerDing
	Since: 2017-07-28 21:54:14
	Alter: 2019-10-24 23:28:48
	Docs:
		* Space -- Freeze GameWorld for a while
]]
local _INPUT = require("engine.input") ---@type Engine.Input
local _TIME = require("engine.time")
local _SCENEMGR = require("system.scene.scenemgr")
local _FACTORY = require("system.entityfactory")
local _ENTITYMGR = require("system.entitymgr")
local _PLAYERMGR = require("system.playermgr")
local _UIMGR = require("system.gui.uimgr")
local _SETTING = require("setting")
local _Timer = require("utils.timer")
local _DEBUGMGR = require("system.debug.debugmgr")

---@class Game
local _GAME = {
	_timeScale = 1.0,
	_timer = _Timer.New(),
	_running = true,
}
LOG.Debug(_VERSION)
function _GAME.Start()
	_INPUT.Register(_GAME)
	_DEBUGMGR.Init()
	local param = {
		x = 155,
		y = 403,
		direction = 1, 
		camp = 1, 
		firstState = "stay"
	}
	local player = _FACTORY.NewEntity("character/swordman", param)
	player.skills.debug = true

	_PLAYERMGR.SetLocalPlayer(player)
	_SCENEMGR.Init(_ENTITYMGR.Draw)
	_SCENEMGR.LoadScene("lorien/proto")
	_UIMGR.Init('hud')
end

function _GAME.Update(dt)
	if not _GAME._running then
		return 
	end

	if _GAME._timeScale < 1.0 then
		_GAME._timer:Tick(dt)
		if _GAME._timer.isRunning == false then
			_GAME._timeScale = 1.0
		end
	end

	_ENTITYMGR.Update(dt * _GAME._timeScale)
	_SCENEMGR.Update(dt)
end

function _GAME.Draw()
	_SCENEMGR.Draw()
	_UIMGR.Draw()
	_DEBUGMGR.Draw()
	--TODO:GameCurtain.Draw()
end

function _GAME.SetTimeScale(timeScale, time)
	_GAME._timeScale = timeScale
	_GAME._timer:Start(time)
end

function _GAME.Quit()
	love.event.quit()
end

function _GAME.HandleAction(_, action, state)
	if _SETTING.release then
		return
	end

	if state == EInput.STATE.PRESSED then
		if action == "pause" then
			_GAME._running = not _GAME._running
		end

		if action == "freeze" then
			_GAME.SetTimeScale(0.05, 3000)
			print("Freeze game world for a while.")
		end

		if action == "reborn-all" then
			local list = _ENTITYMGR.GetEntityList()
			for i=1,#list do
				local e = list[i]
				if e.fighter and e.fighter.isDead then
					e.fighter:Reborn()
				end
			end
		end

		if action == "quit" then
			_GAME.Quit()
		end
	end
end

function _GAME.HandleAxis(_, axis, value)
end

return _GAME