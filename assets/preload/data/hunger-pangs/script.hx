var originalx = PlayState.curCamera.dadPos[0];
var originalbfx = PlayState.curCamera.bfPos[0];
var originalbfzoom = PlayState.curCamera.bfZoom;
var originaldadzoom = PlayState.curCamera.dadZoom;
function onStepHit()
{
    switch(curStep)
    {
        case 1:
            FlxTween.tween(PlayState.camHUD,{alpha:0},0.2);
            PlayState.curCamera.dadZoom = 1;
            PlayState.curCamera.dadPos[0] = 300;
            PlayState.addCinematicBars(0.4,12);
        case 342:
            PlayState.removeCinematicBars(0.2);
            PlayState.curCamera.dadZoom = originaldadzoom;
            PlayState.curCamera.dadPos[0] = originalx;
        case 830:
            var objs = [
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreTxt,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				PlayState.botplayTxt
			];
            for (obj in objs)
                {
                    FlxTween.tween(obj, {alpha: 0}, 0.2);
                }
            PlayState.addCinematicBars(0.3,9);
            FlxTween.tween(PlayState.chedderguybg,{alpha: 0.1},0.4);
        case 1082:
            var objs = [
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreTxt,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				PlayState.botplayTxt
			];
            for (obj in objs)
                {
                    FlxTween.tween(obj, {alpha: 1}, 0.2);
                }
            PlayState.removeCinematicBars(0.4);
            FlxTween.tween(PlayState.chedderguybg,{alpha: 1},0.4);
    }
}