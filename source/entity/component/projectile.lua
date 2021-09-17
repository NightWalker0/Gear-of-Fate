--[[
    Desc: a component for projectile logic
    Feature:
        1.Death: by anim playing end / by time / by distance
        2.Combat: Attack / BeHit
        3.Move: forward / rotate / changeDirection
    Author: SerDing
    Since: 2020-03-18
    Alter: 2021-05-26
]]
local _Vector3 = require("utils.vector3")
local _Base = require("entity.component.base")

---@class Entity.Component.Projectile : Entity.Component.Base
local _Projectile = require("core.class")(_Base)

local _emptyTable = {}

local _SPEED_VARY_TYPE = {
    POSITIVE_RETURN = 1,
    NEGATIVE_RETURN = 2,
    POSITIVE_INCREASE = 3,
    NEGATIVE_INCREASE = 4,
}

function _Projectile:Ctor(entity, data, param)
    _Base.Ctor(self, entity)
    self._data = data
    self._attack = data.attack
    self._tags = data.tags or _emptyTable
    self._playEnd = data.tags.playEnd
    if data.movementParam then
        self._movementParam = {
            tick = data.movementParam.tick,
            v = {},
            a = {},
            distance = data.movementParam.distance,
        }
        for i = 1, #data.movementParam.v do
            self._movementParam.v[i] = data.movementParam.v[i]
        end
        for i = 1, #data.movementParam.a do
            self._movementParam.a[i] = data.movementParam.a[i]
        end
        self._isMoving = false
    end

    self._startPosition = _Vector3.New()
    self._velocity = _Vector3.New()
    self._accerleration = _Vector3.New()
    self._speedVaryType = _Vector3.New()

    self._hitTimes = data.hitTimes or 1
    self._hitCounter = 0
    self._endByDistance = self._data.movementParam and self._data.movementParam.distance
end

function _Projectile:Init()
    self._OnHit = function(combat, behitEntity)
        if self._tags.endOnHit then
            if self._hitTimes > 1 then
                self._hitCounter = self._hitCounter + 1
                if self._hitCounter >= self._hitTimes then
                    self._identity:StartDestroy()
                end
            else
                self._identity:StartDestroy()
            end
        end
    end
    self._entity.combat:StartAttack(self._attack, self._OnHit)
    self._movement = self._entity.movement
    self._identity = self._entity.identity
    self._render = self._entity.render
    self._fighter = self._entity.fighter

    if self._movement and not self._movement.ignoreObstacle then
        self._movement.eventMap.onMove:AddListener(self, self.OnMove)
    end

    --if self._movementParam and self._movementParam.tick == 0 then
    --    self._movement:EaseMove(self._movementParam.type, self._movementParam.v, self._movementParam.a)
    --    self._startPosition:Set(self._entity.transform.position:Get())
    --end
end

function _Projectile:Update(dt)
    if not self.enable or self._fighter.isDead then
        return
	end

    self:_MoveUpdate(dt)

    if self._identity.master then
        if self._playEnd then
            if self._render.renderObj:TickEnd() then
                self._identity:StartDestroy()
            end
        end

        if self._endByDistance  then --and self._movement:IsEasemoving()
            local distance = self._entity.transform.position:GetDistance(self._startPosition)
            if distance >= self._movementParam.distance then
                self._identity:StartDestroy()
                LOG.Debug("projectile over distance:%.3f", distance)
            end
        end

        --todo:death by time
    end
end

function _Projectile:_MoveUpdate(dt)
    local param = self._movementParam
    if param and not self._isMoving and self._render.renderObj:GetTick() == param.tick then --not self._movement:IsEasemoving()
        param.v[1] = self._data.movementParam.v[1] * self._entity.transform.direction
        param.a[1] = self._data.movementParam.a[1] * self._entity.transform.direction
        local varyType = {}
        for i = 1, #param.v do
            if param.v[i] > 0 and (not param.a[i] or param.a[i] == 0) then
                varyType[i] = _SPEED_VARY_TYPE.POSITIVE_INCREASE
            end
            if param.v[i] < 0 and (not param.a[i] or param.a[i] == 0) then
                varyType[i] = _SPEED_VARY_TYPE.NEGATIVE_INCREASE
            end
            if param.v[i] > 0 and param.a[i] < 0 then
                varyType[i] = _SPEED_VARY_TYPE.POSITIVE_RETURN
            end
            if param.v[i] < 0 and param.a[i] > 0 then
                varyType[i] = _SPEED_VARY_TYPE.NEGATIVE_RETURN
            end
        end
        self._speedVaryType:Set(unpack(varyType))
        self._velocity:Set(unpack(param.v))
        self._accerleration:Set(unpack(param.a))
        --self._movement:EaseMove(self._movementParam.type, self._movementParam.v, self._movementParam.a)
        self._startPosition:Set(self._entity.transform.position:Get())
        self._isMoving = true
    end

    if self._isMoving then
        for k, v in pairs(self._velocity) do
            if type(v) == "number" and v ~= 0 then
                self._movement:Move(k, v)
            end
        end

        for k, acc in pairs(self._accerleration) do
            if type(v) == "number" and acc ~= 0 then
                self._velocity[k] = self._velocity[k] + acc * dt
                if self._speedVaryType[k] == _SPEED_VARY_TYPE.POSITIVE_RETURN and self._velocity[k] < 0 then
                    self._velocity[k] = 0
                end
                if self._speedVaryType[k] == _SPEED_VARY_TYPE.NEGATIVE_RETURN and self._velocity[k] > 0 then
                    self._velocity[k] = 0
                end
            end
        end
    end
end

function _Projectile:OnMove(axis, success, delta)
    if not success then
        self._identity:StartDestroy()
        --_LOG.Debug("projectile move failed, axis:%s delta:%.3f, destroy", axis, delta)
    end
end

return _Projectile