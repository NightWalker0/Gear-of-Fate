--[[
	Desc: Effect, a component for features of effects.
	Feature:
		1.Death by anim playing end
		2.Lock anim playing rate with master anim playing rate
		3.Follow master position
		4.Death as master state changing
    Author: SerDing
    Since: 2019-11-5
    Alter: 2019-11-5
]]
local _Base = require("entity.component.base")

---@class Entity.Component.Effect : Entity.Component.Base
local _Effect = require("core.class")(_Base)

local function _Follow(self)
	local x, y, z = self._entity.identity.master.transform.position:Get()
	if self._followType == "xyz" then
		self._entity.transform.position:Set(x, y, z)
	elseif self._followType == "xy" then
		self._entity.transform.position:Set(x, y)
	end
end

---@param entity Entity
function _Effect:Ctor(entity, data, param)
	_Base.Ctor(self, entity)
	self._syncDirection = data.lockDirection
	self._syncRate = data.lockRate
	self._syncStop = data.lockStop == nil and true or data.lockStop
	self._playEnd = data.playEnd or false
	self._eternal = data.eternal or false
	self._followType = data.followType
	self._state = (param.master) and param.master.state.curState or nil
end

function _Effect:Update()
    if not self.enable then
        return
	end
	
	if self._entity.identity.master then
		local master = self._entity.identity.master
		
		if self._eternal == false then
			if self._state ~= master.state.curState then
				self._entity.identity:StartDestroy()
			end
	
			if self._playEnd then
				if self._entity.render.renderObj:TickEnd() then
					self._entity.identity:StartDestroy()
				end
			end
		end

		if self._syncStop and self._entity.identity.isPaused ~= master.identity.isPaused then
			self._entity.identity.isPaused = master.identity.isPaused
		end

		if self._syncDirection then
			if self._entity.transform.direction ~= master.transform.direction then
				self._entity.transform.direction = master.transform.direction
			end
		end

		if self._syncRate then
			if self._entity.render.timeScale ~= master.render.timeScale then
				self._entity.render.timeScale = master.render.timeScale
			end
		end

		if self._followType then
			_Follow(self)
		end
	else
		if self._playEnd then
			if self._entity.render.renderObj:TickEnd() then
				self._entity.identity:StartDestroy()
			end
		end
	end
end

return _Effect