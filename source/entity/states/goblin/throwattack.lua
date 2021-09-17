--[[
	Desc: Throw attack for goblin thrower
	Author: SerDing
	Since: 2018-02-26
	Alter: 2021-05-20
]]
local _Base = require("entity.states.base")

---@class Entity.State.GoblinThrower.ThrowAttack : Entity.State.Base
local _ThrowAttack = require("core.class")(_Base)

function _ThrowAttack:Ctor(data, ...)
	_Base.Ctor(self, data, ...)
	self._ticks = data.ticks
end 

function _ThrowAttack:Enter(attackType)
	_Base.Enter(self)
    self._avatar:Play(self._animNameSet[1])
	self._attackType = attackType or "none"
end

function _ThrowAttack:Update()
	if self._body:GetTick() == self._ticks[1] then
		self:NewStoneEntity(self._entityDataSet[1]) --horizon
		if self._attackType == "heavy" then
			self:NewStoneEntity(self._entityDataSet[2]) --up
			self:NewStoneEntity(self._entityDataSet[3]) --down
		end
		_Base.PlaySound(self._soundDataSet.swing)
	end

	_Base.AutoTransitionAtEnd(self)
end 

function _ThrowAttack:Exit()
	_Base.Exit(self)
end

function _ThrowAttack:NewStoneEntity(entityData)
	local t = self._entity.transform
	_Base.NewEntity(entityData, {
		x = t.position.x + t.direction * self._body:GetWidth() * 0.65,
		y = t.position.y,
		z = t.position.z - self._body:GetHeight() / 2,
		direction = t.direction,
		master = self._entity,
		camp = self._entity.identity.camp,
	})
end

return _ThrowAttack