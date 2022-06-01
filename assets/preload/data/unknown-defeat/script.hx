var curSection = 0;
var stepDev = 0;

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	switch (curStep)
	{
		case 1:
			PlayState.addCinematicBars(0.5,6);
			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 0.5);
		case 64:
			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.2);
		case 192:
			PlayState.removeCinematicBars(0.5);
		case 1215:
			PlayState.addCinematicBars(0.5,9);
			PlayState.defaultCamZoom = 0.65;
			PlayState.followChars = false;
			PlayState.camFollow.x = 600;
		case 1336:
			PlayState.followChars = true;
			PlayState.removeCinematicBars(0.5);
		case 1599:
			PlayState.addCinematicBars(0.5);
		case 1711:
			PlayState.camGame.alpha = 0;
		case 1727:
			var objs = [
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.healthBar,
				PlayState.healthBarBG
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
			PlayState.camGame.alpha = 1;
			PlayState.defaultCamZoom = 0.65;
			PlayState.followChars = false;
			PlayState.camFollow.x = 600;
		case 1855:
			PlayState.camHUD.alpha = 0;
			PlayState.curCamera.dadZoom = 1.1;
			PlayState.removeCinematicBars(0.1);
			PlayState.followChars = true;
			PlayState.curCamera.dadPos[0] = 200;
		case 1983:
			var objs = [
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.healthBar,
				PlayState.healthBarBG
				PlayState.scoreTxt,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				PlayState.botplayTxt
			];
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 1}, 0.4);
			}
			PlayState.camHUD.alpha = 1;
			PlayState.curCamera.dadZoom = 0.8;
			PlayState.curCamera.dadPos[0] = 420.95;
			FlxG.camera.flash();
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}
