--[[
	Desc: Combat Component
	Author: SerDing 
	Since: 2018-02-26 14:36:00 
	Alter: 2019-9-27
	* get 200% damage in flaw state as hit by counter attack
	* get 150% damage in flaw state as hit by normal attack
	* get 120% damage in lift state as hit by normal attack
]]
local _ENTITYMGR = require("system.entitymgr")
local _FACTORY = require("system.entityfactory")
local _RESOURCE = require("engine.resource")
local _RESMGR = require("system.resource.resmgr")
local _AUDIO = require("engine.audio")
local _Event = require("core.event")
local _Color = require("engine.graphics.config.color")
local _Base = require("entity.component.base")

---@class Entity.Component.Combat : Entity.Component.Base
---@field public _OnHit function
local _Combat = require("core.class")(_Base)

local _hitEffectMap = {
	cut = {
		up = {
			_RESMGR.LoadEntityData("effect/common/hit/slashlarge3"),
			_RESMGR.LoadEntityData("effect/common/hit/slashsmall3"),
		},
		horizon = {
			_RESMGR.LoadEntityData("effect/common/hit/slashlarge2"),
			_RESMGR.LoadEntityData("effect/common/hit/slashsmall2"),
		},
		down = {
			_RESMGR.LoadEntityData("effect/common/hit/slashlarge1"),
			_RESMGR.LoadEntityData("effect/common/hit/slashsmall1"),
		},
	},
	blow = {
		_RESMGR.LoadEntityData("effect/common/hit/knocklarge"),
		_RESMGR.LoadEntityData("effect/common/hit/knocksmall"),
	},
	blood = _RESMGR.LoadEntityData("effect/common/hit/blood"),
	fire = _RESMGR.LoadEntityData("effect/common/hit/elemental/fire"),
	ice = _RESMGR.LoadEntityData("effect/common/hit/elemental/ice"),
	dark = _RESMGR.LoadEntityData("effect/common/hit/elemental/dark"),
	light = _RESMGR.LoadEntityData("effect/common/hit/elemental/light"),
}

local _elementSoundDataMap = {
	fire = _RESOURCE.LoadSoundData("entity/effect/hitting/fire"),
	ice = _RESOURCE.LoadSoundData("entity/effect/hitting/ice"),
	dark = _RESOURCE.LoadSoundData("entity/effect/hitting/dark"),
	light = _RESOURCE.LoadSoundData("entity/effect/hitting/light"),
}

function _Combat:Ctor(entity)
	_Base.Ctor(self, entity)
	self._isRunning = false
	self._attackedList = {}
	self._attack = nil
	self.onAttackedEvent = _Event.New()
	self.onAttackedData = {
		damage = 0,
	}
end

---@param OnHitCallback fun(combat:Entity.Component.Combat, behitEntity:Entity):void
function _Combat:StartAttack(attack, OnHitCallback)
	self._attack = attack
	self._OnHit = OnHitCallback
	self:Reset()
	if attack.hitSound then
		self._hitSoundGroup = attack.hitSound
	end
	if attack.turnDirection == nil then
		self._attack.turnDirection = true
	end
end

function _Combat:FinishAttack()
	self._isRunning = false
	self._hitSoundGroup = nil
end

function _Combat:Reset()
	self:ClearAttackedList()
	self._isRunning = true
end

---@param a Entity
---@param b Entity
local function _IsSameCamp(a, b)
	return a.identity.camp == b.identity.camp
end

---@param a Entity
---@param b Entity
---@param key1 string
---@param key2 string
local function _Collide(a, b, key1, key2)
	local aColliders = a.render:GetColliders()
	local bColliders = b.render:GetColliders()
	local hit, x, y, z = false, 0, 0, 0
	for i=1,#aColliders do
		for j=1,#bColliders do
			hit, x, y, z = aColliders[i]:Collide(bColliders[j], key1, key2)
			if hit then
				break
			end
		end
	end

	return hit, x, y, z
end

---@param entity Entity
function _Combat:_CanBeAttacked(entity)
	local fighter = entity.fighter

	return fighter and fighter.isDead == false and
	_IsSameCamp(self._entity, entity) == false and 
	self:InAttackedList(entity.identity.id) == false
end

function _Combat:Update(dt)
	if not self._isRunning or self._entity.fighter.isDead then
		return false
	end

	local entityList = _ENTITYMGR.GetEntityList()
	for i = 1, #entityList do
		local e = entityList[i]
		if self:_CanBeAttacked(e) then
			local hit, x, y, z = _Collide(self._entity, e, "attack", "damage")	
			if hit then
				local oppoTransform = e.transform
				local curState = e.state:GetCurState()
				local isCritical = curState:IsFlawState() or self._entity.transform:IsInBackOf(oppoTransform)

				if (e.fighter or e.projectile) and self._attack.turnDirection then
					local selfPos = self._entity.projectile and self._entity.identity.master.transform.position or self._entity.transform.position
					local oppoPos = e.transform.position
					e.transform.direction = (selfPos.x - oppoPos.x > 0) and 1 or -1
				end

				if self._attack.selfstop then
					local selfstop = isCritical and self._attack.selfstop * 2 or self._attack.selfstop
					self._entity.hitstop:Enter(selfstop)
				end
				
				if self._attack.hitstop then
					local hitstop = isCritical and self._attack.hitstop * 2 or self._attack.hitstop
					e.hitstop:Enter(hitstop)
				end
				
				if e.state then
					local push = self._attack.push
					local lift = self._attack.lift
					local curStateName = curState:GetName()

					if push and curStateName ~= "lift" then
						if curState:HasTag("jump") then
							e.state:SetState("lift")
						else
							e.state:SetState("push", push.time, push.v, push.a)
						end
					end
					
					if lift then
						e.state:SetState("lift", lift.vz, lift.az, lift.vx, lift.ax)
					end
				end
				
				local param = {
					x = x, 
					y = e.transform.position.y, -- for correct order
					z = z,
					direction = e.transform.direction,
					master = e,
				}
				local hitType = self._attack.type
				local hitDirection = self._attack.direction
				local effect = self:_GetEffect(hitType, hitDirection)
				_FACTORY.NewEntity(effect, param)
				
				if self._attack.element then
					_FACTORY.NewEntity(_hitEffectMap[self._attack.element], param)
				end

				if self._attack.type == "cut" then
					local blood = _FACTORY.NewEntity(_hitEffectMap.blood, param)
					-- blood.render.renderObj:SetRenderValue("color", 220, 0, 0 , 255)
				end

				if self._hitSoundGroup then
					if type(self._hitSoundGroup) == "table" then
						_AUDIO.RandomPlay(self._hitSoundGroup)
					else
						_AUDIO.PlaySound(self._hitSoundGroup)
					end
				end

				if self._attack.element then
					_AUDIO.PlaySound(_elementSoundDataMap[self._attack.element])
				end

				local damageSoundDataSet = e.fighter.damageSoundDataSet
				if damageSoundDataSet then
					if type(damageSoundDataSet) == "table" then
						_AUDIO.RandomPlay(damageSoundDataSet)
					else
						_AUDIO.PlaySound(damageSoundDataSet)
					end
				end

				local attackedData = e.combat.onAttackedData
				attackedData.damage = self._attack.damage
				e.combat.onAttackedEvent:Notify()
	
				if self._OnHit then
					self._OnHit(self, e)
				end
				
				self._attackedList[#self._attackedList + 1] = e.identity.id
			end
		end
	end
	
end

---@param eid int
function _Combat:InAttackedList(eid)
	for i=1,#self._attackedList do
		if self._attackedList[i] == eid then
			return true
		end
	end

	return false
end

function _Combat:ClearAttackedList()
	self._attackedList = {}
end

---@param hitType string
---@param hitDriection string
function _Combat:_GetEffect(hitType, hitDriection)
	local list = hitDriection and _hitEffectMap[hitType][hitDriection] or _hitEffectMap[hitType]
	local index = math.random(1, #list)
	return list[index]
end

---@param hitSoundGroup table<int, SoundData>
function _Combat:SetSoundGroup(hitSoundGroup)
	self._hitSoundGroup = hitSoundGroup
end

return _Combat 