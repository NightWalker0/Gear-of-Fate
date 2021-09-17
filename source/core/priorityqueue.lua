--[[
	Desc: Priority queue, implement by max heap.
	Author: SerDing
	Since: 2021-04-04
	Alter: 2021-04-04
]]

local _List = require("core.list")
---@class Core.PriorityQueue
---@alias T System.Navigation.Node | int | Entity
---@field protected _heapTable table<int, T>
---@field protected _compare fun(v1:T, v2:T):boolean
local _PriorityQueue = require("core.class")()

function _PriorityQueue:Ctor(compare)
	self._heapTable = {
		nil, nil, nil, nil, nil, nil, nil, nil,
		nil, nil, nil, nil, nil, nil, nil, nil,
		nil, nil, nil, nil, nil, nil, nil, nil,
		nil, nil, nil, nil, nil, nil, nil, nil
	}
	self._table = self._heapTable
	self._compare = compare
	self._count = 0
end

function _PriorityQueue:Enqueue(value)
	self._count = self._count + 1
	self._heapTable[self._count] = value
	self:_AdjustHeapUp(self._count)

	return true
end

function _PriorityQueue:UpdateOrder(value)
	local index = _List.IndexOf(self, value)
	self:_AdjustHeapUp(index)
end

function _PriorityQueue:Dequeue()
	if self._count < 1 then
		LOG.Error("PriorityQueue.Dequeue - no element can be dequeue.")
		return false
	end

	local value = self._heapTable[1]
	self:_Swap(1, self._count)
	self._heapTable[self._count] = nil
	self:_AdjustHeapDown(1, self._count - 1)
	self._count = self._count - 1

	return value
end

function _PriorityQueue:Peek()
	return self._heapTable[1]
end

---@param start int @start index
function _PriorityQueue:_AdjustHeapUp(start)
	local child = start
	local startValue = self._heapTable[child]
	local parent = math.floor(child / 2)
	while parent >= 1 do
		if self._compare(startValue, self._heapTable[parent]) then
			self._heapTable[child] = self._heapTable[parent]
			child = parent
			parent = math.floor(parent / 2)
		else
			break
		end
	end
	self._heapTable[child] = startValue
end

---@param start int @start index
---@param n int @end index
function _PriorityQueue:_AdjustHeapDown(start, n)
	local startValue = self._heapTable[start]
	local parent = start
	local child = parent * 2
	while child <= n do
		if child + 1 <= n and self._compare(self._heapTable[child + 1], self._heapTable[child]) then
			child = child + 1
		end
		if self._compare(self._heapTable[child], startValue) then
			self._heapTable[parent] = self._heapTable[child]
			parent = child
			child = child * 2
		else
			break
		end
	end
	self._heapTable[parent] = startValue
end

function _PriorityQueue:_Swap(a, b)
	local temp = self._heapTable[a]
	self._heapTable[a] = self._heapTable[b]
	self._heapTable[b] = temp
end

function _PriorityQueue:Contains(value)
	return _List._Contains(self, self._heapTable, value)
end

function _PriorityQueue:Clear()
	self._heapTable = {
		nil, nil, nil, nil, nil, nil, nil, nil,
		nil, nil, nil, nil, nil, nil, nil, nil,
		nil, nil, nil, nil, nil, nil, nil, nil,
		nil, nil, nil, nil, nil, nil, nil, nil
	}
	self._table = self._heapTable
	self._count = 0
end

_PriorityQueue.Count = _List.Count

return _PriorityQueue