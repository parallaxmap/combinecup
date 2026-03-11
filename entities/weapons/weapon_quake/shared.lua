SWEP.PrintName = "Quake"
SWEP.Base = "weapon_base"
SWEP.Instructions = "bahdiuasdhusaudashuiui"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.Spawnable = true 

function SWEP:PrimaryAttack()
    print("quake")
    self:Remove()
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    owner:SetHealth(math.Clamp(owner:Health() + 30, 0, 100))
    self:Remove()
end
