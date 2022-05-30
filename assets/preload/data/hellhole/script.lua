
curSection = 0

stepdev = 0

function onCreate()
    
end

function onStepHit()
    if curStep % 16 == 0 then 
        curSection = math.floor(curStep / 16)
    end

    stepdev = math.floor(curStep%16) + 1 -- Ive never seen a section end at 15 -lunar

    if curSection >= 8 and curSection <= 23 then
        section = curSection % 4

        if section == 0 then 
            if stepdev == 1 then 
                addCamZoom(0.15,0.07)
            end
        end

        if section == 1 then 
            if stepdev == 1 then 
                addCamZoom(0.2,0.09)
            end
        end

        if section == 2 then 
            if stepdev == 1 or stepdev == 13 then 
                addCamZoom(0.15,0.07)
            end
        end

        if section == 3 then 
            if stepdev == 1 then 
                addCamZoom(0.2,0.08)
            end
        end
    end

    if curSection >= 25 and curSection <= 32 then
        if curStep % 4 == 0 then 
            addCamZoom(0.15,0.07)
        end
    end

    if curSection >= 33 and curSection <= 48 or curSection >= 65 and curSection <= 80 or curSection >= 84 and curSection <= 91 or curSection >= 125 and curSection <= 148 or curSection >= 165 and curSection <= 180 or curSection >= 214 and curSection <= 221 then
        if curStep % 8 == 0 then 
            addCamZoom(0.15,0.07)
        end
    end

    if curSection >= 49 and curSection <= 64 or curSection >= 92 and curSection <= 115 or curSection >= 182 and curSection <= 213 then
        if curStep % 4 == 0 then 
            addCamZoom(0.2,0.08)
        end
    end

    if curStep == 2890 or curStep == 2892 or curStep == 2893 or curStep == 2894 or curStep == 2895 then
        addCamZoom(0.3,0.08)
    end
end 

function addCamZoom(game,hud) --trigger event no work
    setProperty("camGame.zoom", getProperty("camGame.zoom") + game)
    setProperty("camHUD.zoom", getProperty("camHUD.zoom") + hud)
end 