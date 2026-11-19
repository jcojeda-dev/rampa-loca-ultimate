--!strict

local FireMode = require(script.Parent.Parent.Enums.FireMode)

local WeaponConfig = {}

WeaponConfig.FireModes = FireMode

WeaponConfig.WeaponTypes = {
    Pistol = "Pistol",
    Sniper = "Sniper",
    Shotgun = "Shotgun",
    SMG = "SMG",
    Rifle = "Rifle",
}

WeaponConfig.Defaults = {
    Damage = 25,
    Range = 80,
    HeadshotMultiplier = 2,
    ReloadTime = 2,
    Magazine = 12,
    ReserveAmmo = 36,
    FireRate = 400,
    Spread = 2,
    Recoil = 1,
    ADSMultiplier = 0.6,
    SupportedFireModes = {FireMode.Single, FireMode.Semi},
    BurstCount = 3,
}

WeaponConfig.Weapons = {
    Pistol = {
        Name = "Pistol",
        Type = WeaponConfig.WeaponTypes.Pistol,
        Damage = 30,
        Range = 70,
        HeadshotMultiplier = 2,
        ReloadTime = 1.8,
        Magazine = 12,
        ReserveAmmo = 48,
        FireRate = 320,
        Spread = 2.5,
        Recoil = 1.4,
        ADSMultiplier = 0.55,
        SupportedFireModes = {FireMode.Single, FireMode.Semi},
        BurstCount = 0,
    },
    Sniper = {
        Name = "Sniper",
        Type = WeaponConfig.WeaponTypes.Sniper,
        Damage = 110,
        Range = 250,
        HeadshotMultiplier = 3,
        ReloadTime = 2.6,
        Magazine = 5,
        ReserveAmmo = 20,
        FireRate = 45,
        Spread = 0.75,
        Recoil = 5,
        ADSMultiplier = 0.2,
        SupportedFireModes = {FireMode.Single},
        BurstCount = 0,
    },
}

WeaponConfig.Progression = {
    XPPerKill = 10,
    XPPerHeadshot = 15,
    LevelCap = 50,
}

return WeaponConfig
