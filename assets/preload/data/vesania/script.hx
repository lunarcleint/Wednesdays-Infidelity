var curSection = 0;
var stepDev = 0;

function onCreate()
{
	PlayState.blackFuck = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, fromRGB(0, 0, 0));
	PlayState.blackFuck.cameras = [PlayState.camOther];
	PlayState.add(PlayState.blackFuck);

	PlayState.curCamera.bfZoom = 0.7;
	PlayState.curCamera.bfPos = [952.9, 400];

	PlayState.curCamera.dadZoom = 0.65;
	PlayState.curCamera.dadPos = [420.95, 313];

	PlayState.curCamera.bfZoom += 0.2;

	PlayState.camHUD.alpha = 0;
}

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	if ((curSection >= 12 && curSection <= 32 && curSection != 16)
		|| curSection >= 49
		&& curSection <= 80
		|| curSection >= 89
		&& curSection <= 96
		|| curSection >= 145
		&& curSection <= 148)
	{
		if (curStep % 8 == 0)
		{
			addCamZoom(0.1, 0.04);
		}
	}

	if (curSection >= 32 && curSection <= 48 || curSection >= 129 && curSection <= 144)
	{
		if (curStep % 8 == 0)
		{
			addCamZoom(0.15, 0.1);
		}
	}

	if (curSection >= 113 && curSection <= 128)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.1, 0.04);
		}
	}

	if (curStep == 128 || curStep == 144 || curStep == 160 || curStep == 172 || curStep == 176 || curStep == 184 || curStep == 2320 || curStep == 2336
		|| curStep == 2352 || curStep == 2364 || curStep == 2368 || curStep == 2367)
	{
		addCamZoom(0.1, 0.04);
	}

	switch (curStep)
	{
		case 1:
			PlayState.isCameraOnForcedPos = true;
			PlayState.followChars = false;

			PlayState.cameraStageZoom = false;

			PlayState.defaultCamZoom = 1.3;
			PlayState.camFollow.set(PlayState.boyfriend.getGraphicMidpoint().x + 20, PlayState.boyfriend.getGraphicMidpoint().y - 65);
		case 64:
			if (PlayState.blackFuck != null)
				FlxTween.tween(PlayState.blackFuck, {alpha: 0}, 4.5);

			FlxTween.tween(PlayState, {defaultCamZoom: 1.2}, 4.5);
		case 128:
			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1);

			PlayState.followChars = true;

			PlayState.cameraStageZoom = true;
		case 144:
			PlayState.curCamera.dadZoom += 0.2;
		case 160:
			PlayState.curCamera.dadZoom -= 0.2;
		case 176:
			PlayState.curCamera.bfZoom += 0.2;
		case 192:
			PlayState.curCamera.bfZoom -= 0.2;
		case 256:
			PlayState.curCamera.dadZoom += 0.4;
			PlayState.curCamera.dadPos[1] += 60;
		case 272:
			PlayState.curCamera.dadZoom -= 0.4;
			PlayState.curCamera.dadPos[1] -= 60;

			PlayState.curCamera.bfZoom -= 0.125;
		case 304:
			PlayState.curCamera.dadZoom += 0.2;
		case 320:
			PlayState.curCamera.dadZoom += 0.1;
		case 336:
			PlayState.curCamera.dadZoom -= 0.3;
		case 368:
			PlayState.curCamera.bfZoom += 0.2;
		case 384:
			PlayState.curCamera.bfZoom += 0.2;
		case 400:
			PlayState.curCamera.bfZoom -= 0.4;
			PlayState.curCamera.dadZoom += 0.1;
		case 408:
			PlayState.curCamera.dadZoom -= 0.1;
		case 416:
			PlayState.curCamera.dadZoom += 0.1;
		case 424:
			PlayState.curCamera.dadZoom -= 0.1;
		case 432:
			PlayState.curCamera.dadZoom += 0.1;
		case 442:
			PlayState.curCamera.dadZoom -= 0.1;
		case 448:
			PlayState.curCamera.dadZoom += 0.1;
		case 454:
			PlayState.curCamera.dadZoom -= 0.1;
		case 464:
			PlayState.curCamera.bfZoom += 0.1;
		case 474:
			PlayState.curCamera.bfZoom -= 0.1;
		case 480:
			PlayState.curCamera.bfZoom += 0.1;
		case 490:
			PlayState.curCamera.bfZoom -= 0.1;
		case 496:
			PlayState.curCamera.bfZoom += 0.1;
		case 504:
			PlayState.curCamera.bfZoom -= 0.1;
		case 512:
			PlayState.curCamera.bfZoom += 0.1;
		case 522:
			PlayState.curCamera.bfZoom -= 0.1;
		case 528:
			PlayState.curCamera.dadZoom += 0.2;
			PlayState.curCamera.dadPos[1] += 60;

			PlayState.curCamera.bfZoom += 0.2;
			PlayState.curCamera.bfPos[1] += 60;

			PlayState.addCinematicBars(0.5);

			PlayState.cameraStageZoom = false;

			FlxTween.tween(PlayState, {defaultCamZoom: PlayState.defaultCamZoom + 0.4}, 9.54);
		case 656:
			PlayState.defaultCamZoom = PlayState.curCamera.bfZoom;

			FlxTween.tween(PlayState, {defaultCamZoom: PlayState.defaultCamZoom + 0.45}, 9.54);
		case 784:
			var objs = [
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
			];
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 0}, 0.5);
			}

			PlayState.curCamera.dadZoom -= 0.2;
			PlayState.curCamera.dadPos[1] -= 60;

			PlayState.curCamera.bfZoom -= 0.2;
			PlayState.curCamera.bfPos[1] -= 60;

			PlayState.removeCinematicBars(0.5);

			PlayState.isCameraOnForcedPos = true;
			PlayState.followChars = false;

			PlayState.cameraStageZoom = false;

			PlayState.defaultCamZoom = PlayState.curCamera.dadZoom + 0.1;

			FlxTween.tween(PlayState, {defaultCamZoom: PlayState.curCamera.dadZoom + 0.05}, 19.04);

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 320, PlayState.dad.getGraphicMidpoint().y - 370);
		case 1040:
			var objs = [
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
			];
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 1}, 0.5);
			}

			PlayState.followChars = true;

			PlayState.cameraStageZoom = true;
		case 1296:
			PlayState.curCamera.dadZoom += 0.3;

			if (PlayState.blackFuck != null)
				FlxTween.tween(PlayState.blackFuck, {alpha: 1}, 0.5, {startDelay: 0.5});
			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 0.5, {startDelay: 0.5});
		case 1300:
			PlayState.cameraStageZoom = false;
			FlxTween.tween(PlayState, {defaultCamZoom: PlayState.curCamera.dadZoom + 0.4}, 0.7);

		case 1370:
			PlayState.cameraStageZoom = true;

			PlayState.curCamera.dadZoom -= 0.3;

			PlayState.curCamera.dadZoom += 0.4;
			PlayState.curCamera.dadPos[1] += 60;
			PlayState.curCamera.dadPos[0] += 50;

			PlayState.curCamera.bfZoom += 0.6;
			PlayState.curCamera.bfPos[1] += 60;

			PlayState.curCamera.bfPos[0] += 60;
			PlayState.curCamera.bfPos[1] += 50;

			PlayState.addCinematicBars(0.00000001);
		case 1408:
			if (PlayState.blackFuck != null)
				FlxTween.tween(PlayState.blackFuck, {alpha: 0}, 1);
			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1);
		case 1552:
			PlayState.curCamera.bfPos[0] -= 60;
			PlayState.curCamera.bfPos[1] -= 50;

			PlayState.curCamera.bfZoom -= 0.3;

			PlayState.curCamera.dadPos[0] -= 50;

			PlayState.curCamera.dadPos[0] -= 160;
			PlayState.curCamera.dadPos[1] += 30;
			PlayState.curCamera.dadZoom += 0.1;

			PlayState.curCamera.dadPos[1] -= 60;
			PlayState.curCamera.dadPos[0] -= 50;

		case 1616:
			PlayState.curCamera.dadPos[0] += 160;
			PlayState.curCamera.dadPos[1] -= 30;

			PlayState.curCamera.dadZoom -= 0.3;
		case 1698:
			PlayState.curCamera.dadZoom += 0.2;
		case 1712:
			PlayState.curCamera.dadZoom -= 0.2;
		case 1762:
			PlayState.curCamera.bfZoom += 0.2;
		case 1776:
			PlayState.curCamera.bfZoom -= 0.2;
		case 1808:
			PlayState.curCamera.bfZoom = 0.7;
			PlayState.curCamera.bfPos = [952.9, 400];

			PlayState.curCamera.dadZoom = 0.65;
			PlayState.curCamera.dadPos = [420.95, 313];

			PlayState.removeCinematicBars(0.5);
		case 2064:
			var objs = [
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
			];
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 0}, 0.5);
			}

			PlayState.isCameraOnForcedPos = true;
			PlayState.followChars = false;

			PlayState.cameraStageZoom = false;

			PlayState.defaultCamZoom = PlayState.curCamera.dadZoom + 0.1;

			FlxTween.tween(PlayState, {defaultCamZoom: PlayState.curCamera.dadZoom + 0.2}, 19.04);

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 247, PlayState.dad.getGraphicMidpoint().y - 170);
		case 2320:
			var objs = [
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
			];
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 1}, 0.5);
			}

			PlayState.followChars = true;

			PlayState.cameraStageZoom = true;
		case 2336:
			PlayState.curCamera.dadZoom += 0.2;
		case 2352:
			PlayState.curCamera.dadZoom -= 0.2;
		case 2368:
			PlayState.curCamera.bfZoom += 0.2;
		case 2384:
			PlayState.curCamera.bfZoom -= 0.2;

			PlayState.curCamera.dadZoom += 0.2;
			PlayState.curCamera.dadPos[1] += 60;

			PlayState.curCamera.bfZoom += 0.2;
			PlayState.curCamera.bfPos[1] += 40;
		case 2448:
			FlxTween.tween(camGame, {alpha: 0}, 1);
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}
