--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfig = require(ReplicatedStorage.Shared.Config.WeaponConfig)

local WeaponRepository = {}
WeaponRepository.__index = WeaponRepository

type WeaponRepositoryInstance = {
    Name: string,
    Init: (self: WeaponRepositoryInstance) -> (),
    Start: (self: WeaponRepositoryInstance) -> (),
    Destroy: (self: WeaponRepositoryInstance) -> (),
    GetWeaponTemplate: (self: WeaponRepositoryInstance, weaponName: string) -> table?,
    GetAllWeaponTemplates: (self: WeaponRepositoryInstance) -> { [string]: table },
}

function WeaponRepository.new(): WeaponRepositoryInstance
    local self = setmetatable({
        Name = "WeaponRepository",
    }, WeaponRepository)

    return self
end

function WeaponRepository:Init(): ()
end

function WeaponRepository:Start(): ()
end

function WeaponRepository:Destroy(): ()
end

function WeaponRepository:GetWeaponTemplate(weaponName: string)
    assert(type(weaponName) == "string" and weaponName ~= "", "Weapon name must be a valid string")
    return WeaponConfig.Weapons[weaponName]
end

function WeaponRepository:GetAllWeaponTemplates()
    return WeaponConfig.Weapons
end

return WeaponRepository
