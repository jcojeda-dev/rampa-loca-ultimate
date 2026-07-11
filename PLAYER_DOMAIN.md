# Player Domain Documentation

## Overview

The Player Domain is the central system upon which the entire project depends. It manages player profiles, data persistence, economy, rewards, and all related player-centric operations.

## Core Principles

1. **Single Source of Truth**: DataStore access is only through ProfileRepository
2. **Layered Architecture**: Clear separation between storage, caching, validation, and services
3. **Complete Type Safety**: All modules use `--!strict` Luau typing
4. **Lifecycle Management**: All services follow Init → Start → Destroy pattern
5. **Immutable Infrastructure**: Use EconomyConstants for all configuration values

## Architecture

### Data Flow

```
DataStore ← ProfileRepository ← ProfileCache ← ProfileSerializer
                                              ← ProfileValidator
                                              ← SessionManager
                                              ← AutoSaveManager
                                                    ↓
DataService ← Orchestrates all data operations
                                                    ↓
PlayerService ← Session & player lifecycle management
                                                    ↓
EconomyService ← Economy operations (coins, XP)
RewardService ← Reward calculations
```

### Module Layers

#### 1. Storage Layer (ProfileRepository)
- **File**: `src/Shared/Domains/Player/ProfileRepository.lua`
- **Responsibility**: Direct DataStore access
- **Key Methods**: Load(userId), Save(profile)
- **Contract**: ONLY module that accesses DataStore

#### 2. Caching Layer (ProfileCache)
- **File**: `src/Server/Domains/Player/ProfileCache.lua`
- **Responsibility**: In-memory profile caching
- **Key Methods**: Set(userId, profile), Get(userId), Remove(userId)
- **Performance**: Reduces DataStore calls

#### 3. Validation Layer (ProfileValidator)
- **File**: `src/Shared/Domains/Player/ProfileValidator.lua`
- **Responsibility**: Data integrity and sanitization
- **Key Methods**: ValidateProfile(profile), Sanitize(profile)
- **Safety**: Clamps values to valid ranges

#### 4. Serialization Layer (ProfileSerializer)
- **File**: `src/Shared/Domains/Player/ProfileSerializer.lua`
- **Responsibility**: JSON serialization/deserialization
- **Key Methods**: Serialize(profile), Deserialize(json), Clone(profile)
- **Compatibility**: Handles complex nested structures

#### 5. Session Layer (SessionManager)
- **File**: `src/Server/Domains/Player/SessionManager.lua`
- **Responsibility**: Active session tracking
- **Key Methods**: CreateSession(), GetSession(), IsSessionActive()
- **Timeout**: 600 seconds (EconomyConstants.SESSION_TIMEOUT)

#### 6. Auto-Save Layer (AutoSaveManager)
- **File**: `src/Server/Domains/Player/AutoSaveManager.lua`
- **Responsibility**: Periodic profile saving
- **Key Methods**: RegisterProfile(), MarkDirty(), Start(), Stop()
- **Interval**: 60 seconds (EconomyConstants.AUTO_SAVE_INTERVAL)

#### 7. Signal Layer (PlayerSignals)
- **File**: `src/Server/Domains/Player/PlayerSignals.lua`
- **Responsibility**: Domain events
- **Signals**: ProfileLoaded, ProfileSaved, CoinsChanged, XPChanged, LevelChanged, StatsUpdated

### Service Layer

#### DataService
- **File**: `src/Server/Services/DataService.lua`
- **Responsibility**: Central data orchestrator
- **Key Methods**:
  - `LoadProfile(userId)`: Load from repository with validation
  - `SaveProfile(profile)`: Save with validation
  - `CreateProfile(userId)`: Create new profile from template
- **Dependencies**: ProfileRepository, ProfileValidator, ProfileTemplate
- **Contract**: ONLY service that accesses ProfileRepository

#### PlayerService
- **File**: `src/Server/Services/PlayerService.lua`
- **Responsibility**: Player lifecycle and session management
- **Key Methods**:
  - `GetProfile(userId)`: Get cached profile with lazy loading
  - `SaveProfile(userId)`: Save profile to DataStore
  - `AddCoins(userId, amount, reason)`: Add coins via EconomyService
  - `RemoveCoins(userId, amount, reason)`: Remove coins via EconomyService
- **Events**: 
  - PlayerAdded: On player join
  - PlayerRemoving: On player leave
- **Dependencies**: DataService, EconomyService, ProfileCache, SessionManager, AutoSaveManager

#### EconomyService
- **File**: `src/Server/Services/EconomyService.lua`
- **Responsibility**: Economy operations
- **Key Methods**:
  - `AddCoins(profile, amount, reason)`: Add coins
  - `RemoveCoins(profile, amount, reason)`: Remove coins (validates balance)
  - `SetCoins(profile, amount)`: Set exact coin amount
  - `AddXP(profile, amount)`: Add XP
  - `CheckLevelUp(profile)`: Check and process level up
- **Contract**: ONLY service that modifies coins
- **Constants**: Uses EconomyConstants.MaxValues, EconomyConstants.Rewards

#### RewardService
- **File**: `src/Server/Services/RewardService.lua`
- **Responsibility**: Reward value calculation and delivery
- **Key Methods**:
  - `GetKillReward()`: 200 coins
  - `GetHeadshotReward()`: 50 coins
  - `GetParticipationReward()`: 100 coins
  - `GetVictoryReward(gameMode)`: 500 (1v1) or 600 (4v4) coins
  - XP getters: GetKillXP(), GetHeadshotXP(), GetVictoryXP(), GetParticipationXP()
- **Constants**: Reads from EconomyConstants.Rewards and EconomyConstants.XP

### Type System (PlayerTypes)

```lua
type ProfileData = {
    UserId: number,
    Version: number,
    Coins: number,
    XP: number,
    Level: number,
    Rank: string,
    Stats: ProfileStats,
    Inventory: Inventory,
    Loadout: Loadout,
    Settings: Settings,
    BattlePass: BattlePass,
    DailyRewards: DailyRewards,
    Missions: {[string]: Mission},
    Achievements: {[string]: Achievement},
    CreatedAt: number,
    LastModified: number,
    LastLogin: number,
}

type ProfileStats = {
    Kills: number,
    Deaths: number,
    Assists: number,
    Headshots: number,
    Wins: number,
    Losses: number,
    PlayTime: number,
}

type Loadout = {
    Primary: string,
    Secondary: string,
    Knife: string,
    Trail: string?,
    KillEffect: string?,
}

type Settings = {
    Music: number,
    SFX: number,
    Sensitivity: number,
    FOV: number,
}

type Inventory = {
    Weapons: {[string]: any},
    Knives: {[string]: any},
    Skins: {[string]: any},
    Trails: {[string]: any},
    Effects: {[string]: any},
    Emotes: {[string]: any},
}

type BattlePass = {
    Active: boolean,
    Level: number,
    Progress: number,
}

type DailyRewards = {
    LastClaimTime: number,
    ConsecutiveDays: number,
    ClaimedToday: boolean,
}
```

### Constants (EconomyConstants)

```lua
PROFILE_VERSION = 1
AUTO_SAVE_INTERVAL = 60  -- seconds
SESSION_TIMEOUT = 600     -- seconds

Rewards = {
    Kill = 200,
    Headshot = 50,
    Participation = 100,
    Win1v1 = 500,
    Win4v4 = 600,
}

XP = {
    Kill = 25,
    Headshot = 10,
    Victory = 100,
    Participation = 20,
}

MaxValues = {
    Coins = 999999999,
    Level = 999,
    XP = 999999999,
}
```

## Usage Patterns

### Loading a Player Profile

```lua
local playerService = game:GetService("PlayerService")
local profile = playerService:GetProfile(userId)

-- First access loads from DataStore
-- Subsequent accesses return cached version
-- Automatically registered for auto-save
```

### Modifying Economy

```lua
-- Always through EconomyService via PlayerService
playerService:AddCoins(userId, 100, "KillReward")
playerService:RemoveCoins(userId, 50, "ItemPurchase")

-- NOT DIRECTLY:
-- profile.Coins = profile.Coins + 100  -- WRONG!
```

### Listening to Domain Events

```lua
local playerService = game:GetService("PlayerService")
local signals = playerService:GetSignals()

signals.CoinsChanged:Connect(function(profile)
    print("Player " .. profile.UserId .. " coins: " .. profile.Coins)
end)

signals.LevelChanged:Connect(function(profile)
    print("Player " .. profile.UserId .. " level: " .. profile.Level)
end)
```

### Auto-Save Guarantee

```lua
-- Auto-save happens every 60 seconds (EconomyConstants.AUTO_SAVE_INTERVAL)
-- Profiles marked as "dirty" are saved on next interval
-- On player leave, profile is immediately saved
-- No manual save() calls needed for normal operations
```

## Integration Points

### Required Services Registration
All services must be registered in ServiceContainer:

```lua
-- In ServiceLoader or Bootstrap
container:Register("DataService", DataService.new())
container:Register("PlayerService", PlayerService.new())
container:Register("EconomyService", EconomyService.new())
container:Register("RewardService", RewardService.new())
```

### Service Dependencies
After registration, services need to know about each other:

```lua
local playerService = container:Get("PlayerService")
local dataService = container:Get("DataService")
local economyService = container:Get("EconomyService")

playerService:SetDataService(dataService)
playerService:SetEconomyService(economyService)
```

### Other Systems Dependency
All other project systems should:
1. Get PlayerService from container
2. Use PlayerService to access player profiles
3. Listen to PlayerSignals for state changes
4. NEVER access ProfileRepository directly
5. NEVER access ProfileCache directly

## Error Handling

All modules include comprehensive error checking:

```lua
-- Validation errors are logged and recovered
local isValid, errorMsg = ProfileValidator:ValidateProfile(profile)
if not isValid then
    Logger:Warn("Profile validation failed: " .. errorMsg)
    profile = ProfileValidator:Sanitize(profile)
end

-- Session timeout detection
local isActive = SessionManager:IsSessionActive(userId)
if not isActive then
    -- Session expired, profile should be unloaded
end
```

## Performance Considerations

1. **Caching**: ProfileCache reduces DataStore calls to ~1 per session join + auto-saves
2. **Auto-Save Interval**: 60 seconds balances data loss risk vs. DataStore quota
3. **Session Timeout**: 600 seconds prevents stale sessions
4. **Lazy Loading**: Profiles load only when first requested
5. **Deep Copy**: ProfileSerializer creates independent copies to prevent mutations

## Testing

See `tests/test_player_domain.py` for validation tests:
- All modules exist and have correct structure
- Services have Init, Start, Destroy methods
- EconomyConstants has correct values
- Type definitions are complete

Run tests with:
```bash
python tests/test_player_domain.py
```

## Future Extensions

The Player Domain architecture supports:
- Additional stats tracking
- Premium currency system
- Cosmetic inventory system
- Achievements and challenges
- Trading systems
- Social features (friends, teams, guilds)
- Analytics integration
