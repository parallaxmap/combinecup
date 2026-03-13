function GM:PlayerSpawn(ply)
	if player_manager.GetPlayerClass(ply) != "player_spectator" then
        player_manager.SetPlayerClass(ply, "player_default")
    end

	ply:SetModel("models/player/group01/male_07.mdl")
	ply:SetupHands()

	ply:SetNWInt("CurrentCheckpoint", ply:GetNWInt("CurrentCheckpoint", 0))
	ply:SetNWInt("NextCheckpoint", ply:GetNWInt("NextCheckpoint", 1))

	ply:SetNWInt("CurrentLap", ply:GetNWInt("CurrentLap", 1))
    
    ply:SpawnAtSpecificCheckpointEnt()
end