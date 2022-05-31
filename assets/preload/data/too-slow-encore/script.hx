var curSection = 0;
var stepDev = 0;

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	if (curSection >= 26 && curSection <= 33)
	{
		if (curStep % 8 == 0)
		{
			addCamZoom(0.2, 0.07);
		}
	}

	if (curSection >= 34 && curSection <= 41 || curSection >= 43 && curSection <= 45 || curSection >= 47 && curSection <= 49 || curSection >= 66
		&& curSection <= 73 || curSection >= 82 && curSection <= 88 || curSection >= 90 && curSection <= 91)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.15, 0.06);
		}
	}

	if (curStep == 672 || curStep == 680 || curStep == 737 || curStep == 744 || curStep == 1424 || curStep == 1428 || curStep == 1432 || curStep == 1436
		|| curStep == 1472 || curStep == 1479 || curStep == 1486 || curStep == 1490)
	{
		addCamZoom(0.2, 0.07);
	}

	if (curSection >= 50 && curSection <= 57 || curSection >= 74 && curSection <= 81 || curSection >= 94 && curSection <= 109)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.2, 0.08);
		}
	}

	if (curSection >= 110 && curSection <= 125)
	{
		if (curStep % 8 == 0)
		{
			addCamZoom(0.25, 0.082);
		}
	}

	switch (curStep)
	{
		case 1:
			PlayState.curCamera.dadPos[1] = 550;
			PlayState.curCamera.dadZoom = 1.0;
		case 928:
			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);
			PlayState.addCinematicBars(1, 12);

			PlayState.isCameraOnForcedPos = true;

			PlayState.followChars = false;
		case 930:
			PlayState.vocals.volume = 1;
			PlayState.camZooming = false;
			FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1);
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x - 175, PlayState.dad.getGraphicMidpoint().y + 120);
		case 1012:
			FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.2);
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x - 175, PlayState.dad.getGraphicMidpoint().y + 50);
		case 1043:
			PlayState.removeCinematicBars(1);
			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1);
			FlxTween.tween(FlxG.camera, {zoom: 1}, 1);

			PlayState.isCameraOnForcedPos = false;

			PlayState.followChars = true;
		case 1443:
			PlayState.curCamera.dadPos[1] = 513;
			PlayState.curCamera.dadZoom = 0.8;
		case 1488:
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
			PlayState.opponentStrums.forEach(function(spr)
			{
				objs.push(spr);
			});
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 0}, 0.2);
			}
			PlayState.addCinematicBars(0.2);
			PlayState.camZooming = false;
			FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.2);
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x - 175, PlayState.dad.getGraphicMidpoint().y + 60);

		case 1504:
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
			PlayState.opponentStrums.forEach(function(spr)
			{
				objs.push(spr);
			});
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 1}, 0.2);
			}
			PlayState.removeCinematicBars(0.2);

		case 2016:
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
			PlayState.opponentStrums.forEach(function(spr)
			{
				objs.push(spr);
			});
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 0}, 0.2, {
					onComplete: function(twn)
					{
						obj.visible = false;
					}
				});
			}
			PlayState.addCinematicBars(0.6);
			PlayState.vocals.volume = 1;
			PlayState.camZooming = false;
			FlxTween.tween(FlxG.camera, {zoom: 1.2}, 1);
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x, PlayState.dad.getGraphicMidpoint().y + 70);

			PlayState.isCameraOnForcedPos = true;

			PlayState.followChars = false;
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}
