--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterConfig = require(ReplicatedStorage.Shared.Config.CharacterConfig)

local FallDamageService = {}
FallDamageService.__index = FallDamageService

type FallDamageServiceInstance = {
    Name: string,
    _combatService: any,
    Init: (self: FallDamageServiceInstance) -> (),
    Start: (self: FallDamageServiceInstance) -> (),
    Destroy: (self: FallDamageServiceInstance) -> (),
    SetDependencies: (self: FallDamageServiceInstance, combatService: any) -> (),
    GetFallDamage: (self: FallDamageServiceInstance, fallSpeed: number) -> number,
    ApplyFallDamage: (self: FallDamageServiceInstance, player: Player, fallSpeed: number) -> number,
}

function FallDamageService.new(): FallDamageServiceInstance
    local self = setmetatable({
        Name = "FallDamageService",
        _combatService = nil,
    }, FallDamageService)

    return self
end

function FallDamageService:Init(): ()
end

function FallDamageService:Start(): ()
end

function FallDamageService:Destroy(): ()
    self._combatService = nil
end

function FallDamageService:SetDependencies(combatService: any): ()
    self._combatService = combatService
end

function FallDamageService:GetFallDamage(fallSpeed: number): number
    assert(type(fallSpeed) == "number", "Fall speed must be a number")

    if fallSpeed < CharacterConfig.FallDamage.Threshold then
        return 0
    end

    local damage = (fallSpeed - CharacterConfig.FallDamage.Threshold) * CharacterConfig.FallDamage.Multiplier
    return math.min(damage, CharacterConfig.FallDamage.Cap)
end

function FallDamageService:ApplyFallDamage(player: Player, fallSpeed: number): number
    assert(player ~= nil, "Player cannot be nil")
    local damage = self:GetFallDamage(fallSpeed)
    if damage > 0 and self._combatService ~= nil then
        self._combatService:ApplyDamage(player, player, "Legs", damage, "FallDamage")
    end
    return damage
end

return FallDamageService
