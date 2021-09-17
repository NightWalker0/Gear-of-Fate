--[[
    Desc: Navigation system, provide pathfinding and move amending.
    Author: SerDing
    Since: 2018-04-05
    Alter: 2021-03-22
]]
local _List = require("core.list")
local _MATH = require("engine.math")
local _Vector2 = require("utils.vector2")
local _GRAPHICS = require("engine.graphics")
local _Color = require("engine.graphics.config.color")
local _Pathfinder = require("system.navigation.pathfinder")
local _SETTING = require("setting")

---@class System.Navigation
---@field protected _passMap table<int>
---@field protected _pathfinder System.Navigation.Pathfinder
local _Navigation = require("core.class")()

local _PASSTYPE = {
	YES = 0,
	NO = 1,
}
local _emptyPath = {}

local _NOPASS_COLOR = _Color.New(255, 0, 0, 150)
local _PATHNODE_COLOR = {
	START = _Color.New(0, 0, 0, 255),
	NORMAL = _Color.New(0, 0, 150, 255),
	DEST = _Color.New(150, 0, 0, 255),
	SCANNED = _Color.New(150, 150, 0, 255),
	CLOSE = _Color.New(0, 150, 150, 255),
}

local _drawBoundLine = false
function _Navigation:Ctor()
	self._area = {
		x = 0,
		y = 0,
		w = 224 * 5,
		h = 600,
		x2 = 0,
		y2 = 0,
	}
	self._AXIS_RATIO_Y = _SETTING.scene.AXIS_RATIO_Y
	self._nodeSize = _Vector2.New(16, 16 * self._AXIS_RATIO_Y)

	self._pathfinder = _Pathfinder.New()
	self._passMap = {}
	self._passMap2D = {}
	self._path = _List.New()
	self._pathTable = {}
	self._pathPoints = {}
	self.walkable = 1

	self.debug = false
end

function _Navigation:Init(x, y, w, h)
	self._area.x = x
	self._area.y = y
	self._area.w = w
	self._area.h = h
	self._area.x2 = x + w
	self._area.y2 = y + h
	self._nCol = math.floor(self._area.w / self._nodeSize.x)
	self._nRow = math.floor(self._area.h / self._nodeSize.y)
	self._passMap = {}
	for i = 1, self._nCol * self._nRow do
		self._passMap[i] = _PASSTYPE.YES
	end
	LOG.Debug("Navigation.Init - nCol:%d nRow:%d", self._nCol, self._nRow)
end

function _Navigation:InitPathfinderPassMap()
	local map2d = {}
	for y = 1, self._nRow do
		map2d[y] = {}
		for x = 1, self._nCol do
			map2d[y][x] = self._passMap[(y - 1) * self._nCol + x]
		end
	end
	self._pathfinder:SetPassMap(map2d, _PASSTYPE.YES)
end

---@param sx number
---@param sy number
---@param dx number
---@param dy number
---@return table<int, Vector2>
function _Navigation:FindPath(sx, sy, dx, dy)
	if not self:IsPositionInArea(sx, sy) or not self:IsPositionInArea(dx, dy) then
		LOG.Error("Navigation:FindPath - start or dest position is not in area.")
		return _emptyPath
	end

	local startIndex = _Vector2.New(self:GetNodeIndexByPos(sx, sy))
	local destIndex = _Vector2.New(self:GetNodeIndexByPos(dx, dy))

	if not self:GetNodePass(startIndex:Get()) then
		LOG.Error("Navigation:FindPath - start position is not passable.")
		return _emptyPath
	end
	if not self:GetNodePass(destIndex:Get()) then
		LOG.Error("Navigation:FindPath - destination is not passable.")
		return _emptyPath
	end

	self._path:Clear()
	self._pathTable = {}
	self._pathPoints = {}
	self._pathfinder:FindPath(startIndex.x, startIndex.y, destIndex.x, destIndex.y, self._path)
	self._pathTable = self._path:ToArray()

	local pathFinal = {}
	for i = 1, #self._pathTable do
		--pathFinal[i] = _Vector2.New(self:GetNodePosition(self._pathTable[i].x, self._pathTable[i].y))
		pathFinal[i] = _Vector2.New(self._pathTable[i].x, self._pathTable[i].y)
	end

	return pathFinal
end

function _Navigation:Draw()
	if _SETTING.debug.navigation.grid == false then
		return
	end

	if _SETTING.debug.navigation.obstacle then
		for iy = 1, self._nRow do
			for ix = 1, self._nCol do
				local nodeIndex = (iy - 1) * self._nCol + ix
				if self._passMap[nodeIndex] == _PASSTYPE.NO then
					local x = self._area.x + (ix - 1) * self._nodeSize.x
					local y = self._area.y + (iy - 1) * self._nodeSize.y
					_GRAPHICS.SetColor(_NOPASS_COLOR:Get())
					_GRAPHICS.DrawRect("fill", x, y, self._nodeSize:Get())
					_GRAPHICS.ResetColor()
				end
			end
		end
	end

	----draw path nodes
	--if #self._pathTable > 0 then
	--	self:DrawPath()
	--end

	-- draw lines of grids
	local y1 = self._area.y
	local y2 = self._area.y + self._nodeSize.y * self._nRow
	for i = 1, self._nCol + 1 do
		local x = self._area.x + (i - 1) * self._nodeSize.x
		_GRAPHICS.Line(x, y1, x, y2)
	end

	local x1 = self._area.x
	local x2 = self._area.x + self._nodeSize.x * self._nCol
	for i = 1, self._nRow + 1 do
		local y = self._area.y + (i - 1) * self._nodeSize.y
		_GRAPHICS.Line(x1, y, x2, y)
	end

	if _drawBoundLine then
		_GRAPHICS.Line(
				self._area.x + self._area.w,
				self._area.y,
				self._area.x + self._area.w,
				self._area.y + self._area.h
		)
		_GRAPHICS.Line(
				self._area.x,
				self._area.y + self._area.h,
				self._area.x + self._area.w,
				self._area.y + self._area.h
		)
	end

end

---@param path table<int, Vector2>
function _Navigation:DrawPath(path)
	if not _SETTING.debug.navigation.path then
		return
	end

	--for y = 1, #self._pathfinder.scannedMap do
	--	for x = 1, #self._pathfinder.scannedMap[y] do
	--		local TempColor
	--		TempColor = self._pathfinder.scannedMap[y][x] == self._pathfinder._closeValue and _PATHNODE_COLOR.SCANNED or TempColor
	--		TempColor = self._pathfinder._closeMap[y][x] == self._pathfinder._closeValue and _PATHNODE_COLOR.CLOSE or TempColor
	--		if TempColor then
	--			local rx = self._area.x + (x - 1) * self._nodeSize.x
	--			local ry = self._area.y + (y - 1) * self._nodeSize.y
	--			_GRAPHICS.SetColor(TempColor:Get())
	--			_GRAPHICS.DrawRect("fill", rx, ry, self._nodeSize:Get())
	--			_GRAPHICS.ResetColor()
	--		end
	--	end
	--end

	--for i = 1, #path do
	--	local nodeColor = _PATHNODE_COLOR.NORMAL
	--	if i == 1 then
	--		nodeColor = _PATHNODE_COLOR.START
	--	elseif i == #path then
	--		nodeColor = _PATHNODE_COLOR.DEST
	--	end
	--
	--	local x = self._area.x + (path[i].x - 1) * self._nodeSize.x
	--	local y = self._area.y + (path[i].y - 1) * self._nodeSize.y
	--	_GRAPHICS.SetColor(nodeColor:Get())
	--	_GRAPHICS.DrawRect("fill", x, y, self._nodeSize:Get())
	--	_GRAPHICS.ResetColor()
	--	--_GRAPHICS.Print(i, x, y)
	--end

	self._pathPoints = {}
	for i = 1, #path do
		local x, y = self:GetNodePosition(path[i].x, path[i].y)
		self._pathPoints[#self._pathPoints + 1] = x
		self._pathPoints[#self._pathPoints + 1] = y
	end

	if #self._pathPoints >= 4 then --2 points at least
		_GRAPHICS.Line(self._pathPoints)
		_GRAPHICS.Points(self._pathPoints)
	end
end

---@param ox float @original x
---@param oy float @original y
---@param tx float @target x
---@param ty float @target y
---@param axis string
function _Navigation:AmendMovePosition(ox, oy, tx, ty, axis)
	local ix, iy = self:GetNodeIndexByPos(tx, ty)
	if ix < 1 or ix > self._nCol or iy < 1 or iy > self._nRow then
		return ox, oy, "bound"
	end

	local retx, rety = tx, ty
	local collisionType = "none"
	if not self:GetNodePass(ix, iy) then
		local direction
		if axis == "x" then
			direction = _MATH.Sign(tx - ox)
			if direction == 1 then
				retx = self._area.x + (ix - 1) * self._nodeSize.x - 1
			elseif direction == -1 then
				retx = self._area.x + ix * self._nodeSize.x + 1
			end
			collisionType = "obstacle_in_x"
		else --y
			direction = _MATH.Sign(ty - oy)
			if direction == 1 then
				rety = self._area.y + (iy - 1) * self._nodeSize.y - 1
			elseif direction == -1 then
				rety = self._area.y + iy * self._nodeSize.y + 1
			end
			collisionType = "obstacle_in_y"
		end
	end

	return retx, rety, collisionType
end

---@param ix int
---@param iy int
---@param passable boolean
function _Navigation:SetNodePass(ix, iy, passable)
	if ix < 1 or ix > self._nCol or iy < 1 or iy > self._nRow then
		return
	end

	self._passMap[(iy - 1) * self._nCol + ix] = passable and _PASSTYPE.YES or _PASSTYPE.NO
end

---@param ix int
---@param iy int
---@return boolean
function _Navigation:GetNodePass(ix, iy)
	if ix < 1 or ix > self._nCol or iy < 1 or iy > self._nRow then
		return false
	end

	return self._passMap[(iy - 1) * self._nCol + ix] == _PASSTYPE.YES
end

---@param ix int
---@param iy int
function _Navigation:GetNodePosition(ix, iy)
	local x = self._area.x + (ix - 1) * self._nodeSize.x + self._nodeSize.x / 2
	local y = self._area.y + (iy - 1) * self._nodeSize.y + self._nodeSize.y / 2
	return x, y
end

function _Navigation:GetNodeIndexByPos(x, y)
	x = x - self._area.x
	y = y - self._area.y
	local floatx = x / self._nodeSize.x
	local floaty = y / self._nodeSize.y
	local intx = math.floor(floatx) + 1
	local inty = math.floor(floaty) + 1

	return intx, inty
end

function _Navigation:GetNodeSize()
	return self._nodeSize:Get()
end

function _Navigation:IsInNode(x, y, nx, ny)
	local nx1 = self._area.x + (nx - 1) * self._nodeSize.x
	local ny1 = self._area.y + (ny - 1) * self._nodeSize.y
	local nx2 = nx1 + self._nodeSize.y
	local ny2 = ny1 + self._nodeSize.y

	return x >= nx1 and x <= nx2 and y >= ny1 and y <= ny2
end

function _Navigation:IsPositionInArea(x, y)
	return _MATH.IsInRange(x, self._area.x, self._area.x2, true)
		and _MATH.IsInRange(y, self._area.y, self._area.y2, true)
end

return _Navigation 