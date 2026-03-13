ENT.Type = "point"
ENT.Base = "base_point"

function ENT:KeyValue(key, value)
    if key == "lap_count" then
        SetGlobalInt("LapCount", tonumber(value))
    elseif key == "race_duration" then
        RACE_DURATION = tonumber(value)
    end
end