var curSection = 0;
var stepDev = 0;

function onCreate()
{
	PlayState.camHUD.alpha = 0;

	PlayState.blackFuck = new FlxSprite().makeGraphic(FlxG.width * 5, FlxG.height * 5, fromRGB(0, 0, 0));
	PlayState.blackFuck.screenCenter();
	PlayState.add(PlayState.blackFuck);
}

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	if (curSection >= 8 && curSection <= 11)
	{
		if (curStep % 16 == 0)
		{
			addCamZoom(0.1, 0.04);
		}
	}

	if (curSection >= 12 && curSection <= 14 || curSection >= 32 && curSection <= 55)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.1, 0.04);
		}
	}

	if (curStep >= 240 && curStep <= 250)
	{
		if (curStep % 2 == 0)
		{
			addCamZoom(0.1, 0.04);
		}
	}

	if (curStep >= 252 && curStep <= 256)
	{
		addCamZoom(0.1, 0.04);
	}

	if (curSection >= 16 && curSection <= 31)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.12, 0.08);
		}
	}

	switch (curStep)
	{
		case 1:
			PlayState.isCameraOnForcedPos = true;
			PlayState.followChars = false;

			PlayState.cameraStageZoom = false;

			PlayState.defaultCamZoom = PlayState.curCamera.dadZoom;

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 400, PlayState.dad.getGraphicMidpoint().y - 30);
		case 32:
			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 2);
		case 64:
			FlxTween.tween(PlayState.blackFuck, {alpha: 0}, 5.5);

			FlxTween.tween(PlayState, {defaultCamZoom: PlayState.curCamera.dadZoom - 0.2}, 5.5);
		case 128:
			PlayState.followChars = true;

			PlayState.cameraStageZoom = true;
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}

function addStageZoom(amount)
{
	PlayState.curCamera.bfZoom += amount;
	PlayState.curCamera.dadZoom += amount;
}
