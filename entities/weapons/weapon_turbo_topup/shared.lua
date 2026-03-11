SWEP.PrintName = "Turbo Top-Up"
SWEP.Base = "weapon_base"
SWEP.Instructions = "Replenish your vehicle's turbo!"

SWEP.Spawnable = true 
SWEP.DrawAmmo = false

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local veh = owner:GetVehicle()
    if IsValid(veh) and veh:GetClass() == "prop_vehicle_airboat" then
        local turboAdd = math.Clamp(veh.AirboatBoost + 50, 0, 100)

        veh.AirboatBoost = turboAdd
        veh:SetNWFloat("AirboatBoostAmount", turboAdd)

        self:Remove()
    end
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    owner:SetHealth(math.Clamp(owner:Health() + 15, 0, 100))
    self:Remove()
end
