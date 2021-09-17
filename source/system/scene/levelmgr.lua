--[[
	Desc: Manage levels in the game
	Author: SerDing
	Since: 2017-09-07 
	Alter: 2019-12-12
]]

local _Event = require("core.event")
local _Level = require("system.scene.level")
local _CAMERA = require("system.scene.camera")
local _GRAPHICS = require("engine.graphics")
local _FILE = require('engine.filesystem')
local _RESOURCE = require("engine.resource")

local _sendPos = {}

-- _CAMERA.Ctor(_SCENEMGR)

---@class LevelManager
---@field curLevel Level
local _LEVELMGR = {}
local this = _LEVELMGR

function _LEVELMGR.Ctor()
	
	this.path = "resource/data/map/"
	this.curLevel = nil
	this.curType = "town"
	
end 

function _LEVELMGR.Update(dt)
	
	if this.curLevel.Update then
		this.curLevel:Update(dt)
	else 
		error("curScene is not existing !")
	end

	-- _CAMERA.Update(dt)
	-- _CAMERA.LookAt(_FACTORY.mainPlayer.transform.position.x, _FACTORY.mainPlayer.transform.position.y)

end 

local drawFunc = function (x, y)
	if this.curLevel then
		if this._curtain.alpha <= 240 then --防止切换场景后 场景先于黑色封面显示
			if this.curLevel.Draw then
				this.curLevel:Draw(x, -y)
			end
		end
	end
	if this._curtain.alpha > 0 then
		_GRAPHICS.SetColor(0, 0, 0, this._curtain.alpha)
		_GRAPHICS.DrawRect("fill", x, y, _GRAPHICS.GetDimension())
		_GRAPHICS.ResetColor()
		this._curtain.alpha = this._curtain.alpha - this._curtain.speed
	end 
end

function _LEVELMGR.Draw(x, y)
	-- _CAMERA.Draw(drawFunc)
end

function _LEVELMGR.LoadLevel(area, map, type)
	this.eventMap.OnLoadScene:Notify(this.curLevel)
end

function _LEVELMGR.SwitchScene(area, map, posIndex)
	
	local _arr = this._area.town[area]
	
	if _arr then
		local _pos = _sendPos[this.curIndex[1] ][this.curIndex[2]][posIndex]
		if _pos then
			this.PutCover()
			this.UnLoadScene()
			this.LoadLevel(area, map, this.curType)
			-- this._playerEntity.transform.position:Set(_pos.x, _pos.y, 0)
		end 
		
	else
		error("the area data is not existing! \n* area:" .. area .. " * map:" .. map)
		return false
	end
	
end

function _LEVELMGR.PutCover()
	this._curtain.alpha = 255
end

return _LEVELMGR 