--[[
	Desc: Frenzy State
 	Author: SerDing
	Since: 2017-07-28 21:54:14
	Alter: 2017-07-30 12:40:40
	Docs:
		* wrap the logic of tmp state in this class
]]
local _AUDIOMGR = require "engine.audio"
local _Base  = require "entity.states.base"

---@class State.Frenzy : Entity.State.Base
local _Frenzy = require("core.class")(_Base)

function _Frenzy:Ctor(data, ...)
	_Base.Ctor(self, data, ...)
	self.name = "frenzy"
	self.effect = {}
	self.stateColor = {255, 150, 0, 255}
	self.switch = false
	self.skillID = 76
end 

function _Frenzy:Enter()
	_Base.Enter(self)
	self.buffComponent = self._entity.buff
	if self.switch then
		
		self.switch = false
		
		self._body:SetRenderValue("color", 255, 255, 255, 255)
		-- self._entity:GetAvatar():GetPart("weapon_b1"):SetColor(255, 255, 255, 255)
		-- self._entity:GetAvatar():GetPart("weapon_c1"):SetColor(255, 255, 255, 255)
		self.buffComponent:OffBuff("frenzy")
		self.FSM:SetState(self.FSM.oriState, self._entity)
		self._entity.atkMode = "normal"

		return 
	end 
	
	self._avatar:Play("grab")
	
	self._body:SetRenderValue("color", unpack(self.stateColor))
	-- self._entity:GetAvatar():GetPart("weapon_b1"):SetColor(unpack(self.stateColor))
	-- self._entity:GetAvatar():GetPart("weapon_c1"):SetColor(unpack(self.stateColor))

	-- _Base.Effect(self, "frenzy/cast.ani")

	self.switch = true
	self._entity.atkMode = "frenzy"
	_AUDIOMGR.PlaySound("SM_FLENSE")
end

function _Frenzy:Update(dt)
	if not self.effect[2] and self._body:GetFrame() == 6 then
		-- _Base.Effect(self, "frenzy/blast.ani")
	end 

	if self._body:GetFrame() == 16 then
		self.buffComponent:AddBuff("frenzy")
	end 
end 

function _Frenzy:Exit()
	for n=1,#self.effect do
		self.effect[n] = nil
	end 
	-- if self.switch then
	-- 	self.body:SetColor(unpack(self.stateColor))
	-- end
end

return _Frenzy 