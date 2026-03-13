AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/items/item_item_crate.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE) 
    self:SetTrigger(true) 
    self:SetNotSolid(true) 
    
    self.IsActive = true
end

function ENT:StartTouch(ent)
    if not self.IsActive then return end

    local ply = nil
    if ent:IsPlayer() then 
        ply = ent 
    elseif ent:GetClass() == "prop_vehicle_airboat" then 
        ply = ent:GetDriver()
    end

    if IsValid(ply) and ply:IsPlayer() then
        local lead_items = {"weapon_helibomb", "weapon_rollermine"}
        local normal_items = {"weapon_turbo_topup", "weapon_quake", "weapon_helibomb", "weapon_rollermine"}
        
        local items = {}

        if ply:GetNWInt("RacePosition") > 1 then
            items = normal_items
        else 
            items = lead_items
        end

        local randomItem = table.Random(items)
        ply:Give(randomItem)
        ply:SelectWeapon(randomItem)

        self:EmitSound("items/suitchargeok1.wav", 75, 100)
        self:SetNoDraw(true)
        self.IsActive = false

        timer.Simple(10, function()
            if IsValid(self) then
                self:SetNoDraw(false)
                self.IsActive = true
                self:EmitSound("hl1/fvox/bell.wav", 65, 100)
            end
        end)
    end
end