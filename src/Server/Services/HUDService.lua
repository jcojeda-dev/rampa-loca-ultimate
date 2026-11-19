--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Game = require(ReplicatedStorage.Shared.Core.Game)
local HUDEvents = require(ReplicatedStorage.Shared.Events.HUDEvents)

local HUDService = {}
HUDService.__index = HUDService

type HUDServiceInstance = {
    Name: string,
    _remoteEvent: RemoteEvent?,
    _ammoState: {[number]: table},
    _playerService: any,
    _weaponService: any,
    _combatService: any,
    _matchService: any,
    _gameStateService: any,
    _teamService: any,
    _healthService: any,
    Init: (self: HUDServiceInstance) -> (),
    Start: (self: HUDServiceInstance) -> (),
    Destroy: (self: HUDServiceInstance) -> (),
    PublishPlayerStats: (self: HUDServiceInstance, player: Player, stats: table) -> (),
    PublishMatchState: (self: HUDServiceInstance, player: Player, state: table) -> (),
    PublishKillFeed: (self: HUDServiceInstance, entry: table) -> (),
    PublishHitMarker: (self: HUDServiceInstance, player: Player) -> (),
    PublishCrosshairSpread: (self: HUDServiceInstance, player: Player, spread: number) -> (),
}

function HUDService.new(): HUDServiceInstance
    local self = setmetatable({
        Name = "HUDService",
        _remoteEvent = nil,
        _ammoState = {},
        _playerService = nil,
        _weaponService = nil,
        _combatService = nil,
        _matchService = nil,
        _gameStateService = nil,
        _teamService = nil,
        _healthService = nil,
    }, HUDService)

    return self
end

function HUDService:Init(): ()
    local remoteRegistry = Game:GetRemoteRegistry()
    assert(remoteRegistry, "RemoteRegistry is required for HUDService")
    self._remoteEvent = remoteRegistry:RegisterEvent("HUDUpdate")
end

function HUDService:Start(): ()
    self._playerService = Game:GetService("PlayerService")
    self._weaponService = Game:GetService("WeaponService")
    self._combatService = Game:GetService("CombatService")
    self._matchService = Game:GetService("MatchService")
    self._gameStateService = Game:GetService("GameStateService")
    self._teamService = Game:GetService("TeamService")
    self._healthService = Game:GetService("HealthService")

    if self._playerService then
        local signals = self._playerService:GetSignals()
        if signals and signals.ProfileLoaded then
            signals.ProfileLoaded:Connect(function(profile)
                local player = Players:GetPlayerByUserId(profile.UserId)
                if player then
                    self:_publishPlayerStats(player)
                end
            end)
        end

        if signals and signals.CoinsChanged then
            signals.CoinsChanged:Connect(function(profile)
                local player = Players:GetPlayerByUserId(profile.UserId)
                if player then
                    self:_publishPlayerStats(player)
                end
            end)
        end
    end

    if self._weaponService then
        local signals = self._weaponService:GetSignals()
        if signals and signals.AmmoUpdated then
            signals.AmmoUpdated:Connect(function(player, ammoState)
                if player then
                    self._ammoState[player.UserId] = ammoState
                    self:_publishPlayerStats(player)
                end
            end)
        end

        if signals and signals.WeaponFired then
            signals.WeaponFired:Connect(function(player)
                if player then
                    self:PublishCrosshairSpread(player, 18)
                    task.delay(0.16, function()
                        if player then
                            self:PublishCrosshairSpread(player, 0)
                        end
                    end)
                end
            end)
        end

        if signals and signals.WeaponHit then
            signals.WeaponHit:Connect(function(player)
                if player then
                    self:PublishHitMarker(player)
                end
            end)
        end
    end

    if self._combatService then
        local signals = self._combatService:GetSignals()
        if signals and signals.DamageApplied then
            signals.DamageApplied:Connect(function(attacker, victim)
                if victim then
                    self:_publishPlayerStats(victim)
                end
                if attacker then
                    self:PublishHitMarker(attacker)
                end
            end)
        end

        if signals and signals.PlayerKilled then
            signals.PlayerKilled:Connect(function(attacker, victim)
                if attacker and victim then
                    self:PublishKillFeed({ Attacker = attacker.Name, Victim = victim.Name })
                    self:_publishPlayerStats(attacker)
                end
            end)
        end
    end

    if self._matchService then
        local signals = self._matchService:GetSignals()
        if signals and signals.TimerTick then
            signals.TimerTick:Connect(function(remaining)
                self:_publishMatchStateToAll({ TimeRemaining = remaining })
            end)
        end

        if signals and signals.MatchStarted then
            signals.MatchStarted:Connect(function()
                self:_publishMatchStateToAll({})
            end)
        end

        if signals and signals.MatchEnded then
            signals.MatchEnded:Connect(function()
                self:_publishMatchStateToAll({})
            end)
        end
    end

    if self._gameStateService then
        local signals = self._gameStateService:GetSignals()
        if signals and signals.StateChanged then
            signals.StateChanged:Connect(function(_, newState)
                self:_publishMatchStateToAll({ MatchState = newState })
            end)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        self:_publishPlayerStats(player)
        self:_publishMatchStateToPlayer(player, {})
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        self:_publishPlayerStats(player)
        self:_publishMatchStateToPlayer(player, {})
    end
end

function HUDService:Destroy(): ()
    self._remoteEvent = nil
    self._ammoState = {}
    self._playerService = nil
    self._weaponService = nil
    self._combatService = nil
    self._matchService = nil
    self._gameStateService = nil
    self._teamService = nil
    self._healthService = nil
end

function HUDService:_fireClient(player: Player, payload: table): ()
    assert(player ~= nil, "Player is required")
    assert(payload ~= nil, "Payload is required")
    if self._remoteEvent then
        self._remoteEvent:FireClient(player, payload)
    end
end

function HUDService:PublishPlayerStats(player: Player, stats: table): ()
    self:_fireClient(player, { Event = HUDEvents.PlayerStatsUpdated, Payload = stats })
end

function HUDService:PublishMatchState(player: Player, state: table): ()
    self:_fireClient(player, { Event = HUDEvents.MatchStateUpdated, Payload = state })
end

function HUDService:PublishKillFeed(entry: table): ()
    if self._remoteEvent then
        self._remoteEvent:FireAllClients({ Event = HUDEvents.KillFeedEntry, Payload = entry })
    end
end

function HUDService:PublishHitMarker(player: Player): ()
    self:_fireClient(player, { Event = HUDEvents.HitMarker, Payload = {} })
end

function HUDService:PublishCrosshairSpread(player: Player, spread: number): ()
    self:_fireClient(player, { Event = HUDEvents.CrosshairSpreadUpdated, Payload = { Spread = spread } })
end

function HUDService:_buildPlayerState(player: Player): table
    local stats = {}
    if self._healthService then
        local ok, health = pcall(function()
            return self._healthService:GetHealth(player)
        end)
        if ok and type(health) == "number" then
            stats.Health = math.floor(health)
        end
    end

    local ammoState = self._ammoState[player.UserId]
    if ammoState then
        stats.Ammo = {
            Current = ammoState.Magazine or 0,
            Max = ammoState.Reserve or ammoState.Magazine or 0,
        }
    else
        stats.Ammo = { Current = 0, Max = 0 }
    end

    if self._playerService then
        local profile = self._playerService:GetProfile(player.UserId)
        if profile then
            stats.Coins = profile.Coins or 0
            stats.Kills = (profile.Stats and profile.Stats.Kills) or 0
        end
    end

    return stats
end

function HUDService:_publishPlayerStats(player: Player): ()
    if not player then
        return
    end
    local stats = self:_buildPlayerState(player)
    self:PublishPlayerStats(player, stats)
end

function HUDService:_buildMatchState(player: Player, overrides: table): table
    local state = {
        MatchState = "Desconocido",
        TimeRemaining = 0,
        TeamName = nil,
    }

    if self._gameStateService then
        state.MatchState = self._gameStateService:GetState()
    end

    if self._teamService then
        state.TeamName = self._teamService:GetTeamForPlayer(player)
    end

    for key, value in pairs(overrides) do
        state[key] = value
    end

    return state
end

function HUDService:_publishMatchStateToPlayer(player: Player, overrides: table): ()
    if not player then
        return
    end

    local state = self:_buildMatchState(player, overrides)
    self:PublishMatchState(player, state)
end

function HUDService:_publishMatchStateToAll(overrides: table): ()
    for _, player in ipairs(Players:GetPlayers()) do
        self:_publishMatchStateToPlayer(player, overrides)
    end
end

return HUDService
