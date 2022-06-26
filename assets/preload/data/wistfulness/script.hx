var curSection = 0;
var stepDev = 0;

function onCreate()
{
	PlayState.curCamera.dadZoom = PlayState.curCamera.dadZoom = 0.9;
}

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	if (curSection >= 1 && curSection <= 32)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.1, 0.03);
		}
	}

	if (curSection >= 34 && curSection <= 41)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.2, 0.07);
		}
	}

	switch (curStep)
	{
		case 276:
			PlayState.curCamera.dadZoom = 1;

		case 528:
			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 0.5);

			PlayState.camZooming = false;

			FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2);

			PlayState.followChars = false;
			PlayState.isCameraOnForcedPos = true;
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x, PlayState.dad.getGraphicMidpoint().y);
		case 544:
			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1);

			PlayState.followChars = true;
		case 546:
			PlayState.curCamera.dadZoom = 0.8;
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}
