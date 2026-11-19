--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CombatConfig = require(ReplicatedStorage.Shared.Config.CombatConfig)
local CombatEvents = require(ReplicatedStorage.Shared.Events.CombatEvents)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local SpectatorService = {}
SpectatorService.__index = SpectatorService

type SpectatorServiceInstance = {
    Name: string,
    _spectators: {[number]: boolean},
    _signals: any,
    Init: (self: SpectatorServiceInstance) -> (),
    Start: (self: SpectatorServiceInstance) -> (),
    Destroy: (self: SpectatorServiceInstance) -> (),
    EnterSpectator: (self: SpectatorServiceInstance, player: Player) -> (),
    ExitSpectator: (self: SpectatorServiceInstance, player: Player) -> (),
    IsSpectator: (self: SpectatorServiceInstance, player: Player) -> boolean,
}

function SpectatorService.new(): SpectatorServiceInstance
    local self = setmetatable({
        Name = "SpectatorService",
        _spectators = {},
        _signals = nil,
    }, SpectatorService)

    return self
end

function SpectatorService:Init(): ()
end

function SpectatorService:Start(): ()
end

function SpectatorService:Destroy(): ()
    self._spectators = {}
end

function SpectatorService:EnterSpectator(player: Player): ()
    assert(player ~= nil, "Player cannot be nil")
    if not CombatConfig.SpectatorEnabled then
        return
    end

    self._spectators[player.UserId] = true
    self._signals = self._signals or {}
    if self._signals and self._signals.SpectatorEntered then
        self._signals.SpectatorEntered:Fire(player)
    end
end

function SpectatorService:ExitSpectator(player: Player): ()
    assert(player ~= nil, "Player cannot be nil")
    self._spectators[player.UserId] = nil
    if self._signals and self._signals.SpectatorExited then
        self._signals.SpectatorExited:Fire(player)
    end
end

function SpectatorService:IsSpectator(player: Player): boolean
    return player ~= nil and self._spectators[player.UserId] == true
end

return SpectatorService
