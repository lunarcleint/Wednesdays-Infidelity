function onStepHit()
{
	switch (curStep)
	{
		case 1610:
			PlayState.addCinematicBars(0.01);
			PlayState.camHUD.alpha = 0;
		case 1744:
			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.5);
	}
}
