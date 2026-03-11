SWEP.PrintName = "Heli Bomb"
SWEP.Base = "weapon_base"
SWEP.Instructions = "Primary: Drop a helicopter bomb behind your vehicle!"

SWEP.Spawnable = true 
SWEP.DrawAmmo = false

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1 

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:InVehicle() then return end

    local veh = owner:GetVehicle()
    
    local dropPos = veh:GetPos() + (veh:GetForward() * -100) + (veh:GetUp() * 20)

    local bomb = ents.Create("grenade_helicopter")
    if not IsValid(bomb) then return end

    bomb:SetPos(dropPos)
    bomb:SetAngles(veh:GetAngles())
    bomb:Spawn()
    bomb:Activate()

    bomb:SetOwner(owner)
    constraint.NoCollide(bomb, veh, 0, 0)

    local phys = bomb:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetBuoyancyRatio(0.6) 
        phys:Wake()
        phys:SetVelocity(veh:GetVelocity() * 0.8)
    end

    self:Remove()
end

function SWEP:SecondaryAttack()
end