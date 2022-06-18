function onStepHit()
{
	switch (curStep)
	{
		case 1055:
			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 0.4);
		case 1071:
			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.3);
	}
}
