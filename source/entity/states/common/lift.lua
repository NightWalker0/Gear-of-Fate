--[[
	Desc: State of being lifted up
	Author: SerDing 
	Since: 2018-02-26 14:25:46 
	Alter: 2018-02-26 14:25:46 
]]
local _Timer = require("utils.timer")
local _Base  = require("entity.states.base")

---@class State.Lift : Entity.State.Base
local _Lift = require("core.class")(_Base)

function _Lift:Ctor(data, name)
	_Base.Ctor(self, data, name)
	self._aerialTimer = _Timer.New(_, _, true)
	self._aerialTimeLimit = data.aerialTimeLimit or 2000
	self._protectionTimer = _Timer.New()
	self._protectionTime = data.protectionTime or 100
	self._defaultVz = data.defaultVz or 260
	self._defaultAz = data.defaultAz or 20
	self._g = 0
	self._lowestHeight = data.lowestHeight or 30
	self._reliftFrame = data.reliftFrame or 3
	self._reliftRate = data.reliftRate or { touchdown = 0.3, lowHeight = 0.5, bounce = 0.5, }
	self._bounce = {
		enable = true,
		hasDone = false,
		vz = 0,
		az = 0,
	}
end

function _Lift:Init(entity)
	_Base.Init(self, entity)
end

function _Lift:Enter(vz, az, vx, ax)
	_Base.Enter(self)
	vz = vz or self._defaultVz
	vx = vx or 0
	az = az or self._defaultAz
	ax = ax or 0
	self._g = az
	self._avatar:Play(self._animNameSet[1])
	if vx == 0 then
		self._movement:StopEasemove()
	else
		self._movement:EaseMove("x", vx, ax)
	end
	-- if vz ~= 0 then
		vz = vz - self._entity.fighter.weight
		vz = vz < 0 and 0 or vz
		local touchdown = self._STATE.preState == self and self._entity.transform.position.z == 0
		vz = touchdown and vz * self._reliftRate.touchdown or vz
		local isAerial = self._movement:IsFalling() or self._movement:IsRising()
		local isLowHeight = self._entity.transform.position.z >= -self._lowestHeight
		if isAerial and isLowHeight then
			local h = (vz <= 0) and 0 or math.pow(vz, 2) / (2 * az)
			vz = math.sqrt(2 * az * h * self._reliftRate.lowHeight)
		end
		self._bounce.enable = (vz >= 200) and true or false
		self._bounce.vz = vz * self._reliftRate.bounce
		self._bounce.az = az
		self._movement:StartJump(vz, az, nil)
		self._movement.eventMap.topped:AddListener(self, self._Topped)
		self._movement.eventMap.touchdown:AddListener(self, self._Touchdown)
	-- end

	if touchdown or (isAerial and isLowHeight) then
		self._avatar:SetFrame(3)
	end
	if not isAerial then -- first lift
		self._aerialTimer:Start(self._aerialTimeLimit)
	end
end

function _Lift:_Topped()
	while self._avatar:GetFrame() < 3 do
		self._avatar:NextFrame()
	end	
end

function _Lift:_Touchdown()
	while self._avatar:GetFrame() < 4 do
		self._avatar:NextFrame()
	end
	if self._bounce.enable and self._bounce.hasDone == false then
		self._movement:StartJump(self._bounce.vz, self._bounce.az, nil)
		self._bounce.hasDone = true
		self._aerialTimer.isRunning = false
	else -- final touchdown
		while self._avatar:GetFrame() < 5 do
			self._avatar:NextFrame()
		end
		self._movement:StopEasemove()
	end
end

function _Lift:Update(dt)
	self._aerialTimer:Tick(dt)
	self._protectionTimer:Tick(dt)
	if self._aerialTimer:GetCount() >= self._aerialTimeLimit then
		if self._protectionTimer.isRunning == false then
			self._protectionTimer:Start(self._protectionTime)
			local overtime = self._aerialTimer:GetCount() - self._aerialTimeLimit
			local g = (1 + overtime * 0.001 * 2) * self._g
			self._movement:Set_g(g)
		end
	end
	_Base.AutoTransitionAtEnd(self)
end

function _Lift:Exit()
	self._bounce.hasDone = false
	self._movement.eventMap.topped:DelListener(self, self._Topped)
	self._movement.eventMap.touchdown:DelListener(self, self._Touchdown)
end

return _Lift