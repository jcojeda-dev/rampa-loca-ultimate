--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Shared.Modules.Signal)

local CharacterSignals = {}
CharacterSignals.__index = CharacterSignals

type SignalType = typeof(Signal.new())

type CharacterSignalsInstance = {
    MovementUpdated: SignalType,
    SprintStarted: SignalType,
    SprintStopped: SignalType,
    CrouchChanged: SignalType,
    SlideStarted: SignalType,
    SlideEnded: SignalType,
    JumpRequested: SignalType,
    Landed: SignalType,
    FallDamageApplied: SignalType,
    CameraShakeRequested: SignalType,
    FOVChanged: SignalType,
    Destroy: (self: CharacterSignalsInstance) -> (),
}

function CharacterSignals.new(): CharacterSignalsInstance
    local self = setmetatable({
        MovementUpdated = Signal.new(),
        SprintStarted = Signal.new(),
        SprintStopped = Signal.new(),
        CrouchChanged = Signal.new(),
        SlideStarted = Signal.new(),
        SlideEnded = Signal.new(),
        JumpRequested = Signal.new(),
        Landed = Signal.new(),
        FallDamageApplied = Signal.new(),
        CameraShakeRequested = Signal.new(),
        FOVChanged = Signal.new(),
    }, CharacterSignals)

    return self
end

function CharacterSignals:Destroy(): ()
    self.MovementUpdated:Destroy()
    self.SprintStarted:Destroy()
    self.SprintStopped:Destroy()
    self.CrouchChanged:Destroy()
    self.SlideStarted:Destroy()
    self.SlideEnded:Destroy()
    self.JumpRequested:Destroy()
    self.Landed:Destroy()
    self.FallDamageApplied:Destroy()
    self.CameraShakeRequested:Destroy()
    self.FOVChanged:Destroy()
end

return CharacterSignals
