--!strict

--[[
	Core entry point for the project lifecycle.
	Coordinates services, controllers, events, cleanup and scheduling.
]]

local ServiceContainer = require(script.Parent.ServiceContainer)
local ControllerContainer = require(script.Parent.ControllerContainer)
local EventBus = require(script.Parent.EventBus)
local Logger = require(script.Parent.Logger)
local ResourceCleaner = require(script.Parent.ResourceCleaner)
local TaskScheduler = require(script.Parent.TaskScheduler)
local RemoteRegistry = require(script.Parent.RemoteRegistry)

local Game = {}
Game.__index = Game

Game._services = nil
Game._controllers = nil
Game._eventBus = nil
Game._logger = nil
Game._resourceCleaner = nil
Game._taskScheduler = nil
Game._remoteRegistry = nil
Game._initialized = false
Game._started = false

local function EnsureCore()
	if Game._services == nil then
		Game._services = ServiceContainer.new()
		Game._controllers = ControllerContainer.new()
		Game._eventBus = EventBus.new()
		Game._logger = Logger
		Game._resourceCleaner = ResourceCleaner.new()
		Game._taskScheduler = TaskScheduler.new()
		Game._remoteRegistry = RemoteRegistry.new()
	end

	return Game
end

function Game:RegisterService(name: string, service)
	EnsureCore()
	return self._services:Register(name, service)
end

function Game:RegisterController(name: string, controller)
	EnsureCore()
	return self._controllers:Register(name, controller)
end

function Game:RegisterServiceContainer(container)
	EnsureCore()
	self._services = container
	return self._services
end

function Game:RegisterControllerContainer(container)
	EnsureCore()
	self._controllers = container
	return self._controllers
end

function Game:GetService(name: string)
	EnsureCore()
	return self._services:Get(name)
end

function Game:GetController(name: string)
	EnsureCore()
	return self._controllers:Get(name)
end

function Game:GetEventBus()
	EnsureCore()
	return self._eventBus
end

function Game:GetLogger()
	EnsureCore()
	return self._logger
end

function Game:GetResourceCleaner()
	EnsureCore()
	return self._resourceCleaner
end

function Game:GetTaskScheduler()
	EnsureCore()
	return self._taskScheduler
end

function Game:GetRemoteRegistry()
	EnsureCore()
	return self._remoteRegistry
end

function Game:Initialize()
	EnsureCore()
	if self._initialized then
		return
	end

	self._logger:Info("Initializing game core")
	self._services:InitializeAll()
	self._controllers:InitializeAll()
	self._initialized = true
end

function Game:Start()
	EnsureCore()
	if self._started then
		return
	end

	self:Initialize()
	self._logger:Info("Starting game core")
	self._services:StartAll()
	self._controllers:StartAll()
	self._started = true
end

function Game:Destroy()
	EnsureCore()
	if not self._initialized then
		return
	end

	self._logger:Info("Destroying game core")
	self._services:DestroyAll()
	self._controllers:DestroyAll()
	self._resourceCleaner:Destroy()
	self._taskScheduler:Destroy()
	self._eventBus:Destroy()
	self._remoteRegistry:Destroy()
	self._initialized = false
	self._started = false
end

return EnsureCore()