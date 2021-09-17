--[[
	Desc: Graphics system of engine.
 	Author: SerDing
	Since: 2020-02-09
	Alter: 2020-02-09
]]
local _Vector2 = require("utils.vector2")

---@class Engine.Graphics
local _GRAPHICS = {}

_GRAPHICS.Draw = love.graphics.draw
_GRAPHICS.Push = love.graphics.push
_GRAPHICS.Pop = love.graphics.pop
_GRAPHICS.Translate = love.graphics.translate
_GRAPHICS.Scale = love.graphics.scale
_GRAPHICS.DrawRect = love.graphics.rectangle
_GRAPHICS.Points = love.graphics.points
_GRAPHICS.Line = love.graphics.line
_GRAPHICS.Print = love.graphics.print
_GRAPHICS.SetCanvas = love.graphics.setCanvas
_GRAPHICS.SetShader = love.graphics.setShader
_GRAPHICS.GetWidth = love.graphics.getWidth
_GRAPHICS.GetHeight = love.graphics.getHeight
_GRAPHICS.GetDimension = love.graphics.getDimensions
_GRAPHICS.NewCanvas = love.graphics.newCanvas
_GRAPHICS.NewQuad = love.graphics.newQuad

local oriwidth = 960
local oriheight = 540
local w, h = _GRAPHICS.GetDimension()
local _dimensionRatio = _Vector2.New(w / oriwidth, h / oriheight)

local _preBlendmode = ""
local _curBlendmode = "alpha"
local _preColor = {}
local _curColor = {red = 255, green = 255, blue = 255, alpha = 255}
local _preShader
local _curShader = love.graphics.getShader()
local _preFont
local _curFont = love.graphics.getFont()

love.graphics.setPointSize(7)
love.graphics.setLineWidth(1)
love.graphics.setBackgroundColor(100, 100, 100, 255)
--love.graphics.setDefaultFilter("nearest", "nearest")

function _GRAPHICS.Init()

end

function _GRAPHICS.DrawDownTriangle(x, y, edge) -- e.g:edge:15
    love.graphics.polygon("fill", x, y, x + edge, y, x + edge / 2, y + math.sqrt(math.pow(edge, 2) - math.pow(edge / 2, 2)))
end

function _GRAPHICS.DrawVerticalScrollBar(x, y)
    local w, h, r = 10, 100, 5
    _GRAPHICS.SetColor(200, 200, 200, 255)
    _GRAPHICS.DrawRect("fill", x, y, w, h, r, r)
end

function _GRAPHICS.SetColor(red, green, blue, alpha)
    if _curColor.red ~= red or _curColor.green ~= green or _curColor.blue ~= blue or _curColor.alpha ~= alpha then
        love.graphics.setColor(red, green, blue, alpha)

        _preColor.red = _curColor.red
        _preColor.green = _curColor.green
        _preColor.blue = _curColor.blue
        _preColor.alpha = _curColor.alpha

        _curColor.red = red
        _curColor.green = green
        _curColor.blue = blue
        _curColor.alpha = alpha
    end
end

function _GRAPHICS.ResetColor()
    _GRAPHICS.SetColor(_preColor.red, _preColor.green, _preColor.blue, _preColor.alpha)
end

function _GRAPHICS.SetBlendmode(blendmode)
    if blendmode ~= _curBlendmode then
        _preBlendmode = _curBlendmode
        _curBlendmode = blendmode
        love.graphics.setBlendMode(blendmode)
    end
end

function _GRAPHICS.ResetBlendmode()
    _GRAPHICS.SetBlendmode(_preBlendmode)
end

function _GRAPHICS.SetScissor(x, y, w, h)
    x = x and x * _dimensionRatio.x
    y = y and y * _dimensionRatio.y
    w = w and w * _dimensionRatio.x
    h = h and h * _dimensionRatio.y
    love.graphics.setScissor(x, y, w, h)
end

function _GRAPHICS.SetWindowMode(w, h, flags)
    local lastw, lasth = _GRAPHICS.GetDimension()
    love.window.setMode(w, h, flags)

    if w ~= lastw or h ~= lasth then
        _dimensionRatio:Set(w / oriwidth, h / oriheight)
    end
    --TODO:窗口尺寸调整后，应当调整Camera的渲染比例。
end

function _GRAPHICS.GetOriginDimension()
    return oriwidth, oriheight
end

---@return Vector2
function _GRAPHICS.GetDimensionRatio()
    return _dimensionRatio
end

return _GRAPHICS