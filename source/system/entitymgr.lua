--[[
	Desc: Entity Manager
	Author: SerDing
	Since: 2019-11-07
    Alter: 2019-11-07
    * Attention! You must assign the logic and responsibility of every component clearly
    to update them in right order, it's neccessary for using this entity-component architecture 
    or you can't find suitable updating order easily.
]]
---@class System.EntityManager
---@field protected _entityList table<int, Entity>
---@field protected _count int
local _EntityMgr = {
    _entityList = {},
    _count = 0,
}

---@param compKey string
---@param dt float
local function _UpdateComponent(compKey, dt)
    local j = 1
    while j <= #_EntityMgr._entityList do
        local entity = _EntityMgr._entityList[j]
        local component = entity[compKey]
        if component and component.enable then
            component:Update(dt)
        end
        j = j + 1
    end
end

---@param compKey string
local function _DrawComponent(compKey)
	for j = 1, #_EntityMgr._entityList do
		local entity = _EntityMgr._entityList[j]
		local component = entity[compKey] or nil ---@type Entity.Component.Base
		if component and component.enable then -- and component.Draw
			component:Draw()
		end
	end
end

local function _ProcessExpiredEntity()
    for n = #_EntityMgr._entityList, 1, -1 do
        if _EntityMgr._entityList[n].identity.process == 0 then
            _EntityMgr.DelEntity(_EntityMgr._entityList[n])
        end
    end
end

---@param a Entity
---@param b Entity
local _Sort = function (a, b)
	local y1 = a.transform.position.y + a.render.offset
	local y2 = b.transform.position.y + b.render.offset
	if math.floor(y1) == math.floor(y2) then
		return a.identity.id < b.identity.id
	else
		return math.floor(y1) < math.floor(y2)
	end
end

function _EntityMgr.Update(dt)
     _UpdateComponent("aic", dt)
     _UpdateComponent("state", dt)
     _UpdateComponent("combat", dt)
     _UpdateComponent("skills", dt)
     _UpdateComponent("projectile", dt)
     _UpdateComponent("movement", dt)
     _UpdateComponent("fighter", dt)
     _UpdateComponent("hitstop", dt)
     _UpdateComponent("effect", dt)
     _UpdateComponent("stats", dt)
     _UpdateComponent("buff", dt)
     _UpdateComponent("input", dt)
     _UpdateComponent("render", dt)

    _ProcessExpiredEntity()
end

function _EntityMgr.Draw() 
    table.sort(_EntityMgr._entityList, _Sort)

    _DrawComponent("render")
	_DrawComponent("transform")
    _DrawComponent("collider")
end

---@param entity Entity
function _EntityMgr.AddEntity(entity)
    _EntityMgr._entityList[#_EntityMgr._entityList + 1] = entity
    _EntityMgr._count = _EntityMgr._count + 1
    entity.identity.id = _EntityMgr._count
end

---@param entity Entity
function _EntityMgr.DelEntity(entity)
    local index = 0
    for i = 1, #_EntityMgr._entityList do
        if _EntityMgr._entityList[i] == entity then
            index = i
        end
    end
    table.remove(_EntityMgr._entityList, index)

    _EntityMgr._count = _EntityMgr._count - 1
end

---@return table<int, Entity>
function _EntityMgr.GetEntityList()
    return _EntityMgr._entityList
end

---Unload entities those are loaded dynamically when entering a new scene.
function _EntityMgr.UnLoad()
	local entity ---@type Entity
	for i = #_EntityMgr._entityList, 1, -1 do
		entity = _EntityMgr._entityList[i]
		if not entity.identity.dontDestroyOnLoadScene then
			table.remove(_EntityMgr._entityList, i)
			_EntityMgr._count = _EntityMgr._count - 1
		end
	end
end

return _EntityMgr