--[[
	Desc: Ashenfork 
	Author: SerDing 
	Since: 2018-04-21 03:51:58 
	Last Modified time: 2018-04-21 03:51:58 
	Docs: 
		* Write notes here even more 
]]
local _AUDIO = require("engine.audio")
local _Base  = require "entity.states.base"

local _Ashenfork = require("core.class")(_Base)
function _Ashenfork:Ctor(data, ...)
	_Base.Ctor(self, data, ...)
	self.name = "ashenfork"
	self.skillID = 16
	self.g = 250 -- 130
	self.speed = 140 * 1.3
	self.enoughHeight = false
end 

function _Ashenfork:Enter()
	_Base.Enter(self)
	-- self.attackName = "ashenfork"
	self.avatar:Play("flowmindtwoattack1") -- waiting for changing a right one
	for _ = 1, 3 do
		self.avatar:NextFrame()
	end

	self.enoughHeight = (self._entity.transform.position.z < -120) and true or false

	self.combat:ClearDamageArr()
	self.atkObj = nil

	self.movement.directionZ = -1
	self._entity.hitstop:Enter(170)

	self.movement:Set_g(self.g, self._entity.stats.attackRate)
	self.movement.eventMap.land:AddListener(self, self.Land)
end

function _Ashenfork:Update(dt)
	_Base.AutoTransitionAtEnd(self)

	if not self.effect[1] then
		local effect = self:Effect("jumpattackhold.ani")
		--effect.transform.SetScale(1.4, 1.4)
		_AUDIO.PlaySound("SKYRADE_SWING")
	end

	self:AtkObjBorn()
	self:X_Move()
	
	-- attack judgement
    -- if self._entity:GetAttackBox() then
    --     self.combat:Judge(self._entity, "MONSTER", self.attackName)
    -- end
end 

function _Ashenfork:Land()
	self.avatar:Play("sit")
end

function _Ashenfork:X_Move()
    if self._entity.transform.position.z < 0 then
		self.movement:X_Move( self.speed * self._entity.transform.direction)
	end
end

function _Ashenfork:AtkObjBorn()
	if self._entity.transform.position.z >= 0 then
		if not self.atkObj and self.enoughHeight then
			self.atkObj = _PassiveObjMgr.GeneratePassiveObj(20016)
			self.atkObj:SetHost(self._entity)
			self.atkObj:SetPos(self._entity.transform.position.x + 0 * self._entity.transform.direction, self._entity.transform.position.y - 1, 0)
			self.atkObj:SetDir(self._entity.transform.direction)
		end
	end
end

function _Ashenfork:Exit()
    _Base.Exit(self)
end

return _Ashenfork 