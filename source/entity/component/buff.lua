--[[
	Desc: Buff component for actor
 	Author: SerDing
	Since: 2017-07-28 
	Alter: 2019-11-10 
]]
--local _Animator = require("engine.animation.frameani")
local _Base = require("entity.component.base")

---@class Entity.Component.Buff : Entity.Component.Base
local _Buff = require("core.class")(_Base)

local _buffAnis = {
	["frenzy"] = "resource/data/character/swordman/effect/animation/frenzy/buff.ani", 
}

function _Buff:Ctor(entity)
	_Base.Ctor(self, entity) 
	self.buff = {['name'] = {switch = false, anim = nil}}
end

function _Buff:Update(dt)
	for name, buff in pairs(self.buff) do
		if buff.switch then
			buff.anim:Update(dt)
		end
	end
end

function _Buff:Draw()
	for name, buff in pairs(self.buff) do
		if buff.switch then
			buff.anim:Draw(self._entity.transform.position.x, self._entity.transform.position.y + self._entity.transform.position.z)
		end
	end
end

function _Buff:AddBuff(buffName)
	if not self.buff[buffName] then
		self.buff[buffName] = {switch = false, anim = nil}
	end
	if self.buff[buffName].switch then
		return
	else 
		self.buff[buffName].switch = true
	end 

	if not self.buff[buffName].anim then	
		self.buff[buffName].anim = _Animator.New()
		self.buff[buffName].anim:Play(dofile(_buffAnis[buffName]))
	end 

end

function _Buff:OffBuff(buffName)
	assert(self.buff[buffName], "not found buff:" .. buffName)
	self.buff[buffName].switch = false
end

return _Buff 