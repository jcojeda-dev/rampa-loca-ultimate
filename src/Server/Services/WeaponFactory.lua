--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfig = require(ReplicatedStorage.Shared.Config.WeaponConfig)

local WeaponFactory = {}
WeaponFactory.__index = WeaponFactory

type WeaponInstance = {
    Name: string,
    Type: string,
    Damage: number,
    Range: number,
    HeadshotMultiplier: number,
    ReloadTime: number,
    Magazine: number,
    ReserveAmmo: number,
    FireRate: number,
    Spread: number,
    Recoil: number,
    ADSMultiplier: number,
    SupportedFireModes: {string},
    BurstCount: number,
    CurrentAmmo: number,
    ReserveAmmoCount: number,
    CurrentFireMode: string,
    XP: number,
    Level: number,
}

type WeaponFactoryInstance = {
    Name: string,
    _repository: any,
    Init: (self: WeaponFactoryInstance) -> (),
    Start: (self: WeaponFactoryInstance) -> (),
    Destroy: (self: WeaponFactoryInstance) -> (),
    SetDependencies: (self: WeaponFactoryInstance, repository: any) -> (),
    CreateWeapon: (self: WeaponFactoryInstance, weaponName: string) -> WeaponInstance,
}

function WeaponFactory.new(): WeaponFactoryInstance
    local self = setmetatable({
        Name = "WeaponFactory",
        _repository = nil,
    }, WeaponFactory)

    return self
end

function WeaponFactory:Init(): ()
end

function WeaponFactory:Start(): ()
end

function WeaponFactory:Destroy(): ()
    self._repository = nil
end

function WeaponFactory:SetDependencies(repository: any): ()
    self._repository = repository
end

function WeaponFactory:CreateWeapon(weaponName: string)
    assert(type(weaponName) == "string" and weaponName ~= "", "Weapon name must be a valid string")
    assert(self._repository ~= nil, "WeaponRepository not configured")

    local template = self._repository:GetWeaponTemplate(weaponName)
    assert(template ~= nil, "Weapon template not found")

    local weapon = {
        Name = template.Name,
        Type = template.Type,
        Damage = template.Damage,
        Range = template.Range,
        HeadshotMultiplier = template.HeadshotMultiplier,
        ReloadTime = template.ReloadTime,
        Magazine = template.Magazine,
        ReserveAmmo = template.ReserveAmmo,
        FireRate = template.FireRate,
        Spread = template.Spread,
        Recoil = template.Recoil,
        ADSMultiplier = template.ADSMultiplier,
        SupportedFireModes = template.SupportedFireModes,
        BurstCount = template.BurstCount,
        CurrentAmmo = template.Magazine,
        ReserveAmmoCount = template.ReserveAmmo,
        CurrentFireMode = template.SupportedFireModes[1] or WeaponConfig.Defaults.SupportedFireModes[1],
        XP = 0,
        Level = 1,
    }

    return weapon
end

return WeaponFactory
