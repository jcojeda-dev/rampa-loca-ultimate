--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local PlayerProfile = require(ReplicatedStorage.Shared.Domains.Player.PlayerProfile)
local ProfileRepository = require(ReplicatedStorage.Shared.Domains.Player.ProfileRepository)
local ProfileValidator = require(ReplicatedStorage.Shared.Domains.Player.ProfileValidator)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local DataService = {}
DataService.__index = DataService

type DataServiceInstance = {
	Name: string,
	_repository: any,
	_validator: any,
	Init: (self: DataServiceInstance) -> (),
	Start: (self: DataServiceInstance) -> (),
	Destroy: (self: DataServiceInstance) -> (),
	LoadProfile: (self: DataServiceInstance, userId: number) -> PlayerTypes.ProfileData?,
	SaveProfile: (self: DataServiceInstance, profile: PlayerTypes.ProfileData) -> (boolean, string?),
	CreateProfile: (self: DataServiceInstance, userId: number) -> PlayerTypes.ProfileData,
}

function DataService.new(): DataServiceInstance
	local self = setmetatable({
		Name = "DataService",
		_repository = ProfileRepository.new(),
		_validator = ProfileValidator.new(),
	}, DataService)

	return self
end

function DataService:Init(): ()
	Logger:Info("Initializing DataService")
end

function DataService:Start(): ()
	Logger:Info("Starting DataService")
end

function DataService:Destroy(): ()
	Logger:Info("Destroying DataService")
	self._repository:Destroy()
end

function DataService:LoadProfile(userId: number): PlayerTypes.ProfileData?
	assert(type(userId) == "number" and userId > 0, "Invalid userId")

	local rawProfile = self._repository:Load(userId)
	if rawProfile == nil then
		return nil
	end

	local profile = PlayerProfile.Migrate(rawProfile)
	local isValid, errorMsg = self._validator:ValidateProfile(profile)
	if not isValid then
		Logger:Warn(`Failed to validate profile for user {userId}: {errorMsg}`)
		profile = self._validator:Sanitize(profile)
	end

	return profile
end

function DataService:SaveProfile(profile: PlayerTypes.ProfileData): (boolean, string?)
	assert(profile ~= nil, "Profile cannot be nil")

	local isValid, errorMsg = self._validator:ValidateProfile(profile)
	local finalProfile = profile
	if not isValid then
		Logger:Warn(`Profile validation failed: {errorMsg}`)
		finalProfile = self._validator:Sanitize(profile)
	end

	return self._repository:Save(finalProfile)
end

function DataService:CreateProfile(userId: number): PlayerTypes.ProfileData
	assert(type(userId) == "number" and userId > 0, "Invalid userId")
	return PlayerProfile.Create(userId)
end

return DataService