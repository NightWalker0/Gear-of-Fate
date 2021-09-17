--[[
	Desc: Normal attack state
 	Author: SerDing
	Since: 2017-07-28
	Alter: 2020-03-29
]]
local _Base = require("entity.states.base")

---@class Entity.State.Swordman.Attack : Entity.State.Base
local _Attack = require("core.class")(_Base)

function _Attack:Ctor(data, ...)
    _Base.Ctor(self, data, ...)
    self._phase = 0
    self._keyFrames = data.keyFrames
    self._ticks = data.ticks
    self._combo = #self._keyFrames + 1
    self._switchPhase = false
end

function _Attack:Enter()
    if self._STATE.preState ~= self then
        _Base.Enter(self)
        self._phase = 1
        self:_OnSetPhase(self._phase)
    else
        self._switchPhase = true
    end
    self._combat:SetSoundGroup(self._soundDataSet.hitting.hsword)
end

function _Attack:Update(dt)
    _Base.EaseMove(self, self._phase)

    if self._phase < self._combo and self._switchPhase and self._body:GetFrame() > self._ticks[self._phase] then
        self:SetPhase(self._phase + 1)
    end

    _Base.AutoTransitionAtEnd(self)
end

function _Attack:SetPhase(nextPhase)
    self._phase = nextPhase
    self._switchPhase = false
    self._avatar:Play(self._animNameSet[self._phase])
    self:_OnSetPhase(nextPhase)
end

function _Attack:_OnSetPhase(process)
    self._combat:StartAttack(self._attackDataSet[process])
    local subtype = self._entity.equipment:GetSubtype("weapon")
    _Base.RandomPlaySound(self._soundDataSet.swing[subtype])
    _Base.RandomPlaySound(self._soundDataSet.voice)
    -- _Base.NewEntity(self._entityDataSet[self._process], {master = self._entity})
end

function _Attack:Exit()
    _Base.Exit(self)
    --self._switchPhase = false
    --self._phase = 0
end

return _Attack 