--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local EconomyConstants = require(ReplicatedStorage.Shared.Constants.EconomyConstants)
local TaskScheduler = require(ReplicatedStorage.Shared.Core.TaskScheduler)

local AutoSaveManager = {}
AutoSaveManager.__index = AutoSaveManager

type SaveCallback = (PlayerTypes.ProfileData) -> (boolean, string?)

type AutoSaveManagerInstance = {
	_profiles: {[number]: PlayerTypes.ProfileData},
	_lastSaveTime: {[number]: number},
	_saveCallback: SaveCallback?,
	_taskScheduler: any,
	_task: any,
	RegisterProfile: (self: AutoSaveManagerInstance, profile: PlayerTypes.ProfileData) -> (),
	UnregisterProfile: (self: AutoSaveManagerInstance, userId: number) -> (),
	MarkDirty: (self: AutoSaveManagerInstance, userId: number) -> (),
	SetSaveCallback: (self: AutoSaveManagerInstance, callback: SaveCallback) -> (),
	Start: (self: AutoSaveManagerInstance) -> (),
	Stop: (self: AutoSaveManagerInstance) -> (),
	Destroy: (self: AutoSaveManagerInstance) -> (),
}

function AutoSaveManager.new(taskScheduler: any?): AutoSaveManagerInstance
	local self = setmetatable({
		_profiles = {},
		_lastSaveTime = {},
		_saveCallback = nil,
		_taskScheduler = taskScheduler or TaskScheduler.new(),
		_task = nil,
	}, AutoSaveManager)

	return self
end

function AutoSaveManager:RegisterProfile(profile: PlayerTypes.ProfileData): ()
	assert(profile ~= nil, "Profile cannot be nil")
	self._profiles[profile.UserId] = profile
	self._lastSaveTime[profile.UserId] = os.time()
end

function AutoSaveManager:UnregisterProfile(userId: number): ()
	self._profiles[userId] = nil
	self._lastSaveTime[userId] = nil
end

function AutoSaveManager:MarkDirty(userId: number): ()
	self._lastSaveTime[userId] = 0
end

function AutoSaveManager:SetSaveCallback(callback: SaveCallback): ()
	self._saveCallback = callback
end

function AutoSaveManager:Start(): ()
	if self._task ~= nil then
		return
	end

	self._task = self._taskScheduler:ScheduleRepeating(function()
		self:_CheckAndSave()
	end, EconomyConstants.AUTO_SAVE_INTERVAL)
end

function AutoSaveManager:Stop(): ()
	if self._task ~= nil then
		self._taskScheduler:Cancel(self._task)
		self._task = nil
	end
end

function AutoSaveManager:_CheckAndSave(): ()
	local now = os.time()

	for userId, profile in pairs(self._profiles) do
		local lastSave = self._lastSaveTime[userId] or 0
		local elapsed = now - lastSave

		if elapsed >= EconomyConstants.AUTO_SAVE_INTERVAL then
			if self._saveCallback ~= nil then
				self._saveCallback(profile)
			end

			self._lastSaveTime[userId] = now
		end
	end
end

function AutoSaveManager:Destroy(): ()
	self:Stop()
	self._profiles = {}
	self._lastSaveTime = {}
	self._saveCallback = nil
end

return AutoSaveManager
