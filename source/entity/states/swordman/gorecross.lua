--[[
	Desc: Gorecross state
	Author: SerDing
	Since: 2017-07-28
	Alter: 2020-02-04
]]
local _Base = require("entity.states.base")

---@class Entity.State.Swordman.GoreCross : Entity.State.Base
---@field protected _effectTicks table<number, number>
---@field protected _attackTicks table<number, number>
local _GoreCross = require("core.class")(_Base)

function _GoreCross:Ctor(data, ...)
	_Base.Ctor(self, data, ...)
	self.skillID = 64
	self._effectTicks = data.effectTicks
	self._attackTicks = data.attackTicks
end 

function _GoreCross:Enter()
	_Base.Enter(self)
	_Base.PlaySound(self._soundDataSet.voice)

	---@param effect Entity
	self._NewProjectile = function(effect)
		local t = effect.transform
		local param = {
			x = t.position.x + t.direction * effect.render.renderObj:GetWidth() * 0.65,
			y = t.position.y,
			z = t.position.z - effect.render.renderObj:GetHeight() / 2,
			direction = t.direction,
			master = self._entity,
			camp = self._entity.identity.camp,
		}
		_Base.NewEntity(self._entityDataSet[3], param)
	end

	local param = { master = self._entity }
	_Base.NewEntity(self._entityDataSet[1], param)
	self._crossEffect = _Base.NewEntity(self._entityDataSet[2], param)
	-- self._crossEffect.identity.destroyEvent:AddListener(self._crossEffect, self._NewProjectile)

	self._combat:SetSoundGroup(self._soundDataSet.hitting)
	self._combat:StartAttack(self._attackDataSet[1])
end

function _GoreCross:Update(dt)
	local tick = self._body:GetTick()
	if tick == self._effectTicks[1] or tick == self._effectTicks[2] then
		_Base.PlaySound(self._soundDataSet.swing[1])
	elseif tick == self._effectTicks[3] then
		_Base.PlaySound(self._soundDataSet.swing[2])
	end

	if tick == self._attackTicks[1] then
		self._combat:StartAttack(self._attackDataSet[2])
	end

	if self._crossEffect and self._crossEffect.render.renderObj:GetTick() == self._effectTicks[3] then
		self._NewProjectile(self._crossEffect)
		self._crossEffect.identity:StartDestroy()
		self._crossEffect = nil
	end
	
	_Base.AutoTransitionAtEnd(self)
end 

function _GoreCross:Exit()
	self._projectile = nil
	_Base.Exit(self)
end

return _GoreCross 