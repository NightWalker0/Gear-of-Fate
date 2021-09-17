--[[
    Desc: Common functions for ai.
    Author: SerDing
    Since: 2021-09-01
    Alter: 2021-09-04
]]

local CommonFuncs = {}

---@param point1 Vector3
---@param point2 Vector3
function CommonFuncs.GetDistance(point1, point2)
	return point1:GetDistance(point2)
end

---@param entity Entity
---@param id int
function CommonFuncs.CastSkill(entity, id)
	entity.skills:CastSkill(id)
end

---@param entity Entity
---@param name int
function CommonFuncs.CanCastSkill(entity, name)
	entity.skills:CanCast(name)
end

---@param entity Entity
function CommonFuncs.IsCastingSkill(entity)
	return entity.skills:IsCastingSkill()
end

return CommonFuncs