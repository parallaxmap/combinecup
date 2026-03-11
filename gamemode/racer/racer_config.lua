function GM:PlayerSpawn(ply)
	ply:SetModel("models/player/group01/male_07.mdl")
	ply:SetupHands()

	ply:Give("weapon_turbo_topup")

	ply:SetNWInt("CurrentCheckpoint", ply:GetNWInt("CurrentCheckpoint", 0))
	ply:SetNWInt("NextCheckpoint", ply:GetNWInt("NextCheckpoint", 1))

	ply:SetNWInt("CurrentLap", ply:GetNWInt("CurrentLap", 1))
end

hook.Add("PlayerSpawn", "SpawnAtSpecificCheckpointEnt", function(ply)
    timer.Simple(0, function()
        if not IsValid(ply) then return end

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

            if IsValid(ply.MyRacingBoat) then
                local veh = ply.MyRacingBoat
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
                
                ply.MyRacingBoat = veh
                ply:EnterVehicle(veh)
            end
        end
    end)
end)