--[[
    Desc: Game world
    Author: SerDing
    Since: 
    Alter: 
]]
---@class World
local _World = require("core.class")()

function _World:Ctor()
	self.levelMgr = nil
	self.playerMgr = nil
	self.uiMgr = nil
end

function _World:Enter()

end

function _World:Exit()

end

return _World