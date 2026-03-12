SWEP.PrintName = "Rollermine"
SWEP.Base = "weapon_base"
SWEP.Instructions = "Drop a rollermine that latches onto other racers!"

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

    local bomb = ents.Create("npc_rollermine")
    if not IsValid(bomb) then return end

    bomb:SetPos(dropPos)
    bomb:SetAngles(veh:GetAngles())
    bomb:Spawn()
    bomb:Activate()

    bomb:SetOwner(owner)

    local phys = bomb:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetBuoyancyRatio(0.6) 
        phys:Wake()
        phys:SetVelocity(veh:GetVelocity() * 0.8)
    end

    self:Remove()
end

function SWEP:Reload()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:InVehicle() then return end

    local veh = owner:GetVehicle()
    
    local dropPos = veh:GetPos() + (veh:GetUp() * 50)

    local bomb = ents.Create("npc_rollermine")
    if not IsValid(bomb) then return end

    bomb:SetPos(dropPos)
    bomb:SetAngles(veh:GetAngles())
    bomb:Spawn()
    bomb:Activate()

    bomb:SetOwner(owner)

    local phys = bomb:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetBuoyancyRatio(0.6) 
        phys:Wake()
        local throwForce = 1000 
        local forwardDir = veh:GetForward()
        local upDir = veh:GetUp()

        phys:SetVelocity(veh:GetVelocity() + (forwardDir * throwForce) + (upDir * (throwForce / 4)))
    end

    self:Remove()
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    owner:SetHealth(math.Clamp(owner:Health() + 30, 0, 100))
    owner:EmitSound("items/medshot4.wav", 75, 100)
    self:Remove()
end