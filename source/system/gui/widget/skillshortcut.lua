--[[
	Desc: Shortcut for skill
	Author: SerDing 
	Since: 2018-08-29 15:11:16 
	Last Modified time: 2018-08-29 15:11:16
]]
local _Sprite = require "engine.graphics.drawable.sprite"
local _GRAPHICS = require("engine.graphics")
local _Widget = require("system.gui.widget.widget")

---@class GUI.Widgets.SkillShortcut : GUI.Widgets.Base
---@field protected _cooldownPercent float
local _SkillShortcut = require("core.class")(_Widget)

function _SkillShortcut.NewWithData(data)
    return _SkillShortcut.New(data.name, data.x, data.y, data.is_origin, data.img_path)
end

function _SkillShortcut:Ctor(name, x, y, isOrigin, imgPath)
	_Widget.Ctor(self, name, x, y)
	self._isOrigin = isOrigin or false
	self._cooldownPercent = 1.00
	self._slot = _Sprite.New()
	self._slot:SetImage(imgPath)
	self._sprites = {
		_Sprite.New(), -- useable
		_Sprite.New(), -- cool
	}
	self:AddChild(self._slot)
	self:AddChild(self._sprites[1])
	self:AddChild(self._sprites[2])
	self._sprites[1]:SetRenderValue("position", 1, 1)
	self._sprites[2]:SetRenderValue("position", 1, 1)
end 

function _SkillShortcut:_OnDraw()
	self._slot:Draw()
	if self._skill then
		self._sprites[self._skill.state]:Draw()
		self._cooldownPercent = 1.0 - self._skill._timer:GetProgress()
		self._cooldownPercent = math.abs(self._cooldownPercent)
		if self._cooldownPercent > 0 then
			_GRAPHICS.SetColor(0, 0, 0, 180)
			_GRAPHICS.DrawRect("fill", self.x + 1, self.y + 1, self._sprites[1]:GetWidth(), self._sprites[1]:GetHeight() * self._cooldownPercent)
			_GRAPHICS.ResetColor()
		end
	end
end 

---@param skill Entity.Skill
function _SkillShortcut:SetSkill(skill)
	assert(skill, "skill is nil")
	self._skill = skill
	self._sprites[1]:SetImage(self._skill.icon.normal)
	self._sprites[2]:SetImage(self._skill.icon.cooldown)
end

function _SkillShortcut:SetCooldownTimePercent(percent)
end

function _SkillShortcut:CheckPoint(x, y)
    return self._slot:GetRect():CheckPoint(x, y)
end

return _SkillShortcut