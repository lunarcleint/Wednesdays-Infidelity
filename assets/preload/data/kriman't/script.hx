var curSection = 0;
var stepDev = 0;

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	if (curSection >= 16 && curSection <= 55)
	{
		if (curStep % 8 == 0)
		{
			addCamZoom(0.17, 0.06);
		}
	}

	if (curSection >= 70 && curSection <= 133)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.23, 0.09);
		}
	}

	switch (curStep)
	{
		case 959:
			PlayState.isCameraOnForcedPos = true;

			PlayState.followChars = false;
		case 960:
			PlayState.addCinematicBars(0.75, 12);

			PlayState.camZooming = false;

			FlxTween.tween(FlxG.camera, {zoom: 1.4}, 5);

			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x - 170, PlayState.dad.getGraphicMidpoint().y);

		case 992:
			PlayState.isCameraOnForcedPos = false;

			PlayState.followChars = true;

			FlxG.camera.flash(black, 5);
			FlxTween.tween(PlayState.blackFuck, {alpha: 1}, 0.5);
		case 1050:
			PlayState.songLength = FlxG.sound.music.length;
			FlxTween.tween(PlayState.blackFuck, {alpha: 0}, 2);

		case 1112:
			PlayState.removeCinematicBars(1);

			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1, {startDelay: 1});
		case 2144:
			PlayState.isCameraOnForcedPos = true;

			PlayState.followChars = false;

			PlayState.addCinematicBars(1, 12);

			PlayState.camZooming = false;

			FlxTween.tween(FlxG.camera, {zoom: 1.4}, 1);

			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x - 50, PlayState.dad.getGraphicMidpoint().y - 40);
		case 2181:
			FlxTween.tween(FlxG.camera, {zoom: 1.2}, 1, {ease: FlxEase.quadInOut});

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x - 40, PlayState.dad.getGraphicMidpoint().y - 100);
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}
