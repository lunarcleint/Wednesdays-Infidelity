var curSection;

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	if (curSection > 15 && curSection < 32 || curSection > 47 && curSection < 64)
	{
		if (curStep % 4 == 0)
			addCameraZoom();
	}

	switch (curStep)
	{
		case 511:
			PlayState.addCinematicBars(1, 5);
			var arr = [
				PlayState.scoreTxt,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.healthBarBG,
				PlayState.healthBar
			];

			for (obj in arr)
			{
				FlxTween.tween(obj, {alpha: 0}, 1);
			}
		case 1023:
			PlayState.addCinematicBars(1, 5);
			var arr = [
				PlayState.scoreTxt,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.healthBarBG,
				PlayState.healthBar
			];

			for (obj in arr)
			{
				FlxTween.tween(obj, {alpha: 0}, 1);
			}
		case 623:
			PlayState.removeCinematicBars(0.2);
			var arr = [
				PlayState.scoreTxt,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.healthBarBG,
				PlayState.healthBar
			];

			for (obj in arr)
			{
				FlxTween.tween(obj, {alpha: 1}, 0.5);
			}
	}
}

function addCameraZoom()
{
	FlxG.camera.zoom += 0.1;
	PlayState.camHUD.zoom += 0.05;
}
