local music_tracks = {
    "music/HL2_song14.mp3", -- you're not supposed to be here
    "music/HL2_song12_long.mp3", -- hard fought
    "music/HL2_song20_submix0.mp3", -- cp violation
    "music/hl2_song29.mp3", -- apprehension and evasion
}

local current_station = nil
local last_track = nil

local function PlayRandomMusic()
    local track = music_tracks[math.random(#music_tracks)]

    while last_track == track do
        track = music_tracks[math.random(#music_tracks)]
    end

    last_track = track
    
    sound.PlayFile("sound/" .. track, "noplay", function(station, err, errname)
        if IsValid(station) then
            if IsValid(current_station) then current_station:Stop() end
            
            current_station = station
            station:SetVolume(1)
            station:Play()

            print("now playing music: " .. track)

            timer.Create("MusicLoopCheck", 1, 0, function()
                if not IsValid(station) or station:GetState() == GMOD_CHANNEL_STOPPED then
                    timer.Remove("MusicLoopCheck")
                    PlayRandomMusic()
                end
            end)
        else
            print("music errrrrrror " .. errname .. " on path: " .. track)
            surface.PlaySound(track)
        end
    end)
end

hook.Add("InitPostEntity", "MusicLoop", function()
    PlayRandomMusic()
end)