GM.Name = "Combine Cup"
GM.Author = "scuttlerpod"

if SERVER then
    AddCSLuaFile("player_class/player_combinecup_spectator.lua")
end
include("player_class/player_combinecup_spectator.lua")

STATE_WAITING = 1  
STATE_RACING  = 2  
STATE_RESULTS = 3  

CurrentGameState = CurrentGameState or STATE_WAITING

if CLIENT then
    net.Receive("GameStateSync", function()
        CurrentGameState = net.ReadInt(4)
    end)

    hook.Add("InitPostEntity", "CombineCup_InitialGameStatePull", function()
        CurrentGameState = GetGlobalInt("CurrentGameState", CurrentGameState)
    end)
end

AIRBOAT_MAX_BOOST = 100
AIRBOAT_BOOST_DRAIN = 40
AIRBOAT_BOOST_REGEN = 10
AIRBOAT_BOOST_FORCE = 250000 

function GM:Initialize()
end