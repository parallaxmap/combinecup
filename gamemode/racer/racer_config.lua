function GM:PlayerSpawn(ply)
	ply:SetModel("models/player/group01/male_07.mdl")
	ply:SetupHands()

	ply:Give("weapon_quake")

	local spawnPos = ply:GetPos() + Vector(0, 0, 50)
	local airboat = ents.Create("prop_vehicle_airboat")

	if IsValid(airboat) then
		airboat:SetModel("models/airboat.mdl")
		airboat:SetKeyValue("vehiclescript", "scripts/vehicles/airboat.txt")
		airboat:SetPos(spawnPos)
		airboat:SetAngles(ply:GetAngles())
		airboat:Spawn()
		airboat:Activate()

		timer.Simple(0.1, function()
			if IsValid(ply) and IsValid(airboat) then
				ply:EnterVehicle(airboat)
			end
		end)
		airboat:SetNWEntity("Owner", ply)
	end
end