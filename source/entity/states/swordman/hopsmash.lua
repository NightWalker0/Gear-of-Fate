--[[
	Desc: Skill state: hopsmash
	Author: SerDing
	Since: 2017-07-28 21:54:14
	Alter: 2020-10-15 12:40:40
]]
local _TIME = require("engine.time")
local _CAMERA = require("system.scene.camera")
local _Timer = require("utils.timer")
local _Base  = require("entity.states.base")

---@class Entity.State.Swordman.Hopsmash : Entity.State.Base
local _Hopsmash = require("core.class")(_Base)

function _Hopsmash:Ctor(data, name)
	_Base.Ctor(self, data, name)
	self.skillID = 65
	
	self._verticalSpeedBase = data.verticalSpeedBase or 750
	self._verticalSpeed = 0
	self._gravity = data.gravity or 36
	self._attackRateRange = data.varAttackRate
    self._minTimePercent = data.minTimePercent
	self._verticalSpeed = 0
	self._forwardSpeedBase = data.forwardSpeed or 450
	self._forwardSpeed = 0
	self._holddownTimer = _Timer.New()
	self._holddownTimeMax = data.holddownTimeMax or 0.15
	self._holddownTimeMin = data.holddownTimeMin or 0.11
	self._holddownTime = 0

	self._attackEnable = false
	self._attackTimes = 2
	self._attackCount = 0
	self._attackInterval = 60
	self._attackTimer = _Timer.New()
	self._hitFrame = 0

	self._process = 0
	self._shakeParam = {
		time = 0.3,
		x = 15, 
		y = 18
	}

	self._touchdown = false
	self._smash = true
	--self._smash = false
	self._switchProcess = false
end 

function _Hopsmash:Enter()

	if self._process == 0 then
		_Base.Enter(self)
		self._process = 1
		self._holddownTimer:Start(self._holddownTimeMax * 1000)

		self._OnHit = function(combat, entity)
			local hitFrame = _TIME.GetFrame()
			if hitFrame ~= self._hitFrame then
				self._attackCount = self._attackCount + 1
				if self._attackCount < self._attackTimes then
					self._attackEnable = true
					self._attackTimer:Start(self._attackInterval)
				end
				self._hitFrame = hitFrame
			end
		end
		self._combat:StartAttack(self._attackDataSet[1], self._OnHit)
		self._combat:SetSoundGroup(self._soundDataSet.hitting.hsword)
		self._movement.eventMap.topped:AddListener(self, self._Topped)
		self._movement.eventMap.touchdown:AddListener(self, self._Touchdown)
	else
		self._switchProcess = true
	end

end

function _Hopsmash:_Topped()
	self._movement:Set_g(self._gravity * 2.25 * self._attackRate)
	_Base.PlaySound(self._soundDataSet.voice)
	while self._body:GetFrame() < 3 do
		self._avatar:NextFrame()
		print("hopsmash nextframe")
	end
end

function _Hopsmash:_Touchdown()
	self._touchdown = true
end

function _Hopsmash:Update(dt)
	if self._process == 1 then
		self._holddownTimer:Tick(dt)
		if self._switchProcess or self._holddownTimer.isRunning == false then
			self._holddownTime = self._holddownTimer:GetCount() / 1000
			self._holddownTime = math.min(self._holddownTime, self._holddownTimeMax)

			local timePercent = self._holddownTime / self._holddownTimeMax
			self._attackRate = self._entity.stats.attackRate + (self._attackRateRange * (1.0 - timePercent))
			self._render.timeScale = self._attackRate
			self._forwardSpeed = self._forwardSpeedBase * math.max(self._minTimePercent, timePercent) * self._entity.stats.attackRate
			
			self._holddownTime = math.max(self._holddownTimeMin, self._holddownTime)
			local root = math.ceil(math.sqrt(self._attackRate) * 1000) * 0.001 --self._entity.stats.attackRate
			self._verticalSpeed = self._verticalSpeedBase * (self._holddownTime / self._holddownTimeMax) * root

			local param = {master = self._entity}
			_Base.NewEntity(self._entityDataSet[1], param)
			_Base.NewEntity(self._entityDataSet[2], param)
			self._avatar:Play(self._animNameSet[2])
			self:_StartJump()
			self._process = 2
			self._switchProcess = false
		end
	elseif self._process == 2 then
		self:_Attack(dt)
		self:_SmashEffect()
		self:_Movement(dt)
		_Base.AutoTransitionAtEnd(self)
	end 
end 

function _Hopsmash:_StartJump()
	local function fallCond()
		if self._avatar:GetPart():GetTick() == 2 then
			return true 
		end
		return false
	end
	if not self._movement:IsRising() and not self._movement:IsFalling() then
		self._movement:StartJump(self._verticalSpeed, self._gravity * self._entity.stats.attackRate, fallCond)
	end 
end

function _Hopsmash:_Attack(dt)
	self._attackTimer:Tick(dt)
	if self._attackEnable and self._attackTimer.isRunning == false then
		local attack = (self._attackCount + 1 == self._attackTimes) and self._attackDataSet[2] or self._attackDataSet[1]
		self._combat:StartAttack(attack, self._OnHit)
		self._attackEnable = false
	end
end
function _Hopsmash:_SmashEffect()
	if self._touchdown and self._body:GetFrame() >= 4 then 
		if self._smash then
			local masterPosition = self._entity.transform.position
			local masterDirection = self._entity.transform.direction
			local param = {
				x = masterPosition.x + 140 * masterDirection, 
				y = masterPosition.y + 10, 
				direction = masterDirection, 
				master = self._entity,
				camp = self._entity.identity.camp,
			}
			_Base.NewEntity(self._entityDataSet[3], param)
			_Base.NewEntity(self._entityDataSet[4], param)
		end
		_CAMERA.Shake(self._shakeParam.time, -self._shakeParam.x * self._holddownTime, self._shakeParam.x * self._holddownTime, -self._shakeParam.y * self._holddownTime, self._shakeParam.y * self._holddownTime)
		self._touchdown = false
	end
end

function _Hopsmash:_Movement(dt)
	if self._entity.transform.position.z < 0 then
		if self._movement:IsRising() then
			self._movement:Move('x', self._forwardSpeed * self._entity.transform.direction)
		elseif self._movement:IsFalling() then
			self._movement:Move('x', self._forwardSpeed * self._entity.transform.direction * 0.35) -- * 0.25
		end
	end 
end

function _Hopsmash:Exit()
	_Base.Exit(self)
	self._attackCount = 0
	self._projectile = nil
	self._movement.eventMap.topped:DelListener(self, self._Topped)
	self._movement.eventMap.touchdown:DelListener(self, self._Touchdown)
	self._touchdown = false
	self._holddownTime = 0
	self._process = 0
	self._switchProcess = false
end

function _Hopsmash:IsFlawState()
	return false
end

return _Hopsmash 