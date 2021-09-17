--[[
    Desc: Collider, set of boxes.
    * contains damage boxes and attack boxes
    * set from data
    * frame->colliderData, frames->colliderDataGroup(table)
    * Frameani carry collider, colliderGroup, colliderGroupPool
 	Author: SerDing
	Since: 2020-04-19
	Alter: 2020-04-19 
]]
local _SETTING = require("setting")
local _Box = require("entity.drawable.box")
local _Color = require("engine.graphics.config.color")

---@class Entity.Collider
---@field protected _boxlists table<string, table<int, Entity.Drawable.Box>>
local _Collider = require("core.class")()

---@class Entity.Collider.ColliderData
---@field public damage table
---@field public attack table

local function _HandleData(data, lists, key)
    if data[key] and #data[key] >= 1 then
        if #data[key][1] > 6 then -- all boxes in one table
            local args = data[key][1]
            for i=1,#data[key][1] / 6, 6 do
                lists[key][i] = _Box.New(args[i], args[i + 1], args[i + 2], args[i + 3], args[i + 4], args[i + 5])
            end
        else
            for i=1,#data[key] do
                lists[key][i] = _Box.New(unpack(data[key][i]))
            end
        end
    end
end

---@param data Entity.Collider.ColliderData
function _Collider:Ctor(data)
    self._boxlists = {
        damage = {},
        attack = {},
    }

    if data then
        _HandleData(data, self._boxlists, "damage")
        _HandleData(data, self._boxlists, "attack")
    end
end

function _Collider:Set(x, y, z, sx, sy)
    for key, list in pairs(self._boxlists) do
        for i=1,#list do
            list[i]:Set(x, y, z, sx, sy)
        end
    end
end

---@param opponent Entity.Collider
---@param selfKey string
---@param oppoKey string
function _Collider:Collide(opponent, selfKey, oppoKey)
    local selfList = self._boxlists[selfKey]
    local oppoList = opponent:GetBoxList(oppoKey)

    for i=1,#selfList do
        for j=1,#oppoList do
            local collision, x, y, z = selfList[i]:Collide(oppoList[j])
            if collision then
                return true, x, y, z
            end
        end
    end

    return false
end

---@param boxType string
---@param x float
---@param y float
---@param z float
function _Collider:CheckPoint(boxType, x, y, z)
    local boxlist = self._boxlists[boxType]
    for i = 1, #boxlist do
        if boxlist[i]:CheckPoint(x, y, z) then
            return true
        end
    end

    return false
end

function _Collider:Draw()
    if not _SETTING.debug.collider then
        return 
    end
    
    for i=1,#self._boxlists.damage do
        self._boxlists.damage[i]:Draw(_Color.const.blue, _Color.const.green)
    end
    for i=1,#self._boxlists.attack do
        self._boxlists.attack[i]:Draw(_Color.const.blue, _Color.const.red)
    end
end

function _Collider:GetBoxList(key)
    return self._boxlists[key]
end

function _Collider:IsEmpty()
    return #self._boxlists.damage == 0 and #self._boxlists.attack == 0
end

return _Collider