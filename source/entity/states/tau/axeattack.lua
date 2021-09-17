--[[
	Desc: Axe attack for Tau
	Author: SerDing
	Since: 2021-05-26
	Alter: 2021-05-26
]]
local _Base = require("entity.states.base")

---@class Entity.State.Tau.AxeAttack : Entity.State.Base
local _AxeAttack = require("core.class")(_Base)

function _AxeAttack:Ctor(data, name)
	_Base.Ctor(self, data, name)
	self.ticks = data.ticks
	self._attackTimes = 2
	self._attackCount = 0
	self._firstAttackHit = false
end

function _AxeAttack:Enter()
	_Base.Enter(self)
	self._avatar:Play(self._animNameSet[1])
	self._combat:StartAttack(self._attackDataSet[1], function(combat, behitEntity)
		self._firstAttackHit = true
	end)
	self._combat:SetSoundGroup(self._soundDataSet.hitting)
	self._attackCount = self._attackCount + 1
end

function _AxeAttack:Update(dt)
	if self._body:GetTick() == self.ticks.swing then
		_Base.PlaySound(self._soundDataSet.swing)
	elseif self._body:GetTick() == self.ticks.voice then
		_Base.PlaySound(self._soundDataSet.voice)
	end

	if self._body:GetTick() == self.ticks.secAttack and self._attackCount < self._attackTimes and self._firstAttackHit then
		self._avatar:Play(self._animNameSet[1])
		self._avatar:SetFrame(3)
		self._combat:StartAttack(self._attackDataSet[1])
		self._attackCount = self._attackCount + 1
		self._firstAttackHit = false
	end

	_Base.AutoTransitionAtEnd(self)
end

function _AxeAttack:Exit()
	_Base.Exit(self)
	self._attackCount = 0
end

return _AxeAttack