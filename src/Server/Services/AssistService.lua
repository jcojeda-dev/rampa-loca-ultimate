--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatConfig = require(ReplicatedStorage.Shared.Config.CombatConfig)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local AssistService = {}
AssistService.__index = AssistService

type AssistRecord = {
    TotalDamage: number,
    LastHit: number,
}

type AssistServiceInstance = {
    Name: string,
    _damageRecords: {[number]: {[number]: AssistRecord}},
    _assistWindow: number,
    _playerService: any,
    _combatService: any,
    Init: (self: AssistServiceInstance) -> (),
    Start: (self: AssistServiceInstance) -> (),
    Destroy: (self: AssistServiceInstance) -> (),
    SetDependencies: (self: AssistServiceInstance, playerService: any, combatService: any) -> (),
    RegisterDamageContribution: (self: AssistServiceInstance, attacker: Player, victim: Player, damage: number) -> (),
    RegisterAssist: (self: AssistServiceInstance, victim: Player, killer: Player?) -> (),
}

function AssistService.new(): AssistServiceInstance
    local self = setmetatable({
        Name = "AssistService",
        _damageRecords = {},
        _assistWindow = CombatConfig.AssistTimeWindow,
        _playerService = nil,
        _combatService = nil,
    }, AssistService)

    return self
end

function AssistService:Init(): ()
end

function AssistService:Start(): ()
end

function AssistService:Destroy(): ()
    self._damageRecords = {}
end

function AssistService:SetDependencies(playerService: any, combatService: any): ()
    self._playerService = playerService
    self._combatService = combatService
end

function AssistService:_getVictimRecords(victim: Player)
    if victim == nil then
        return nil
    end

    if self._damageRecords[victim.UserId] == nil then
        self._damageRecords[victim.UserId] = {}
    end

    return self._damageRecords[victim.UserId]
end

function AssistService:RegisterDamageContribution(attacker: Player, victim: Player, damage: number): ()
    assert(attacker ~= nil, "Attacker cannot be nil")
    assert(victim ~= nil, "Victim cannot be nil")
    assert(type(damage) == "number" and damage > 0, "Damage must be positive")

    if attacker == victim then
        return
    end

    local victimRecords = self:_getVictimRecords(victim)
    local attackerId = attacker.UserId
    local now = os.time()
    local record = victimRecords[attackerId]

    if record == nil then
        record = { TotalDamage = 0, LastHit = now }
        victimRecords[attackerId] = record
    end

    record.TotalDamage += damage
    record.LastHit = now
end

function AssistService:RegisterAssist(victim: Player, killer: Player?): ()
    assert(victim ~= nil, "Victim cannot be nil")

    local victimRecords = self._damageRecords[victim.UserId]
    if victimRecords == nil then
        return
    end

    local now = os.time()
    for attackerId, record in pairs(victimRecords) do
        if killer and attackerId == killer.UserId then
            continue
        end

        if now - record.LastHit <= self._assistWindow and record.TotalDamage > 0 then
            local attacker = game:GetService("Players"):GetPlayerByUserId(attackerId)
            if attacker and self._playerService then
                local profile = self._playerService:GetProfile(attacker.UserId)
                if profile then
                    profile.Stats.Assists += 1
                    profile.Statistics.Assists = profile.Stats.Assists
                    if self._combatService then
                        self._combatService._signals.PlayerAssisted:Fire(attacker, victim, record.TotalDamage)
                    end
                end
            end
        end
    end

    self._damageRecords[victim.UserId] = nil
end

return AssistService
