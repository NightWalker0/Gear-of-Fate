--[[
	Desc: UI widget base
	Author: SerDing 
	Since: 2019-08-10 
	Last Modified time: 2020-02-04 17:29:59
]]
local _Drawable = require("engine.graphics.drawable.base")

---@class GUI.Widgets.Base:Engine.Graphics.Drawable.Base
---@field public name string
---@field public x float
---@field public y float
---@field public wtype string
---@field public mousePressed boolean
---@field protected _children table<int, GUI.Widgets.Base>
---@field protected _interactable boolean
---@field protected _visible boolean
local _Widget = require("core.class")(_Drawable)

function _Widget:Ctor(name, x, y)
    _Drawable.Ctor(self)
    self.name = name
    self.x, self.y = x, y
    self.focus = false
    self._children = {}
    self._visible = true
    self._interactable = true
    self.mousePressed = false
    self.controller = nil
    self.wtype = "widget"
end

function _Widget:Init()
    self.eventMap.setPosition:AddListener(self, self.RefreshPosition)
    self:SetPosition(self.x, self.y)
end

function _Widget:Draw()
    if self._visible == true then
        _Drawable.Draw(self)
    end
end

function _Widget:DrawChildren()
    for i = 1, #self._children do
        local child = self._children[i]
        if child._visible == true then
            child:Draw()
        end
    end
end

function _Widget:_OnDraw()
end

function _Widget:MouseEntered()
end

function _Widget:MouseExited()
end

function _Widget:MousePressed(btn, rx, ry)
    self.mousePressed = true
end

function _Widget:MouseReleased(btn, rx, ry)
end

function _Widget:MouseClicked(btn, rx, ry)
end

function _Widget:SetPosition(x, y)
    _Drawable.SetRenderValue(self, "position", x, y, 0)
end

function _Widget:RefreshPosition()
    self.x, self.y = _Drawable.GetRenderValue(self, "position")
end

function _Widget:SetController(controller)
    self.controller = controller
end

function _Widget:SetVisible(v)
    self._visible = v
end

function _Widget:CheckPoint(x, y)
    return false
end

function _Widget:SetFocus(f)
    self.focus = f
end

---@param index int
---@return GUI.Widgets.Base
function _Widget:GetChild(index)
    return _Drawable.GetChild(self, index)
end

function _Widget:GetSize()
    return 1, 1
end

return _Widget 