--!strict

local CharacterEvents = table.freeze({
    MovementInput = "CharacterMovementInput",
    SprintStarted = "CharacterSprintStarted",
    SprintStopped = "CharacterSprintStopped",
    CrouchToggled = "CharacterCrouchToggled",
    SlideStarted = "CharacterSlideStarted",
    SlideEnded = "CharacterSlideEnded",
    JumpRequested = "CharacterJumpRequested",
    Landed = "CharacterLanded",
    FallDamageApplied = "CharacterFallDamageApplied",
    CameraShake = "CharacterCameraShake",
    FOVUpdated = "CharacterFOVUpdated",
    StateChanged = "CharacterStateChanged",
})

return CharacterEvents
