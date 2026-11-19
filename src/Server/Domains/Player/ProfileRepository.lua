--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local PlayerProfile = require(ReplicatedStorage.Shared.Domains.Player.PlayerProfile)
local ProfileSerializer = require(ReplicatedStorage.Shared.Domains.Player.ProfileSerializer)
local ProfileValidator = require(ReplicatedStorage.Shared.Domains.Player.ProfileValidator)
local ProfileTemplate = require(ReplicatedStorage.Shared.Domains.Player.ProfileTemplate)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)

local ProfileRepository = {}
ProfileRepository.__index = ProfileRepository

type RepositoryInstance = {
	_store: DataStore,
	_serializer: any,
	_validator: any,
	Load: (self: RepositoryInstance, userId: number) -> PlayerTypes.ProfileData?,
	Save: (self: RepositoryInstance, profile: PlayerTypes.ProfileData) -> (boolean, string?),
	Destroy: (self: RepositoryInstance) -> (),
}

local function buildStoreKey(userId: number): string
	return tostring(userId)
end

function ProfileRepository.new(): RepositoryInstance
	local self = setmetatable({
		_store = DataStoreService:GetDataStore("PlayerProfiles_V1"),
		_serializer = ProfileSerializer.new(),
		_validator = ProfileValidator.new(),
	}, ProfileRepository)

	return self
end

function ProfileRepository:_saveRaw(profile: PlayerTypes.ProfileData): (boolean, string?)
	profile.LastModified = os.time()

	local success, errorMessage = pcall(function()
		self._store:SetAsync(buildStoreKey(profile.UserId), self._serializer:Serialize(profile))
	end)

	if not success then
		Logger:Warn(`Failed to save profile for user {profile.UserId}: {tostring(errorMessage)}`)
		return false, tostring(errorMessage)
	end

	return true, nil
end

function ProfileRepository:Load(userId: number): PlayerTypes.ProfileData?
	assert(type(userId) == "number" and userId > 0, "Invalid userId")

	local success, rawData = pcall(function()
		return self._store:GetAsync(buildStoreKey(userId))
	end)

	if not success then
		Logger:Warn(`Failed to load profile for user {userId}`)
		return ProfileTemplate.Create(userId)
	end

	if rawData == nil then
		local profile = PlayerProfile.Create(userId)
		self:_saveRaw(profile)
		return profile
	end

	local profileData
	if type(rawData) == "string" then
		profileData = self._serializer:Deserialize(rawData)
	elseif type(rawData) == "table" then
		profileData = rawData
	end

	if type(profileData) ~= "table" then
		Logger:Warn(`Invalid profile payload for user {userId}`)
		local profile = PlayerProfile.Create(userId)
		self:_saveRaw(profile)
		return profile
	end

	local profile = PlayerProfile.Migrate(profileData)
	local isValid, errorMsg = self._validator:ValidateProfile(profile)
	if not isValid then
		Logger:Warn(`Profile validation failed for user {userId}: {errorMsg}`)
		profile = self._validator:Sanitize(profile)
		self:_saveRaw(profile)
	end

	return profile
end

function ProfileRepository:Save(profile: PlayerTypes.ProfileData): (boolean, string?)
	assert(profile ~= nil, "Profile cannot be nil")

	local migratedProfile = PlayerProfile.Migrate(profile)
	local isValid, errorMsg = self._validator:ValidateProfile(migratedProfile)
	if not isValid then
		Logger:Warn(`Profile validation failed for user {profile.UserId}: {errorMsg}`)
		migratedProfile = self._validator:Sanitize(migratedProfile)
	end

	return self:_saveRaw(migratedProfile)
end

function ProfileRepository:Destroy(): ()
	-- No cleanup required for DataStore references
end

return ProfileRepository
