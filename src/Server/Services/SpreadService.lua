--!strict

local SpreadService = {}
SpreadService.__index = SpreadService

type SpreadState = {
    CurrentSpread: number,
}

type SpreadServiceInstance = {
    Name: string,
    Init: (self: SpreadServiceInstance) -> (),
    Start: (self: SpreadServiceInstance) -> (),
    Destroy: (self: SpreadServiceInstance) -> (),
    CreateState: (self: SpreadServiceInstance) -> SpreadState,
    ApplySpread: (self: SpreadServiceInstance, state: SpreadState, weapon: table, isADS: boolean) -> number,
    Recover: (self: SpreadServiceInstance, state: SpreadState, dt: number) -> (),
}

function SpreadService.new(): SpreadServiceInstance
    local self = setmetatable({
        Name = "SpreadService",
    }, SpreadService)

    return self
end

function SpreadService:Init(): ()
end

function SpreadService:Start(): ()
end

function SpreadService:Destroy(): ()
end

function SpreadService:CreateState(): SpreadState
    return { CurrentSpread = 0 }
end

function SpreadService:ApplySpread(state: SpreadState, weapon: table, isADS: boolean): number
    assert(state ~= nil, "Spread state cannot be nil")
    assert(type(weapon) == "table", "Weapon must be a table")

    local multiplier = isADS and weapon.ADSMultiplier or 1
    local spread = weapon.Spread + state.CurrentSpread
    return spread * multiplier
end

function SpreadService:Recover(state: SpreadState, dt: number): ()
    assert(state ~= nil, "Spread state cannot be nil")
    state.CurrentSpread = math.max(0, state.CurrentSpread - dt)
end

return SpreadService
