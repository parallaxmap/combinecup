local playermeta = FindMetaTable("Player")

function playermeta:SpawnAtSpecificCheckpointEnt()
    timer.Simple(0, function()
		if player_manager.GetPlayerClass(self) == "player_spectator" then return end

        local targetID = self:GetNWInt("CurrentCheckpoint", 0)
        local spawnPoint = nil

        local classes = {"info_checkpoint_spawn", "trigger_checkpoint"}

        for _, class in ipairs(classes) do
            for _, ent in ipairs(ents.FindByClass(class)) do
                if ent.CheckpointID == targetID then
                    spawnPoint = ent
                    print(ent)
                    break
                end
            end
            if IsValid(spawnPoint) then break end
        end

        if IsValid(spawnPoint) then
            local pos = spawnPoint:GetClass() == "trigger_checkpoint" and spawnPoint:WorldSpaceCenter() or spawnPoint:GetPos()
            local ang = spawnPoint:GetAngles()

            if spawnPoint:GetClass() == "trigger_checkpoint" then
                pos = pos + Vector(0, 0, 10)
            end
            

            if IsValid(self.MyAirboat) then
                local veh = self.MyAirboat
                local phys = veh:GetPhysicsObject()
                
                if IsValid(phys) then
                    phys:SetVelocity(Vector(0, 0, 0))
                    phys:SetAngleVelocity(Vector(0, 0, 0))
                end

                veh:SetPos(pos)
                veh:SetAngles(ang)
                
                self:EnterVehicle(veh)
                self:SetEyeAngles(ang) 
            else
                local veh = ents.Create("prop_vehicle_airboat")
                veh:SetModel("models/airboat.mdl")
                veh:SetKeyValue("vehiclescript", "scripts/vehicles/airboat.txt")
                veh:SetPos(pos)
                veh:SetAngles(ang)
                veh:Spawn()
                veh:Activate()
                
                self.MyAirboat = veh
                self:EnterVehicle(veh)
            end
        end
    end)
end

function playermeta:RemovePlayerAirboat()
    if IsValid(self.MyAirboat) then
        local veh = self.MyAirboat
        if self:GetVehicle() == veh then
            self:ExitVehicle()
        end
        veh:Remove()
        self.MyAirboat = nil
    end
end

function playermeta:ResetRacerRunState()
    self:SetNWBool("RaceFinished", false)
    self:SetNWBool("RaceDNF", false)
    self:SetNWInt("FinishPosition", 0)
    self:SetNWFloat("FinishTime", 0)
end