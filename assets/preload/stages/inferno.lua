local xx = 220.95;
local yy = 513;
local xx2 = 952.9;
local yy2 = 650;
local ofs = 60;
local followchars = true;
local del = 0;
local del2 = 0;

local xx3 = 600;
local yy3 = 100;

active = true

dadZoom = 0.8

bfZoom = 1.0

function onUpdate()
    if active then 
        if followchars == true then
            if mustHitSection == false then
                if gfSection == true then
                    setProperty('defaultCamZoom',0.5)
                    if getProperty('gf.animation.curAnim.name') == 'singLEFT' then
                        triggerEvent('Camera Follow Pos',xx3-ofs,yy3)
                    end
                    if getProperty('gf.animation.curAnim.name') == 'singRIGHT' then
                        triggerEvent('Camera Follow Pos',xx3+ofs,yy3)
                    end
                    if getProperty('gf.animation.curAnim.name') == 'singUP' then
                        triggerEvent('Camera Follow Pos',xx3,yy3-ofs)
                    end
                    if getProperty('gf.animation.curAnim.name') == 'singDOWN' then
                        triggerEvent('Camera Follow Pos',xx3,yy3+ofs)
                    end
                    if getProperty('gf.animation.curAnim.name') == 'singLEFT-alt' then
                        triggerEvent('Camera Follow Pos',xx3-ofs,yy3)
                    end
                    if getProperty('gf.animation.curAnim.name') == 'singRIGHT-alt' then
                        triggerEvent('Camera Follow Pos',xx3+ofs,yy3)
                    end
                    if getProperty('gf.animation.curAnim.name') == 'singUP-alt' then
                        triggerEvent('Camera Follow Pos',xx3,yy3-ofs)
                    end
                    if getProperty('gf.animation.curAnim.name') == 'singDOWN-alt' then
                        triggerEvent('Camera Follow Pos',xx3,yy3+ofs)
                    end
                    if getProperty('gf.animation.curAnim.name') == 'idle-alt' then
                        triggerEvent('Camera Follow Pos',xx3,yy3)
                    end
                    if getProperty('gf.animation.curAnim.name') == 'idle' then
                        triggerEvent('Camera Follow Pos',xx3,yy3)
                    end
                else
                    setProperty('defaultCamZoom',dadZoom)
                    if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
                        triggerEvent('Camera Follow Pos',xx-ofs,yy)
                    end
                    if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                        triggerEvent('Camera Follow Pos',xx+ofs,yy)
                    end
                    if getProperty('dad.animation.curAnim.name') == 'singUP' then
                        triggerEvent('Camera Follow Pos',xx,yy-ofs)
                    end
                    if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                        triggerEvent('Camera Follow Pos',xx,yy+ofs)
                    end
                    if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                        triggerEvent('Camera Follow Pos',xx-ofs,yy)
                    end
                    if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                        triggerEvent('Camera Follow Pos',xx+ofs,yy)
                    end
                    if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                        triggerEvent('Camera Follow Pos',xx,yy-ofs)
                    end
                    if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                        triggerEvent('Camera Follow Pos',xx,yy+ofs)
                    end
                    if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
                        triggerEvent('Camera Follow Pos',xx,yy)
                    end
                    if getProperty('dad.animation.curAnim.name') == 'idle' then
                        triggerEvent('Camera Follow Pos',xx,yy)
                    end
                end
            else
                setProperty('defaultCamZoom',bfZoom)
                if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                    triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
                end
                if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
                    triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
                end
                if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                    triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
                end
                if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                    triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
                end
                if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
                    triggerEvent('Camera Follow Pos',xx2,yy2)
                end
                if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                    triggerEvent('Camera Follow Pos',xx2,yy2)
                end
            end
        else
            triggerEvent('Camera Follow Pos','','')
        end
    end
end

function onStepHit()
    if songName == "Hellhole" then 
        if curStep == 1311 then 
            active = false
        end
        
        if curStep == 1344 then 
            active = true
        end

        if curStep == 1855 then 
            active = false
        end

        if curStep == 1876 then 
            active = true
        end

        if curStep == 2384 then 
            dadZoom = 1.2
            bfZoom = 1.2
        end

        if curStep == 2896 then 
            dadZoom = 0.8
            bfZoom = 1
        end

        if curStep == 3552 then 
            dadZoom = 1.2
            bfZoom = 1.2
        end
    end
end