var curSection = 0;
var stepDev = 0;

function onCreate()
{
	PlayState.camZooming = false;
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
		case 1:
			PlayState.cutsceneText.alpha = 0;
			PlayState.cutsceneText.visible = true;
			PlayState.cutsceneText.size = 32;
			PlayState.cutsceneText.fieldWidth = 1000;
			PlayState.cutsceneText.x = 170;
			PlayState.cutsceneText.y = 600;
		case 112:
			PlayState.addCinematicBars(0.5, 12);
			FlxTween.tween(FlxG.camera, {zoom: 1.2}, 3.62);

			FlxTween.tween(PlayState.cutsceneText, {alpha: 1}, 0.5);

			PlayState.cutsceneText.text = "Alright, Alright";

			PlayState.followChars = false;
			PlayState.isCameraOnForcedPos = true;
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 70, PlayState.dad.getGraphicMidpoint().y);

			PlayState.camHUD.alpha = 1;
		case 137:
			PlayState.cutsceneText.text = "Let's get this over with.";
			PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 32, fromRGB(145, 28, 28), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));
		case 160:
			FlxTween.tween(PlayState.cutsceneText, {alpha: 0}, 0.5, {
				onComplete: function(twn)
				{
					PlayState.cutsceneText.text = "";
					PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 32, fromRGB(255, 255, 255), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));
				}
			});
			PlayState.followChars = true;
			PlayState.removeCinematicBars(0.5);
		case 696:
			PlayState.curCamera.bfZoom = 1.3;

			PlayState.curCamera.dadZoom = 1.3;

			PlayState.addCinematicBars(1);
		case 952:
			PlayState.followChars = false;
			PlayState.isCameraOnForcedPos = true;
			PlayState.camZooming = false;

			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 0.3);

			FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2);

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x - 70, PlayState.dad.getGraphicMidpoint().y);

			FlxTween.tween(PlayState.cutsceneText, {alpha: 1}, 0.2);

			PlayState.cutsceneText.text = "In the end, we all..";
		case 976:
			PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 40, fromRGB(214, 32, 32), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));
			PlayState.cutsceneText.text = "DIE.";
			PlayState.cutsceneText.size = 36;
			PlayState.camZooming = false;
			FlxTween.tween(FlxG.camera, {zoom: 1.3}, 0.2, {
				onComplete: function(twn)
				{
					FlxG.camera.zoom = 1.3;
					new FlxTimer().start(0.25, function(tmr)
					{
						FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.2, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn)
							{
								FlxTween.tween(FlxG.camera, {zoom: 1.2}, 7);
							},
						});
					});
				}
			});
		case 984:
			PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 32, fromRGB(255, 255, 255), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));
			PlayState.cutsceneText.text = "Why should I, even try.";
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 170, PlayState.dad.getGraphicMidpoint().y);
		case 1017:
			PlayState.cutsceneText.text = "Gun in hand, my life shall end..";
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x - 70, PlayState.dad.getGraphicMidpoint().y);
		case 1044:
			PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 32, fromRGB(145, 28, 28), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));
			PlayState.cutsceneText.text = "MY SUFFERING SHALL BE KNOWN, FRIEND!";
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 170, PlayState.dad.getGraphicMidpoint().y - 10);
		case 1072:
			FlxTween.tween(PlayState.cutsceneText, {alpha: 0}, 0.5, {
				onComplete: function(twn)
				{
					PlayState.cutsceneText.text = "";
					PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 32, fromRGB(255, 255, 255), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));
				}
			});

			PlayState.followChars = true;
			PlayState.camZooming = true;

			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1);
			PlayState.healthBar.alpha = 0;
			PlayState.healthBarBG.alpha = 0;
			PlayState.iconP1.alpha = 0;
			PlayState.iconP2.alpha = 0;
			PlayState.scoreTxt.alpha = 0;
			PlayState.timeBarBG.alpha = 0;
			PlayState.timeBar.alpha = 0;
			PlayState.timeTxt.alpha = 0;
		case 1080:
			PlayState.cutsceneText.text = "";
		case 1174:
			PlayState.followChars = false;
			PlayState.isCameraOnForcedPos = true;
			PlayState.camZooming = false;
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 70, PlayState.dad.getGraphicMidpoint().y);
		case 1201:
			PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 46, fromRGB(214, 32, 32), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));
			PlayState.cutsceneText.alpha = 1;
			PlayState.cutsceneText.text = "RAAAH!";
		case 1208:
			PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 32, fromRGB(255, 255, 255), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));
			PlayState.cutsceneText.text = "";

			PlayState.healthBar.alpha = 1;
			PlayState.healthBarBG.alpha = 1;
			PlayState.iconP1.alpha = 1;
			PlayState.iconP2.alpha = 1; // poop
			PlayState.scoreTxt.alpha = 1;
			PlayState.timeBarBG.alpha = 1;
			PlayState.timeBar.alpha = 1;
			PlayState.timeTxt.alpha = 1;

			PlayState.followChars = true;
			PlayState.camZooming = true;
			PlayState.curCamera.bfZoom = 1;

			PlayState.curCamera.dadZoom = 0.8;

			PlayState.removeCinematicBars(0.5);
		case 1712:
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 70, PlayState.dad.getGraphicMidpoint().y);
			PlayState.followChars = false;
			PlayState.isCameraOnForcedPos = true;
			PlayState.camZooming = false;
		case 1728:
			PlayState.followChars = true;
			PlayState.camZooming = true;
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}
