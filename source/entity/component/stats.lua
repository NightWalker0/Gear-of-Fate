--[[
    Desc: Stats Component for entity
    Author: SerDing
    Since: 2019-11-24
    Alter: 2019-11-24
]]

local _Value = require("utils.value")
local _MpModel = require("entity.mpmodel")
local _Base = require("entity.component.base")

---@class Entity.Component.Stats : Entity.Component.Base
local _Stats = require("core.class")(_Base)

function _Stats:Ctor(entity, data)
    _Base.Ctor(self, entity)

    self.maxhp = data.maxhp or 100
    self.maxmp = data.maxmp or 100
    self.hpRecovery = data.hpRecovery or 0
    self.mpRecovery = data.mpRecovery or 0
    self.hp = _Value.New(data.hp or self.maxhp, self.maxhp, self.hpRecovery)
    self.mp = _MpModel.New(data.mp or self.maxmp, self.maxmp, self.mpRecovery)
    self.attack = data.attack or 10
    self.defense = data.defense or 10
    self.critical = data.critical or 0
    self.attackRate = data.attackRate or 1.0
    self.moveRate = data.moveRate or 1.0
    self.moveSpeed = data.moveSpeed or 100

    self._entity.combat.onAttackedEvent:AddListener(self, self.OnAttacked)
end

function _Stats:Update(dt)
    if self._entity.fighter.isDead then
        return
    end

    self.hp:Update(dt)
    self.mp:Update(dt)
end

function _Stats:OnAttacked()
    local data = self._entity.combat.onAttackedData
    self.hp:Decrease(data.damage)
    if self.hp:GetCur() == 0 then
        self._entity.fighter:Die()
    end
end

return _Stats