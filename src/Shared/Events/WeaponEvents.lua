--!strict

local WeaponEvents = table.freeze({
    WeaponFired = "WeaponFired",
    WeaponReloadStarted = "WeaponReloadStarted",
    WeaponReloadCompleted = "WeaponReloadCompleted",
    WeaponEquipped = "WeaponEquipped",
    WeaponUnequipped = "WeaponUnequipped",
    AmmoUpdated = "AmmoUpdated",
    MagazineEmpty = "MagazineEmpty",
    WeaponHit = "WeaponHit",
    WeaponMissed = "WeaponMissed",
    WeaponModeChanged = "WeaponModeChanged",
    WeaponXPChanged = "WeaponXPChanged",
})

return WeaponEvents
