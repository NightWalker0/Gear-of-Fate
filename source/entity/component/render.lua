--[[
    Desc: Render Component
    Author: SerDing
    Since: 2019-12-04
    Alter: 2019-12-04
]]
local _Drawable = require("engine.graphics.drawable.base")
local _Color = require("engine.graphics.config.color")
local _Base = require("entity.component.base")

---@class Entity.Component.Render : Entity.Component.Base
---@field public renderObj Entity.Drawable.Avatar | Entity.Drawable.Frameani
---@field public navPath table<int, Vector2>
---@field public skillCollider Entity.Collider
local _Render = require("core.class")(_Base)

function _Render.HandleData(data)
    if data.obj then
        data.objClass = require("entity.drawable." .. data.obj)
        if data.objClass.HandleData then 
            data.objClass.HandleData(data)
        end
    end
end

function _Render:Ctor(entity, data, param)
    _Base.Ctor(self, entity)
    self._transform = entity.transform
    self.renderObj = data.objClass.New(data)
    self.height = data.height or 0
    self.offset = data.offset or 0 -- offset for render order
    self.color = data.color and _Color.New(data.color.red, data.color.green, data.color.blue, data.color.alpha) or _Color.White()
    self.navPath = nil
    self.skillCollider = nil
    self.timeScale = 1.0

    if data.obj == "frameani" or data.obj == "sprite" then
        self.layer = _Drawable.New()
        self.layer:AddChild(self.renderObj)
    end
end

function _Render:Update(dt)
    if self.renderObj.Update and not self._entity.identity.isPaused then
        self.renderObj:Update(dt, self.timeScale)
    end
    
    local e = self._entity
    local px, py, pz = e.transform.position:Get()
    local sx, sy = e.transform.scale:Get()

    local obj = self.renderObj --self.layer or
    obj:SetRenderValue("position", math.floor(px), math.floor(py), math.floor(pz))
    obj:SetRenderValue("radian", e.transform.rotation)
    obj:SetRenderValue("scale", sx * e.transform.direction, sy)
    obj:SetRenderValue("color", self.color:Get())
end

function _Render:Draw()
    self.renderObj:Draw()

    if self.navPath and self._entity.aic and self._entity.aic.navigation then
        self._entity.aic.navigation:DrawPath(self.navPath)
    end

    --if self.skillCollider then
    --    self.skillCollider:Draw()
    --end
end

function _Render:GetColliders()
    return (self.renderObj.GetColliderGroup) and self.renderObj:GetColliderGroup() or {self.renderObj:GetCollider()}
end

return _Render