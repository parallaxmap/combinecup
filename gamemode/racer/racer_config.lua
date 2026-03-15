function GM:PlayerSpawn(ply)
	if player_manager.GetPlayerClass(ply) != "player_spectator" then
        player_manager.SetPlayerClass(ply, "player_default")
    end

	local models = {
		"male_07", 
		"breen",
		"alyx",
		"gman_high",
		"barney",
		"police", 
		"combine_soldier",
		"combine_super_soldier",
		"zombie_soldier",

		"group03/male_01",
		"group03/male_02",
		"group03/male_03",
		"group03/male_04",
		"group03/male_05",
		"group03/male_06",
		"group03/male_07",
		"group03/male_08",
		"group03/male_09",

		"group03/female_01",
		"group03/female_02",
		"group03/female_03",
		"group03/female_04",
		"group03/female_05",
		"group03/female_06",
	}

	local model = "models/player/" .. table.Random(models) .. ".mdl"

	ply:SetModel(model)

	local r = math.random(0, 255) / 255
	local g = math.random(0, 255) / 255
	local b = math.random(0, 255) / 255

	ply:SetPlayerColor( Vector( r, g, b ) )
	ply:SetupHands()

	ply:SetNWInt("CurrentCheckpoint", ply:GetNWInt("CurrentCheckpoint", 0))
	ply:SetNWInt("NextCheckpoint", ply:GetNWInt("NextCheckpoint", 1))

	ply:SetNWInt("CurrentLap", ply:GetNWInt("CurrentLap", 1))
    
    ply:SpawnAtSpecificCheckpointEnt()
end

hook.Add("PlayerInitialSpawn", "PlayerRandomAppearance", function(ply)
    local models = {
        "breen", "alyx", "gman_high", "barney", "police", 
        "combine_soldier", "combine_super_soldier", "zombie_soldier",
        "group03/male_01", "group03/male_02", "group03/male_03",
        "group03/male_04", "group03/male_05", "group03/male_06",
        "group03/male_07", "group03/male_08", "group03/male_09",
        "group03/female_01", "group03/female_02", "group03/female_03",
        "group03/female_04", "group03/female_05", "group03/female_06",
    }

    local id = ply:SteamID()

    local modelIndex = math.floor(util.SharedRandom("playermodel", 1, #models, id))
    local randomModel = models[modelIndex]

    local r = util.SharedRandom("playercolor_r", 0, 1, id)
    local g = util.SharedRandom("playercolor_g", 0, 1, id)
    local b = util.SharedRandom("playercolor_b", 0, 1, id)

    timer.Simple(0, function()
        if not IsValid(ply) then return end
        
        ply:SetModel("models/player/" .. randomModel .. ".mdl")
        ply:SetPlayerColor(Vector(r, g, b))
        ply:SetupHands()
    end)
end)