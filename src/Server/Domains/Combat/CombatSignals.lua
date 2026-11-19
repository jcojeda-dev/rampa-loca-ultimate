--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Shared.Modules.Signal)

local CombatSignals = {}
CombatSignals.__index = CombatSignals

type SignalType = typeof(Signal.new())

type CombatSignalsInstance = {
    DamageApplied: SignalType,
    DamageBlocked: SignalType,
    PlayerKilled: SignalType,
    PlayerDied: SignalType,
    PlayerAssisted: SignalType,
    PlayerHeadshotted: SignalType,
    Respawned: SignalType,
    SpawnProtected: SignalType,
    SpectatorEntered: SignalType,
    SpectatorExited: SignalType,
    CombatEvent: SignalType,
    Destroy: (self: CombatSignalsInstance) -> (),
}

function CombatSignals.new(): CombatSignalsInstance
    local self = setmetatable({
        DamageApplied = Signal.new(),
        DamageBlocked = Signal.new(),
        PlayerKilled = Signal.new(),
        PlayerDied = Signal.new(),
        PlayerAssisted = Signal.new(),
        PlayerHeadshotted = Signal.new(),
        Respawned = Signal.new(),
        SpawnProtected = Signal.new(),
        SpectatorEntered = Signal.new(),
        SpectatorExited = Signal.new(),
        CombatEvent = Signal.new(),
    }, CombatSignals)

    return self
end

function CombatSignals:Destroy(): ()
    self.DamageApplied:Destroy()
    self.DamageBlocked:Destroy()
    self.PlayerKilled:Destroy()
    self.PlayerDied:Destroy()
    self.PlayerAssisted:Destroy()
    self.PlayerHeadshotted:Destroy()
    self.Respawned:Destroy()
    self.SpawnProtected:Destroy()
    self.SpectatorEntered:Destroy()
    self.SpectatorExited:Destroy()
    self.CombatEvent:Destroy()
end

return CombatSignals
