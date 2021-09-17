--[[
	Desc: Audio module of engine
	Author: SerDing
	Since: 2018-08-02
	Alter: 2020-01-19
]]
local _SETTING = require("setting")
local _RESOURCE = require('engine.resource')

---@class Engine.Audio
local _AUDIO = {}

local _playbackQueue = {} ---@type table<number, SoundData>
local _sceneMusicData = {
    source = nil,
    path = "",
}
local _ambientSonudData = {
    source = nil,
    path = "",
}

function _AUDIO.Update(dt)
    --TODO: play first sound in playbackQueue
end

---@param soundData SoundData|string 
function _AUDIO.PlaySound(soundData)
    local source = _RESOURCE.NewSound(soundData)
    source:setVolume(0.7 * _SETTING.sound)
    source:play()
end 

---@param soundDataSet table<int, SoundData>
function _AUDIO.RandomPlay(soundDataSet)
    local n = math.random(1, #soundDataSet)
    _AUDIO.PlaySound(soundDataSet[n])
end

--- play background music
function _AUDIO.PlaySceneMusic(name)
    _AUDIO.PlaySceneAudio(_sceneMusicData, name, _RESOURCE.LoadMusic)
    _sceneMusicData.source:setVolume(_SETTING.music)
end

--- play ambient music
function _AUDIO.PlayAmbientSound(name)
    _AUDIO.PlaySceneAudio(_ambientSonudData, "ambient/" .. name, _RESOURCE.LoadSound)
    _ambientSonudData.source:setVolume(_SETTING.ambient)
end

---@param data table
---@param path string
---@param loadFunc fun(path:string):void
function _AUDIO.PlaySceneAudio(data, path, loadFunc)
    if data.path == path then
        if not data.source:isPlaying() then
            data.source:play()
        end

        return true
    else
        if data.source then
            data.source:stop()
        end

        data.source = loadFunc(path)
        if data.source then
            data.source:setLooping(true)
            data.source:play()
            data.path = path
            return true
        else
            print("Error: Audio.PlaySceneAudio, audio source load failed!")
            return false
        end
    end

end

return _AUDIO