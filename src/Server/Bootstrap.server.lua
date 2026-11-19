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
	local rewardService = container:Get("RewardService")

	if playerService and dataService then
		playerService:SetDataService(dataService)
	end

	if playerService and economyService then
		playerService:SetEconomyService(economyService)
	end

	if rewardService and economyService then
		rewardService:SetEconomyService(economyService)
	end

	local matchService = container:Get("MatchService")
	local stateService = container:Get("GameStateService")
	local roundService = container:Get("RoundService")
	local teamService = container:Get("TeamService")
	local spawnService = container:Get("SpawnService")
	local countdownService = container:Get("CountdownService")
	local timerService = container:Get("TimerService")

	if matchService and stateService and roundService and teamService and spawnService and countdownService and timerService then
		matchService:SetDependencies(stateService, roundService, teamService, spawnService, countdownService, timerService)
	end

	local weaponRepository = container:Get("WeaponRepository")
	local weaponFactory = container:Get("WeaponFactory")
	local ammoService = container:Get("AmmoService")
	local reloadService = container:Get("ReloadService")
	local recoilService = container:Get("RecoilService")
	local spreadService = container:Get("SpreadService")
	local fireModeService = container:Get("FireModeService")
	local hitScanService = container:Get("HitScanService")
	local weaponService = container:Get("WeaponService")
	local raycastService = container:Get("RaycastService")
	local combatService = container:Get("CombatService")
	local damageService = container:Get("DamageService")
	local healthService = container:Get("HealthService")
	local deathService = container:Get("DeathService")
	local assistService = container:Get("AssistService")
	local headshotService = container:Get("HeadshotService")
	local spectatorService = container:Get("SpectatorService")
	local respawnService = container:Get("RespawnService")
	local killService = container:Get("KillService")
	local killStreakService = container:Get("KillStreakService")
	local fallDamageService = container:Get("FallDamageService")

	if damageService and teamService then
		damageService:SetDependencies(teamService)
	end

	if killService and killStreakService and headshotService then
		killService:SetDependencies(killStreakService, headshotService)
	end

	if fallDamageService and combatService then
		fallDamageService:SetDependencies(combatService)
	end

	if weaponRepository and weaponFactory then
		weaponFactory:SetDependencies(weaponRepository)
	end

	if reloadService and ammoService then
		reloadService:SetAmmoService(ammoService)
	end

	if hitScanService and raycastService and combatService then
		hitScanService:SetDependencies(raycastService, combatService)
	end

	if weaponService and weaponFactory and ammoService and reloadService and recoilService and spreadService and fireModeService and hitScanService then
		weaponService:SetDependencies(weaponFactory, ammoService, reloadService, recoilService, spreadService, fireModeService, hitScanService)
	end

	if combatService and damageService and healthService and deathService and respawnService and killService and assistService and headshotService and spectatorService and playerService and teamService and rewardService then
		combatService:SetDependencies(damageService, healthService, deathService, respawnService, killService, assistService, headshotService, spectatorService, playerService, teamService, rewardService)
	end

	if deathService and killService and assistService and respawnService and rewardService and combatService then
		deathService:SetDependencies(killService, assistService, respawnService, rewardService, combatService)
	end

	if assistService and playerService and combatService then
		assistService:SetDependencies(playerService, combatService)
	end

	if headshotService and playerService and combatService then
		headshotService:SetDependencies(playerService, combatService)
	end

	if respawnService and spawnService and spectatorService and playerService then
		respawnService:SetDependencies(spawnService, spectatorService, playerService)
	end

	if rewardService and economyService then
		rewardService:SetEconomyService(economyService)
	end

	Game:RegisterServiceContainer(container)
	Game:Start()
end

BootstrapServer()