hook.Add("CanExitVehicle", "PreventExit", function(ply, veh)
  return false
end)

hook.Add("Think", "AirboatBoost", function()
    for _, veh in ipairs(ents.FindByClass("prop_vehicle_airboat")) do
        if not IsValid(veh) then continue end

        veh.AirboatBoost = veh.AirboatBoost or AIRBOAT_MAX_BOOST
        
        local ply = veh:GetDriver()
        local isBoosting = false

        if IsValid(ply) and ply:IsPlayer() then
            if ply:KeyDown(IN_SPEED) and veh.AirboatBoost > 0 then
                local phys = veh:GetPhysicsObject()
                if IsValid(phys) then
                    local force = veh:GetForward() * AIRBOAT_BOOST_FORCE * FrameTime()
                    phys:ApplyForceCenter(force)
                    
                    veh.AirboatBoost = math.max(0, veh.AirboatBoost - (AIRBOAT_BOOST_DRAIN * FrameTime()))
                    isBoosting = true
                end
            end
        end

        if not isBoosting and veh.AirboatBoost < AIRBOAT_MAX_BOOST and not ply:KeyDown(IN_SPEED) then
            veh.AirboatBoost = math.min(AIRBOAT_MAX_BOOST, veh.AirboatBoost + (AIRBOAT_BOOST_REGEN * FrameTime()))
        end

        veh:SetNWFloat("AirboatBoostAmount", veh.AirboatBoost)
    end
end)

hook.Add("PlayerEnteredVehicle", "SetupAirboatDriver", function(ply, vehicle)
    if IsValid(vehicle) and vehicle:GetClass() == "prop_vehicle_airboat" then
        ply:SetAllowWeaponsInVehicle(true)

        if not IsValid(ply.MyRacingBoat) then
            ply.MyRacingBoat = veh
            veh.BoatOwner = ply 
        end
        
        local activeWep = ply:GetActiveWeapon()
        if IsValid(activeWep) then
            activeWep:SetNoDraw(false)
        end
    end
end)

