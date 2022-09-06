var curSection = 0;
var stepDev = 0;

function onCreate()
{
	PlayState.curCamera.dadPos[1] += 100;
	PlayState.curCamera.bfPos[1] += 70;

	PlayState.camHUD.alpha = 0;
	PlayState.camGame.visible = false;
	FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.5);
}

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	if (curSection >= 32 && curSection <= 54 || curSection >= 56 && curSection <= 71 || curSection >= 112 && curSection <= 143)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.15, 0.05);
		}
	}

	if (curSection >= 80 && curSection <= 94)
	{
		var section = curSection % 8;

		if (section == 0 || section == 2 || section == 4 || section == 6)
		{
			if (stepDev == 1 || stepDev == 13)
				addCamZoom(0.15, 0.05);

			if (stepDev == 5 || stepDev == 7)
				addCamZoom(0.15, 0.07);
		}
		if (section == 1 || section == 5 || section == 7)
		{
			if (stepDev == 5 || stepDev == 7)
				addCamZoom(0.15, 0.07);
			if (stepDev == 13)
				addCamZoom(0.15, 0.05);
		}
		if (section == 3)
		{
			if (stepDev < 13)
			{
				if (curStep % 2 == 0)
					addCamZoom(0.15, 0.05);
			}
		}
	}

	if (curStep >= 892 && curStep <= 895 || curStep >= 1660 && curStep <= 1663)
		addCamZoom(0.15, 0.07);

	switch (curStep)
	{
		case 1:
			PlayState.camGame.visible = true;
			PlayState.curCamera.dadZoom = 1;
		case 256:
			PlayState.curCamera.bfZoom = 1.2;
			PlayState.curCamera.dadZoom = 1.2;

			PlayState.addCinematicBars(1, 7);

			var objs = [
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				PlayState.botplayTxt
			];
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 0}, 1);
			}
		case 288:
			PlayState.curCamera.bfZoom = 1.3;
		case 320:
			PlayState.curCamera.bfZoom = 1.2;
		case 352:
			PlayState.curCamera.bfZoom = 1.3;
		case 384:
			PlayState.curCamera.bfZoom = 1.2;
		case 390:
			PlayState.curCamera.dadZoom = 1.25;
		case 416:
			PlayState.curCamera.dadZoom = 1.2;
		case 422:
			PlayState.curCamera.dadZoom = 1.25;
		case 448:
			PlayState.curCamera.dadZoom = 1.2;
		case 496:
			var objs = [
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				PlayState.botplayTxt,
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
			];
			PlayState.strumLineNotes.forEach(function(spr)
			{
				objs.push(spr);
			});
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 0}, 0.2);
			}

			PlayState.isCameraOnForcedPos = true;

			PlayState.followChars = false;

			PlayState.curCamera.dadZoom = 1;

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x - 300, PlayState.dad.getGraphicMidpoint().y - 350);
		case 508:
			var objs = [
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				PlayState.botplayTxt,
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
			];
			PlayState.strumLineNotes.forEach(function(spr)
			{
				objs.push(spr);
			});
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 1}, 0.5);
			}

		case 512:
			PlayState.isCameraOnForcedPos = false;

			PlayState.followChars = true;

			PlayState.removeCinematicBars(0.5);

			PlayState.curCamera.bfZoom = 1;
			PlayState.curCamera.dadZoom = 0.8;

			PlayState.curCamera.dadPos[1] -= 100;
			PlayState.curCamera.bfPos[1] -= 30;

			PlayState.oscuro.visible = false;
			PlayState.basedSkeletons.visible = true;
			PlayState.sky.visible = true;
			PlayState.ground.visible = true;
		case 768:
			PlayState.curCamera.dadZoom = 1;
		case 898:
			PlayState.curCamera.dadZoom = 0.9;
		case 1204:
			PlayState.curCamera.dadZoom = 0.8;
		case 1036:
			PlayState.curCamera.dadZoom = 0.9;
		case 1040:
			PlayState.curCamera.dadZoom = 0.8;
		case 1052:
			PlayState.curCamera.dadZoom = 0.9;
		case 1068:
			PlayState.curCamera.bfZoom = 1.1;
		case 1072:
			PlayState.curCamera.bfZoom = 1;
		case 1084:
			PlayState.curCamera.bfZoom = 1.1;
		case 1088:
			PlayState.curCamera.dadZoom = 0.8;
			PlayState.curCamera.bfZoom = 1;
		case 1152:
			PlayState.curCamera.bfZoom = 1.2;
			PlayState.curCamera.dadZoom = 1.2;

			PlayState.addCinematicBars(1, 7);

			var objs = [
				PlayState.scoreGroup,
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
				FlxTween.tween(obj, {alpha: 0}, 1);
			}

			PlayState.curCamera.bfZoom = 1.4;

			PlayState.curCamera.bfPos[1] += 30;
		case 1280:
			PlayState.curCamera.bfZoom = 1.1;
		case 1395:
			PlayState.curCamera.dadZoom = 0.7;
			PlayState.opponentStrums.forEach(function(spr)
			{
				FlxTween.tween(spr, {alpha: 1}, 1);
			});
		case 1512:
			var objs = [
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				PlayState.botplayTxt,
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
			];
			PlayState.strumLineNotes.forEach(function(spr)
			{
				objs.push(spr);
			});
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 0}, 0.5);
			}
		case 1519:
			PlayState.satanlaugh.alpha = 1;
			PlayState.satanlaugh.animation.play('scape');

			// Being nice :) -lunar
			PlayState.health += 0.4;
		case 1528:
			var objs = [
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				PlayState.botplayTxt,
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
			];
			PlayState.strumLineNotes.forEach(function(spr)
			{
				objs.push(spr);
			});
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 1}, 1);
			}

			PlayState.curCamera.bfZoom = 1.4;

			PlayState.curCamera.bfPos[1] -= 70;
		case 1664:
			PlayState.curCamera.dadZoom = 0.9;

		case 1728:
			PlayState.isCameraOnForcedPos = true;

			PlayState.followChars = false;

			PlayState.curCamera.dadZoom = 0.65;
			PlayState.curCamera.bfZoom = 0.65;

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 300, PlayState.dad.getGraphicMidpoint().y - 10);
		case 1792:
			PlayState.curCamera.bfZoom = 1;
			PlayState.curCamera.dadZoom = 0.8;

			PlayState.curCamera.dadPos[1] -= 100;
			PlayState.curCamera.bfPos[1] -= 30;

			PlayState.isCameraOnForcedPos = false;

			PlayState.followChars = true;

			PlayState.removeCinematicBars(0.5);
		case 2304:
			PlayState.isCameraOnForcedPos = true;

			PlayState.followChars = false;

			PlayState.curCamera.dadZoom = 0.65;
			PlayState.curCamera.bfZoom = 0.65;

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 300, PlayState.dad.getGraphicMidpoint().y + 50);

			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}
