--[[
    Desc: Identity Component
    Author: SerDing
    Since: 2019-12-02
    Alter: 2019-12-02
]]
local _Event = require("core.event")
local _Base = require("entity.component.base")

---@class Entity.Component.Identity : Entity.Component.Base
---@field public name string
---@field public type string
---@field public id number
---@field public process number
---@field public master Entity
---@field public camp int
local _Identity = require("core.class")(_Base)

function _Identity:Ctor(entity, data, param)
    _Base.Ctor(self, entity)
    self.name = param.name or data.name or ""
    self.job = data.job or ""
    self.type = data.type or ""
    self.master = param.master or nil
    self.camp = param.camp or 0
    self.weight = 0
    self.id = -1
    self.process = 2
    self.isPaused = false
    self.immortal = false
    self.dontDestroyOnLoadScene = false
    self.onDestroy = _Event.New()
end

function _Identity:StartDestroy()
    self.process = 0
    self.onDestroy:Notify()
end

return _Identity