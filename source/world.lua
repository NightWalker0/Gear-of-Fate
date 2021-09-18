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
local _World = require("core.class")()

EWorldState = {
	LoadLevel = 1,
	InLevel = 2,
}

function _World:Ctor()
	self.entityMgr = nil
	self.playerMgr = nil
	self.eventMgr = nil
	self.levelMap = {}
	self.currentLevel = nil
	self.rate = 1.0
end

function _World:Enter()

end

function _World:Update(dt)
	self.entityMgr:Update(dt * self.rate)
	--switch process update of current world state
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

function _World:ChangeState(key)
	self.state = key
	--switch process new state enter and old state exit
	if key == EWorldState.LoadLevel then
		 self:LoadLevel()
	end
end

function _World:LoadLevel()

end

return _World