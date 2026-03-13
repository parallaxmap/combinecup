local PLAYER = {}

PLAYER.DisplayName = "Spectator"
PLAYER.WalkSpeed = 0
PLAYER.RunSpeed = 0

function PLAYER:Spawn()
    local ply = self.Player
    if not IsValid(ply) then return end

    if SERVER then
        ply:StripWeapons()
        ply:AllowFlashlight(false)

        ply:SetNoDraw(true)
        ply:SetMoveType(MOVETYPE_NOCLIP)
        ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    end
end

player_manager.RegisterClass("player_spectator", PLAYER, "player_default")

