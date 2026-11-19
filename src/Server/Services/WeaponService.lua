--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Game = require(ReplicatedStorage.Shared.Core.Game)

local WeaponFactory = require(script.Parent.WeaponFactory)
local AmmoService = require(script.Parent.AmmoService)
local ReloadService = require(script.Parent.ReloadService)
local RecoilService = require(script.Parent.RecoilService)
local SpreadService = require(script.Parent.SpreadService)
local FireModeService = require(script.Parent.FireModeService)
local HitScanService = require(script.Parent.HitScanService)
local WeaponSignals = require(script.Parent.Parent.Domains.Weapon.WeaponSignals)

local WeaponService = {}
WeaponService.__index = WeaponService

type WeaponState = {
    Weapon: table,
    AmmoState: table,
    RecoilState: table,
    SpreadState: table,
    IsADS: boolean,
    LastShotTime: number,
}

type WeaponServiceInstance = {
    Name: string,
    _factory: any,
    _ammoService: any,
    _reloadService: any,
    _recoilService: any,
    _spreadService: any,
    _fireModeService: any,
    _hitScanService: any,
    _weaponSignals: any,
    _playerWeapons: {[number]: WeaponState},
    Init: (self: WeaponServiceInstance) -> (),
    Start: (self: WeaponServiceInstance) -> (),
    Destroy: (self: WeaponServiceInstance) -> (),
    SetDependencies: (self: WeaponServiceInstance, factory: any, ammoService: any, reloadService: any, recoilService: any, spreadService: any, fireModeService: any, hitScanService: any) -> (),
    EquipWeapon: (self: WeaponServiceInstance, player: Player, weaponName: string) -> (),
    FireWeapon: (self: WeaponServiceInstance, player: Player, origin: Vector3, direction: Vector3, bodyPartMap: {[string]: string?}) -> (),
    StartReload: (self: WeaponServiceInstance, player: Player) -> boolean,
    SetADS: (self: WeaponServiceInstance, player: Player, isADS: boolean) -> (),
    SwitchFireMode: (self: WeaponServiceInstance, player: Player, fireMode: string) -> boolean,
    GetSignals: (self: WeaponServiceInstance) -> any,
}

function WeaponService.new(): WeaponServiceInstance
    local self = setmetatable({
        Name = "WeaponService",
        _factory = nil,
        _ammoService = nil,
        _reloadService = nil,
        _recoilService = nil,
        _spreadService = nil,
        _fireModeService = nil,
        _hitScanService = nil,
        _weaponSignals = WeaponSignals.new(),
        _playerWeapons = {},
    }, WeaponService)

    return self
end

function WeaponService:Init(): ()
    local remoteRegistry = Game:GetRemoteRegistry()
    if remoteRegistry == nil then
        return
    end

    local equipRemote = remoteRegistry:RegisterFunction("EquipWeapon")
    equipRemote.OnServerInvoke = function(player, weaponName)
        if type(weaponName) ~= "string" then
            return false
        end
        self:EquipWeapon(player, weaponName)
        return true
    end

    local fireRemote = remoteRegistry:RegisterEvent("FireWeapon")
    fireRemote.OnServerEvent:Connect(function(player, origin, direction, bodyPartMap)
        if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
            self:FireWeapon(player, origin, direction, type(bodyPartMap) == "table" and bodyPartMap or {})
        end
    end)

    local reloadRemote = remoteRegistry:RegisterFunction("StartWeaponReload")
    reloadRemote.OnServerInvoke = function(player)
        return self:StartReload(player)
    end

    local adsRemote = remoteRegistry:RegisterEvent("SetWeaponADS")
    adsRemote.OnServerEvent:Connect(function(player, isADS)
        self:SetADS(player, type(isADS) == "boolean" and isADS or false)
    end)

    local modeRemote = remoteRegistry:RegisterFunction("SwitchWeaponFireMode")
    modeRemote.OnServerInvoke = function(player, fireMode)
        return type(fireMode) == "string" and self:SwitchFireMode(player, fireMode) or false
    end
end

function WeaponService:Start(): ()
end

function WeaponService:Destroy(): ()
    self._weaponSignals:Destroy()
    self._playerWeapons = {}
end

function WeaponService:SetDependencies(factory: any, ammoService: any, reloadService: any, recoilService: any, spreadService: any, fireModeService: any, hitScanService: any): ()
    self._factory = factory
    self._ammoService = ammoService
    self._reloadService = reloadService
    self._recoilService = recoilService
    self._spreadService = spreadService
    self._fireModeService = fireModeService
    self._hitScanService = hitScanService
end

function WeaponService:GetSignals(): any
    return self._weaponSignals
end

function WeaponService:_createWeaponState(player: Player, weaponName: string): WeaponState
    assert(self._factory ~= nil, "WeaponFactory not configured")
    assert(self._ammoService ~= nil, "AmmoService not configured")
    assert(self._recoilService ~= nil, "RecoilService not configured")
    assert(self._spreadService ~= nil, "SpreadService not configured")

    local weapon = self._factory:CreateWeapon(weaponName)
    return {
        Weapon = weapon,
        AmmoState = self._ammoService:CreateAmmoState(weapon),
        RecoilState = self._recoilService:CreateState(),
        SpreadState = self._spreadService:CreateState(),
        IsADS = false,
        LastShotTime = 0,
    }
end

function WeaponService:EquipWeapon(player: Player, weaponName: string): ()
    assert(player ~= nil, "Player cannot be nil")
    assert(type(weaponName) == "string" and weaponName ~= "", "Weapon name must be a valid string")

    local state = self:_createWeaponState(player, weaponName)
    self._playerWeapons[player.UserId] = state
    self._weaponSignals.WeaponEquipped:Fire(player, state.Weapon)
end

function WeaponService:FireWeapon(player: Player, origin: Vector3, direction: Vector3, bodyPartMap: {[string]: string?})
    assert(player ~= nil, "Player cannot be nil")
    local state = self._playerWeapons[player.UserId]
    if state == nil then
        return
    end

    if self._reloadService ~= nil and self._reloadService:IsReloading(player) then
        return
    end

    if not self._ammoService:CanFire(state.AmmoState) then
        self._weaponSignals.MagazineEmpty:Fire(player)
        return
    end

    local now = os.clock()
    local timeBetweenShots = 60 / state.Weapon.FireRate
    if now - state.LastShotTime < timeBetweenShots then
        return
    end

    state.LastShotTime = now
    self._ammoService:ConsumeAmmo(state.AmmoState, 1)
    self._weaponSignals.WeaponFired:Fire(player, state.Weapon, state.AmmoState)

    if self._weaponSignals.AmmoUpdated then
        self._weaponSignals.AmmoUpdated:Fire(player, state.AmmoState)
    end

    local spread = self._spreadService:ApplySpread(state.SpreadState, state.Weapon, state.IsADS)
    local recoil = self._recoilService:ApplyRecoil(state.RecoilState, state.Weapon)

    local shotDirection = direction + Vector3.new((math.random() * 2 - 1) * spread, (math.random() * 2 - 1) * spread, 0) + Vector3.new(0, recoil * 0.001, 0)
    local hit = self._hitScanService and self._hitScanService:FireHitScan(player, origin, shotDirection, state.Weapon, bodyPartMap)

    if hit then
        self._weaponSignals.WeaponHit:Fire(player, state.Weapon)
    else
        self._weaponSignals.WeaponMissed:Fire(player, state.Weapon)
    end
end

function WeaponService:StartReload(player: Player): boolean
    assert(player ~= nil, "Player cannot be nil")
    local state = self._playerWeapons[player.UserId]
    if state == nil then
        return false
    end
    if self._ammoService == nil or self._reloadService == nil then
        return false
    end

    if not self._ammoService:CanReload(state.AmmoState) then
        return false
    end

    local started = self._reloadService:StartReload(player, state.Weapon, state.AmmoState)
    if started then
        self._weaponSignals.WeaponReloadStarted:Fire(player, state.Weapon)
    end
    return started
end

function WeaponService:SetADS(player: Player, isADS: boolean): ()
    assert(player ~= nil, "Player cannot be nil")
    local state = self._playerWeapons[player.UserId]
    if state == nil then
        return
    end
    state.IsADS = isADS
end

function WeaponService:SwitchFireMode(player: Player, fireMode: string): boolean
    assert(player ~= nil, "Player cannot be nil")
    assert(type(fireMode) == "string" and fireMode ~= "", "Fire mode must be a valid string")

    local state = self._playerWeapons[player.UserId]
    if state == nil or self._fireModeService == nil then
        return false
    end

    local success = self._fireModeService:SetFireMode(state.Weapon, fireMode)
    if success then
        self._weaponSignals.WeaponModeChanged:Fire(player, fireMode)
    end
    return success
end

return WeaponService
