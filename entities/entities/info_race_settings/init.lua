ENT.Type = "point"
ENT.Base = "base_point"

function ENT:KeyValue(key, value)
    if key == "lap_count" then
        SetGlobalInt("LapCount", tonumber(value))
        print("map has " .. value .. " laps")
    end
end