SWEP.PrintName = "Quake"
SWEP.Base = "weapon_base"
SWEP.Instructions = "Send out a shockwave to disrupt other racers!"

SWEP.Spawnable = true 

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local radius = 300
    local force = 800
    local pos = owner:GetPos()

    owner:EmitSound("ambient/explosions/exp2.wav", 100, 120)

    local targets = ents.FindInSphere(pos, radius)

    for _, ent in ipairs(targets) do
        if ent == owner or ent == owner:GetVehicle() then continue end

        if ent:IsPlayer() or ent:GetMoveType() == MOVETYPE_VPHYSICS then
            
            local dir = (ent:GetPos() - pos):GetNormal()
            
            dir.z = dir.z + 0.5 
            
            if ent:IsPlayer() then
                ent:SetVelocity(dir * force)
            else
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    phys:ApplyForceCenter(dir * force * phys:GetMass())
                end
            end
        end
    end

    util.ScreenShake(pos, 10, 5, 1, radius)

    self:Remove()
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    owner:SetHealth(math.Clamp(owner:Health() + 30, 0, 100))
    self:Remove()
end
