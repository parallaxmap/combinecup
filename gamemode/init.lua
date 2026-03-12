AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("ui/race_hud.lua")
AddCSLuaFile("ui/bg_music.lua")

include("shared.lua")
include("racer/racer_config.lua")
include("racer/airboat_config.lua")

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
    player_manager.SetPlayerClass(ply, "player_spectator")

    PrintMessage(HUD_PRINTTALK, ply:Nick() .. " finished the race in pos #" .. ply:GetNWInt("RacePosition"))
end)

hook.Add("RacerCrossedCheckpoint", "SetNextCheckpoint", function(ply, cpt)
	ply:SetNWInt("CurrentCheckpoint", cpt.CheckpointID)
	ply:SetNWInt("NextCheckpoint", cpt.NextCheckpointID)
end)

local lastUpdate = 0
local checkpointPositions = {}

local lastPositionUpdate = 0

hook.Add("Think", "RacerPositionTracker", function()
    if CurTime() < lastPositionUpdate + 0.05 then return end
    lastPositionUpdate = CurTime()

    local racers = player.GetAll()
    local board = {}

    for _, ply in ipairs(racers) do
        local lap = ply:GetNWInt("CurrentLap", 1)
        local checkpoint = ply:GetNWInt("CurrentCheckpoint", 0)
        local nextCheckpointID = ply:GetNWInt("NextCheckpoint", 1)

        local targetPos = nil
        for _, ent in ipairs(ents.FindByClass("trigger_checkpoint")) do
            if ent.CheckpointID == nextCheckpointID then
                targetPos = ent:GetPos()
                break
            end
        end

        local distScore = 0
        if targetPos then
            local d = ply:GetPos():Distance(targetPos)
            distScore = math.max(0, 20000 - d)
        end

        local totalScore = (lap * 1000000) + (checkpoint * 20000) + distScore
        
        table.insert(board, {p = ply, s = totalScore})
    end

    table.sort(board, function(a, b) return a.s > b.s end)

    for rank, data in ipairs(board) do
        data.p:SetNWInt("RacePosition", rank)
    end
end)

local VOICE_DISTANCE = 1000

-- no idea if this will actually work or not but lol

hook.Add("PlayerCanHearPlayersVoice", "ProximityVoice", function(listener, talker)
    local dist = listener:GetPos():Distance(talker:GetPos())
    return (dist <= VOICE_DISTANCE), true
end)