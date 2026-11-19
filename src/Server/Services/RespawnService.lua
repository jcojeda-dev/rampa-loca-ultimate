--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CombatConfig = require(ReplicatedStorage.Shared.Config.CombatConfig)
local MatchConfig = require(ReplicatedStorage.Shared.Config.MatchConfig)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local RespawnService = {}
RespawnService.__index = RespawnService

type RespawnServiceInstance = {
    Name: string,
    _spawnService: any,
    _spectatorService: any,
    _playerService: any,
    _pendingRespawns: {[number]: number},
    _spawnProtection: {[number]: number},
    Init: (self: RespawnServiceInstance) -> (),
    Start: (self: RespawnServiceInstance) -> (),
    Destroy: (self: RespawnServiceInstance) -> (),
    SetDependencies: (self: RespawnServiceInstance, spawnService: any, spectatorService: any, playerService: any) -> (),
    ScheduleRespawn: (self: RespawnServiceInstance, player: Player) -> (),
    Update: (self: RespawnServiceInstance, dt: number) -> (),
    IsProtected: (self: RespawnServiceInstance, player: Player) -> boolean,
}

function RespawnService.new(): RespawnServiceInstance
    local self = setmetatable({
        Name = "RespawnService",
        _spawnService = nil,
        _spectatorService = nil,
        _playerService = nil,
        _pendingRespawns = {},
        _spawnProtection = {},
    }, RespawnService)

    return self
end

function RespawnService:Init(): ()
end

function RespawnService:Start(): ()
    RunService.Heartbeat:Connect(function(dt)
        self:Update(dt)
    end)
end

function RespawnService:Destroy(): ()
    self._pendingRespawns = {}
    self._spawnProtection = {}
end

function RespawnService:SetDependencies(spawnService: any, spectatorService: any, playerService: any): ()
    self._spawnService = spawnService
    self._spectatorService = spectatorService
    self._playerService = playerService
end

function RespawnService:ScheduleRespawn(player: Player): ()
    assert(player ~= nil, "Player cannot be nil")
    self._pendingRespawns[player.UserId] = CombatConfig.RespawnDelay

    if self._spectatorService ~= nil then
        self._spectatorService:EnterSpectator(player)
    end
end

function RespawnService:Update(dt: number): ()
    for userId, remaining in pairs(self._pendingRespawns) do
        remaining = math.max(0, remaining - dt)
        self._pendingRespawns[userId] = remaining

        if remaining <= 0 then
            self._pendingRespawns[userId] = nil
            local player = game:GetService("Players"):GetPlayerByUserId(userId)
            if player then
                if self._spectatorService ~= nil then
                    self._spectatorService:ExitSpectator(player)
                end
                if self._spawnService ~= nil then
                    self._spawnService:RespawnPlayer(player, MatchConfig.SpawnTypes.Lobby)
                end
                if CombatConfig.SpawnProtection.Enabled then
                    self._spawnProtection[userId] = os.clock() + CombatConfig.SpawnProtection.Duration
                end
            end
        end
    end

    for userId, expiresAt in pairs(self._spawnProtection) do
        if os.clock() >= expiresAt then
            self._spawnProtection[userId] = nil
        end
    end
end

function RespawnService:IsProtected(player: Player): boolean
    if not CombatConfig.SpawnProtection.Enabled then
        return false
    end

    local expiresAt = self._spawnProtection[player.UserId]
    return expiresAt ~= nil and os.clock() < expiresAt
end

return RespawnService
