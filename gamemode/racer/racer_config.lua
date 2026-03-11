function GM:PlayerSpawn(ply)
	ply:SetModel("models/player/group01/male_07.mdl")
	ply:SetupHands()

	ply:Give("weapon_turbo_topup")

	ply:SetNWInt("CurrentCheckpoint", ply:GetNWInt("CurrentCheckpoint", 0))
	ply:SetNWInt("NextCheckpoint", ply:GetNWInt("NextCheckpoint", 1))

	ply:SetNWInt("CurrentLap", ply:GetNWInt("CurrentLap", 1))
end

hook.Add("PlayerSpawn", "RacerRespawn", function(ply)
    timer.Simple(0, function()
        if not IsValid(ply) then return end

        local spawnPos = ply:GetPos() + Vector(0, 0, 50)
        local spawnAng = ply:GetAngles()

        if IsValid(ply.MyRacingBoat) then
            local veh = ply.MyRacingBoat
            
            local phys = veh:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(Vector(0, 0, 0))
                phys:SetAngleVelocity(Vector(0, 0, 0))
            end

            veh:SetPos(spawnPos)
            veh:SetAngles(spawnAng)

            ply:EnterVehicle(veh)
            
            veh:SetHealth(math.max(veh:GetHealth(), 50))
        else
            local veh = ents.Create("prop_vehicle_airboat")
            if not IsValid(veh) then return end
            
            veh:SetModel("models/airboat.mdl")
            veh:SetKeyValue("vehiclescript", "scripts/vehicles/airboat.txt")
            veh:SetPos(spawnPos)
            veh:SetAngles(spawnAng)
            veh:Spawn()
            veh:Activate()

            ply.MyRacingBoat = veh
            ply:EnterVehicle(veh)
        end
    end)
end)