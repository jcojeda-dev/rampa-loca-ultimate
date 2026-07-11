--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Game = require(ReplicatedStorage.Shared.Core.Game)
local Logger = require(ReplicatedStorage.Shared.Core.Logger)
local ServiceContainer = require(ReplicatedStorage.Shared.Core.ServiceContainer)
local ServiceLoader = require(ServerScriptService.ServiceLoader)

local function BootstrapServer()
	Logger:Info("Bootstrapping Server...")

	local container = ServiceContainer.new()
	local loader = ServiceLoader.new(container, Game)
	loader:Load(ServerScriptService.Services)

	-- Set up service dependencies
	local playerService = container:Get("PlayerService")
	local dataService = container:Get("DataService")
	local economyService = container:Get("EconomyService")

	if playerService and dataService then
		playerService:SetDataService(dataService)
	end

	if playerService and economyService then
		playerService:SetEconomyService(economyService)
	end

	Game:RegisterServiceContainer(container)
	Game:Start()
end

BootstrapServer()