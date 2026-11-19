--!strict

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MatchConfig = require(ReplicatedStorage.Shared.Config.MatchConfig)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local SpawnService = {}
SpawnService.__index = SpawnService

type SpawnServiceInstance = {
	Name: string,
	_spawnPoints: {[string]: {SpawnLocation}},
	Init: (self: SpawnServiceInstance) -> (),
	Start: (self: SpawnServiceInstance) -> (),
	Destroy: (self: SpawnServiceInstance) -> (),
	RefreshSpawnLocations: (self: SpawnServiceInstance) -> (),
	GetSpawnPoints: (self: SpawnServiceInstance, spawnType: string) -> {SpawnLocation},
	GetSpawnPoint: (self: SpawnServiceInstance, spawnType: string, teamName: string?) -> SpawnLocation?,
	RespawnPlayer: (self: SpawnServiceInstance, player: Player, spawnType: string, teamName: string?) -> (),
	RespawnPlayers: (self: SpawnServiceInstance, players: {Player}, spawnType: string, teamName: string?) -> (),
}

function SpawnService.new(): SpawnServiceInstance
	local self = setmetatable({
		Name = "SpawnService",
		_spawnPoints = {},
	}, SpawnService)

	return self
end

function SpawnService:Init(): ()
	self:RefreshSpawnLocations()
	Logger:Info("Initializing SpawnService")
end

function SpawnService:Start(): ()
	Logger:Info("Starting SpawnService")
end

function SpawnService:Destroy(): ()
	self._spawnPoints = {}
end

function SpawnService:RefreshSpawnLocations(): ()
	self._spawnPoints = {}

	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("SpawnLocation") then
			local spawnType = self:_ClassifySpawnLocation(descendant)
			if self._spawnPoints[spawnType] == nil then
				self._spawnPoints[spawnType] = {}
			end
			table.insert(self._spawnPoints[spawnType], descendant)
		end
	end
end

function SpawnService:GetSpawnPoints(spawnType: string): {SpawnLocation}
	assert(type(spawnType) == "string" and spawnType ~= "", "Spawn type must be a non-empty string")
	return self._spawnPoints[spawnType] or {}
end

function SpawnService:GetSpawnPoint(spawnType: string, teamName: string?): SpawnLocation?
	assert(type(spawnType) == "string" and spawnType ~= "", "Spawn type must be a non-empty string")

	local points = self:GetSpawnPoints(spawnType)
	if #points == 0 and teamName ~= nil then
		points = self:GetSpawnPoints(teamName)
	end

	if #points == 0 then
		return nil
	end

	return points[math.random(1, #points)]
end

function SpawnService:RespawnPlayer(player: Player, spawnType: string, teamName: string?): ()
	assert(player ~= nil, "Player cannot be nil")
	assert(type(spawnType) == "string" and spawnType ~= "", "Spawn type must be a non-empty string")

	local spawnPoint = self:GetSpawnPoint(spawnType, teamName)
	if spawnPoint == nil then
		return
	end

	player.RespawnLocation = spawnPoint
	if player.Character ~= nil then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root ~= nil then
			root.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
		end
	else
		player:LoadCharacter()
	end
end

function SpawnService:RespawnPlayers(players: {Player}, spawnType: string, teamName: string?): ()
	for _, player in ipairs(players) do
		self:RespawnPlayer(player, spawnType, teamName)
	end
end

function SpawnService:_ClassifySpawnLocation(spawnLocation: SpawnLocation): string
	local name = string.lower(spawnLocation.Name)
	if string.find(name, "lobby") then
		return MatchConfig.SpawnTypes.Lobby
	end
	if string.find(name, "red") then
		return MatchConfig.SpawnTypes.Red
	end
	if string.find(name, "blue") then
		return MatchConfig.SpawnTypes.Blue
	end
	if string.find(name, "spectator") then
		return MatchConfig.SpawnTypes.Spectator
	end

	return MatchConfig.SpawnTypes.Lobby
end

return SpawnService
