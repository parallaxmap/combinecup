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
    if not IsValid(ply) then return end

    local stateText = "unknown"
    
    if CurrentGameState == STATE_WAITING then
        stateText = "Waiting to start..."
    elseif CurrentGameState == STATE_RACING then
        stateText = ""
    elseif CurrentGameState == STATE_RESULTS then
        stateText = "Race finished!"
    end

    draw.SimpleText(stateText, "DermaDefault", ScrW()/2, ScrH() - 100, color_white, TEXT_ALIGN_CENTER)

    if CurrentGameState == STATE_RESULTS then
        local entries = {}
        for _, p in ipairs(player.GetAll()) do
            table.insert(entries, {
                ply = p,
                finished = p:GetNWBool("RaceFinished", false),
                dnf = p:GetNWBool("RaceDNF", false),
                pos = p:GetNWInt("FinishPosition", 0),
                t = p:GetNWFloat("FinishTime", 0),
            })
        end

        table.sort(entries, function(a, b)
            if a.finished ~= b.finished then return a.finished end
            if a.finished and b.finished then return a.pos < b.pos end
            if a.dnf ~= b.dnf then return not a.dnf end
            return a.ply:Nick() < b.ply:Nick()
        end)

        local function fmtTime(t)
            if not t or t <= 0 then return "--:--.--" end
            local m = math.floor(t / 60)
            local s = t - (m * 60)
            return string.format("%d:%05.2f", m, s)
        end

        local x = ScrW() / 2
        local y = 110

        draw.SimpleText("Results", "DermaLarge", x, y - 40, Color(255, 215, 0), TEXT_ALIGN_CENTER)

        local maxRows = math.min(#entries, 10)
        for i = 1, maxRows do
            local e = entries[i]
            local name = IsValid(e.ply) and e.ply:Nick() or "?"
            local left = ""
            if e.finished then
                left = string.format("#%d", e.pos)
            elseif e.dnf then
                left = "DNF"
            else
                left = "-"
            end

            local line = string.format("%s  %s  %s", left, name, e.finished and fmtTime(e.t) or "")
            local col = e.finished and Color(255, 255, 255) or (e.dnf and Color(200, 200, 200) or Color(255, 255, 255))
            draw.SimpleText(line, "DermaDefault", x, y + (i - 1) * 18, col, TEXT_ALIGN_CENTER)
        end
    end

    if player_manager.GetPlayerClass(ply) == "player_spectator" then 
        draw.SimpleText("SPECTATING", "DermaDefault", ScrW()/2, 50, color_white, TEXT_ALIGN_CENTER)
        return 
    else
        local veh = ply:GetVehicle() 
        if not IsValid(veh) then return end

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
        local myPos = ply:GetNWBool("RaceFinished", false) and ply:GetNWInt("FinishPosition", ply:GetNWInt("RacePosition", 1)) or ply:GetNWInt("RacePosition", 1)
        local posNumText = myPos .. "/" .. #player.GetAll()

        local posNumW, posNumH = surface.GetTextSize(posNumText)

        surface.SetFont("HudHintTextLarge")
        local posLabelW, posLabelH = surface.GetTextSize("position")

        local posTotalW = posLabelW + posNumW + 30
        
        local posX, posY = ScrW() - posTotalW - 35, 30

        draw.RoundedBox(6, posX - 10, posY, posTotalW, posH, Color(0, 0, 0, 80))
        draw.SimpleText("position", "HudHintTextLarge", posX, posY + 17, Color(255, 215, 0))
        draw.SimpleText(posNumText, "HudNumbersGlow", posX + posLabelW + 5, posY + 3, Color(255, 215, 0))
        draw.SimpleText(posNumText, "HudNumbers", posX + posLabelW + 5, posY + 3, Color(255, 215, 0))

        -- HP DISPLAY
        local hpW, hpH = 180, 40

        surface.SetFont("HudNumbers")
        local hpNumText = ply:Health()

        local hpNumW, hpNumH = surface.GetTextSize(hpNumText)

        surface.SetFont("HudHintTextLarge")
        local hpLabelW, hpLabelH = surface.GetTextSize("position")

        local hpTotalW = hpLabelW + hpNumW + 30
        
        local hpX, hpY = posX - hpTotalW - 10, 30

        draw.RoundedBox(6, hpX - 10, hpY, hpTotalW, hpH, Color(0, 0, 0, 80))
        draw.SimpleText("health", "HudHintTextLarge", hpX, hpY + 17, Color(255, 215, 0))
        draw.SimpleText(hpNumText, "HudNumbersGlow", hpX + hpLabelW + 5, hpY + 3, Color(255, 215, 0))
        draw.SimpleText(hpNumText, "HudNumbers", hpX + hpLabelW + 5, hpY + 3, Color(255, 215, 0))

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
    end
end)

hook.Add("HUDPaint", "ShowRacerInfo", function()
    local lp = LocalPlayer()
    if not IsValid(lp) or player_manager.GetPlayerClass(lp) == "player_spectator" then return end

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

                    draw.SimpleText(ply:Nick(), "DefaultFixedDropShadow", x, y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                    
                    local meters = math.Round(dist * 0.019, 1)
                    local speed = math.Round(ply:GetVehicle():GetVelocity():Length()* 0.0568)
                    draw.SimpleText("< " .. ply:Health() .. " hp / " .. meters .. " m / " .. speed .. " mph >", "DefaultFixedDropShadow", x, y + 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                end
            end
        end
    end
end)

local endRaceTime = 0

net.Receive("RaceTimerSync", function()
    endRaceTime = net.ReadFloat()
end)

hook.Add("HUDPaint", "RaceTimerHUD", function()
    if endRaceTime == 0 or CurTime() > endRaceTime then return end

    local timeLeft = math.max(0, endRaceTime - CurTime())
    
    local minutes = math.floor(timeLeft / 60)
    local seconds = math.floor(timeLeft % 60)
    local timeStr = string.format("%02d.%02d", minutes, seconds)
    local textStr = "time remaining"

    if CurrentGameState == STATE_WAITING then
        textStr = "game starts in"
    else 
        textStr = "time remaining"
    end

    local x, y = ScrW() / 2, 50
    draw.SimpleText(textStr, "HudHintTextLarge", x, y - 20, color_white, TEXT_ALIGN_CENTER)
    
    local textColor = (timeLeft < 30) and Color(255, 215, 0) or color_white
    draw.SimpleText(timeStr, "HudNumbers", x, y, textColor, TEXT_ALIGN_CENTER)
end)

local countdownNum = 0
local countdownTime = 0

net.Receive("RaceCountdown", function()
    countdownNum = 3
    countdownTime = CurTime() + 1
    
    surface.PlaySound("buttons/blip1.wav")
end)

hook.Add("HUDPaint", "RaceCountdownHUD", function()
    if countdownNum <= 0 then return end

    local w, h = ScrW(), ScrH()
    local text = tostring(countdownNum)
    local color = Color(255, 255, 255)

    if countdownNum == 0 then 
        text = "GO!" 
        color = Color(0, 255, 0)
    end

    if CurTime() > countdownTime then
        countdownNum = countdownNum - 1
        countdownTime = CurTime() + 1
        
        if countdownNum > 0 then
            surface.PlaySound("buttons/blip1.wav") 
        elseif countdownNum == 0 then
            surface.PlaySound("buttons/button9.wav") 
            
            timer.Simple(2, function() countdownNum = -1 end)
        end
    end

    local scale = 1 + (countdownTime - CurTime())
    local font = "DermaLarge" 
    
    draw.SimpleTextOutlined(text, font, w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
end)