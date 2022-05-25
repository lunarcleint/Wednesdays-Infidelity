local xx = 420.95;
local yy = 513;
local xx2 = 952.9;
local yy2 = 550;
local ofs = 60;
local followchars = true;
local del = 0;
local del2 = 0;

local small = false;

function onCreatePost()
    if dadName == 'tiny-mouse' then
        small = true
    end
end

function onUpdate()
    if followchars == true then
        if mustHitSection == false then
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

function opponentNoteHit(id,data,type,sus)
	triggerEvent('Screen Shake','0.2,0.008','0.2,0.008')
end

function onStepHit()
    if curStep == 1443 then
        if songName == 'Too Slow Encore' then
            small = false
        end
    end
end