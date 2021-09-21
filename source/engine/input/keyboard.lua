--[[
	Desc: Input keyboard
	Author: SerDing
	Since: 2021-04-05
	Alter: 2021-04-13
]]
local _Event = require("core.event")
local _InputDevice = require("engine.input.inputdevice")

---@class Engine.Input.Keyboard : Engine.Input.InputDevice
local _InputKeyboard = require("core.class")(_InputDevice)

function _InputKeyboard:Ctor(INPUT)
	_InputDevice.Ctor(self, "keyboard", INPUT)
	self.onKeyPress = _Event.New()
	self.onKeyRelease = _Event.New()
	self._buttonToActionEvent = {}
	self._buttonToAxisEvent = {}
	self._axisDirection = {}
	self:_HookLoveCallbacks()
end

function _InputKeyboard:Update()
	_InputDevice.Update(self)
	--TODO:模拟轴值增加/减少
end

function _InputKeyboard:_HookLoveCallbacks()
	---@param button string
	local function _KeyPressed(button)
		self:Press(button)
	end
	---@param button string
	local function _KeyReleased(button)
		self:Release(button)
	end
	love.keypressed = _KeyPressed
	love.keyreleased = _KeyReleased
end

function _InputKeyboard:Press(button)
	_InputDevice.Press(self, button)
	self:AnalogAxisAway(self._buttonToAxisEvent[button], 1)
	self._INPUT.HandleAction(self._buttonToActionEvent[button], EInput.STATE.PRESSED)
	self._INPUT.SetMode(self._deviceType)
	self.onKeyPress:Notify(button)
end

function _InputKeyboard:Release(button)
	_InputDevice.Release(self, button)
	self._INPUT.HandleAction(self._buttonToActionEvent[button], EInput.STATE.RELEASED)
	self._INPUT.SetMode(self._deviceType)
	self.onKeyRelease:Notify(button)
	--TODO：设置模拟轴值减少
end

function _InputKeyboard:AnalogAxisAway(axis, direction)
	if axis then
		self._axisDirection[axis] = direction
		self._axisState[axis] = self._axisState[axis] or 0
	end
end

---@param mapping Engine.Input.InputMapping
function _InputKeyboard:AddMapping(mapping)
	if mapping.event.type == EInput.EVENT_TYPE.ACTION then
		if mapping.control.type == EInput.CONTROL_TYPE.BUTTON then
			self._buttonToActionEvent[mapping.control.code] = mapping.event.name
		else
			LOG.Error("InputKeyboard: control type:%s is not supported on keyboard!", mapping.control.type)
		end
	elseif mapping.event.type == EInput.EVENT_TYPE.AXIS then
		self._buttonToAxisEvent[mapping.control.code] = mapping.event.name
	end
end

---@param key string
---@return int
function _InputKeyboard.GetCodeByKey(key)
	return love.keyboard.getScancodeFromKey(key)
end

---@param keycode int
---@return string
function _InputKeyboard.GetKeyByCode(keycode)
	return love.keyboard.getKeyFromScancode(keycode)
end

return _InputKeyboard