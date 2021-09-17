--[[
	Desc: Entity Factory
	Author: SerDing 
	Since: 2019-03-14
	Alter: 2019-11-07
]]
local _Transform = require("entity.component.transform")
local _Identity = require("entity.component.identity")
local _RESMGR = require("system.resource.resmgr")
local _ENTITYMGR = require("system.entitymgr")

---@class System.EntityFactory
---@field public mainPlayer Entity
---@field public monsters table<number, Monster>
local _FACTORY = {
    mainPlayer = nil,
    monsters = {}
}
local this = _FACTORY

local _creationOrder = {
    "aic",
    "input", 
    "movement", 
    "fighter",
    "combat",
    "stats",
    "buff",
    "render",
    "skills",
    "state",
    "hitstop",
    "effect",
    "projectile",
    "equipment",
    "obstacle"
}

---@param data string @entity instance data path
---@return Entity
function _FACTORY.NewEntity(data, param)
    if type(data) == "string" then
        data = _RESMGR.LoadEntityData(data)
    end

    ---@class Entity
    ---@field public transform Entity.Component.Transform
    ---@field public identity Entity.Component.Identity
    ---@field public aic Entity.Component.AIC
    ---@field public input Entity.Component.Input
    ---@field public render Entity.Component.Render
    ---@field public fighter Entity.Component.Fighter
    ---@field public movement Entity.Component.Movement
    ---@field public stats Entity.Component.Stats
    ---@field public state Entity.Component.State
    ---@field public skills Entity.Component.Skills
    ---@field public combat Entity.Component.Combat
    ---@field public equipment Entity.Component.Equipment
    ---@field public hitstop Entity.Component.HitStop
    ---@field public buff Entity.Component.Buff
    ---@field public effect Entity.Component.Effect
    ---@field public projectile Entity.Component.Projectile
    local entity = {}
    entity.transform = _Transform.New(entity, data.transform or {}, param)
    entity.identity = _Identity.New(entity, data.identity or {}, param)
    
    local key = ""
    for i=1,#_creationOrder do
        key = _creationOrder[i]
        if data[key] then
            entity[key] = data[key].class.New(entity, data[key], param)
        end 
    end

    for _, component in pairs(entity) do
        component:Init()
    end

    _ENTITYMGR.AddEntity(entity)

    return entity
end

return _FACTORY