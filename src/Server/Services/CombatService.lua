--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatEvents = require(ReplicatedStorage.Shared.Events.CombatEvents)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)
local CombatSignals = require(script.Parent.Parent.Domains.Combat.CombatSignals)

local CombatService = {}
CombatService.__index = CombatService

type CombatServiceInstance = {
    Name: string,
    _mode: string,
    _damageService: any,
    _healthService: any,
    _deathService: any,
    _respawnService: any,
    _killService: any,
    _assistService: any,
    _headshotService: any,
    _spectatorService: any,
    _playerService: any,
    _teamService: any,
    _rewardService: any,
    _signals: any,
    _events: any,
    _mode: string,
    Init: (self: CombatServiceInstance) -> (),
    Start: (self: CombatServiceInstance) -> (),
    Destroy: (self: CombatServiceInstance) -> (),
    SetDependencies: (self: CombatServiceInstance, damageService: any, healthService: any, deathService: any, respawnService: any, killService: any, assistService: any, headshotService: any, spectatorService: any, playerService: any, teamService: any, rewardService: any) -> (),
    ApplyDamage: (self: CombatServiceInstance, attacker: Player, victim: Player, bodyPart: string, baseDamage: number, weaponName: string?) -> (),
    GetSignals: (self: CombatServiceInstance) -> any,
}

function CombatService.new(): CombatServiceInstance
    local self = setmetatable({
        Name = "CombatService",
        _damageService = nil,
        _healthService = nil,
        _deathService = nil,
        _respawnService = nil,
        _killService = nil,
        _assistService = nil,
        _headshotService = nil,
        _spectatorService = nil,
        _playerService = nil,
        _teamService = nil,
        _rewardService = nil,
        _signals = CombatSignals.new(),
        _events = CombatEvents,
        _mode = "1v1",
    }, CombatService)

    return self
end

function CombatService:Init(): ()
    Logger:Info("Initializing CombatService")
end

function CombatService:Start(): ()
    Logger:Info("Starting CombatService")
end

function CombatService:Destroy(): ()
    self._signals:Destroy()
end

function CombatService:SetDependencies(damageService: any, healthService: any, deathService: any, respawnService: any, killService: any, assistService: any, headshotService: any, spectatorService: any, playerService: any, teamService: any, rewardService: any): ()
    self._damageService = damageService
    self._healthService = healthService
    self._deathService = deathService
    self._respawnService = respawnService
    self._killService = killService
    self._assistService = assistService
    self._headshotService = headshotService
    self._spectatorService = spectatorService
    self._playerService = playerService
    self._teamService = teamService
    self._rewardService = rewardService
end

function CombatService:GetSignals(): any
    return self._signals
end

function CombatService:SetMode(mode: string): ()
    assert(type(mode) == "string" and mode ~= "", "Mode must be a non-empty string")
    self._mode = mode
end

function CombatService:GetMode(): string
    return self._mode
end

function CombatService:ApplyDamage(attacker: Player, victim: Player, bodyPart: string, baseDamage: number, weaponName: string?): ()
    assert(attacker ~= nil, "Attacker cannot be nil")
    assert(victim ~= nil, "Victim cannot be nil")
    assert(type(baseDamage) == "number" and baseDamage >= 0, "Base damage must be a non-negative number")

    if self._respawnService ~= nil and self._respawnService:IsProtected(victim) then
        self._signals.DamageBlocked:Fire(attacker, victim, CombatEvents.SpawnProtected)
        return
    end

    local damage, isHeadshot, blocked, reason = self._damageService:CalculateDamage(attacker, victim, baseDamage, bodyPart)
    if blocked then
        self._signals.DamageBlocked:Fire(attacker, victim, reason)
        return
    end

    if damage <= 0 then
        self._signals.DamageBlocked:Fire(attacker, victim, "NoDamage")
        return
    end

    if self._headshotService ~= nil then
        isHeadshot = self._headshotService:ProcessHit(attacker, victim, bodyPart, damage)
    end

    if self._assistService ~= nil then
        self._assistService:RegisterDamageContribution(attacker, victim, damage)
    end

    local remainingHealth = self._healthService:ApplyDamage(victim, damage)
    self._signals.DamageApplied:Fire(attacker, victim, damage, remainingHealth, weaponName)

    if remainingHealth <= 0 then
        if self._deathService ~= nil then
            self._deathService:HandleDeath(victim, attacker, weaponName, isHeadshot)
        end
    end
end

return CombatService
