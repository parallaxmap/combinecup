-- AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
end

function ENT:KeyValue(key, value)
    if key == "checkpoint_id" then
        self.CheckpointID = tonumber(value)
    elseif key == "next_checkpoint_id" then
        self.NextCheckpointID = tonumber(value)
    elseif key == "lap_checkpoint" then
        self.LapCheckpoint = (value == "1")
    end
end

function ENT:StartTouch(ent)
    if ent:IsPlayer() then
        print(ent:Nick() .. " crossed checkpoint " .. tostring(self.CheckpointID))

        if ent:GetNWInt("NextCheckpoint") == self.CheckpointID then
            hook.Run("RacerCrossedCheckpoint", ent, self)

            if self.LapCheckpoint == true then
                hook.Run("RacerCompletedLap", ent) 
            end

            ent:EmitSound("buttons/blip1.wav", 60, 100)
        end
    end
end

