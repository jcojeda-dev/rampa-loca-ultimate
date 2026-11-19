--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MatchConfig = require(ReplicatedStorage.Shared.Config.MatchConfig)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local HealthService = {}
HealthService.__index = HealthService

type HealthServiceInstance = {
    Name: string,
    Init: (self: HealthServiceInstance) -> (),
    Start: (self: HealthServiceInstance) -> (),
    Destroy: (self: HealthServiceInstance) -> (),
    ApplyDamage: (self: HealthServiceInstance, victim: Player, damage: number) -> number,
    GetHealth: (self: HealthServiceInstance, victim: Player) -> number,
}

function HealthService.new(): HealthServiceInstance
    local self = setmetatable({
        Name = "HealthService",
    }, HealthService)

    return self
end

function HealthService:Init(): ()
end

function HealthService:Start(): ()
end

function HealthService:Destroy(): ()
end

function HealthService:ApplyDamage(victim: Player, damage: number): number
    assert(victim ~= nil, "Victim cannot be nil")
    assert(type(damage) == "number" and damage >= 0, "Damage must be a non-negative number")

    local humanoid = victim.Character and victim.Character:FindFirstChildOfClass("Humanoid")
    if humanoid == nil then
        return 0
    end

    local newHealth = math.max(0, humanoid.Health - damage)
    humanoid:TakeDamage(damage)
    return newHealth
end

function HealthService:GetHealth(victim: Player): number
    local humanoid = victim.Character and victim.Character:FindFirstChildOfClass("Humanoid")
    if humanoid == nil then
        return 0
    end

    return humanoid.Health
end

return HealthService
