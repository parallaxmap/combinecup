AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("racer/racer_config.lua")
include("racer/airboat_config.lua")

SetGlobalInt("TotalCheckpoints", 0)

hook.Add("InitPostEntity", "CalculateMapCheckpoints", function()
    local allCheckpoints = ents.FindByClass("trigger_checkpoint")
    local count = #allCheckpoints

    SetGlobalInt("TotalCheckpoints", count)

    print("found " .. count .. " checkpoints.")
    
    table.SortByMember(allCheckpoints, "CheckpointID", true)
    
    for i, cp in ipairs(allCheckpoints) do
        print(" checkpoint #" .. cp.CheckpointID .. " at " .. tostring(cp:GetPos()))
    end
end)

hook.Add("RacerCompletedLap", "HandleLapIncrement", function(ply)
    local currentLap = ply:GetNWInt("CurrentLap", 1)
    local maxLaps = GetGlobalInt("LapCount", 3)

    if currentLap < maxLaps then
        local nextLap = currentLap + 1
        
        ply:SetNWInt("CurrentLap", nextLap)
        ply:SetNWInt("CurrentCheckpoint", 0) 

		ply:EmitSound("buttons/button3.wav", 75, 110)
    else
        hook.Run("RacerFinishedRace", ply)
    end
end)

hook.Add("RacerFinishedRace", "AnnounceRacerFinish", function(ply)
    PrintMessage(HUD_PRINTTALK, ply:Nick() .. " finished the race!")
end)

hook.Add("RacerCrossedCheckpoint", "SetNextCheckpoint", function(ply, cpt)
	ply:SetNWInt("CurrentCheckpoint", cpt.CheckpointID)
	ply:SetNWInt("NextCheckpoint", cpt.NextCheckpointID)
end)