AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("ui/race_hud.lua")
AddCSLuaFile("ui/bg_music.lua")
AddCSLuaFile("player_class/player_combinecup_spectator.lua")

include("shared.lua")
include("racer/racer_config.lua")
include("racer/airboat_config.lua")

local CC_SPECTATOR_CLASS = "player_combinecup_spectator"
local raceStartTime = 0
local finishedCount = 0

local function ResetRacerRunState(ply)
    if not IsValid(ply) then return end
    ply:SetNWBool("RaceFinished", false)
    ply:SetNWBool("RaceDNF", false)
    ply:SetNWInt("FinishPosition", 0)
    ply:SetNWFloat("FinishTime", 0)
end

local function FormatRaceTime(t)
    if not t or t <= 0 then return "0:00.00" end
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    return string.format("%d:%05.2f", minutes, seconds)
end

local function GetSpectateTargets()
    local t = {}
    for _, ply in ipairs(player.GetAll()) do
        if player_manager.GetPlayerClass(ply) == CC_SPECTATOR_CLASS then continue end
        if not ply:Alive() then continue end
        table.insert(t, ply)
    end
    return t
end

local function ApplySpectate(ply, target)
    if not IsValid(ply) then return end
    if player_manager.GetPlayerClass(ply) ~= CC_SPECTATOR_CLASS then return end

    ply:StripWeapons()
    ply:ExitVehicle()

    local mode = ply:GetNWInt("CC_SpecMode", OBS_MODE_CHASE)
    if mode ~= OBS_MODE_CHASE and mode ~= OBS_MODE_IN_EYE and mode ~= OBS_MODE_ROAMING then
        mode = OBS_MODE_CHASE
        ply:SetNWInt("CC_SpecMode", mode)
    end

    local targets = GetSpectateTargets()
    if not IsValid(target) then target = targets[1] end

    if IsValid(target) then
        if mode == OBS_MODE_IN_EYE and IsValid(target:GetVehicle()) then
            ply:SpectateEntity(target:GetVehicle())
        else
            ply:SpectateEntity(target)
        end
        ply:Spectate(mode)
    else
        ply:Spectate(OBS_MODE_ROAMING)
    end
end

local function RemovePlayerAirboat(ply)
    if not IsValid(ply) then return end

    if IsValid(ply.MyAirboat) then
        local veh = ply.MyAirboat
        if ply:GetVehicle() == veh then
            ply:ExitVehicle()
        end
        veh:Remove()
        ply.MyAirboat = nil
    end
end

local function EnterSpectator(ply)
    if not IsValid(ply) then return end

    RemovePlayerAirboat(ply)
    player_manager.SetPlayerClass(ply, CC_SPECTATOR_CLASS)
    ply:SetNWInt("CC_SpecMode", ply:GetNWInt("CC_SpecMode", OBS_MODE_CHASE))
    ply:KillSilent()
    ply:Spawn()

    ply:SetNoDraw(true)
    ply:SetMoveType(MOVETYPE_NOCLIP)
    ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

    ApplySpectate(ply)
end

local function ExitSpectator(ply)
    if not IsValid(ply) then return end
    if player_manager.GetPlayerClass(ply) ~= CC_SPECTATOR_CLASS then return end

    ply:UnSpectate()
    ply:Spectate(OBS_MODE_NONE)
    ply:SetNoDraw(false)
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)

    player_manager.SetPlayerClass(ply, "player_default")
    ply:KillSilent()
    ply:Spawn()
end

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
    if not IsValid(ply) then return end
    if ply:GetNWBool("RaceFinished", false) then return end

    finishedCount = finishedCount + 1
    ply:SetNWBool("RaceFinished", true)
    ply:SetNWBool("RaceDNF", false)
    ply:SetNWInt("FinishPosition", finishedCount)
    ply:SetNWFloat("FinishTime", (raceStartTime > 0) and (CurTime() - raceStartTime) or 0)
    ply:SetNWInt("RacePosition", finishedCount)

    EnterSpectator(ply)

    PrintMessage(
        HUD_PRINTTALK,
        ply:Nick()
            .. " finished #"
            .. ply:GetNWInt("FinishPosition")
            .. " ("
            .. FormatRaceTime(ply:GetNWFloat("FinishTime"))
            .. ")"
    )
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
    local finished = {}
    local unfinished = {}

    for _, ply in ipairs(racers) do
        local isSpectator = (player_manager.GetPlayerClass(ply) == CC_SPECTATOR_CLASS)
        local isFinished = ply:GetNWBool("RaceFinished", false)

        if isSpectator and not isFinished then
            -- late joiners / spectators shouldn't be ranked
            continue
        end

        if isFinished then
            table.insert(finished, ply)
            continue
        end

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
        
        table.insert(unfinished, {p = ply, s = totalScore})
    end

    table.sort(finished, function(a, b)
        return a:GetNWInt("FinishPosition", 0) < b:GetNWInt("FinishPosition", 0)
    end)
    table.sort(unfinished, function(a, b) return a.s > b.s end)

    local rank = 0
    for _, ply in ipairs(finished) do
        rank = rank + 1
        ply:SetNWInt("RacePosition", ply:GetNWInt("FinishPosition", rank))
    end

    for _, data in ipairs(unfinished) do
        rank = rank + 1
        data.p:SetNWInt("RacePosition", rank)
    end
end)

local VOICE_DISTANCE = 1000

-- no idea if this will actually work or not but lol

hook.Add("PlayerCanHearPlayersVoice", "ProximityVoice", function(listener, talker)
    local dist = listener:GetPos():Distance(talker:GetPos())
    return (dist <= VOICE_DISTANCE), true
end)

util.AddNetworkString("RaceTimerSync")
util.AddNetworkString("RaceCountdown")

local raceDuration = 180 
local raceEndTime = 0

function StartGlobalRace()
    timer.Remove("RaceEndTimer")
    raceEndTime = CurTime() + raceDuration

    net.Start("RaceTimerSync")
        net.WriteFloat(raceEndTime)
    net.Broadcast()

    timer.Create("RaceEndTimer", raceDuration, 1, function()
        SetGameState(STATE_RESULTS)
    end)
end

function StartRaceSequence()
    timer.Remove("LobbyToRaceTimer")
    net.Start("RaceCountdown")
    net.Broadcast()

    timer.Simple(3, function()
        SetGameState(STATE_RACING)
        
        for _, ply in ipairs(player.GetAll()) do
            local veh = ply:GetVehicle()
            if IsValid(veh) then
                local phys = veh:GetPhysicsObject()
                if IsValid(phys) then
                    phys:Wake()
                    phys:ApplyForceCenter(veh:GetForward() * 5000) 
                end
            end
        end
    end)
end

concommand.Add("start_race", function(ply)
    if not ply:IsSuperAdmin() then return end
    StartRaceSequence()
end)

concommand.Add("start_wait", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    StartWaitingTimer()
end)

util.AddNetworkString("GameStateSync")

function SetGameState(newState)
    CurrentGameState = newState
    SetGlobalInt("CurrentGameState", newState)

    net.Start("GameStateSync")
        net.WriteInt(newState, 4)
    net.Broadcast()

    if newState == STATE_WAITING then
        print("waiting for players...")
        timer.Remove("RaceEndTimer")
        -- stop all boats, reset positions...
        raceStartTime = 0
        finishedCount = 0
        for _, ply in ipairs(player.GetAll()) do
            ResetRacerRunState(ply)

            if player_manager.GetPlayerClass(ply) == CC_SPECTATOR_CLASS then
                ExitSpectator(ply) -- sets player_default + respawns
            else
                ply:UnSpectate()
                ply:Spectate(OBS_MODE_NONE)
                ply:SetNoDraw(false)
                ply:SetMoveType(MOVETYPE_WALK)
                ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
                player_manager.SetPlayerClass(ply, "player_default")
                ply:KillSilent()
                ply:Spawn()
            end
        end
    elseif newState == STATE_RACING then
        print("race started")
        raceStartTime = CurTime()
        finishedCount = 0
        for _, ply in ipairs(player.GetAll()) do
            ResetRacerRunState(ply)
        end
        StartGlobalRace() 
    elseif newState == STATE_RESULTS then
        print("race finished")
        timer.Remove("RaceEndTimer")
        net.Start("RaceTimerSync")
            net.WriteFloat(0)
        net.Broadcast()

        for _, ply in ipairs(player.GetAll()) do
            local isSpectator = (player_manager.GetPlayerClass(ply) == CC_SPECTATOR_CLASS)
            if not ply:GetNWBool("RaceFinished", false) and not isSpectator then
                ply:SetNWBool("RaceDNF", true)
                ply:SetNWFloat("FinishTime", 0)
                ply:SetNWInt("FinishPosition", 0)
            end
        end
    end
end

hook.Add("SetupMove", "FreezeInput", function(ply, mv, cmd)
    if CurrentGameState == STATE_WAITING then
        mv:SetButtons(0)
        mv:SetSideSpeed(0)
        mv:SetForwardSpeed(0)
        mv:SetUpSpeed(0)
    end
end)

hook.Add("Think", "FreezeAirboats", function()
    if CurrentGameState == STATE_WAITING then
        for _, ply in ipairs(player.GetAll()) do
            local veh = ply:GetVehicle()
            if IsValid(veh) then
                local phys = veh:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetVelocity(Vector(0, 0, 0))
                    phys:AddAngleVelocity(phys:GetAngleVelocity() * -1)
                    phys:Sleep() 
                end
            end
        end
    end
end)

local waitingDuration = 30
local waitingEndTime = 0

local function HumanCount()
    return #player.GetHumans()
end

local function StopWaitingCountdown()
    timer.Remove("LobbyToRaceTimer")
    waitingEndTime = 0
    net.Start("RaceTimerSync")
        net.WriteFloat(0)
    net.Broadcast()
end

function StartWaitingTimer()
    SetGameState(STATE_WAITING)
    timer.Remove("LobbyToRaceTimer")

    if HumanCount() < 2 then
        StopWaitingCountdown()
        return
    end

    waitingEndTime = CurTime() + waitingDuration

    net.Start("RaceTimerSync") 
        net.WriteFloat(waitingEndTime)
    net.Broadcast()

    timer.Create("LobbyToRaceTimer", waitingDuration, 1, function()
        StartRaceSequence()
    end)
end

function GM:Initialize()
    SetGameState(STATE_WAITING)
    StopWaitingCountdown()
end

hook.Add("Think", "CombineCup_WaitingCountdownGate", function()
    if CurrentGameState ~= STATE_WAITING then return end

    if HumanCount() >= 2 then
        if not timer.Exists("LobbyToRaceTimer") and waitingEndTime == 0 then
            StartWaitingTimer()
        end
    else
        if timer.Exists("LobbyToRaceTimer") or waitingEndTime ~= 0 then
            StopWaitingCountdown()
        end
    end
end)

hook.Add("PlayerDisconnected", "CombineCup_WaitingCountdownOnLeave", function()
    if CurrentGameState ~= STATE_WAITING then return end
    if HumanCount() < 2 then
        StopWaitingCountdown()
    end
end)

hook.Add("PlayerInitialSpawn", "SyncTimerOnJoin", function(ply)
    timer.Simple(2, function() 
        if IsValid(ply) then
            net.Start("GameStateSync")
                net.WriteInt(CurrentGameState, 4)
            net.Send(ply)

            net.Start("RaceTimerSync")
                net.WriteFloat(
                    (CurrentGameState == STATE_WAITING and waitingEndTime)
                    or (CurrentGameState == STATE_RACING and raceEndTime)
                    or 0
                )
            net.Send(ply)

            if CurrentGameState == STATE_RACING or CurrentGameState == STATE_RESULTS then
                EnterSpectator(ply)
            end
        end
    end)
end)

hook.Add("PlayerButtonDown", "CombineCup_SpectatorControls", function(ply, button)
    if not IsValid(ply) then return end
    if player_manager.GetPlayerClass(ply) ~= CC_SPECTATOR_CLASS then return end

    if button == MOUSE_LEFT or button == MOUSE_RIGHT then
        local targets = GetSpectateTargets()
        if #targets == 0 then
            ApplySpectate(ply, nil)
            return
        end

        local cur = ply:GetObserverTarget()
        local idx = 1
        for i, t in ipairs(targets) do
            if t == cur or (IsValid(t:GetVehicle()) and t:GetVehicle() == cur) then
                idx = i
                break
            end
        end

        if button == MOUSE_LEFT then
            idx = (idx % #targets) + 1
        else
            idx = ((idx - 2) % #targets) + 1
        end

        ApplySpectate(ply, targets[idx])
        return
    end

    if button == KEY_SPACE then
        local order = {OBS_MODE_CHASE, OBS_MODE_IN_EYE, OBS_MODE_ROAMING}
        local cur = ply:GetNWInt("CC_SpecMode", OBS_MODE_CHASE)
        local nextIdx = 1
        for i, m in ipairs(order) do
            if m == cur then
                nextIdx = (i % #order) + 1
                break
            end
        end
        ply:SetNWInt("CC_SpecMode", order[nextIdx])

        local curTarget = ply:GetObserverTarget()
        if IsValid(curTarget) and curTarget:IsVehicle() then
            curTarget = curTarget:GetDriver()
        end
        ApplySpectate(ply, curTarget)
        return
    end
end)

hook.Add("PlayerUse", "CombineCup_BlockSpectatorUse", function(ply, ent)
    if not IsValid(ply) then return end
    if player_manager.GetPlayerClass(ply) ~= CC_SPECTATOR_CLASS then return end

    if IsValid(ent) and (ent:IsVehicle() or ent:GetClass() == "prop_vehicle_airboat") then
        return false
    end
end)

hook.Add("CanPlayerEnterVehicle", "CombineCup_BlockSpectatorEnterVehicle", function(ply, veh, role)
    if not IsValid(ply) then return end
    if player_manager.GetPlayerClass(ply) ~= CC_SPECTATOR_CLASS then return end
    return false
end)

hook.Add("PlayerEnteredVehicle", "CombineCup_KickSpectatorOutOfVehicle", function(ply, veh, role)
    if not IsValid(ply) then return end
    if player_manager.GetPlayerClass(ply) ~= CC_SPECTATOR_CLASS then return end

    timer.Simple(0, function()
        if not IsValid(ply) then return end
        if ply:InVehicle() then
            ply:ExitVehicle()
        end
        ApplySpectate(ply, nil)
    end)
end)