--[[
	Desc: Ai utility of skill selection.
	Author: SerDing
	Since: 2021-04-24
	Alter: 2021-05-04
]]

local _SkillSelector = require("core.class")()

function _SkillSelector:Ctor()

end

---@param entity Entity
function _SkillSelector:Init(entity)
	self._entity = entity
	self._skills = entity.skills
end

function _SkillSelector:Run()
	if self._skills then
		local skills = self._skills.skillList ---@type table<int, Entity.Skill>
		for i = 1, #skills do
			local skill = skills[i]
			--print("_SkillSelector.Run", skill.name, skill:CanCast(), skill:IsInAttackRange(self._target))
			--print("_SkillSelector.Run", skill.name, skill.stateDebug.cooldownOver, skill.stateDebug.isInPreState, skill.stateDebug.energyEnough)
			if skill:CanCast() and skill:IsInAttackRange(self._target) then
				--_LOG.Debug("usable skill %s", _)
				return skill
			end
		end
	end

end

function _SkillSelector:SetTarget(target)
	self._target = target
end

return _SkillSelector