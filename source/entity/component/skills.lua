--[[
	Desc: Skill Component, manage skills of entity.
	Author: SerDing 
	Since: 2018-08-20
	Alter: 2021-04-20
]]
local _RESMGR = require("system.resource.resmgr")
local _Skill = require("entity.skill")
local _SETTING = require("setting")
local _Base = require("entity.component.base")

---@class Entity.Component.Skills : Entity.Component.Base
---@field protected _skillShortcutMap table<string, Entity.Skill>
---@field protected _skillMap table<string, Entity.Skill>
local _SkillComponent = require("core.class")(_Base)

function _SkillComponent:Ctor(entity, data, param)
	_Base.Ctor(self, entity)
	self._skillShortcutMap = {} --<shortcut, skill>
	self._skillMap = {} --<name, skill>
	for shortcut, path in pairs(data) do
		if shortcut ~= "class" then
			--_LOG.Debug("load skill: %s", name)
			local skillData = _RESMGR.LoadSkill(path)
			local skill = _Skill.New(self._entity, skillData, self)
			self._skillShortcutMap[shortcut] = skill
			self._skillMap[skillData.name] = skill
		end
	end

	--init skill list for ai
	self.skillList = {}
	for _, skill in pairs(self._skillShortcutMap) do
		self.skillList[#self.skillList + 1] = skill
	end
	table.sort(self.skillList, function(a, b)
		return a.aiPriority < b.aiPriority
	end)

	if param.skills then
		for i = 1, #param.skills do
			self._skillShortcutMap[param.skills[i]]:SetActive(true)
		end
	else
		for _, skill in pairs(self._skillShortcutMap) do
			skill:SetActive(true)
		end
	end
	self.debug = _SETTING.debug.skill
end

function _SkillComponent:Init()
	for _, skill in pairs(self._skillShortcutMap) do
		skill:Init()
		skill.debug = self.debug
	end
end

function _SkillComponent:Update(dt)
	for _, skill in pairs(self._skillShortcutMap) do
		skill:Update(dt)
	end
end

---@param id string
function _SkillComponent:CastSkill(id)
	local skill = self._skillMap[id]
	if skill then
		skill:Cast()
		self._curSkill = skill
		--self.world.eventMgr.Notify(EEvent.SKILL_CAST, skill, self._entity)
	end
end

---@param skill Entity.Skill
function _SkillComponent:OnSkillFinish(skill)
	self._curSkill = nil
end

function _SkillComponent:IsCastingSkill()
	return self._curSkill ~= nil
end

---@param name string
---@return boolean
function _SkillComponent:CanCast(name)
	local skill = self._skillShortcutMap[name]
	if skill then
		return skill:CanCast()
	end
	return false
end

---@param shortcut string
---@return Entity.Skill
function _SkillComponent:GetSkill(shortcut)
	return self._skillShortcutMap[shortcut] or nil
end

function _SkillComponent:LearnSkill(name)
	self._skillShortcutMap[name]:SetActive(true)
end

return _SkillComponent