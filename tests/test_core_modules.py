from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_core_modules_exist() -> None:
    required_files = [
        "src/Shared/Core/Game.lua",
        "src/Shared/Core/ServiceContainer.lua",
        "src/Shared/Core/ControllerContainer.lua",
        "src/Shared/Core/EventBus.lua",
        "src/Shared/Modules/Signal.lua",
        "src/Shared/Core/Logger.lua",
        "src/Shared/Core/ResourceCleaner.lua",
        "src/Shared/Core/TaskScheduler.lua",
        "src/Server/ServiceLoader.lua",
        "src/client/ControllerLoader.lua",
        "src/Shared/Core/RemoteRegistry.lua",
        "src/Shared/Constants/GameConstants.lua",
        "src/Shared/Types/Types.lua",
        "src/Shared/Utilities/Utilities.lua",
    ]

    for relative_path in required_files:
        assert (ROOT / relative_path).exists(), f"Missing required module: {relative_path}"


def test_core_modules_expose_expected_lifecycle_members() -> None:
    game_module = read("src/Shared/Core/Game.lua")
    service_container = read("src/Shared/Core/ServiceContainer.lua")
    controller_container = read("src/Shared/Core/ControllerContainer.lua")
    event_bus = read("src/Shared/Core/EventBus.lua")
    logger = read("src/Shared/Core/Logger.lua")
    cleaner = read("src/Shared/Core/ResourceCleaner.lua")
    scheduler = read("src/Shared/Core/TaskScheduler.lua")
    service_loader = read("src/Server/ServiceLoader.lua")
    controller_loader = read("src/client/ControllerLoader.lua")
    remote_registry = read("src/Shared/Core/RemoteRegistry.lua")
    constants = read("src/Shared/Constants/GameConstants.lua")
    types_module = read("src/Shared/Types/Types.lua")
    utilities = read("src/Shared/Utilities/Utilities.lua")

    assert "function Game:Initialize" in game_module
    assert "function Game:Start" in game_module
    assert "function Game:Destroy" in game_module
    assert "function ServiceContainer:InitializeAll" in service_container
    assert "function ServiceContainer:StartAll" in service_container
    assert "function ServiceContainer:DestroyAll" in service_container
    assert "function ControllerContainer:InitializeAll" in controller_container
    assert "function ControllerContainer:StartAll" in controller_container
    assert "function ControllerContainer:DestroyAll" in controller_container
    assert "function EventBus:Connect" in event_bus
    assert "function EventBus:Fire" in event_bus
    assert "function Logger:Info" in logger
    assert "function ResourceCleaner:Cleanup" in cleaner
    assert "function TaskScheduler:Schedule" in scheduler
    assert "function ServiceLoader:Load" in service_loader
    assert "function ControllerLoader:Load" in controller_loader
    assert "function RemoteRegistry:RegisterEvent" in remote_registry
    assert "function RemoteRegistry:RegisterFunction" in remote_registry
    assert "GameConstants.GameName" in constants
    assert "export type Lifecycle" in types_module
    assert "function Utilities.DeepCopy" in utilities


if __name__ == "__main__":
    test_core_modules_exist()
    test_core_modules_expose_expected_lifecycle_members()
    print("Core module tests passed")
