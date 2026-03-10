hook.Add("CanExitVehicle", "PreventExit", function(ply, veh)
  return false
end)

hook.Add("Think", "AirboatBoost", function()
	for _, ply in ipairs(player.GetAll()) do
		ply.AirboatBoost = ply.AirboatBoost or AIRBOAT_MAX_BOOST
		
		local veh = ply:GetVehicle()
		local isBoosting = false

		if IsValid(veh) then
			local model = veh:GetModel()
			if veh:GetClass() == "prop_vehicle_airboat" or (model and string.find(model, "airboat")) then
				
				if ply:KeyDown(IN_SPEED) and ply.AirboatBoost > 0 then
					local phys = veh:GetPhysicsObject()
					if IsValid(phys) then
						local force = veh:GetForward() * AIRBOAT_BOOST_FORCE * FrameTime()
						phys:ApplyForceCenter(force)
						
						ply.AirboatBoost = math.max(0, ply.AirboatBoost - (AIRBOAT_BOOST_DRAIN * FrameTime()))
						isBoosting = true
					end
				end
			end
		end

		if not isBoosting and not ply:KeyDown(IN_SPEED) and ply.AirboatBoost < AIRBOAT_MAX_BOOST then
			ply.AirboatBoost = math.min(AIRBOAT_MAX_BOOST, ply.AirboatBoost + (AIRBOAT_BOOST_REGEN * FrameTime()))
		end

		ply:SetNWFloat("AirboatBoostAmount", ply.AirboatBoost)
		ply:SetNWInt("Checkpoint", 8)
	end
end)

hook.Add("PlayerEnteredVehicle", "EnableAirboatWeapons", function(ply, vehicle)
    if IsValid(vehicle) and vehicle:GetClass() == "prop_vehicle_airboat" then
        ply:SetAllowWeaponsInVehicle(true)
        
        local activeWep = ply:GetActiveWeapon()
        if IsValid(activeWep) then
            activeWep:SetNoDraw(false)
        end
    end
end)