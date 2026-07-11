# Rampa Loca Ultimate - Architecture Documentation

## Project Overview

**Rampa Loca Ultimate** is a Roblox multiplayer game engine built with modular architecture, type-safe Luau, and complete separation of concerns.

## Core Design Principles

1. **Modular Architecture**: Each system is self-contained and testable
2. **Strict Typing**: Complete `--!strict` Luau typing throughout
3. **Lifecycle Management**: All systems follow Init → Start → Destroy pattern
4. **No Global State**: All systems are instantiated and registered in containers
5. **Single Responsibility**: Each module has exactly one reason to change
6. **Dependency Injection**: Services are injected, never globally accessed

## Directory Structure

```
src/
├── Shared/                 # Shared between client and server
│   ├── Bootstrap.lua      # Shared initialization
│   ├── Core/              # Core infrastructure
│   │   ├── Game.lua       # Main orchestrator
│   │   ├── ServiceContainer.lua
│   │   ├── ControllerContainer.lua
│   │   ├── EventBus.lua
│   │   ├── Logger.lua
│   │   ├── ResourceCleaner.lua
│   │   ├── TaskScheduler.lua
│   │   └── RemoteRegistry.lua
│   ├── Modules/           # Utility modules
│   │   ├── Signal.lua
│   │   └── Promise.lua
│   ├── Domains/           # Business logic domains
│   │   └── Player/
│   │       ├── PlayerTypes.lua
│   │       ├── ProfileTemplate.lua
│   │       ├── ProfileValidator.lua
│   │       └── ProfileSerializer.lua
│   ├── Constants/         # Configuration
│   │   ├── EconomyConstants.lua
│   │   └── GameConstants.lua
│   ├── Config/            # Game settings
│   │   ├── EconomyConfig.lua
│   │   ├── GameConfig.lua
│   │   ├── MatchConfig.lua
│   │   └── ProfileTemplate.lua
│   ├── Enums/            # Type enumerations
│   │   ├── GameMode.lua
│   │   ├── MatchState.lua
│   │   └── MatchResult.lua
│   ├── Types/            # Type definitions
│   ├── Utilities/        # Helper functions
│   ├── Assets/           # Shared assets
│   ├── Animations/       # Shared animations
│   ├── Remotes/          # RemoteEvent definitions
│   ├── Sounds/           # Sound assets
│   ├── FX/               # Visual effects
│   └── UI/               # Shared UI

├── Server/               # Server-only code
│   ├── Bootstrap.server.lua
│   ├── ServiceLoader.lua
│   ├── Services/         # Server services
│   │   ├── DataService.lua
│   │   ├── PlayerService.lua
│   │   ├── EconomyService.lua
│   │   ├── RewardService.lua
│   │   ├── GameService.lua
│   │   ├── NotificationService.lua
│   │   ├── ProfileService.lua
│   │   ├── RemoteService.lua
│   │   └── ServiceRegistry.lua
│   ├── Domains/          # Domain logic
│   │   └── Player/
│   │       ├── ProfileRepository.lua
│   │       ├── ProfileCache.lua
│   │       ├── SessionManager.lua
│   │       ├── AutoSaveManager.lua
│   │       └── PlayerSignals.lua
│   ├── Systems/          # Game systems
│   ├── Controllers/      # Server-side controllers
│   └── Lighting/         # Lighting setup

└── Client/               # Client-only code
    ├── Bootstrap.client.lua
    ├── ControllerLoader.lua
    ├── Controllers/      # Client controllers
    ├── Camera/
    ├── Input/
    ├── Weapons/
    ├── Effects/
    └── UI/
```

## Core Infrastructure (Layer 0)

### Game.lua
Central orchestrator that initializes and manages all core systems.

**Responsibilities**:
- Initialize ServiceContainer, ControllerContainer
- Initialize EventBus, Logger, ResourceCleaner, TaskScheduler, RemoteRegistry
- Provide singleton access to all core systems
- Manage lifecycle (Init → Start → Destroy)

**Usage**:
```lua
local Game = require(ReplicatedStorage.Shared.Core.Game)
Game:RegisterServiceContainer(container)
Game:Start()
```

### ServiceContainer / ControllerContainer
Manages registration and lifecycle of services/controllers.

**Methods**:
- Register(name, service): Register a service
- Get(name): Get registered service
- InitializeAll(): Call Init() on all
- StartAll(): Call Start() on all
- DestroyAll(): Call Destroy() on all

### EventBus
Pub/sub event system for inter-service communication.

**Methods**:
- Connect(eventName, handler): Subscribe to event
- Once(eventName, handler): Subscribe once
- Fire(eventName, ...args): Publish event
- Disconnect(eventName): Unsubscribe

### Logger
Centralized logging with configurable levels.

**Levels**: Debug, Info, Warn, Error
**Methods**: Logger:Info(), Logger:Warn(), Logger:Error(), Logger:Debug()

### ResourceCleaner
Tracks and safely destroys resources.

**Methods**:
- Track(item): Register item for cleanup
- Add(item): Add item to cleanup
- Cleanup(): Clean all tracked items
- Destroy(): Full cleanup

### TaskScheduler
Task scheduling without legacy wait()/spawn().

**Methods**:
- Schedule(callback, delay): Schedule one-time task
- ScheduleRepeating(callback, interval): Schedule repeating task
- Cancel(handle): Cancel scheduled task

### RemoteRegistry
Creates and manages RemoteEvents/RemoteFunctions.

**Methods**:
- RegisterEvent(name): Create RemoteEvent
- RegisterFunction(name): Create RemoteFunction
- GetEvent(name): Get RemoteEvent
- GetFunction(name): Get RemoteFunction

## Player Domain (Layer 1)

The Player Domain is the foundational layer upon which all other systems depend.

### Type System (PlayerTypes.lua)

Complete Luau type definitions for all player-related data:

- **ProfileData**: Complete player profile with all nested structures
- **ProfileStats**: Kill/death ratios, play time, achievements
- **Loadout**: Current equipped weapons and cosmetics
- **Settings**: Player-specific game preferences
- **Inventory**: Owned weapons, cosmetics, effects
- **BattlePass**: Active battle pass and progress
- **DailyRewards**: Daily login streak tracking
- **Mission**: In-progress and completed missions
- **Achievement**: Unlocked achievements
- **Session**: Active player session info
- **RewardEvent**: Reward event for analytics

### Infrastructure Layer

**Data Flow**:
```
DataStore → ProfileRepository → ProfileCache
                                ↓
                        ProfileValidator
                        ProfileSerializer
                        SessionManager
                        AutoSaveManager
```

**ProfileRepository** (ONLY DataStore accessor)
- Load(userId): Load profile from DataStore
- Save(profile): Save profile to DataStore
- Contract: No other module accesses DataStore

**ProfileCache**
- Set(userId, profile): Cache profile
- Get(userId): Retrieve cached profile
- Remove(userId): Remove from cache
- Performance: Eliminates repeated DataStore calls

**ProfileValidator**
- ValidateProfile(profile): Validate all fields
- Sanitize(profile): Clamp values to valid ranges
- Safety: Prevents invalid data in system

**ProfileSerializer**
- Serialize(profile): Convert to JSON string
- Deserialize(json): Parse JSON to ProfileData
- Clone(profile): Deep copy profile
- Compatibility: Handles complex nested structures

**SessionManager**
- CreateSession(userId): Create active session
- GetSession(userId): Retrieve session info
- IsSessionActive(userId): Check timeout
- Timeout: 600 seconds (EconomyConstants)

**AutoSaveManager**
- RegisterProfile(profile): Add to auto-save
- MarkDirty(userId): Mark for next save
- Start/Stop: Control auto-save loop
- Interval: 60 seconds (EconomyConstants)

**PlayerSignals**
- ProfileLoaded: Profile loaded from DataStore
- ProfileSaved: Profile saved to DataStore
- CoinsChanged: Player coins modified
- XPChanged: Player XP modified
- LevelChanged: Player level changed
- StatsUpdated: Player stats updated

### Service Layer

**DataService**
- Central data orchestrator
- LoadProfile(userId): Load with validation
- SaveProfile(profile): Save with validation
- CreateProfile(userId): Create new profile

**PlayerService**
- Player lifecycle management
- GetProfile(userId): Get cached profile
- SaveProfile(userId): Save to DataStore
- AddCoins/RemoveCoins: Modify economy
- GetSignals(): Access domain events

**EconomyService**
- Economy operations (coins, XP)
- AddCoins(profile, amount, reason)
- RemoveCoins(profile, amount, reason): Validates balance
- SetCoins(profile, amount)
- AddXP(profile, amount)
- CheckLevelUp(profile)

**RewardService**
- Reward value lookups
- GetKillReward(): 200
- GetHeadshotReward(): 50
- GetParticipationReward(): 100
- GetVictoryReward(gameMode): 500 or 600
- XP getters: Kill=25, Headshot=10, Victory=100, Participation=20

### Configuration (EconomyConstants)

```lua
PROFILE_VERSION = 1
AUTO_SAVE_INTERVAL = 60
SESSION_TIMEOUT = 600

Rewards = {Kill=200, Headshot=50, Participation=100, Win1v1=500, Win4v4=600}
XP = {Kill=25, Headshot=10, Victory=100, Participation=20}
MaxValues = {Coins=999999999, Level=999, XP=999999999}
Ranks = ["Recruit", "Private", ..., "General"]
```

## Service Pattern

All services follow this pattern:

```lua
local Service = {}
Service.__index = Service

function Service.new()
    local self = setmetatable({Name = "ServiceName"}, Service)
    return self
end

function Service:Init()
    -- Initialize service - set up data structures
end

function Service:Start()
    -- Start service - connect signals, begin tasks
end

function Service:Destroy()
    -- Clean up resources
end

return Service
```

## Bootstrapping

### Server Bootstrap (Bootstrap.server.lua)
1. Create ServiceContainer
2. Create ServiceLoader
3. Load services from ServerScriptService.Services
4. Register container with Game
5. Call Game:Start()

### Client Bootstrap (Bootstrap.client.lua)
1. Create ControllerContainer
2. Create ControllerLoader
3. Load controllers from script.Parent.Controllers
4. Register container with Game
5. Call Game:Start()

## Lifecycle

```
Init Phase:
  Game:Init() → ServiceContainer:InitializeAll()
    ↓ each service
    Service:Init()

Start Phase:
  Game:Start() → ServiceContainer:StartAll()
    ↓ each service
    Service:Start()

Destroy Phase:
  Game:Destroy() → ServiceContainer:DestroyAll()
    ↓ each service (reverse order)
    Service:Destroy()
```

## Coding Standards

### Type Safety
- All modules use `--!strict`
- All function parameters and returns are typed
- No implicit any types

### Error Handling
- Assert preconditions in all functions
- Log errors with context
- Graceful degradation when possible

### Performance
- Use ResourceCleaner for proper cleanup
- Use TaskScheduler instead of wait()/spawn()
- Cache expensive computations
- Profile code regularly

### Testing
- test_core_modules.py: Validates infrastructure
- test_player_domain.py: Validates player domain
- All tests automated and CI-ready

## Future Extensions

The architecture supports:
- Additional game modes and systems
- New domains (weapon, matchmaking, etc.)
- Cross-domain communication via EventBus
- Replicated logic via RemoteRegistry
- Performance monitoring via Logger
- Graceful shutdown and cleanup via ResourceCleaner

## Key Constraints

1. **No Direct DataStore Access**: Only ProfileRepository touches DataStore
2. **No Magic Numbers**: All configuration in Constants/Config files
3. **No Global Variables**: All state in service instances
4. **No Circular Dependencies**: Clear dependency flow
5. **No Long-Running Tasks**: Use TaskScheduler for all scheduling
6. **No Blocking Operations**: All async via promises or signals
