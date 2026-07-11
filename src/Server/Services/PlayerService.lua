--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Logger = require(ReplicatedStorage.Shared.Core.Logger)
local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local ProfileCache = require(ReplicatedStorage.Shared.Domains.Player.ProfileCache)
local SessionManager = require(ReplicatedStorage.Shared.Domains.Player.SessionManager)
local AutoSaveManager = require(ReplicatedStorage.Shared.Domains.Player.AutoSaveManager)
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
	AddCoins: (self: PlayerServiceInstance, userId: number, amount: number, reason: string) -> (),
	RemoveCoins: (self: PlayerServiceInstance, userId: number, amount: number, reason: string) -> boolean,
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

	local success, errorMsg = self._dataService:SaveProfile(profile)
	if success then
		self._signals.ProfileSaved:Fire(profile)
	end

	return success, errorMsg
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
		self._sessions:CreateSession(player.UserId, player.UserId)
	end
end

function PlayerService:_OnPlayerRemoving(player: Player): ()
	local profile = self._cache:Get(player.UserId)
	if profile ~= nil then
		self:SaveProfile(player.UserId)
	end

	self._cache:Remove(player.UserId)
	self._sessions:DestroySession(player.UserId)
	self._autoSave:UnregisterProfile(player.UserId)
end

return PlayerService