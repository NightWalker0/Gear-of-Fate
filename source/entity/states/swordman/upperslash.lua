--[[
	Desc: UpperSlash state 
 	Author: SerDing
	Since: 2017-07-28 21:54:14
	Alter: 2017-07-30 12:40:40
	Docs:
		* wrap the logic of UpperSlash state in this class
]]
local _AUDIO = require("engine.audio")
local _FACTORY = require("system.entityfactory") 
local _Base  = require("entity.states.base")

---@class Entity.State.Swordman.UpperSlash : Entity.State.Base
local _UpperSlash = require("core.class")(_Base)

function _UpperSlash:Ctor(data, ...)
	_Base.Ctor(self, data, ...)
	self.skillID = 46
	self._process = 1
	self._ticks = data.ticks
end 

function _UpperSlash:Enter()
	_Base.Enter(self)
	self._combat:SetSoundGroup(self._soundDataSet.hitting.hsword)
	self._combat:StartAttack(self._attackDataSet[1])
end

function _UpperSlash:Update(dt)
	_Base.EaseMove(self, self._process)
	_Base.AutoTransitionAtEnd(self)
	
	if self._body:GetTick() == self._ticks[1] then
		local param = {master = self._entity}
		_FACTORY.NewEntity(self._entityDataSet[1], param)

		_AUDIO.PlaySound(self._soundDataSet.voice)
		_AUDIO.PlaySound(self._soundDataSet.swing)
	end 
end 

function _UpperSlash:Exit()
	_Base.Exit(self)
end

return _UpperSlash 