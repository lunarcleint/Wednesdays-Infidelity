var curSection = 0;
var stepDev = 0;

function onCreate()
{
	PlayState.blackFuck = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, fromRGB(0, 0, 0));
	PlayState.blackFuck.cameras = [PlayState.camOther];
	PlayState.add(PlayState.blackFuck);
}

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	switch (curStep)
	{
		case 1:
			if (PlayState.blackFuck != null)
				FlxTween.tween(PlayState.blackFuck, {alpha: 0}, 2);
		case 128:
			PlayState.curCamera.dadZoom = 1;
		case 152:
			PlayState.curCamera.dadZoom = 1.1;
		case 160:
			PlayState.curCamera.dadZoom = 1;
		case 184:
			PlayState.curCamera.dadZoom = 1.1;
		case 192:
			PlayState.curCamera.dadZoom = 1;
		case 216:
			PlayState.curCamera.dadZoom = 1.1;
		case 256:
			PlayState.curCamera.dadZoom = 1;
		case 280:
			PlayState.curCamera.bfZoom = 1.1;
		case 288:
			PlayState.curCamera.bfZoom = 1;
		case 312:
			PlayState.curCamera.bfZoom = 1.1;
		case 320:
			PlayState.curCamera.bfZoom = 1;
		case 344:
			PlayState.curCamera.bfZoom = 1.1;
		case 408:
			PlayState.curCamera.dadZoom = 1.1;
		case 416:
			PlayState.curCamera.dadZoom = 1;
		case 440:
			PlayState.curCamera.dadZoom = 1.1;
		case 448:
			PlayState.curCamera.dadZoom = 1;
		case 480:
			PlayState.curCamera.dadZoom = 1.1;
		case 512:
			PlayState.curCamera.dadZoom = 1;
			PlayState.curCamera.bfZoom = 1;
		case 536:
			PlayState.curCamera.bfZoom = 1.1;
		case 544:
			PlayState.curCamera.bfZoom = 1;
		case 568:
			PlayState.curCamera.bfZoom = 1.1;
		case 576:
			PlayState.curCamera.bfZoom = 1;
		case 608:
			PlayState.curCamera.bfZoom = 1.1;
		case 630:
			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);

			PlayState.camZooming = false;

			FlxTween.tween(FlxG.camera, {zoom: 1.1}, 3.4);

			PlayState.vocals.volume = 1;

		case 644:
			PlayState.vocals.volume = 1;

		case 650:
			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.5);
		case 656:
			PlayState.distort.shader.working.value = [true];

			PlayState.addCinematicBars(1, 7);
		case 1424:
			PlayState.clearShaders();

			PlayState.removeCinematicBars(1);

			PlayState.curCamera.dadZoom = 1.1;
			PlayState.curCamera.bfZoom = 1.1;

			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1, {
				onComplete: function(twn)
				{
					PlayState.camHUD.visible = false;
				}
			});
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}
