--[[
    Desc: Level module
    Author: SerDing
    Since: 2017-09-09
    Alter: 2019-12-12
]]

local Floor = math.floor
local Ceil = math.ceil
local Abs = math.abs

---@class Level 
local _Level = require("core.class")()

function _Level:Ctor(path, LEVELMGR) --initialize
    self._LEVELMGR = LEVELMGR

    self.isDgn = false
    self.clear = false
end

function _Level:Awake() -- ReAdd objects into ObjMgr

    -- for n=1,#self.animations do
    --     if self.animations[n]:GetLayer() == "[normal]" then
    --         _ObjectMgr.AddObject(self.animations[n])
    --     end
    -- end
    
    -- for n=1,#self.passiveobjs do
    --     if self.passiveobjs[n]:GetLayer() == "[normal]" then
    --         _ObjectMgr.AddObject(self.passiveobjs[n])
    --     end
    -- end 

    -- for n=1,#self.pathgates do
    --     if self.pathgates[n]:GetLayer() == "[normal]" then
    --         _ObjectMgr.AddObject(self.pathgates[n])
    --     end
    -- end 

    -- if self.isDgn and self.clear == false then
    --     for n=1,#self.monsters do
    --         _ObjectMgr.AddObject(self.monsters[n])
    --     end
    -- end
    
    -- _AUDIOMGR.PlaySceneMusic(self.map["[sound]"])
end

function _Level:Update(dt)

end

return _Level