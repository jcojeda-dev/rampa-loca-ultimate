--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local ProfileTemplate = require(ReplicatedStorage.Shared.Domains.Player.ProfileTemplate)
local ProfileSerializer = require(ReplicatedStorage.Shared.Domains.Player.ProfileSerializer)
local ProfileValidator = require(ReplicatedStorage.Shared.Domains.Player.ProfileValidator)

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

function ProfileRepository.new(): RepositoryInstance
	local self = setmetatable({
		_store = DataStoreService:GetDataStore("PlayerProfiles_V1"),
		_serializer = ProfileSerializer.new(),
		_validator = ProfileValidator.new(),
	}, ProfileRepository)

	return self
end

function ProfileRepository:Load(userId: number): PlayerTypes.ProfileData?
	assert(type(userId) == "number" and userId > 0, "Invalid userId")

	local success, data = pcall(function()
		return self._store:GetAsync(userId)
	end)

	if not success then
		return nil
	end

	if data == nil then
		local newProfile = ProfileTemplate.Create(userId)
		self:Save(newProfile)
		return newProfile
	end

	if type(data) == "string" then
		data = self._serializer:Deserialize(data)
	end

	if type(data) == "table" then
		local isValid, _ = self._validator:ValidateProfile(data)
		if isValid then
			return self._validator:Sanitize(data)
		end
	end

	return ProfileTemplate.Create(userId)
end

function ProfileRepository:Save(profile: PlayerTypes.ProfileData): (boolean, string?)
	assert(profile ~= nil, "Profile cannot be nil")

	local isValid, errorMsg = self._validator:ValidateProfile(profile)
	if not isValid then
		return false, errorMsg
	end

	profile.LastModified = os.time()

	local success, errorMessage = pcall(function()
		self._store:SetAsync(profile.UserId, profile)
	end)

	if not success then
		return false, tostring(errorMessage)
	end

	return true, nil
end

function ProfileRepository:Destroy(): ()
	-- No cleanup needed for DataStore
end

return ProfileRepository
