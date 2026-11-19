--!strict

local RecoilService = {}
RecoilService.__index = RecoilService

type RecoilState = {
    CurrentRecoil: number,
}

type RecoilServiceInstance = {
    Name: string,
    Init: (self: RecoilServiceInstance) -> (),
    Start: (self: RecoilServiceInstance) -> (),
    Destroy: (self: RecoilServiceInstance) -> (),
    CreateState: (self: RecoilServiceInstance) -> RecoilState,
    ApplyRecoil: (self: RecoilServiceInstance, state: RecoilState, weapon: table) -> number,
    Recover: (self: RecoilServiceInstance, state: RecoilState, dt: number) -> (),
}

function RecoilService.new(): RecoilServiceInstance
    local self = setmetatable({
        Name = "RecoilService",
    }, RecoilService)

    return self
end

function RecoilService:Init(): ()
end

function RecoilService:Start(): ()
end

function RecoilService:Destroy(): ()
end

function RecoilService:CreateState(): RecoilState
    return { CurrentRecoil = 0 }
end

function RecoilService:ApplyRecoil(state: RecoilState, weapon: table): number
    assert(state ~= nil, "Recoil state cannot be nil")
    assert(type(weapon) == "table", "Weapon must be a table")

    state.CurrentRecoil += weapon.Recoil
    return state.CurrentRecoil
end

function RecoilService:Recover(state: RecoilState, dt: number): ()
    assert(state ~= nil, "Recoil state cannot be nil")
    state.CurrentRecoil = math.max(0, state.CurrentRecoil - dt * 2)
end

return RecoilService
