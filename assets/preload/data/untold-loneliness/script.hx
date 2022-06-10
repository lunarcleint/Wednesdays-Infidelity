var curSection = 0;
var stepDev = 0;

function onCreate()
{
}

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	if (ClientPrefs.flashing && curSection == 1)
	{
		if (stepDev > 8)
		{
			if (curStep % 2 == 1)
			{
				PlayState.triggerEventNote("camHud & camera Off", "", "");
			}
			else
			{
				PlayState.triggerEventNote("camHud & camera On", "", "");
			}
		}
	}

	if (curStep == 32)
	{
		PlayState.triggerEventNote("camHud & camera On", "", "");

		FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);
	}

	if (curSection >= 43 && curSection <= 58)
	{
		if (curStep % 8 == 0)
		{
			addCamZoom(0.15, 0.06);
		}
	}

	if (curStep == 696)
	{
		addCamZoom(0.15, 0.06);
	}

	if (curSection >= 18 && curSection <= 25)
	{
		if (stepDev == 1 || stepDev == 7)
		{
			addCamZoom(0.15, 0.06);
		}
		if (stepDev == 13 || stepDev == 15)
		{
			addCamZoom(0.2, 0.07);
		}
	}

	if (curSection >= 27 && curSection <= 42 || curSection >= 76 && curSection <= 138)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.2, 0.07);

			/*
				var beatdev = (curStep % 4) % 2;

				if (beatdev == 0)
				{
					FlxTween.tween(PlayState.camHUD, {y: -1000}, ((60 / PlayState.SONG.bpm) * 1000));
				}

				if (beatdev == 1)
				{
					FlxTween.tween(PlayState.camHUD, {y: 0}, ((60 / PlayState.SONG.bpm) * 1000));
				}
			 */
		}
	}

	if (curStep == 1208 || curStep == 1212)
	{
		addCamZoom(0.2, 0.07);
	}

	switch (curStep)
	{
		case 112:
			PlayState.addCinematicBars(1., 12);
			FlxTween.tween(FlxG.camera, {zoom: 1.2}, 3.62);

			PlayState.followChars = false;
			PlayState.isCameraOnForcedPos = true;
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 70, PlayState.dad.getGraphicMidpoint().y);

			PlayState.camHUD.alpha = 1;
		case 160:
			PlayState.followChars = true;
			PlayState.removeCinematicBars(1.);
		case 696:
			PlayState.curCamera.bfZoom = 1.2;

			PlayState.curCamera.dadZoom = 1.2;

			PlayState.addCinematicBars(1.);
		case 952:
			PlayState.followChars = false;
			PlayState.isCameraOnForcedPos = true;
			PlayState.camZooming = false;

			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);

			FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2);

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 170, PlayState.dad.getGraphicMidpoint().y);
		case 977:
			FlxTween.tween(FlxG.camera, {zoom: 1.3}, 0.2, {
				ease: FlxEase.quadInOut,
				onComplete: function(twn)
				{
					FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.2, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn)
						{
							FlxTween.tween(FlxG.camera, {zoom: 1.2}, 7);
						},
						startDelay: 0.25
					});
				}
			});
		case 1072:
			PlayState.followChars = true;
			PlayState.camZooming = true;

			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1);
		case 1201:
		// scream shit

		case 1208:
			PlayState.curCamera.bfZoom = 1;

			PlayState.curCamera.dadZoom = 0.8;

			PlayState.removeCinematicBars(1);
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}
