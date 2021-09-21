--[[
    Desc: Debugger Manager
    Author: SerDing
    Since: 2021-09-19
    Alter: 2021-09-20
]]
local _INPUT = require("engine.input") ---@type Engine.Input
local _GRAPHICS = require("engine.graphics") ---@type Engine.Graphics
local _TIME = require("engine.time")
local _PLAYERMGR = require("system.playermgr")
local _CAMERA = require("system.scene.camera")
local _Mouse = require("engine.input.mouse")
local _CONFIG = require("setting")

---@class System.DebugManager
local _DebugManager = {}

local mathFloor = math.floor

function _DebugManager.Init()
	_INPUT.keyboard.onKeyPress:AddListener(nil, _DebugManager._OnKeyPress)
end

function _DebugManager._OnKeyPress(key)
	if key == "f1" then
		LOG.Debug("debugger manager f1")
	end
end

function _DebugManager.Draw()
	local h = mathFloor(_GRAPHICS.GetHeight() * 0.3)
	local y = _GRAPHICS.GetHeight() - h
	_GRAPHICS.SetColor(0, 0, 0, 150)
	_GRAPHICS.DrawRect("fill", 0, y, _GRAPHICS.GetWidth(), h)
	_GRAPHICS.SetColor(255, 255, 255, 255)
	local fps = _TIME.GetFPS()
	local startx, starty = 30, y + 30
	local hd, vd = 200, 20 + 10
	if _CONFIG.debug.fps then
		_GRAPHICS.Print("FPS:", startx, starty)
		_GRAPHICS.Print(fps, startx + hd, starty)
		--local font = love.graphics.getFont()
		--_GRAPHICS.DrawRect("line", startx, starty, font:getWidth("FPS:"), font:getHeight())
	end

	if _CONFIG.debug.mouse then
		local rawx, rawy = _Mouse.GetRawPosition()
		--local drawx, drawy = Floor((rawx - 20)), Floor((rawy - 10))
		local worldx, worldy = _CAMERA.ScreenToWorld(rawx, rawy)
		worldx, worldy = mathFloor(worldx), mathFloor(worldy)
		_GRAPHICS.Print("mouse raw pos:", startx, starty + vd)
		_GRAPHICS.Print(mathFloor(rawx) .. "," .. mathFloor(rawy), startx + hd, starty + vd)
		_GRAPHICS.Print("mouse world pos:", startx, starty + vd * 2)
		_GRAPHICS.Print(worldx .. "|" .. worldy, startx + hd, starty + vd * 2)
	end

	if _CONFIG.debug.playerPosition then
		local px, py = _PLAYERMGR.GetLocalPlayer().transform.position:Get()
		_GRAPHICS.Print("player pos:", startx, starty + vd * 3)
		_GRAPHICS.Print(mathFloor(px) .. "," .. mathFloor(py), startx + hd, starty + vd * 3)
	end
end

return _DebugManager