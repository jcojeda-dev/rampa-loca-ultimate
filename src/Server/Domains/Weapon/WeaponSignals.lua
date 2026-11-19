--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Shared.Modules.Signal)

local WeaponSignals = {}
WeaponSignals.__index = WeaponSignals

type SignalType = typeof(Signal.new())

type WeaponSignalsInstance = {
    WeaponFired: SignalType,
    WeaponReloadStarted: SignalType,
    WeaponReloadCompleted: SignalType,
    WeaponEquipped: SignalType,
    WeaponUnequipped: SignalType,
    AmmoUpdated: SignalType,
    MagazineEmpty: SignalType,
    WeaponHit: SignalType,
    WeaponMissed: SignalType,
    WeaponModeChanged: SignalType,
    WeaponXPChanged: SignalType,
    Destroy: (self: WeaponSignalsInstance) -> (),
}

function WeaponSignals.new(): WeaponSignalsInstance
    local self = setmetatable({
        WeaponFired = Signal.new(),
        WeaponReloadStarted = Signal.new(),
        WeaponReloadCompleted = Signal.new(),
        WeaponEquipped = Signal.new(),
        WeaponUnequipped = Signal.new(),
        AmmoUpdated = Signal.new(),
        MagazineEmpty = Signal.new(),
        WeaponHit = Signal.new(),
        WeaponMissed = Signal.new(),
        WeaponModeChanged = Signal.new(),
        WeaponXPChanged = Signal.new(),
    }, WeaponSignals)

    return self
end

function WeaponSignals:Destroy(): ()
    self.WeaponFired:Destroy()
    self.WeaponReloadStarted:Destroy()
    self.WeaponReloadCompleted:Destroy()
    self.WeaponEquipped:Destroy()
    self.WeaponUnequipped:Destroy()
    self.AmmoUpdated:Destroy()
    self.MagazineEmpty:Destroy()
    self.WeaponHit:Destroy()
    self.WeaponMissed:Destroy()
    self.WeaponModeChanged:Destroy()
    self.WeaponXPChanged:Destroy()
end

return WeaponSignals
