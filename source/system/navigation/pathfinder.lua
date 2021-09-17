--[[
	Desc: Pathfinder of a star algorithm.
	Author: SerDing
	Since: 2021-03-31
	Alter: 2021-04-03
]]
local _List = require("core.list")
local _PriorityQueue = require("core.priorityqueue")
local _TIME = require("engine.time")
local _Vector2 = require("utils.vector2")
local _Node = require("system.navigation.node")

---@class System.Navigation.Pathfinder
---@field protected _nodes table<int, table<int, System.Navigation.Node>>
local _Pathfinder = require("core.class")()

---@param map2d  table<int, table<int, int>> @ 2d pass map
function _Pathfinder:Ctor(map2d, passableValue)
	self._nodes = {}
	self._openList = _List.New() ---@type Core.List
	self._openQueue = _PriorityQueue.New(_Pathfinder._ComparePriority) ---@type Core.PriorityQueue
	self._closeMap = {}
	self._closeValue = 0
	self.scannedMap = {}
	self:SetPassMap(map2d, passableValue)
end

---@param v1 System.Navigation.Node
---@param v2 System.Navigation.Node
---@return boolean
function _Pathfinder._ComparePriority(v1, v2)
	if v1.fCost == v2.fCost then
		return v1.hCost < v2.hCost
	else
		return v1.fCost < v2.fCost
	end
end

---@param startX int @start x index
---@param startY int @start y index
---@param destX int @end x index
---@param destY int @end y index
---@param pathList Core.List
---@return table<int, int>
function _Pathfinder:FindPath(startX, startY, destX, destY, pathList)
	--_LOG.Debug("==========================================================")
	--_LOG.Debug("Pathfinder.FindPath - %d %d %d %d", startX, startY, destX, destY)
	self:_ResetNodes()
	self._closeValue = self._closeValue + 1
	self._openList = self._openQueue
	self._openList:Clear()
	local timeRecord = _TIME.GetTime(true)
	local startNode = self._nodes[startY][startX]
	local destNode = self._nodes[destY][destX]

	self._openList:Enqueue(startNode)
	local gotEnd = false
	local loopCount = 0
	while self._openList:Count() > 0 and gotEnd == false do
		local currentNode = self._openList:Dequeue()
		if currentNode == destNode then
			gotEnd = true
			break
		end

		self._closeMap[currentNode.iy][currentNode.ix] = self._closeValue
		local neighbors = self:_GetNeighbors(currentNode.ix, currentNode.iy)
		for i = 1, #neighbors do
			local node = neighbors[i]
			if node.passable then
				self.scannedMap[node.iy][node.ix] = self._closeValue
			end
			if node.passable and self._closeMap[node.iy][node.ix] ~= self._closeValue then
				local newGCost = node:CalcG(currentNode)
				local inOpenList = self._openList:Contains(node)
				local lessGCsot = newGCost < node.gCost
				if lessGCsot or not inOpenList then
					node.from = currentNode
					node.gCost = newGCost
					node.hCost = node:CalcDistanceCost(destX, destY)
					node:CalcFCost()
					if not inOpenList then
						self._openList:Enqueue(node)
					end
					if lessGCsot then
						self._openList:UpdateOrder(node)
					end
				end
			end
		end
		loopCount = loopCount + 1
	end
	if not gotEnd then
		LOG.Debug("Pathfinder.FindPath - no valid path.")
		return false
	end

	local costTime = (_TIME.GetTime(true) - timeRecord) * 1000
	--_LOG.Debug("- cost time:%.10f", costTime)
	--_LOG.Debug("- loop count:%d",  loopCount)
	--_LOG.Debug("- openlist count:%d", self._openList:Count())

	self:_RetracePath(destNode, pathList)
	--_LOG.Debug("- path length:%d", pathList:Count())

	return true
end

---@param destNode System.Navigation.Node
---@param pathList Core.List
function _Pathfinder:_RetracePath(destNode, pathList)
	local node = destNode
	while node do
		pathList:Add(_Vector2.New(node.ix, node.iy))
		node = node.from
	end
	pathList:Reverse()
end

---@param map2d  table<int, table<int, int>> @ 2d pass map
function _Pathfinder:SetPassMap(map2d, passableValue)
	if not map2d then
		return
	end

	self._PASSABLE_VALUE = passableValue
	self._passMapWidth = #map2d[1]
	self._passMapHeight = #map2d
	self._nodes = {}
	self._closeMap = {}
	for y = 1, #map2d do
		self._nodes[y] = {}
		self._closeMap[y] = {}
		self.scannedMap[y] = {}
		for x = 1, #map2d[y] do
			self._nodes[y][x] = _Node.New(x, y, map2d[y][x])
			self._nodes[y][x].fCost = 0
			self._nodes[y][x].passable = map2d[y][x] == self._PASSABLE_VALUE and true or false
			self._closeMap[y][x] = 0
			self.scannedMap[y][x] = 0
		end
	end
end

function _Pathfinder:_ResetNodes()
	for y = 1, #self._nodes do
		for x = 1, #self._nodes[y] do
			self._nodes[y][x]:Reset()
		end
	end
end

---@param openList Core.List
---@return System.Navigation.Node
function _Pathfinder:_GetMinFCostNode(openList)
	if openList:Count() < 1 then
		return nil
	end

	local minNode = openList:Get(1) ---@type System.Navigation.Node
	local minF = minNode.fCost
	---@param node System.Navigation.Node
	local action = function(node)
		if _Pathfinder._ComparePriority(node, minNode) then --node.fCost < minF or (node.fCost == minF and node.hCost < minNode.hCost)		node.fCost <= minF
			minNode = node
			minF = node.fCost
			LOG.Debug("minNode[%d][%d], gCost:%d hCost:%d fCost:%d",
					node.ix, node.iy, node.gCost, node.hCost, node.fCost)
		end
	end
	openList:ForEach(action)

	return minNode
end

---@param ix int
---@param iy int
function _Pathfinder:GetNode(ix, iy)
	if ix > 0 and ix < self._passMapWidth and iy > 0 and iy < self._passMapHeight then
		return self._nodes[iy][ix]
	end

	return nil
end

---@param ix int
---@param iy int
---@return table<int, System.Navigation.Node>
function _Pathfinder:_GetNeighbors(ix, iy)
	local neighbors = {}
	local sx = ix - 1 > 0 and ix - 1 or 1
	local sy = iy - 1 > 0 and iy - 1 or 1
	local ex = ix + 1 <= self._passMapWidth and ix + 1 or self._passMapWidth
	local ey = iy + 1 <= self._passMapHeight and iy + 1 or self._passMapHeight
	for y = sy, ey do
		for x = sx, ex do
			neighbors[#neighbors + 1] = (x == ix or y == iy) and nil or self._nodes[y][x]
		end
	end

	return neighbors
end

return _Pathfinder