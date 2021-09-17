--[[
	Desc: Fighter Component, any entity that can attack or be attacked owns this component.
	Author: SerDing 
	Since: 2020-10-09
	Alter: 2020-10-09
]]
local _RESOURCE = require("engine.resource")
local _RESMGR = require("system.resource.resmgr")
local _AUDIO = require("engine.audio")
local _FACTORY = require("system.entityfactory")
local _Timer = require("utils.timer")
local _Base = require("entity.component.base")

---@class Entity.Component.Fighter : Entity.Component.Base
---@field protected _mark Entity
---@field protected _deathFlashTimer Utils.Timer
local _Fighter = require("core.class")(_Base)

local _auras = {
    player = _RESMGR.LoadEntityData("effect/common/aura/player"),
}

local _deathEffectData = {
    flash = {},
    smoke = {},
    bloodstain = {},
}

function _Fighter.HandleData(data)
    if data.deathSound then
        data.deathSoundDataSet = _RESOURCE.RecursiveLoad(data.deathSound, _RESOURCE.LoadSoundData)
    end
    
    if data.damageSound then
        data.damageSoundDataSet = _RESOURCE.RecursiveLoad(data.damageSound, _RESOURCE.LoadSoundData)
    end
end 
function _Fighter:Ctor(entity, data)
    _Base.Ctor(self, entity)
    self.weight = data.weight or 0
    self.isDead = false
    self.isBoss = false
    self.damageSoundDataSet = data.damageSoundDataSet
    self._deathSoundDataSet = data.deathSoundDataSet
    self._deathProcess = 0
    self._deathFlash = self._entity.identity.type == "character" and true or false
    self._deathFlashTimer = _Timer.New()
    self._deathFlashTime = 400
    self._deathFlashFreq = 2
    self._deathFlashCount = 0
end

function _Fighter:Update(dt)
    if self._deathProcess == 1 then
        local isAerial = self._entity.movement:IsFalling() or self._entity.movement:IsRising()
        if not isAerial and self._entity.identity.isPaused == false then
            if self._entity.identity.type == "character" then
                self._entity.render.renderObj:Play("down")
                self._entity.render.renderObj:SetFrame(5)
                self._deathFlashTimer:Start(self._deathFlashTime)
                self._deathProcess = 2
            elseif self._entity.identity.type == "monster" then
                self._entity.render.renderObj:Play("down")
                self._entity.render.renderObj:SetFrame(5)
                self._deathFlashTimer:Start(self._deathFlashTime)
                self._deathProcess = 2
            else
                self._deathProcess = 2
            end
            self._entity.movement:StopEasemove()
            self._entity.movement.enable = false

            if self._deathSoundDataSet then
                _AUDIO.RandomPlay(self._deathSoundDataSet)
            end
        end
    elseif self._deathProcess == 2 then
        if self._deathFlash then
            self._deathFlashTimer:Tick(dt)
            if self._deathFlashTimer.isRunning == false and self._deathFlashCount < self._deathFlashFreq * 2 then
                self._entity.render.enable = not self._entity.render.enable
                self._deathFlashTimer:Start(self._deathFlashTime)
                self._deathFlashCount = self._deathFlashCount + 1
                if self._deathFlashCount == self._deathFlashFreq * 2 then
                    self._deathProcess = 3
                    self._entity.render.color:Set(128, 128, 128, 255)
                end
            end
        else
            self._deathProcess = 3
            self._entity.render.color:Set(128, 128, 128, 255)
        end
    end
end

function _Fighter:Die(process)
    self.isDead = true
    self._deathProcess = 1
    if self._deathFlash then
        self._deathFlashTimer:Reset()
        self._deathFlashCount = 0
    end
end

function _Fighter:Reborn()
    self.isDead = false
    self._deathProcess = 0
    self._entity.movement.enable = true
    self._entity.render.enable = true
    self._entity.render.color:Set(255, 255, 255, 255)
    self._entity.stats.hp:Increase(self._entity.stats.maxhp)
    self._entity.state:SetState("stay")
end

---@param key string
function _Fighter:SetMark(key)
    if self._mark then
        self._mark.identity:StartDestroy()
        self._mark = nil
    end

    if key then
        self._mark = _FACTORY.NewEntity(_auras[key], { master = self._entity})
    end
end

return _Fighter