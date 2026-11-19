--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CombatConfig = require(ReplicatedStorage.Shared.Config.CombatConfig)
local CombatEvents = require(ReplicatedStorage.Shared.Events.CombatEvents)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local DeathService = {}
DeathService.__index = DeathService

type DeathServiceInstance = {
    Name: string,
    _killService: any,
    _assistService: any,
    _respawnService: any,
    _rewardService: any,
    _combatService: any,
    _signals: any,
    Init: (self: DeathServiceInstance) -> (),
    Start: (self: DeathServiceInstance) -> (),
    Destroy: (self: DeathServiceInstance) -> (),
    SetDependencies: (self: DeathServiceInstance, killService: any, assistService: any, respawnService: any, rewardService: any, combatService: any) -> (),
    HandleDeath: (self: DeathServiceInstance, victim: Player, attacker: Player?, weaponName: string?, isHeadshot: boolean) -> (),
}

function DeathService.new(): DeathServiceInstance
    local self = setmetatable({
        Name = "DeathService",
        _killService = nil,
        _assistService = nil,
        _respawnService = nil,
        _rewardService = nil,
        _combatService = nil,
        _signals = nil,
    }, DeathService)

    return self
end

function DeathService:Init(): ()
end

function DeathService:Start(): ()
end

function DeathService:Destroy(): ()
end

function DeathService:SetDependencies(killService: any, assistService: any, respawnService: any, rewardService: any, combatService: any): ()
    self._killService = killService
    self._assistService = assistService
    self._respawnService = respawnService
    self._rewardService = rewardService
    self._combatService = combatService
end

function DeathService:HandleDeath(victim: Player, attacker: Player?, weaponName: string?, isHeadshot: boolean): ()
    assert(victim ~= nil, "Victim cannot be nil")

    if self._killService ~= nil and attacker and attacker ~= victim then
        self._killService:RegisterKill(attacker, victim, weaponName, isHeadshot)
    end

    if self._assistService ~= nil then
        self._assistService:RegisterAssist(victim, attacker)
    end

    if self._rewardService ~= nil and attacker and attacker ~= victim then
        local profile = self._combatService and self._combatService._playerService and self._combatService._playerService:GetProfile(attacker.UserId)
        if profile ~= nil then
            self._rewardService:AwardKill(profile, self._combatService and self._combatService:GetMode() or "")
        end
    end

    if self._combatService ~= nil then
        if attacker and attacker ~= victim then
            self._combatService._signals.PlayerKilled:Fire(attacker, victim)
        end
        self._combatService._signals.PlayerDied:Fire(victim, attacker, weaponName, isHeadshot)
    end

    if self._respawnService ~= nil then
        self._respawnService:ScheduleRespawn(victim)
    end
end

return DeathService
