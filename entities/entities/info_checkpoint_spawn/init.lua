-- AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
end

function ENT:KeyValue(key, value)
    if key == "checkpoint_id" then
        self.CheckpointID = tonumber(value)
    end
end

