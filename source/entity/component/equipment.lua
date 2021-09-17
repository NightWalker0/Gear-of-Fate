--[[
	Desc: Equipment Component
 	Author: SerDing
	Since: 2019-08-31 01:52:21
    Alter: 2019-09-27 19:32:25
]]

local _RESMGR = require("system.resource.resmgr")
local _Event = require("core.event")
local _Base = require("entity.component.base")

---@class Entity.Component.Equipment : Entity.Component.Base
---@field protected _equipments table<int, EquData>
---@field public onEquipmentChanged Event
local _Equipment = require("core.class")(_Base)

---@class EquData
---@field public name string
---@field public explain string
---@field public type string
---@field public subtype string
---@field public damage int
---@field public icon Engine.Graphics.Drawable.Sprite
---@field public avatar table<string, string>
---@field public add table<string, int>
local _EquData = require("core.class")()

local _EQU_TYPE_ENUM = {
    weapon = 1,
    ring = 2,
    stone = 3, 
    coat = 4,
}

function _Equipment.HandleData(data)
    for key, value in pairs(data) do
        if key ~= "class" then
            data[key] = _RESMGR.LoadEquipmentData(value)
        end
    end
end

function _Equipment:Ctor(entity, data)
    _Base.Ctor(self, entity) 
    self._equipments = {} -- entity's current equipments
    self.onEquipmentChanged = _Event.New()
    -- self.onEquipmentChanged:AddListener(self, self._printEquInfo)
    -- self.equPathList = dofile("resource/data/equipment/equipmentlist.lua")

    for key, value in pairs(data) do
        if key ~= "class" then
            self:Wear(value)
        end
    end

end

--- Wear the equipment and update animation
---@param equ table equipment data 
---@param slotIndex string 
function _Equipment:Wear(equ)
    if self._entity.identity.type == "character" then
        local slotIndex = _EQU_TYPE_ENUM[equ.type]
        self._equipments[slotIndex] = equ
        self.onEquipmentChanged:Notify(equ, "equiped")
    else -- for monster
        -- accessory
        self._equipments[#self._equipments + 1] = equ
    end
    
    self._entity.render.renderObj:AddByData(equ.avatar)
    for key, _ in pairs(equ.avatar) do
        self._entity.state:ReloadAnimDatas(key)
        self._entity.render.renderObj:SyncPart(key)
    end
end

---@param slot string 
function _Equipment:UnEquip(slot)
    -- statements
end

---@param part string 
---@return table equipment data 
function _Equipment:GetCurrentEqu(part)
    return self._equipments[_EQU_TYPE_ENUM[part]]
end

function _Equipment:GetSubtype(part)
    return self._equipments[_EQU_TYPE_ENUM[part]].subtype
end

function _Equipment:_printEquInfo(equ, msgType)
    -- weapon
    print("_print equipment:")
    print("\tname:", equ.name)
    print("\texplain:", equ.explain)
    print("\tbackground_text:", equ.background_text)
    print("\ttype:", equ.type) 
    print("\tsubtype:", equ.subtype)
    print("\tattack:", equ.add.attack)
end

return _Equipment
