--[[
	Desc: Button widget
	Author: SerDing 
	Since: 2018-08-14 02:03:40 
	Last Modified time: 2018-08-14 02:03:40 
]]
local _Event = require("core.event")
local _RESOURCE = require("engine.resource")
local _Color = require("engine.graphics.config.color")
local _Sprite = require("engine.graphics.drawable.sprite")
local _Label = require("system.gui.widget.label")
local _Widget = require("system.gui.widget.widget")

---@class GUI.Widgets.Button : GUI.Widgets.Base
---@field protected _labelColor Engine.Graphics.Config.Color
---@field protected _sprites table<string, Engine.Graphics.Drawable.Sprite>
---@field protected _curSprite Engine.Graphics.Drawable.Sprite
---@field public onClick Event
local _Button = require("core.class")(_Widget)

function _Button.NewWithData(data)
    return _Button.New(data.name, data.text, data.x, data.y, data.style_path)
end

function _Button:Ctor(name, text, x, y, stylePath)
    _Widget.Ctor(self, name, x, y)
    self._text = text
    self._style = _RESOURCE.LoadUiData(stylePath)
    self._sprites = {
        normal = _Sprite.New(),
        light = _Sprite.New(),
        pressed = _Sprite.New(),

    }
    self._sprites.normal:SetImage(self._style[1])
    self._sprites.light:SetImage(self._style[2])
    self._sprites.pressed:SetImage(self._style[3])
    if self._style[4] then
        self._sprites.disable = _Sprite.New()
        self._sprites.disable:SetImage(self._style[4])
    end
    if self._style[5] then
        self._sprites.flash = _Sprite.New()
        self._sprites.flash:SetImage(self._style[5])
    end
    for _,spr in pairs(self._sprites) do
        self:AddChild(spr)
    end
    self.onClick = _Event.New()
    self._flash = {
        alpha = 255,
        v = 5
    }
    self._dragging = false
    self._dragOffset = {x = 0, y = 0}
    self._labelColor = _Color.New(250, 179, 0, 255)
    self._label = _Label.New(name .. "_label", 0, 0, text, true)
    self._label:SetRenderValue("color", self._labelColor:Get())
    self._label:Init()
    self:AddChild(self._label)
    self:SetState("normal")
end

function _Button:Init()
    _Widget.Init(self)

end

function _Button:_OnDraw()
    self._curSprite:Draw()
    if self._text then
        self:DrawChildren()
    end
    if self._sprites.flash then
        if self._flash.alpha >= 255 or self._flash.alpha <= 0 then
            self._flash.v = - self._flash.v
        end
        self._flash.alpha = self._flash.alpha + self._flash.v
        self._sprites.flash:SetRenderValue("color", 255, 255, 255, self._flash.alpha)
        self._sprites.flash:Draw()
    end
end

function _Button:MouseEntered()
    if self.mousePressed then
        self:SetState("pressed")
    else
        self:SetState("light")
    end
end

function _Button:MouseExited()
    self:SetState("normal")
end

function _Button:MousePressed(btn, rx, ry)
    _Widget.MousePressed(self)
    self:SetState("pressed")
    self:SetFocus(true)
end

function _Button:MouseReleased(btn, rx, ry)
    _Widget.MouseReleased(self)
    self:SetState("light")
    if self.mousePressed then
        self:MouseClicked()
        self.mousePressed = false
    end
end

function _Button:MouseClicked(btn, rx, ry)
    self.onClick:Notify()
end

function _Button:SetState(state)
    self._state = state or self._state
    self._curSprite = self._sprites[self._state]

    self._label:SetToCenter(0, 0, self._curSprite:GetWidth(), self._curSprite:GetHeight())
end

function _Button:CheckPoint(x, y)
    return self._curSprite:GetRect():CheckPoint(x, y)
end

function _Button:Disable()
    if self._sprites.disable then
        self:SetState("disable")
    end
end

return _Button 