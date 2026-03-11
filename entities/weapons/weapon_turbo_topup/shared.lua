SWEP.PrintName = "Turbo Top-Up"
SWEP.Base = "weapon_base"
SWEP.Instructions = "Replenish your vehicle's turbo!"

SWEP.Spawnable = true 
SWEP.DrawAmmo = false

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1 

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local veh = owner:GetVehicle()
    if IsValid(veh) and veh:GetClass() == "prop_vehicle_airboat" then
        local turboAdd = math.Clamp(veh.AirboatBoost + 50, 0, 100)

        veh.AirboatBoost = turboAdd
        veh:SetNWFloat("AirboatBoostAmount", turboAdd)

        owner:EmitSound("player/suit_sprint.wav", 100, 100)

        self:Remove()
    end
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    owner:SetHealth(math.Clamp(owner:Health() + 15, 0, 100))
    owner:EmitSound("items/medshot4.wav", 75, 100)
    self:Remove()
end
