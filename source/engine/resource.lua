--[[
    Desc: Resource module of engine, load basic resource with pool.
    Author: SerDing
    Since: 2019-12-06
    Alter: 2020-01-14
]]

local _STRING = require('engine.string')
local _FILE = require('engine.filesystem')

---@class Engine.Resource
local _RESOURCE = {}
local _RESDIR = "resource/"
local _DIRS = {
    IMAGE = _RESDIR .. "image/",
    SOUND = _RESDIR .. "sound/",
    MUSIC = _RESDIR .. "music/",
    COLLIDER = _RESDIR .. "data/entity/collider/",
    ANIM = _RESDIR .. "data/animation/",
    SPRITE = _RESDIR .. "data/sprite/",
    UI = _RESDIR .. "data/ui/",
}

local _pools = {
    aniData = {},
    spriteData = {},
    colliderData = {},
    image = {},
    font = {},
    sound = {},
    soundData = {},
}

local _meta = {__mode = 'v'}
for _, p in pairs(_pools) do
    setmetatable(p, _meta)
end

_RESOURCE.nullImg = love.graphics.newImage(love.image.newImageData(1, 1))
_RESOURCE.NewShader = love.graphics.newShader

---@param path string
---@return Image
function _RESOURCE.NewImage(path)
    if type(path) ~= "string" then
        return love.graphics.newImage(path)
    end
    
    return love.graphics.newImage(_DIRS.IMAGE .. path .. ".png")
end

---@param path string
---@return SoundData 
function _RESOURCE.NewSoundData(path)
    return love.sound.newSoundData(_DIRS.SOUND .. path .. ".ogg")
end

---@param path string
---@return Source
function _RESOURCE.NewMusic(path)
    if type(path) ~= "string" then
        return love.audio.newSource(path)
    end

    return love.audio.newSource(_DIRS.MUSIC .. path .. ".ogg")
end

---@param path string
---@return Source
function _RESOURCE.NewSound(path)
    if type(path) ~= "string" then
        return love.audio.newSource(path)
    end

    return love.audio.newSource(_DIRS.SOUND .. path .. ".ogg")
end

---@param path string
---@return Engine.Graphics.Drawable.SpriteData
function _RESOURCE.NewSpriteData(path)
    ---@type Engine.Graphics.Drawable.SpriteData
    local data = _RESOURCE.LoadData(_DIRS.SPRITE .. path)
    data.image = _RESOURCE.LoadImage(path)

    return data
end

---@param path string
---@param newSpriteDataFunc function
---@param imgPath string | nil
---@return Engine.Resource.AnimData
function _RESOURCE.NewAniData(path, newSpriteDataFunc, imgPath, loadCollider)
    imgPath = imgPath and imgPath .. "/" or ""
    local staticData = _RESOURCE.LoadData(_DIRS.ANIM .. path)

    ---@class Engine.Resource.AnimData
    ---@field public path string
    ---@field public isLoop boolean
    ---@field public frames table<int, Engine.Graphics.Drawable.Frameani.Frame>
    ---@field public colliderData table<int, Entity.Collider.ColliderData>
    local data = {path = path, isLoop = staticData.isLoop or false, frames = {}}

    for k,v in pairs(staticData.frames) do
        data.frames[k] = {}
        data.frames[k].time = v.time
        if v.sprite then
            data.frames[k].data = _RESOURCE.LoadResource(imgPath .. v.sprite, newSpriteDataFunc, _pools.spriteData, imgPath)
        end
    end
    
    imgPath = string.sub(imgPath, 1, string.len(imgPath) - 1) -- delete '/'
    local aniName = string.sub(path, _STRING.FindCharReverse(path, "/") + 1, string.len(path))
    local colliderDataPath = (imgPath ~= "") and string.sub(imgPath, 1, _STRING.FindCharReverse(imgPath, "/")) .. aniName or path
    colliderDataPath = string.gsub(colliderDataPath, "entity/", "")
    data.colliderData = _RESOURCE.NewColliderData(colliderDataPath)

    if not data.colliderData then
        --print(path, imgPath, data.colliderData, #data.colliderData)
        print("no collider data:", colliderDataPath)
    end

    return data
end

function _RESOURCE.NewColliderData(path)
    path = _DIRS.COLLIDER .. path
    local exists = _FILE.Exist(path .. ".dat")

    ---@class Engine.Resource.ColliderData
    local data = exists and _RESOURCE.LoadData(path) or nil

    return data
end

---@param path string
---@return Image
function _RESOURCE.LoadImage(path)
    return _RESOURCE.LoadResource(path, _RESOURCE.NewImage, _pools.image)
end

---@param path string
---@return Source
function _RESOURCE.LoadSound(path)
    return _RESOURCE.LoadResource(path, _RESOURCE.NewSound, _pools.sound)
end

---@param path string
---@return SoundData
function _RESOURCE.LoadSoundData(path)
    return _RESOURCE.LoadResource(path, _RESOURCE.NewSoundData, _pools.soundData)
end

---@param path string
---@return Source
function _RESOURCE.LoadMusic(path)
    return _RESOURCE.LoadResource(path, _RESOURCE.NewMusic, _pools.sound)
end

---@param path string
---@return Engine.Graphics.Drawable.SpriteData
function _RESOURCE.LoadSpriteData(path)
    return _RESOURCE.LoadResource(path, _RESOURCE.NewSpriteData, _pools.spriteData)
end

---@param path string
---@return Engine.Resource.AnimData
function _RESOURCE.LoadAnimData(path)
    -- print("_RESOURCE.LoadAnimData(path)", path)
    return _RESOURCE.LoadResource(path, _RESOURCE.NewAniData, _pools.aniData, _RESOURCE.NewSpriteData)
end

---@param path string
---@return Engine.Resource.ColliderData
function _RESOURCE.LoadColliderData(path)
    return _RESOURCE.LoadResource(path, _RESOURCE.NewColliderData, _pools.colliderData)
end

---@param path string
---@return table
function _RESOURCE.LoadUiData(path)
    return _RESOURCE.LoadData(_DIRS.UI .. path)
end

---@param path string
---@return table
function _RESOURCE.LoadSceneData(path)
    return _RESOURCE.LoadData("resource/data/", "scene/" .. path)
end

---@param path string
---@param subpath string
---@return table
function _RESOURCE.LoadData(path, subpath)
    if type(path) == "table" then
        return path
    end

    local subDirectory = ""
    if subpath then
        path = path .. subpath .. ".dat"
        subDirectory = _STRING.GetFileDirectory(subpath)
    else
        path = path .. ".dat"
    end

    if _FILE.Exist(path) == false then
        error("_RESOURCE.LoadData, no file:" .. path)
    end

    local content = _FILE.LoadFile(path)
    content = string.gsub(content, "$SD", subDirectory)
    return loadstring(content)()
end

---@param path string
---@param newFunc function
---@param pool table
function _RESOURCE.LoadResource(path, newFunc, pool, ...)
    if pool[path] == nil then
        local t = newFunc(path, ...)
        pool[path] = t
    end

    return pool[path]
end

function _RESOURCE.ReloadResource(path, newFunc, pool, ...)
    local t = newFunc(path, ...)
    pool[path] = t
    return pool[path]
end

function _RESOURCE.RecursiveLoad(tab, loadFunc, keyword)
	if type(tab) == "table" and tab[keyword] == nil then
        for key, value in pairs(tab) do
            tab[key] = _RESOURCE.RecursiveLoad(value, loadFunc, keyword)
        end

        return tab
    else
        return loadFunc(tab)
    end
end

return _RESOURCE