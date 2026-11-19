--!strict

local CharacterConfig = {}

CharacterConfig.Movement = {
    WalkSpeed = 16,
    SprintSpeed = 24,
    CrouchSpeedMultiplier = 0.65,
    SlideSpeedMultiplier = 1.35,
    MaxAcceleration = 128,
    MaxDeceleration = 240,
    AirControl = 0.35,
    GroundFriction = 12,
    SlideFriction = 8,
    MaxSlopeAngle = 45,
    SlideDuration = 0.9,
    SlideCooldown = 1.2,
    CrouchTransitionTime = 0.18,
    SprintTransitionTime = 0.18,
    MomentumRetention = 0.88,
    GroundedTolerance = 0.12,
    MaxAirSpeed = 18,
}

CharacterConfig.Jump = {
    Power = 52,
    BufferTime = 0.18,
    CoyoteTime = 0.22,
    LandingRecoveryTime = 0.16,
    MaxAirJumps = 0,
}

CharacterConfig.FallDamage = {
    Threshold = 18,
    Multiplier = 2.5,
    Cap = 75,
}

CharacterConfig.Camera = {
    DefaultFOV = 70,
    SprintFOV = 84,
    CrouchFOV = -4,
    SlideFOV = 8,
    FOVLerpSpeed = 9,
    CameraSmoothing = 0.1,
    LandingShakeIntensity = 0.65,
    DamageShakeIntensity = 1.0,
    ShakeDuration = 0.16,
}

CharacterConfig.State = {
    DamageMovementPenalty = 0.8,
    MaxAirSpeed = 18,
}

return CharacterConfig
