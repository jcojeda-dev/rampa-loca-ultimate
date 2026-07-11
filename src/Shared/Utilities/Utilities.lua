--!strict

--[[
	Utilities exposes reusable helpers for deep copies, tables, clamping and folder creation.
]]

local Utilities = {}

function Utilities.DeepCopy<T>(value: T): T
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, item in pairs(value) do
		copy[key] = Utilities.DeepCopy(item)
	end

	return copy
end

function Utilities.MergeTables<T>(target: T, source: T): T
	local merged = Utilities.DeepCopy(target)
	for key, value in pairs(source) do
		merged[key] = Utilities.DeepCopy(value)
	end

	return merged
end

function Utilities.Clamp(value: number, minimum: number, maximum: number): number
	return math.max(minimum, math.min(maximum, value))
end

function Utilities.IsEmpty(value: any): boolean
	if value == nil then
		return true
	end

	if type(value) == "table" then
		return next(value) == nil
	end

	return false
end

function Utilities.CreateFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("Folder") then
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

return Utilities
