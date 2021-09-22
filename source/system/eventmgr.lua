local _Event = require("core.event")

---@class System.EventManager
---@field protected _eventMap table<int, Event>
local _EventManager = {
    _eventMap = {}
}

function _EventManager.Init()

end

function _EventManager.Register(eventType, obj, func)
    local event = _EventManager._eventMap[eventType]
    if not event then
        event = _Event.New()
        _EventManager._eventMap[eventType] = event
    end
    event:AddListener(obj, func)
end

function _EventManager.Remove(eventType, obj, func)
    local event = _EventManager._eventMap[eventType]
    if not event then
        LOG.Error("Error: no registered event of type:" .. eventType)
        return false
    end

    return event:DelListener(obj, func)
end

function _EventManager.Notify(eventType, ...)
    local event = _EventManager._eventMap[eventType]
    if not event then
        LOG.Error("Error: no registered event of type:" .. eventType)
        return false
    end

    event:Notify(...)
    return true
end

function _EventManager.Clear()
    _EventManager._eventMap = {}
end

return _EventManager