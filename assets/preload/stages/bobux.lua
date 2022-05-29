local xx = 420.95;
local yy = 513;
local xx2 = 952.9;
local yy2 = 550;
local xx3 = 952.9;
local yy3 = 200;
local ofs = 60;
local followchars = true;
local del = 0;
local del2 = 0;

local small = false;

local active = true



function onCreatePost()
    if dadName == 'tiny-mouse' then
        small = true
    end
end

function onUpdate()
    if active then 
        if followchars == true then
            if mustHitSection == false then
                if gfSection == true then
                    setProperty('defaultCamZoom',0.65)
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
                    if small == true then setProperty('defaultCamZoom',1.0)  yy = 550  else setProperty('defaultCamZoom',0.8) yy = 513 end

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
                        if getProperty('camHUD.alpha') == not 1 then
                            doTweenAlpha('camtween','camHUD',1,0.3,'linear')
                        end
                    end
                    if getProperty('dad.animation.curAnim.name') == 'dial' or getProperty('dad.animation.curAnim.name') == 'die' then
                        triggerEvent('Camera Follow Pos',xx,yy)
                        if getProperty('camHUD.alpha') == not 0 then
                            doTweenAlpha('camtween','camHUD',0,0.5,'linear')
                        end
                    end
                end
            else
                setProperty('defaultCamZoom',1.0)
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
    if songName == 'Too Slow Encore' then
        if curStep == 1443 then
            small = false
        end

        if curStep == 928 then 
            active = false
            followchars = false
        end 

        if curStep == 1043 then 
            active = true
            followchars = true
        end

        if curStep == 2016 then
            active = false
            followchars = false
        end
    end
    
    if songName == 'Battered' then
        if curStep == 1197 then
            active = false
            followchars = false          
        end
        if curStep == 1263 then
            active = true
            followchars = true
        end
    end
end