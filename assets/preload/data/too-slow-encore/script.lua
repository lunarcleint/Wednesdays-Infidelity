
curSection = 0;

function onCreate()
    
end

function onStepHit()
    if curStep % 16 == 0 then 
        curSection = math.floor(curStep / 16)
    end

    if curSection >= 26 and curSection <= 33 then 
        if curStep % 8 == 0 then 
            addCamZoom(0.2, 0.07)
        end
    end

    if curSection >= 34 and curSection <= 41 or curSection >= 43 and curSection <= 45 or curSection >= 47 and curSection <= 49 or curSection >= 66 and curSection <= 73 or curSection >= 82 and curSection <= 88 or curSection >= 90 and curSection <= 91 then 
        if curStep % 4 == 0 then 
            addCamZoom(0.15, 0.06)
        end
    end

    if curStep == 672 or curStep == 680 or curStep == 737 or curStep == 744 or curStep == 1424 or curStep == 1428 or curStep == 1432 or curStep == 1436 or curStep == 1472 or curStep == 1479 or curStep == 1486 or curStep == 1490 then 
        addCamZoom(0.2, 0.07)
    end

    if curSection >= 50 and curSection <= 57 or curSection >= 74 and curSection <= 81 or curSection >= 94 and curSection <= 109 then 
        if curStep % 4 == 0 then 
            addCamZoom(0.2, 0.08)
        end
    end

    if curSection >= 110 and curSection <= 125 then
        if curStep % 8 == 0 then 
            addCamZoom(0.25, 0.082)
        end
    end

end

function onUpdatePost(elapsed)
    
end

function addCamZoom(game,hud) --trigger event no work
    setProperty("camGame.zoom", getProperty("camGame.zoom") + game)
    setProperty("camHUD.zoom", getProperty("camHUD.zoom") + hud)
end