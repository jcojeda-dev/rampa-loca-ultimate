#!/usr/bin/env python3
"""
Tests for the Player Domain modules
"""

import os
import json

# Paths to validate
test_dir = os.path.dirname(os.path.abspath(__file__))
workspace_root = os.path.dirname(test_dir)
src_dir = os.path.join(workspace_root, "src")

def test_player_domain_modules_exist():
    """Test that all player domain modules exist"""
    
    # Domain modules
    domain_modules = [
        "Shared/Domains/Player/PlayerTypes.lua",
        "Shared/Domains/Player/ProfileTemplate.lua",
        "Shared/Domains/Player/ProfileValidator.lua",
        "Shared/Domains/Player/ProfileSerializer.lua",
        "Server/Domains/Player/ProfileRepository.lua",
        "Server/Domains/Player/ProfileCache.lua",
        "Server/Domains/Player/SessionManager.lua",
        "Server/Domains/Player/AutoSaveManager.lua",
        "Server/Domains/Player/PlayerSignals.lua",
    ]
    
    for module in domain_modules:
        path = os.path.join(src_dir, module)
        assert os.path.exists(path), f"Missing module: {module}"
        assert os.path.getsize(path) > 0, f"Empty module: {module}"
    
    print("✓ All player domain modules exist")

def test_service_modules_exist():
    """Test that all service modules exist and have been updated"""
    
    service_modules = [
        "Server/Services/DataService.lua",
        "Server/Services/PlayerService.lua",
        "Server/Services/EconomyService.lua",
        "Server/Services/RewardService.lua",
    ]
    
    for module in service_modules:
        path = os.path.join(src_dir, module)
        assert os.path.exists(path), f"Missing service: {module}"
        assert os.path.getsize(path) > 0, f"Empty service: {module}"
    
    print("✓ All service modules exist")

def test_constants_exist():
    """Test that EconomyConstants exists"""
    
    constants_path = os.path.join(src_dir, "Shared/Constants/EconomyConstants.lua")
    assert os.path.exists(constants_path), "Missing EconomyConstants.lua"
    assert os.path.getsize(constants_path) > 0, "Empty EconomyConstants.lua"
    
    # Check that it contains expected values
    with open(constants_path, 'r') as f:
        content = f.read()
        assert "AUTO_SAVE_INTERVAL" in content, "Missing AUTO_SAVE_INTERVAL"
        assert "SESSION_TIMEOUT" in content, "Missing SESSION_TIMEOUT"
        assert "Rewards" in content, "Missing Rewards configuration"
    
    print("✓ EconomyConstants exists and has expected structure")

def test_player_types_complete():
    """Test that PlayerTypes has all required type definitions"""
    
    types_path = os.path.join(src_dir, "Shared/Domains/Player/PlayerTypes.lua")
    with open(types_path, 'r') as f:
        content = f.read()
        required_types = [
            "ProfileData",
            "ProfileStats",
            "Loadout",
            "Settings",
            "Inventory",
            "BattlePass",
            "DailyRewards",
            "Session",
            "RewardEvent",
        ]
        for type_name in required_types:
            assert f"type {type_name}" in content, f"Missing type: {type_name}"
    
    print("✓ PlayerTypes has all required type definitions")

def test_lifecycle_methods():
    """Test that services have Init, Start, Destroy methods"""
    
    service_modules = [
        ("Server/Services/DataService.lua", "DataService"),
        ("Server/Services/PlayerService.lua", "PlayerService"),
        ("Server/Services/EconomyService.lua", "EconomyService"),
        ("Server/Services/RewardService.lua", "RewardService"),
    ]
    
    for module_path, service_name in service_modules:
        path = os.path.join(src_dir, module_path)
        with open(path, 'r') as f:
            content = f.read()
            assert f"function {service_name}:Init" in content, f"Missing Init in {service_name}"
            assert f"function {service_name}:Start" in content, f"Missing Start in {service_name}"
            assert f"function {service_name}:Destroy" in content, f"Missing Destroy in {service_name}"
    
    print("✓ All services have Init, Start, Destroy methods")

def test_economy_constants_values():
    """Test that EconomyConstants has the correct reward values"""
    
    constants_path = os.path.join(src_dir, "Shared/Constants/EconomyConstants.lua")
    with open(constants_path, 'r') as f:
        content = f.read()
        
        # Check reward values
        assert "Kill = 200" in content or "Kill=200" in content, "Kill reward should be 200"
        assert "Headshot = 50" in content or "Headshot=50" in content, "Headshot reward should be 50"
        assert "Participation = 100" in content or "Participation=100" in content, "Participation reward should be 100"
        assert "Win1v1 = 500" in content or "Win1v1=500" in content, "Win1v1 reward should be 500"
        assert "Win4v4 = 600" in content or "Win4v4=600" in content, "Win4v4 reward should be 600"
    
    print("✓ EconomyConstants has correct reward values")

if __name__ == "__main__":
    test_player_domain_modules_exist()
    test_service_modules_exist()
    test_constants_exist()
    test_player_types_complete()
    test_lifecycle_methods()
    test_economy_constants_values()
    
    print("\n✅ All player domain tests passed!")
