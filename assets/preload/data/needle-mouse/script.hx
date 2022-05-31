var curSection = 0;
var stepDev = 0;

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	if (curSection >= 12 && curSection <= 14 || curSection >= 120 && curSection <= 135 || curSection >= 104 && curSection <= 110)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.15, 0.04);
		}
	}

	if (curSection == 15)
	{
		if (curStep % 2 == 0)
		{
			addCamZoom(0.15, 0.04);
		}
	}

	if (curSection >= 32 && curSection <= 35)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.15, 0.04);
		}
	}

	if (curSection >= 36 && curSection <= 38)
	{
		if (stepDev == 1 || stepDev == 4 || stepDev == 7)
		{
			addCamZoom(0.15, 0.04);
		}

		if (stepDev == 11 || stepDev == 14)
		{
			addCamZoom(0.2, 0.08);
		}
	}

	if (curSection >= 16 && curSection <= 31 || curSection >= 40 && curSection <= 55)
	{
		var section = curSection % 2;

		if (section == 0)
		{
			if (stepDev == 1 || stepDev == 7 || stepDev == 9)
			{
				addCamZoom(0.1, 0.02);
			}

			if (stepDev == 5 || stepDev == 13)
			{
				addCamZoom(0.15, 0.06);
			}
		}

		if (section == 1)
		{
			if (stepDev == 1 || stepDev == 9)
			{
				addCamZoom(0.1, 0.02);
			}
			if (stepDev == 5 || stepDev == 13)
			{
				addCamZoom(0.15, 0.06);
			}
		}
	}

	if (curStep == 896 || curStep == 912 || curStep == 928 || curStep == 943 || curStep == 944 || curStep == 960 || curStep == 968 || curStep == 976
		|| curStep == 984 || curStep == 992 || curStep == 1008 || curStep == 1012 || curStep == 1016 || curStep == 1021 || curStep == 1022)
	{
		addCamZoom(0.2, 0.08);
	}

	if (curSection >= 64 && curSection <= 87)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.15, 0.04);
		}
	}

	if (curStep == 1408 || curStep == 1429 || curStep == 1434 || curStep == 1440 || curStep == 1460 || curStep == 1466 || curStep == 1472
		|| curStep == 1492 || curStep == 1498 || curStep == 1504 || curStep == 1524 || curStep == 1531 || curStep == 1536 || curStep == 1556
		|| curStep == 1562 || curStep == 1568 || curStep == 1588 || curStep == 1594 || curStep == 1600 || curStep == 1620 || curStep == 1626 || curStep == 1632)
	{
		addCamZoom(0.2, 0.09);
	}

	if (curSection >= 112 && curSection <= 119)
	{
		if (curStep % 8 == 0)
		{
			addCamZoom(0.15, 0.04);
		}
	}

	switch (curStep)
	{
		case 1:
			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);

			new FlxTimer().start(2, function(tmr)
			{
				PlayState.addCinematicBars(2);
			});

			FlxTween.tween(FlxG.camera, {zoom: 1.5}, 13, {
				ease: FlxEase.quadInOut,
				onComplete: function(tween)
				{
					PlayState.defaultCamZoom = 1.5;
				}
			});

		case 128:
			PlayState.removeCinematicBars(1);

			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1, {startDelay: 1});

		case 888:
			PlayState.addCinematicBars(0.7);

		case 896:
			PlayState.curCamera.dadZoom = 1.3;

		case 1014:
			PlayState.removeCinematicBars(1);

		case 1024:
			PlayState.curCamera.dadZoom = 0.8;

		case 1399:
			PlayState.addCinematicBars(1);

		case 1408:
			PlayState.curCamera.dadZoom = 1.1;

		case 1657:
			PlayState.removeCinematicBars(0.5);

		case 1664:
			PlayState.curCamera.dadZoom = 0.8;

		case 1788:
			PlayState.addCinematicBars(0.5);

		case 1792:
			PlayState.curCamera.dadZoom = 1.1;

		case 1914:
			PlayState.removeCinematicBars(0.5);

		case 1920:
			PlayState.curCamera.dadZoom = 0.8;
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}
