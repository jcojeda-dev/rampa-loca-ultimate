--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Logger = require(ReplicatedStorage.Shared.Core.Logger)
local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local ProfileCache = require(ReplicatedStorage.Shared.Domains.Player.ProfileCache)
local SessionManager = require(ReplicatedStorage.Shared.Domains.Player.SessionManager)
local AutoSaveManager = require(ReplicatedStorage.Shared.Domains.Player.AutoSaveManager)
local PlayerProfile = require(ReplicatedStorage.Shared.Domains.Player.PlayerProfile)
local PlayerSignals = require(ReplicatedStorage.Shared.Domains.Player.PlayerSignals)

local PlayerService = {}
PlayerService.__index = PlayerService

type PlayerServiceInstance = {
	Name: string,
	_cache: any,
	_sessions: any,
	_autoSave: any,
	_signals: any,
	_dataService: any,
	_economyService: any,
	Init: (self: PlayerServiceInstance) -> (),
	Start: (self: PlayerServiceInstance) -> (),
	Destroy: (self: PlayerServiceInstance) -> (),
	GetProfile: (self: PlayerServiceInstance, userId: number) -> PlayerTypes.ProfileData?,
	SaveProfile: (self: PlayerServiceInstance, userId: number) -> (boolean, string?),
	GetSession: (self: PlayerServiceInstance, userId: number) -> PlayerTypes.Session?,
	UpdateSessionActivity: (self: PlayerServiceInstance, userId: number) -> (),
	LockSession: (self: PlayerServiceInstance, userId: number) -> (),
	UnlockSession: (self: PlayerServiceInstance, userId: number) -> (),
	IsSessionActive: (self: PlayerServiceInstance, userId: number) -> boolean,
	GetSignals: (self: PlayerServiceInstance) -> any,
	SetDataService: (self: PlayerServiceInstance, dataService: any) -> (),
	SetEconomyService: (self: PlayerServiceInstance, economyService: any) -> (),
}

function PlayerService.new(): PlayerServiceInstance
	local self = setmetatable({
		Name = "PlayerService",
		_cache = ProfileCache.new(),
		_sessions = SessionManager.new(),
		_autoSave = AutoSaveManager.new(),
		_signals = PlayerSignals.new(),
		_dataService = nil,
		_economyService = nil,
	}, PlayerService)

	return self
end

function PlayerService:Init(): ()
	Logger:Info("Initializing PlayerService")
end

function PlayerService:Start(): ()
	Logger:Info("Starting PlayerService")

	self._autoSave:SetSaveCallback(function(profile)
		if self._dataService ~= nil then
			self._dataService:SaveProfile(profile)
		end
	end)

	self._autoSave:Start()

	Players.PlayerAdded:Connect(function(player)
		self:_OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_OnPlayerRemoving(player)
	end)
end

function PlayerService:Destroy(): ()
	Logger:Info("Destroying PlayerService")
	self._autoSave:Stop()
	self._autoSave:Destroy()
	self._cache:Destroy()
	self._sessions:Destroy()
	self._signals:Destroy()
end

function PlayerService:SetDataService(dataService: any): ()
	self._dataService = dataService
end

function PlayerService:SetEconomyService(economyService: any): ()
	self._economyService = economyService
end

function PlayerService:GetProfile(userId: number): PlayerTypes.ProfileData?
	assert(type(userId) == "number" and userId > 0, "Invalid userId")

	local cached = self._cache:Get(userId)
	if cached ~= nil then
		return cached
	end

	if self._dataService == nil then
		return nil
	end

	local profile = self._dataService:LoadProfile(userId)
	if profile ~= nil then
		profile = PlayerProfile.UpdateLastLogin(profile)
		self._cache:Set(userId, profile)
		self._autoSave:RegisterProfile(profile)
		self._signals.ProfileLoaded:Fire(profile)
	end

	return profile
end

function PlayerService:SaveProfile(userId: number): (boolean, string?)
	assert(type(userId) == "number" and userId > 0, "Invalid userId")

	local profile = self._cache:Get(userId)
	if profile == nil then
		return false, "Profile not found in cache"
	end

	if self._dataService == nil then
		return false, "DataService not available"
	end

	profile = PlayerProfile.MarkModified(profile)
	local success, errorMsg = self._dataService:SaveProfile(profile)
	if success then
		self._signals.ProfileSaved:Fire(profile)
	end

	return success, errorMsg
end

function PlayerService:GetSession(userId: number): PlayerTypes.Session?
	return self._sessions:GetSession(userId)
end

function PlayerService:UpdateSessionActivity(userId: number): ()
	self._sessions:UpdateActivity(userId)
end

function PlayerService:LockSession(userId: number): ()
	self._sessions:LockSession(userId)
	local session = self._sessions:GetSession(userId)
	if session ~= nil then
		self._signals.SessionLocked:Fire(session)
	end
end

function PlayerService:UnlockSession(userId: number): ()
	self._sessions:UnlockSession(userId)
	local session = self._sessions:GetSession(userId)
	if session ~= nil then
		self._signals.SessionUnlocked:Fire(session)
	end
end

function PlayerService:IsSessionActive(userId: number): boolean
	return self._sessions:IsSessionActive(userId)
end

function PlayerService:AddCoins(userId: number, amount: number, reason: string): ()
	assert(type(userId) == "number" and userId > 0, "Invalid userId")
	assert(type(amount) == "number" and amount >= 0, "Invalid amount")

	local profile = self:GetProfile(userId)
	if profile == nil then
		return
	end

	if self._economyService ~= nil then
		self._economyService:AddCoins(profile, amount, reason)
		self._signals.CoinsChanged:Fire(profile)
		self._autoSave:MarkDirty(userId)
	end
end

function PlayerService:RemoveCoins(userId: number, amount: number, reason: string): boolean
	assert(type(userId) == "number" and userId > 0, "Invalid userId")
	assert(type(amount) == "number" and amount >= 0, "Invalid amount")

	local profile = self:GetProfile(userId)
	if profile == nil then
		return false
	end

	if self._economyService == nil then
		return false
	end

	local success = self._economyService:RemoveCoins(profile, amount, reason)
	if success then
		self._signals.CoinsChanged:Fire(profile)
		self._autoSave:MarkDirty(userId)
	end

	return success
end

function PlayerService:GetSignals(): any
	return self._signals
end

function PlayerService:_OnPlayerAdded(player: Player): ()
	local profile = self:GetProfile(player.UserId)
	if profile ~= nil then
		local session = self._sessions:CreateSession(player.UserId, player.UserId)
		self._signals.SessionCreated:Fire(session)
	end
end

function PlayerService:_OnPlayerRemoving(player: Player): ()
	local profile = self._cache:Get(player.UserId)
	if profile ~= nil then
		self:SaveProfile(player.UserId)
	end

	local session = self._sessions:GetSession(player.UserId)
	if session ~= nil then
		self._signals.SessionEnded:Fire(session)
	end

	self._cache:Remove(player.UserId)
	self._sessions:DestroySession(player.UserId)
	self._autoSave:UnregisterProfile(player.UserId)
end

return PlayerService