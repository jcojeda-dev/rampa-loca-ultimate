--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatConfig = require(ReplicatedStorage.Shared.Config.CombatConfig)

local DamageService = {}
DamageService.__index = DamageService

type DamageServiceInstance = {
    Name: string,
    _teamService: any,
    Init: (self: DamageServiceInstance) -> (),
    Start: (self: DamageServiceInstance) -> (),
    Destroy: (self: DamageServiceInstance) -> (),
    SetDependencies: (self: DamageServiceInstance, teamService: any) -> (),
    CalculateDamage: (self: DamageServiceInstance, attacker: Player, victim: Player, baseDamage: number, bodyPart: string) -> (number, boolean, boolean, string?),
}

function DamageService.new(): DamageServiceInstance
    local self = setmetatable({
        Name = "DamageService",
        _teamService = nil,
    }, DamageService)

    return self
end

function DamageService:Init(): ()
end

function DamageService:Start(): ()
end

function DamageService:Destroy(): ()
end

function DamageService:SetDependencies(teamService: any): ()
    self._teamService = teamService
end

function DamageService:_IsSameTeam(attacker: Player, victim: Player): boolean
    if self._teamService == nil then
        return false
    end

    local attackerTeam = self._teamService:GetTeamForPlayer(attacker)
    local victimTeam = self._teamService:GetTeamForPlayer(victim)

    return attackerTeam ~= nil and attackerTeam == victimTeam
end

function DamageService:CalculateDamage(attacker: Player, victim: Player, baseDamage: number, bodyPart: string): (number, boolean, boolean, string?)
    assert(attacker ~= nil, "Attacker cannot be nil")
    assert(victim ~= nil, "Victim cannot be nil")
    assert(type(baseDamage) == "number" and baseDamage >= 0, "Base damage must be non-negative")

    local isHeadshot = type(bodyPart) == "string" and bodyPart:lower() == "head"
    local damage = baseDamage

    if isHeadshot then
        damage = damage * CombatConfig.HeadshotMultiplier
    end

    if attacker ~= victim and self:_IsSameTeam(attacker, victim) then
        if not CombatConfig.FriendlyFire.Enabled then
            return 0, false, true, "FriendlyFireDisabled"
        end

        if not CombatConfig.TeamDamage.Enabled then
            return 0, false, true, "TeamDamageDisabled"
        end

        damage = damage * CombatConfig.TeamDamage.DamageMultiplier
    end

    return math.max(0, damage), isHeadshot, false, nil
end

return DamageService
