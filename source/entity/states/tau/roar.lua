--[[
	Desc: Roar for Tau
	Author: SerDing
	Since: 2021-05-26
	Alter: 2021-05-26
]]
local _Base = require("entity.states.base")

---@class Entity.State.Tau.Roar : Entity.State.Base
local _Roar = require("core.class")(_Base)

function _Roar:Ctor(data, name)
	_Base.Ctor(self, data, name)
	self.ticks = data.ticks
end

function _Roar:Enter()
	_Base.Enter(self)
	self._avatar:Play(self._animNameSet[1])
	self._combat:StartAttack(self._attackDataSet[1])
	--self._combat:SetSoundGroup(self._soundDataSet.hitting)
end

function _Roar:Update(dt)
	if self._body:GetTick() == self.ticks.voice then
		_Base.PlaySound(self._soundDataSet.voice)
	end

	if self._body:GetTick() == self.ticks.secAttack then
		self._combat:StartAttack(self._attackDataSet[1])
	end

	_Base.AutoTransitionAtEnd(self)
end

function _Roar:Exit()
	_Base.Exit(self)
end

return _Roar