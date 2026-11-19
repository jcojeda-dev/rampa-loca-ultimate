--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FireMode = require(ReplicatedStorage.Shared.Enums.FireMode)

local FireModeService = {}
FireModeService.__index = FireModeService

type FireModeServiceInstance = {
    Name: string,
    Init: (self: FireModeServiceInstance) -> (),
    Start: (self: FireModeServiceInstance) -> (),
    Destroy: (self: FireModeServiceInstance) -> (),
    SetFireMode: (self: FireModeServiceInstance, weapon: table, fireMode: string) -> boolean,
    GetFireMode: (self: FireModeServiceInstance, weapon: table) -> string,
    IsFireModeSupported: (self: FireModeServiceInstance, weapon: table, fireMode: string) -> boolean,
}

function FireModeService.new(): FireModeServiceInstance
    local self = setmetatable({
        Name = "FireModeService",
    }, FireModeService)

    return self
end

function FireModeService:Init(): ()
end

function FireModeService:Start(): ()
end

function FireModeService:Destroy(): ()
end

function FireModeService:IsFireModeSupported(weapon: table, fireMode: string): boolean
    assert(type(weapon) == "table", "Weapon must be a table")
    assert(type(fireMode) == "string" and fireMode ~= "", "Fire mode must be a valid string")

    for _, supported in ipairs(weapon.SupportedFireModes) do
        if supported == fireMode then
            return true
        end
    end

    return false
end

function FireModeService:SetFireMode(weapon: table, fireMode: string): boolean
    if self:IsFireModeSupported(weapon, fireMode) then
        weapon.CurrentFireMode = fireMode
        return true
    end
    return false
end

function FireModeService:GetFireMode(weapon: table): string
    assert(type(weapon) == "table", "Weapon must be a table")
    return weapon.CurrentFireMode
end

return FireModeService
