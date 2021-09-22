--[[
    Desc: Game world, consist of levels.
    Author: SerDing
    Since: 2021-09-16
    Alter: 2021-09-18
    Docs:
    	world can be a city or dungeon, which has several levels like city sections or dungeon rooms.
]]
---@class World
---@field public entityMgr System.EntityManager
---@field public playerMgr System.PlayerManager
---@field public eventMgr System.EventManager
---@field public sceneMgr System.SceneMgr
local _World = require("core.class")()

---@class WorldData
---@field public name string
---@field public levelIds table<int, int>
local WorldData = {}

EWorldType = {
	Town = 1,
	Dungeon = 2,
}

---@param data WorldData
function _World:Ctor(data)
	self.name = data.name
	self.levelIds = data.levelIds
	self.levelMap = {}
	self.currentLevel = nil
	self.phase = 1

	self.entityMgr = nil
	self.playerMgr = nil
	self.eventMgr = nil

	self.rate = 1.0
end

function _World:Enter()
	--load levels into levelMap
	for i = 1, #self.levelIds do
		local id = self.levelIds[i]
		self.levelMap[id] = self:LoadLevel(id)
	end
end

function _World:Update(dt)
	self.entityMgr:Update(dt * self.rate)
end

function _World:Exit()

end

function _World:SwitchLevel(levelId)
	local newLevel = self.levelMap[levelId]
	if self.currentLevel then
		self.currentLevel:Leave()
	end
	self.currentLevel = newLevel
	self.currentLevel:Enter()
	collectgarbage()
end

function _World:LoadLevel(levelId)
	local level
	--load
	return level
end

return _World