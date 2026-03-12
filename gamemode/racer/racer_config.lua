function GM:PlayerSpawn(ply)
	if player_manager.GetPlayerClass(ply) != "player_combinecup_spectator" then
        player_manager.SetPlayerClass(ply, "player_default")
    end

	ply:SetModel("models/player/group01/male_07.mdl")
	ply:SetupHands()

	ply:SetNWInt("CurrentCheckpoint", ply:GetNWInt("CurrentCheckpoint", 0))
	ply:SetNWInt("NextCheckpoint", ply:GetNWInt("NextCheckpoint", 1))

	ply:SetNWInt("CurrentLap", ply:GetNWInt("CurrentLap", 1))
end

hook.Add("PlayerSpawn", "SpawnAtSpecificCheckpointEnt", function(ply)

    timer.Simple(0, function()
        if not IsValid(ply) then return end
		if player_manager.GetPlayerClass(ply) == "player_combinecup_spectator" then return end

        local targetID = ply:GetNWInt("CurrentCheckpoint", 0)
        local spawnPoint = nil

        for _, ent in ipairs(ents.FindByClass("info_checkpoint_spawn")) do
            if ent.CheckpointID == targetID then
                spawnPoint = ent
                break
            end
        end

        if IsValid(spawnPoint) then
            local pos = spawnPoint:GetPos()
            local ang = spawnPoint:GetAngles()

            if IsValid(ply.MyAirboat) then
                local veh = ply.MyAirboat
                local phys = veh:GetPhysicsObject()
                
                if IsValid(phys) then
                    phys:SetVelocity(Vector(0, 0, 0))
                    phys:SetAngleVelocity(Vector(0, 0, 0))
                end

                veh:SetPos(pos)
                veh:SetAngles(ang)
                
                ply:EnterVehicle(veh)
                ply:SetEyeAngles(ang) 
            else
                local veh = ents.Create("prop_vehicle_airboat")
                veh:SetModel("models/airboat.mdl")
                veh:SetKeyValue("vehiclescript", "scripts/vehicles/airboat.txt")
                veh:SetPos(pos)
                veh:SetAngles(ang)
                veh:Spawn()
                
                ply.MyAirboat = veh
                ply:EnterVehicle(veh)
            end
        end
    end)
end)