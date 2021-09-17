--[[
    Desc: Layer, a container of drawables.
    Author: SerDing
	Since: 2020-03-21
	Alter: 2020-03-21
]]
local _Base = require("engine.graphics.drawable.base")

---@class Engine.Graphics.Drawable.Layer:Engine.Graphics.Drawable.Base
---@field protected _list table<number, Engine.Graphics.Drawable.Base>
local _Layer = require("core.class")(_Base)

function _Layer:Ctor()
    _Base.Ctor(self)
    self._list = {}
end

---@param e Engine.Graphics.Drawable.Base
function _Layer:Add(e)
    self._list[#self._list + 1] = e
    _Base.AddChild(self, e)
end

---@param func function
function _Layer:Sort(func)
    table.sort(self._list, func)
end

function _Layer:_OnDraw()
    for i=1,#self._list do
        self._list[i]:Draw()
    end
end

---@param func fun(o:Engine.Graphics.Drawable.Base):void
function _Layer:DoFuncForAll(func)
    for i=1,#self._list do
        func(self._list[i])
    end
end

function _Layer:Clear()
    self._list = {}
end

return _Layer