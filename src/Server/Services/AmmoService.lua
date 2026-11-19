--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfig = require(ReplicatedStorage.Shared.Config.WeaponConfig)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local AmmoService = {}
AmmoService.__index = AmmoService

type AmmoState = {
    Magazine: number,
    Reserve: number,
    MagazineCapacity: number,
}

type AmmoServiceInstance = {
    Name: string,
    Init: (self: AmmoServiceInstance) -> (),
    Start: (self: AmmoServiceInstance) -> (),
    Destroy: (self: AmmoServiceInstance) -> (),
    CreateAmmoState: (self: AmmoServiceInstance, weapon: table) -> AmmoState,
    CanFire: (self: AmmoServiceInstance, ammoState: AmmoState) -> boolean,
    ConsumeAmmo: (self: AmmoServiceInstance, ammoState: AmmoState, count: number) -> (),
    CanReload: (self: AmmoServiceInstance, ammoState: AmmoState) -> boolean,
    Reload: (self: AmmoServiceInstance, ammoState: AmmoState, weapon: table) -> number,
}

function AmmoService.new(): AmmoServiceInstance
    local self = setmetatable({
        Name = "AmmoService",
    }, AmmoService)

    return self
end

function AmmoService:Init(): ()
end

function AmmoService:Start(): ()
end

function AmmoService:Destroy(): ()
end

function AmmoService:CreateAmmoState(weapon: table): AmmoState
    assert(type(weapon) == "table", "Weapon must be a table")
    return {
        Magazine = weapon.Magazine,
        Reserve = weapon.ReserveAmmo,
        MagazineCapacity = weapon.Magazine,
    }
end

function AmmoService:CanFire(ammoState: AmmoState): boolean
    assert(ammoState ~= nil, "Ammo state cannot be nil")
    return ammoState.Magazine > 0
end

function AmmoService:ConsumeAmmo(ammoState: AmmoState, count: number): ()
    assert(ammoState ~= nil, "Ammo state cannot be nil")
    assert(type(count) == "number" and count > 0, "Count must be positive")
    ammoState.Magazine = math.max(0, ammoState.Magazine - count)
end

function AmmoService:CanReload(ammoState: AmmoState): boolean
    assert(ammoState ~= nil, "Ammo state cannot be nil")
    local capacity = ammoState.MagazineCapacity or 0
    return capacity > 0 and ammoState.Magazine < capacity and ammoState.Reserve > 0
end

function AmmoService:Reload(ammoState: AmmoState, weapon: table): number
    assert(ammoState ~= nil, "Ammo state cannot be nil")
    assert(type(weapon) == "table", "Weapon must be a table")

    local required = weapon.Magazine - ammoState.Magazine
    local available = math.min(required, ammoState.Reserve)
    ammoState.Magazine += available
    ammoState.Reserve -= available
    return available
end

return AmmoService
