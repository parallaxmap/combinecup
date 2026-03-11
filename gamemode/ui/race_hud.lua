local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true, 
    ["CHudVehicle"] = true,
}
hook.Add("HUDShouldDraw", "HideDefaultHealthShield", function(name)
	if hide[name] then
		return false
	end
end)

local smoothBoost = 100 

hook.Add("HUDPaint", "RaceHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:InVehicle() then return end
    
    local veh = ply:GetVehicle()
    if not IsValid(veh) or not veh.GetVelocity then return end

    local velocity = veh:GetVelocity():Length()
    local displayMPH = math.Round(velocity * 0.0568)

    local targetBoost = veh:GetNWFloat("AirboatBoostAmount", 100)
    local currentCheckpoint = ply:GetNWInt("Checkpoint", 0)
    smoothBoost = Lerp(FrameTime() * 10, smoothBoost, targetBoost)
    
    local boostRatio = math.Clamp(smoothBoost / 100, 0, 1)
    
    -- CHECKPOINT DISPLAY 
    local cpX, cpY = 50, 30
    local cpW, cpH = 180, 40

    surface.SetFont("HudNumbers")
    local cpNumText = ply:GetNWInt("CurrentCheckpoint", 0) + 1 .. "/" .. GetGlobalInt("TotalCheckpoints")
    local cpNumW, cpNumH = surface.GetTextSize(cpNumText)

    surface.SetFont("HudHintTextLarge")
    local cpLabelW, cpLabelH = surface.GetTextSize("checkpoint")

    local cpTotalW = cpLabelW + cpNumW + 25

    draw.RoundedBox(6, cpX - 10, cpY, cpTotalW, cpH, Color(0, 0, 0, 80))
    draw.SimpleText("checkpoint", "HudHintTextLarge", cpX, cpY + 17, Color(255, 215, 0))
    draw.SimpleText(cpNumText, "HudNumbersGlow", cpX + cpLabelW + 5, cpY + 3, Color(255, 215, 0))
    draw.SimpleText(cpNumText, "HudNumbers", cpX + cpLabelW + 5, cpY + 3, Color(255, 215, 0))

    -- LAP DISPLAY
    local lpX, lpY = cpTotalW + 60, cpY
    local lpW, lpH = 180, 40

    surface.SetFont("HudNumbers")
    local lpNumText = ply:GetNWInt("CurrentLap", 1) .. "/" .. GetGlobalInt("LapCount")
    local lpNumW, lpNumH = surface.GetTextSize(lpNumText)

    surface.SetFont("HudHintTextLarge")
    local lpLabelW, lpLabelH = surface.GetTextSize("lap")

    draw.RoundedBox(6, lpX - 10, lpY, lpLabelW + lpNumW + 25, lpH, Color(0, 0, 0, 80))
    draw.SimpleText("lap", "HudHintTextLarge", lpX, lpY + 17, Color(255, 215, 0))
    draw.SimpleText(lpNumText, "HudNumbersGlow", lpX + lpLabelW + 5, lpY + 3, Color(255, 215, 0))
    draw.SimpleText(lpNumText, "HudNumbers", lpX + lpLabelW + 5, lpY + 3, Color(255, 215, 0))

    -- POS DISPLAY
    local posW, posH = 180, 40

    surface.SetFont("HudNumbers")
    local posNumText = ply:GetNWInt("RacePosition", 1) .. "/" .. #player.GetAll()

    local posNumW, posNumH = surface.GetTextSize(posNumText)

    surface.SetFont("HudHintTextLarge")
    local posLabelW, posLabelH = surface.GetTextSize("position")

    local posTotalW = posLabelW + posNumW + 30
    
    local posX, posY = ScrW() - posTotalW - 35, 30

    draw.RoundedBox(6, posX - 10, posY, posTotalW, posH, Color(0, 0, 0, 80))
    draw.SimpleText("position", "HudHintTextLarge", posX, posY + 17, Color(255, 215, 0))
    draw.SimpleText(posNumText, "HudNumbersGlow", posX + posLabelW + 5, posY + 3, Color(255, 215, 0))
    draw.SimpleText(posNumText, "HudNumbers", posX + posLabelW + 5, posY + 3, Color(255, 215, 0))

    local class = veh:GetClass()
    if class == "prop_vehicle_airboat" then
        -- BOOST BAR
        local boostX, boostY = 50, ScrH() - 55
        local boostW, boostH = 230, 20

        draw.RoundedBox(4, boostX - 10, boostY, boostW, boostH, Color(0, 0, 0, 80))
        draw.RoundedBox(2, boostX - 5, boostY + 5, (boostW - 10) * boostRatio, boostH - 10, Color(255, 215 * (targetBoost / 100), 0))

        -- SPEEDO
        local speedX, speedY = boostX, boostY - 43
        local speedW, speedH = 140, 45

        surface.SetFont("HudNumbers")
        local sNumW, sNumH = surface.GetTextSize(displayMPH)

        local sTotalW = sNumW + 55

        draw.RoundedBox(6, speedX - 10, speedY - 10, sTotalW, speedH, Color(0, 0, 0, 80))
        draw.SimpleText(displayMPH, "HudNumbersGlow", speedX + 2, speedY - 4, Color(255, 215, 0))
        draw.SimpleText(displayMPH, "HudNumbers", speedX + 2, speedY - 4, Color(255, 215, 0))
        draw.SimpleText("mph", "HudHintTextLarge", speedX + sNumW + 5, speedY + 11, Color(255, 215, 0))   
    end
end)

hook.Add("HUDPaint", "ShowRacerInfo", function()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end

    local myPos = lp:EyePos()
    local myVehicle = lp:GetVehicle()

    for _, ply in ipairs(player.GetAll()) do
        if not ply:Alive() or ply:GetNoDraw() then continue end

        local offset = ply:InVehicle() and Vector(0, 0, 60) or Vector(0, 0, 80)
        local targetPos = ply:GetPos() + offset
        local screenData = targetPos:ToScreen()

        if screenData.visible then
            local filterList = {lp, ply}
            if IsValid(myVehicle) then table.insert(filterList, myVehicle) end
            if IsValid(ply:GetVehicle()) then table.insert(filterList, ply:GetVehicle()) end

            local tr = util.TraceLine({
                start = myPos,
                endpos = targetPos,
                filter = filterList
            })

            if not tr.Hit then
                local dist = myPos:Distance(targetPos)
                local alpha = math.Clamp(255 - (dist / 4), 0, 255)

                if alpha > 0 then
                    local x, y = screenData.x, screenData.y
                    local col = Color(255, 215, 0, alpha)

                    local hp = 
                    draw.SimpleText(ply:Nick(), "DefaultFixedDropShadow", x, y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                    
                    local meters = math.Round(dist * 0.019, 1)
                    local speed = math.Round(ply:GetVehicle():GetVelocity():Length()* 0.0568)
                    draw.SimpleText("< " .. ply:Health() .. " hp / " .. meters .. " m / " .. speed .. " mph >", "DefaultFixedDropShadow", x, y + 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                end
            end
        end
    end
end)
