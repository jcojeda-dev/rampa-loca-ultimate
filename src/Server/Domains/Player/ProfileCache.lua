--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)

local ProfileCache = {}
ProfileCache.__index = ProfileCache

type CacheEntry = {
	Profile: PlayerTypes.ProfileData,
	LoadedAt: number,
}

type ProfileCacheInstance = {
	_cache: {[number]: CacheEntry},
	Set: (self: ProfileCacheInstance, userId: number, profile: PlayerTypes.ProfileData) -> (),
	Get: (self: ProfileCacheInstance, userId: number) -> PlayerTypes.ProfileData?,
	Remove: (self: ProfileCacheInstance, userId: number) -> (),
	Clear: (self: ProfileCacheInstance) -> (),
	Destroy: (self: ProfileCacheInstance) -> (),
}

function ProfileCache.new(): ProfileCacheInstance
	local self = setmetatable({
		_cache = {},
	}, ProfileCache)

	return self
end

function ProfileCache:Set(userId: number, profile: PlayerTypes.ProfileData): ()
	assert(type(userId) == "number" and userId > 0, "Invalid userId")
	assert(profile ~= nil, "Profile cannot be nil")

	self._cache[userId] = {
		Profile = profile,
		LoadedAt = os.time(),
	}
end

function ProfileCache:Get(userId: number): PlayerTypes.ProfileData?
	assert(type(userId) == "number" and userId > 0, "Invalid userId")

	local entry = self._cache[userId]
	if entry ~= nil then
		return entry.Profile
	end

	return nil
end

function ProfileCache:Remove(userId: number): ()
	self._cache[userId] = nil
end

function ProfileCache:Clear(): ()
	self._cache = {}
end

function ProfileCache:Destroy(): ()
	self:Clear()
end

return ProfileCache
