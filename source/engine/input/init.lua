--[[
	Desc: Input Module of Engine, manage input messages and devices
	Author: SerDing
	Since: 2018-04-06
	Alter: 2019-10-24
]]
require("engine.input.inputdefine")
local _Event = require("core.event")
local _RESOURCE = require("engine.resource")
local _Mouse = require("engine.input.mouse")
local _Keyboard = require("engine.input.keyboard")
local _Joystick = require("engine.input.joystick")
local _InputMap = require("engine.input.inputmap")
---@class Engine.Input
---@field public keyboard Engine.Input.Keyboard
---@field public joystick Engine.Input.Joystick
---@field public mouse Engine.Input.Mouse
---@field public onInputModeSwitch Event
---@field protected _inputHandlers table<int, Engine.Input.InputHandler>
---@field protected _mode string @input mode
local _INPUT = {}
local this = _INPUT

function _INPUT.Init()
	this._inputHandlers = {}
	this._mode = "keyboard"
	this.onInputModeSwitch = _Event.New()
    this.joystick = _Joystick.New(this)
    this.keyboard = _Keyboard.New(this)
    this.mouse = _Mouse.New(this)
    this._inputMapData = _RESOURCE.LoadData("resource/data/input/gameplay")
    this._inputMap = _InputMap.New(this, this._inputMapData)
end

function _INPUT.Update()
	this.joystick:Update()
	this.keyboard:Update()
    this.mouse:Update()
end

function _INPUT.SetMode(mode)
	if mode ~= this._mode then
		this._mode = mode
		this.onInputModeSwitch:Notify(mode)
	end
end

---@param action string
---@param state int
function _INPUT.HandleAction(action, state)
    if action and state then
        for i = 1, #this._inputHandlers do
            this._inputHandlers[i]:HandleAction(action, state)
        end
    end
end

---@param axis string
---@param value number
function _INPUT.HandleAxis(axis, value)
    if axis and value then
        for i = 1, #this._inputHandlers do
            this._inputHandlers[i]:HandleAxis(axis, value)
        end
    end
end

---@param inputHandler Engine.Input.InputHandler
function _INPUT.Register(inputHandler)
    this._inputHandlers[#this._inputHandlers + 1] = inputHandler
end

---@param inputHandler Engine.Input.InputHandler
function _INPUT.UnRegister(inputHandler)
    local n = 0
    for i = 1, #this._inputHandlers do
        if this._inputHandlers[i] == inputHandler then
            n = i
        end
    end
    table.remove(this._inputHandlers, n)
end

return _INPUT