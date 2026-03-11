SWEP.PrintName = "Quake"
SWEP.Base = "weapon_base"
SWEP.Instructions = "Send out a shockwave to disrupt other racers!"

SWEP.Spawnable = true 
SWEP.DrawAmmo = false

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1 

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local radius = 300
    local force = 800
    local damage = 100
    local pos = owner:GetPos()

    owner:EmitSound("ambient/explosions/exp2.wav", 100, 120)

    local targets = ents.FindInSphere(pos, radius)

    for _, ent in ipairs(targets) do
        if ent == owner or ent == owner:GetVehicle() then continue end

        if ent:IsNPC() then
            local d = DamageInfo()
            d:SetDamage(damage)
            d:SetAttacker(owner)
            d:SetInflictor(self)
            d:SetDamageType(DMG_BLAST)
            d:SetDamagePosition(pos)
            
            ent:TakeDamageInfo(d)
        end

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
    owner:EmitSound("items/medshot4.wav", 75, 100)
    self:Remove()
end
