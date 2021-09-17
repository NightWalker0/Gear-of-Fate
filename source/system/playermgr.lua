--[[
    Desc: Player manager.
    Author: SerDing
    Since: 2020-10-13T19:54:48.608Z+08:00
    Alter: 2020-10-13T19:54:48.608Z+08:00
]]

local _Event = require("core.event")

---@class System.PlayerManager
---@field protected _players table<int, Entity>
---@field protected _localPlayer Entity
---@field public onSetLocalPlayer Event @func(preLocalPlayer, newLocalPlayer)
local _PLAYERMGR = {
    _players = {},
    _localPlayer = nil,
    onSetLocalPlayer = _Event.New(),
}

local this = _PLAYERMGR

---@param player Entity
---@param isLocal boolean
function _PLAYERMGR.Add(player, isLocal)
    this._players[#this._players + 1] = player
    if isLocal then
        _PLAYERMGR.SetLocalPlayer(player)
    end
end


---@param player Entity
function _PLAYERMGR.SetLocalPlayer(player)
    if this._localPlayer == player then
        return 
    end

    player.fighter:SetMark("player")
    player.aic.enable = false
    player.identity.dontDestroyOnLoadScene = true
    
    if this._localPlayer then
        this._localPlayer.aic.enable = true
        this._localPlayer.identity.dontDestroyOnLoadScene = true
        if not this._localPlayer.fighter.isDead then
            local auraType = (player.identity.camp == this._localPlayer.identity.camp) and "partner" or nil
            this._localPlayer.fighter:SetMark(auraType)
        end
    end
    
    this.onSetLocalPlayer:Notify(player)
    this._localPlayer = player
end

function _PLAYERMGR.GetLocalPlayer()
    return this._localPlayer
end

return _PLAYERMGR