include("shared.lua")

function ENT:Draw()
    if not self:GetNWBool("IsActive", true) then return end

    local time = CurTime()
    local ang = Angle(0, time * 90, 0)

    self:SetRenderAngles(ang)
    
    self:DrawModel()
end