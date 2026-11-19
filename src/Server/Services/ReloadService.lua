--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfig = require(ReplicatedStorage.Shared.Config.WeaponConfig)
local WeaponEvents = require(ReplicatedStorage.Shared.Events.WeaponEvents)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local ReloadService = {}
ReloadService.__index = ReloadService

type ReloadState = {
    RemainingTime: number,
    Active: boolean,
    Weapon: table,
    AmmoState: table,
}

type ReloadServiceInstance = {
    Name: string,
    _activeReloads: {[number]: ReloadState},
    _ammoService: any,
    Init: (self: ReloadServiceInstance) -> (),
    Start: (self: ReloadServiceInstance) -> (),
    Destroy: (self: ReloadServiceInstance) -> (),
    StartReload: (self: ReloadServiceInstance, player: Player, weapon: table, ammoState: table) -> boolean,
    IsReloading: (self: ReloadServiceInstance, player: Player) -> boolean,
    Update: (self: ReloadServiceInstance, dt: number) -> (),
    SetAmmoService: (self: ReloadServiceInstance, ammoService: any) -> (),
}

function ReloadService.new(): ReloadServiceInstance
    local self = setmetatable({
        Name = "ReloadService",
        _activeReloads = {},
        _ammoService = nil,
    }, ReloadService)

    return self
end

function ReloadService:Init(): ()
end

function ReloadService:Start(): ()
    task.spawn(function()
        while true do
            task.wait(0.1)
            self:Update(0.1)
        end
    end)
end

function ReloadService:Destroy(): ()
    self._activeReloads = {}
end

function ReloadService:SetAmmoService(ammoService: any): ()
    assert(ammoService ~= nil, "AmmoService cannot be nil")
    self._ammoService = ammoService
end

function ReloadService:StartReload(player: Player, weapon: table, ammoState: table): boolean
    assert(player ~= nil, "Player cannot be nil")
    assert(type(weapon) == "table", "Weapon must be a table")
    assert(type(ammoState) == "table", "Ammo state must be a table")

    if self._activeReloads[player.UserId] then
        return false
    end

    if ammoState.Magazine >= weapon.Magazine or ammoState.Reserve <= 0 then
        return false
    end

    self._activeReloads[player.UserId] = {
        RemainingTime = weapon.ReloadTime,
        Active = true,
        Weapon = weapon,
        AmmoState = ammoState,
    }

    return true
end

function ReloadService:IsReloading(player: Player): boolean
    local state = self._activeReloads[player.UserId]
    return state ~= nil and state.Active
end

function ReloadService:Update(dt: number): ()
    for userId, state in pairs(self._activeReloads) do
        state.RemainingTime = math.max(0, state.RemainingTime - dt)
        if state.RemainingTime <= 0 and state.Active then
            state.Active = false
            local player = game:GetService("Players"):GetPlayerByUserId(userId)
            if player then
                if self._ammoService ~= nil then
                    self._ammoService:Reload(state.AmmoState, state.Weapon)
                end
            end
            self._activeReloads[userId] = nil
        end
    end
end

return ReloadService
