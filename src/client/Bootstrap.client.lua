--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = require(ReplicatedStorage.Shared.Core.Game)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)
local ControllerContainer = require(ReplicatedStorage.Shared.Core.ControllerContainer)
local ControllerLoader = require(script.Parent.ControllerLoader)

local function BootstrapClient()
	Logger:Info("Bootstrapping Client...")

	local container = ControllerContainer.new()
	local loader = ControllerLoader.new(container, Game)
	loader:Load(script.Parent.Controllers)

	Game:RegisterControllerContainer(container)
	Game:Start()
end

BootstrapClient()