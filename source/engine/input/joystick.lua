--[[
	Desc: Input joystick
	Author: SerDing
	Since: 2021-04-13
	Alter: 2021-04-14
]]
local _INPUT_DEFINE = require("engine.input.inputdefine")
local _InputDevice = require("engine.input.inputdevice")

---@class Engine.Input.Joystick : Engine.Input.InputDevice
---@field protected _INPUT Engine.Input
local _InputJoystick = require("core.class")(_InputDevice)

local _DEADBAND = 0.22

function _InputJoystick:Ctor(INPUT)
	_InputDevice.Ctor(self, "joystick", INPUT)
	self._joystick = nil
	self._mappings = {}
	self._buttonToActionEvent = {
		--rightshoulder = "attack",
	}
	self._axisToAxisEvent = {
		--leftx = "movex",
	}
	self._axisToActionEvent = {
		positive = {
			-- leftx = "move-right",
		},
		negative = {
			-- leftx = "move-left",
		}
	}
	self._axisState = {
		leftx = 0,
		lefty = 0,
		rightx = 0,
		righty = 0,
		triggerleft = 0,
		triggerright = 0,
	}

	self:_HookLoveCallbakcs()
end

function _InputJoystick:Update()
	_InputDevice.Update(self)
end

function _InputJoystick:_HookLoveCallbakcs()

	---@param joystick Joystick
	local function _JoystickAdded(joystick)
		LOG.Debug("Connected Joystick: %d %s %s", joystick:getID(), joystick:getName(), joystick:getGUID())
	end

	---@param joystick Joystick
	---@param button string
	local function _JoystickPressed(joystick, button)
		if self._joystick == nil and joystick ~= nil then
			LOG.Debug("InputJoystick: player joystick confirm:%s  :)", joystick:getID())
		end
		self._joystick = self._joystick or joystick
		if joystick == self._joystick then
			self:Press(button)
			--_LOG.Debug("joystickpressed: %s ", button)
		end
	end

	---@param joystick Joystick
	---@param button string
	local function _JoystickReleased(joystick, button)
		if joystick == self._joystick then
			self:Release(button)
			--_LOG.Debug("joystickreleased: %s ", button)
		end
	end

	---@param joystick Joystick
	---@param axis string
	---@param newValue number
	local function _JoystickAxis(joystick, axis, newValue)
		if self._joystick == nil and joystick ~= nil then
			LOG.Debug("InputJoystick: player joystick confirm:%s  :)", joystick:getID())
		end
		if joystick == self._joystick then
			self:OnAxis(axis, newValue)
			--_LOG.Debug("joystickaxis: %s %.2f", axis, newValue)
		end
	end

	local function _JoystickHat(joystick, hat, direction)
		print("joystickhat:", hat, direction)
	end

	love.joystickadded = _JoystickAdded
	--love.joystickaxis = _JoystickAxis
	--love.joystickpressed = _JoystickPressed
	--love.joystickreleased = _JoystickReleased
	--love.joystickhat = _JoystickHat
	love.gamepadaxis = _JoystickAxis
	love.gamepadpressed = _JoystickPressed
	love.gamepadreleased = _JoystickReleased

end

---@param mapping Engine.Input.InputMapping
function _InputJoystick:AddMapping(mapping)
	self._mappings[#self._mappings + 1] = mapping
	if mapping.event.type == _INPUT_DEFINE.EVENT_TYPE.AXIS then
		if mapping.control.type == _INPUT_DEFINE.CONTROL_TYPE.AXIS then
			self._axisToAxisEvent[mapping.control.code] = mapping.event.name
		else
			LOG.Error("InputJoystick, the mapping of button to axisEvent is not supported.")
		end
	elseif mapping.event.type == _INPUT_DEFINE.EVENT_TYPE.ACTION then
		if mapping.control.type == _INPUT_DEFINE.CONTROL_TYPE.BUTTON then
			self._buttonToActionEvent[mapping.control.code] = mapping.event.name
		elseif mapping.control.type == _INPUT_DEFINE.CONTROL_TYPE.AXIS_P then
			self._axisToActionEvent.positive[mapping.control.code] = mapping.event.name
		elseif mapping.control.type ==_INPUT_DEFINE.CONTROL_TYPE.AXIS_N then
			self._axisToActionEvent.negative[mapping.control.code] = mapping.event.name
		end
	end
end

function _InputJoystick:Press(button)
	_InputDevice.Press(self, button)
	self._INPUT.HandleAction(self._buttonToActionEvent[button], _INPUT_DEFINE.STATE.PRESSED)
	self._INPUT.SetMode(self._deviceType)
end

function _InputJoystick:Release(button)
	_InputDevice.Release(self, button)
	self._INPUT.HandleAction(self._buttonToActionEvent[button], _INPUT_DEFINE.STATE.RELEASED)
	self._INPUT.SetMode(self._deviceType)
end

function _InputJoystick:OnAxis(axis, newValue)
	-- translate axis variation to action
	if newValue > self._axisState[axis] then
		if newValue > _DEADBAND and self._axisState[axis] < _DEADBAND then -- positive axis away
			self._INPUT.HandleAction(self._axisToActionEvent.positive[axis], _INPUT_DEFINE.STATE.PRESSED)
		end
		if newValue > -_DEADBAND and self._axisState[axis] < -_DEADBAND then -- negative axis return
			self._INPUT.HandleAction(self._axisToActionEvent.negative[axis], _INPUT_DEFINE.STATE.RELEASED)
		end
	end
	if newValue < self._axisState[axis] then
		if newValue < _DEADBAND and self._axisState[axis] > _DEADBAND then -- positive axis return
			self._INPUT.HandleAction(self._axisToActionEvent.positive[axis], _INPUT_DEFINE.STATE.RELEASED)
		end
		if newValue < -_DEADBAND and self._axisState[axis] > -_DEADBAND then -- negative axis away
			self._INPUT.HandleAction(self._axisToActionEvent.negative[axis], _INPUT_DEFINE.STATE.PRESSED)
		end
	end

	_InputDevice.OnAxis(self, axis, newValue)
	self._INPUT.HandleAxis(self._axisToAxisEvent[axis], newValue)
	self._INPUT.SetMode(self._deviceType)
end

return _InputJoystick