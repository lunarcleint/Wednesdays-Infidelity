
curSection = 0

function onCreate()

end

function onStepHit()
    if curStep % 16 == 0 then 
        curSection = math.floor(curStep / 16)
    end

    if curSection >= 16 and curSection <= 55 then
        if curStep % 8 == 0 then
            addCamZoom(0.17, 0.06)
        end
    end

    if curSection >= 70 and curSection <= 133 then
        if curStep % 4 == 0 then
            addCamZoom(0.23, 0.09)
        end
    end

end

function addCamZoom(game,hud) --trigger event no work
    setProperty("camGame.zoom", getProperty("camGame.zoom") + game)
    setProperty("camHUD.zoom", getProperty("camHUD.zoom") + hud)
end  

