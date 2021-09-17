--[[
    Desc: 3D Bound box, composition of 2 rectangles.
 	Author: SerDing
	Since: 2020-04-19
	Alter: 2020-04-19 
]]

local _Rect = require("engine.graphics.drawable.rect")

---@class Entity.Drawable.Box : Engine.Graphics.Drawable.Base
local _Box = require("core.class")()

function _Box:Ctor(x, y1, y2, w, h1, h2)
    self._x = 0
    self._y = 0
    self._z = 0
    self._sx = 1
    self._sy = 1

    self._struct = { -- position is relative
        x = x,
        y1 = y1,
        y2 = y2,
        w = w,
        h1 = h1,
        h2 = h2,
    }

    self.xyRect = _Rect.New()
    self.xzRect = _Rect.New()
end

---@param x int
---@param y int
---@param z int
---@param sx int
---@param sy int
function _Box:Set(x, y, z, sx, sy)
    self._x = x or self._x
    self._y = y or self._y
    self._z = z or self._z
    self._sx = sx or self._sx
    self._sy = sy or self._sy
    self:Update()
end

---@param x int
---@param y1 int
---@param y2 int
---@param w number
---@param h1 number
---@param h2 number
function _Box:SetStruct(x, y1, y2, w, h1, h2)
    self._struct.x = x or self._struct.x
    self._struct.y1 = y1 or self._struct.y1
    self._struct.y2 = y2 or self._struct.y2
    self._struct.w = w or self._struct.w
    self._struct.h1 = h1 or self._struct.h1
    self._struct.h2 = h2 or self._struct.h2
    self:Update()
end

function _Box:Update()
    local x = self._x + self._struct.x * self._sx
    local y1 = self._y - (self._struct.y1 + self._struct.h1) * self._sy
    local y2 = self._y - (self._struct.y2 + -self._z + self._struct.h2) * self._sy 
    local w = self._struct.w * math.abs(self._sy)
    local h1 = self._struct.h1 * math.abs(self._sy)
    local h2 = self._struct.h2 * math.abs(self._sy)

    if self._sx < 0 then
        x = x - w
    end
    
    if self._sy < 0 then
        y1 = y1 - h1
        y2 = y2 - h2
    end
    
    self.xyRect:SetDrawData(x, y1, w, h1)
    self.xzRect:SetDrawData(x, y2, w, h2)
end

---@param box Entity.Drawable.Box
---@return boolean
---return result and collision point
function _Box:Collide(box)
    if self.xyRect:CheckRect(box.xyRect) then
        local collision, x, z = self.xzRect:CheckRect(box.xzRect)
        return collision, x, self._y, z - self._y
    end

    return false
end

function _Box:CheckPoint(x, y, z)
    return self.xyRect:CheckPoint(x, y) and self.xzRect:CheckPoint(x, y + z)
end

function _Box:Draw(colorA, colorB)
    self.xyRect:Draw(colorA, "line")
    self.xzRect:Draw(colorB, "line")
end

return _Box