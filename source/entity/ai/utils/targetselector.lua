--[[
    Desc: Ai utility of target selection.
    Author: SerDing
    Since: 2021-05-03
    Alter: 2021-05-04
]]
local _Rect = require("engine.graphics.drawable.rect")
local _ENTITYMGR = require("system.entitymgr")

local _TargetSelector = require("core.class")()

function _TargetSelector:Ctor(sightRange)
	self._sightRange = sightRange
	self.target = nil
	self.sightRect = _Rect.New()
	self.sightRect:SetSize(sightRange.x * 2, sightRange.y * 2)
end

---@param entity Entity
function _TargetSelector:Init(entity)
	self._entity = entity
end

---@return Entity
function _TargetSelector:Run()
	if not self._sightRange then
		return nil
	end

	local selfpos = self._entity.transform.position
	self.sightRect:SetPosition(selfpos.x - self._sightRange.x, selfpos.y - self._sightRange.y)

	if self.target then
		if not self:_IsInSightRange(self.target.transform.position:Get()) or self.target.fighter.isDead then
			self.target = nil
		end

		return self.target
	end

	local entityList = _ENTITYMGR.GetEntityList()
	for i = 1, #entityList do
		local e = entityList[i]
		if e.fighter and not e.fighter.isDead and e.identity.camp ~= self._entity.identity.camp then
			local epos = e.transform.position
			if self:_IsInSightRange(epos.x, epos.y) then
				self.target = e
				return e
			end
		end
	end

	return nil
end

function _TargetSelector:_IsInSightRange(x, y)
	local selfX, selfY = self._entity.transform.position:Get()
	local radiusX, radiusY = self.sightRect:Get("width"), self.sightRect:Get("height")
	return (x - selfX)^2 / radiusX^2 + (y - selfY)^2 / radiusY^2 < 1
	--return self.sightRect:CheckPoint(x, y)
	--local spos = self._entity.transform.position
	--return math.abs(x - spos.x) <= self._sightRange.x and math.abs(y - spos.y) <= self._sightRange.y
end

return _TargetSelector