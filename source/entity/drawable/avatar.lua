--[[
	Desc: Avatar, a set of frame animations.
	Author: SerDing 
	Since: 2018-09-22
	Alter: 2020-03-11
]]
local _Frameani = require "entity.drawable.frameani"
local _Layer = require("engine.graphics.drawable.layer")
local _RESMGR = require("system.resource.resmgr")
local _RESOURCE = require("engine.resource")

---@class Entity.Drawable.Avatar : Engine.Graphics.Drawable.Layer
---@field protected _aniMap table<string, Entity.Drawable.Frameani>
---@field protected _aniDatas table<string, table<string, Engine.Resource.AnimData>>
---@field protected _path string @ basic path for animData and images
---@field protected _subpath table<string, string> @ sprite subpath for dynamic mode
---@field protected _order table<string, number>
---@field protected _dynamic boolean
local _Avatar = require("core.class")(_Layer)

local _DEFAULT_KEY = "body"

function _Avatar.HandleData(data)
    if data.animPathSet then
        data.aniDatas = {}
        for key, path in pairs(data.animPathSet) do
            data.aniDatas[key] = _RESOURCE.LoadAnimData(data.path .. path)
        end
    end
end

---@param data table
function _Avatar:Ctor(data)
    _Layer.Ctor(self)
    self._aniMap = {}
    self._aniDatas = {}
    
    self._path = data.path or ""
    self._subpath = data.subpath
    self._order = data.order
    self._dynamic = data.dynamic
    
    local keylist = (self._dynamic == true) and self._subpath or data.animPathSet
    for key,_ in pairs(keylist) do
        self:AddPart(key)
    end
    if self._dynamic == false then
        self._aniDatas = data.aniDatas
        self:Play()
    end
    if data.init then
        self:InitAnimDatas(data.init.animNameSet)
        self:Play(data.init.defaultAnim)
    end
end 

function _Avatar:Update(dt, timeScale)
    for _,part in pairs(self._aniMap) do
        part:Update(dt, timeScale)
    end 
end 

---@param name string
function _Avatar:Play(name)
    for key, part in pairs(self._aniMap) do
        local data = (self._dynamic) and self._aniDatas[key][name] or self._aniDatas[key]
        part:Play(data, name)
    end
end 

function _Avatar:SyncPart(key)
    local animName = self:GetPart()._aniName
    local part = self._aniMap[key]
    part:Play(self._aniDatas[key][animName], animName)
    part:Sync(self:GetPart())
end

---@param data table<string, string> @ new subpath data table
function _Avatar:AddByData(data)
    for key, subpath in pairs(data) do
        if not self._aniMap[key] then
            self:AddPart(key)
        end
        self._subpath[key] = subpath
    end
end

---@param animNameSet table<number, string>
function _Avatar:InitAnimDatas(animNameSet)
    for part, subpath in pairs(self._subpath) do
        -- for i=1,#animPathSet do
        --     self._animDatas[part][animPathSet[i]] = _RESMGR.LoadAvatarAnimData(self._path .. animPathSet[i], self._path .. subpath)
        -- end
        self:LoadAnimDatas(part, animNameSet, subpath)
    end
end

function _Avatar:LoadAnimDatas(part, animNameSet, path)
    local subpath = path or self._subpath[part]
    for i=1,#animNameSet do
        self._aniDatas[part][animNameSet[i]] = _RESMGR.LoadAvatarAnimData(self._path .. animNameSet[i], self._path .. subpath)
    end
end

---@param key string
function _Avatar:AddPart(key)
    self._aniMap[key] = _Frameani.New()
    self._aniMap[key].order = self._order[key]
    self._aniDatas[key] = {}
    self:Add(self._aniMap[key])
    
    ---@param partA Engine.Graphics.Drawable.Base
    ---@param partB Engine.Graphics.Drawable.Base
    local function _Sort(partA, partB)
        return partA.order < partB.order
    end
    _Layer.Sort(self, _Sort)
end

function _Avatar:GetPart(key)
    return self._aniMap[key or _DEFAULT_KEY]
end

function _Avatar:NextFrame()
    for _,part in pairs(self._aniMap) do
        part:NextFrame()
    end
end 

function _Avatar:SetFrame(n)
    for _,part in pairs(self._aniMap) do
        part:SetFrame(n)
    end
end

function _Avatar:CallChildGetFunc(op)
    for _,part in pairs(self._aniMap) do
        return part[op](part)
    end
end

function _Avatar:GetFrame()
    return self:CallChildGetFunc("GetFrame")
end

function _Avatar:GetTick()
    return self:CallChildGetFunc("GetTick")
end

function _Avatar:TickEnd()
    return self:CallChildGetFunc("TickEnd")
end

---@return table<int, Entity.Collider>
function _Avatar:GetColliderGroup()
    local colliders = {}
    for _,v in pairs(self._aniMap) do
        local collider = v:GetCollider()
        if collider and not collider:IsEmpty() then
            colliders[#colliders + 1] = collider
        end
    end
    
    return colliders
end

function _Avatar:GetHeight(key)
    return self._aniMap[key or _DEFAULT_KEY]:GetWidth()
end

function _Avatar:GetHeight(key)
    return self._aniMap[key or _DEFAULT_KEY]:GetHeight()
end

return _Avatar