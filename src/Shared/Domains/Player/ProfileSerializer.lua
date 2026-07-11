--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local PlayerTypes = require(ReplicatedStorage.Shared.Domains.Player.PlayerTypes)
local Utilities = require(ReplicatedStorage.Shared.Utilities.Utilities)

local ProfileSerializer = {}
ProfileSerializer.__index = ProfileSerializer

function ProfileSerializer.new()
	local self = setmetatable({}, ProfileSerializer)
	return self
end

function ProfileSerializer:Serialize(profile: PlayerTypes.ProfileData): string
	local success, result = pcall(function()
		return HttpService:JSONEncode(profile)
	end)

	if not success then
		error("Failed to serialize profile: " .. tostring(result))
	end

	return result
end

function ProfileSerializer:Deserialize(json: string): PlayerTypes.ProfileData?
	if type(json) ~= "string" or json == "" then
		return nil
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(json)
	end)

	if not success then
		return nil
	end

	return result
end

function ProfileSerializer:Clone(profile: PlayerTypes.ProfileData): PlayerTypes.ProfileData
	return Utilities.DeepCopy(profile)
end

return ProfileSerializer
