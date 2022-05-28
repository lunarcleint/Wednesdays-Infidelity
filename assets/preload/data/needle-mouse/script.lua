
curSection = 0

stepdev = 0

function onCreate()
    
end

function onStepHit()
    if curStep % 16 == 0 then 
        curSection = math.floor(curStep / 16)
    end

    stepdev = math.floor(curStep%16) + 1 -- Ive never seen a section end at 15 -lunar

    if curSection >= 12 and curSection <= 14 or curSection >= 120 and curSection <= 135 or curSection >= 104 and curSection <= 110 then 
        if curStep % 4 == 0 then 
            addCamZoom(0.15, 0.04)
        end
    end

    if curSection == 15 then 
        if curStep % 2 == 0 then 
            addCamZoom(0.15, 0.04)
        end
    end

    if curSection >= 32 and curSection <= 35 then 
        if curStep % 4 == 0 then 
            addCamZoom(0.15, 0.04)
        end
    end

    if curSection >= 36 and curSection <= 38 then 
        if stepdev == 1 or stepdev == 4 or stepdev == 7 then 
            addCamZoom(0.15, 0.04)
        end

        if stepdev == 11 or stepdev == 14 then 
            addCamZoom(0.2, 0.08)
        end
    end

    if curSection >= 16 and curSection <= 31 or curSection >= 40 and curSection <= 55 then -- I love drum pattern
        section = curSection % 2 

        if section == 0 then 
            if stepdev == 1 or stepdev == 7 or stepdev == 9 then 
                addCamZoom(0.1, 0.02)
            end

            if stepdev == 5 or stepdev == 13 then 
                addCamZoom(0.15, 0.06)
            end
        end 

        if section == 1 then
            if stepdev == 1 or stepdev == 9 then 
                addCamZoom(0.1, 0.02)
            end
            if stepdev == 5 or stepdev == 13 then 
                addCamZoom(0.15, 0.06)
            end
        end
    end

    if curStep == 896 or curStep == 912 or curStep == 928 or curStep == 943 or curStep == 944 or curStep == 960 or curStep == 968 or curStep == 976 or curStep == 984 or curStep == 992 or curStep == 1008 or curStep == 1012 or curStep == 1016 or curStep == 1021 or curStep == 1022 then 
        addCamZoom(0.2, 0.08)
    end

    if curSection >= 64 and curSection <= 87 then
        if curStep % 4 == 0 then
            addCamZoom(0.15, 0.04)
        end
    end

    if curStep == 1408 or curStep == 1429 or curStep == 1434 or curStep == 1440 or curStep == 1460 or curStep == 1466 or curStep == 1472 or curStep == 1492 or curStep == 1498 or curStep == 1504 or curStep == 1524 or curStep == 1531 or curStep == 1536 or curStep == 1556 or curStep == 1562 or curStep == 1568 or curStep == 1588 or curStep == 1594 or curStep == 1600 or curStep == 1620 or curStep == 1626 or curStep == 1632 then
        addCamZoom(0.2, 0.09)
    end

    if curSection >= 112 and curSection <= 119 then
        if curStep % 8 == 0 then
            addCamZoom(0.15, 0.04)
        end
    end
end

function addCamZoom(game,hud) --trigger event no work
    setProperty("camGame.zoom", getProperty("camGame.zoom") + game)
    setProperty("camHUD.zoom", getProperty("camHUD.zoom") + hud)
end 