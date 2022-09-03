var curSection = 0;
var stepDev = 0;

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	if (curSection >= 8 && curSection <= 23)
	{
		var section = curSection % 4;

		if (section == 0)
		{
			if (stepDev == 1)
			{
				addCamZoom(0.15, 0.07);
			}
		}

		if (section == 1)
		{
			if (stepDev == 1)
			{
				addCamZoom(0.2, 0.09);
			}
		}

		if (section == 2)
		{
			if (stepDev == 1 || stepDev == 13)
			{
				addCamZoom(0.15, 0.07);
			}
		}

		if (section == 3)
		{
			if (stepDev == 1)
			{
				addCamZoom(0.2, 0.08);
			}
		}
	}

	if (curSection >= 25 && curSection <= 32)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.15, 0.07);
		}
	}

	if (curSection >= 33 && curSection <= 48 || curSection >= 65 && curSection <= 80 || curSection >= 84 && curSection <= 91 || curSection >= 125
		&& curSection <= 148 || curSection >= 165 && curSection <= 180 || curSection >= 214 && curSection <= 221)
	{
		if (curStep % 8 == 0)
		{
			addCamZoom(0.15, 0.07);
		}
	}

	if (curSection >= 49 && curSection <= 64 || curSection >= 92 && curSection <= 115 || curSection >= 182 && curSection <= 213)
	{
		if (curStep % 4 == 0)
		{
			addCamZoom(0.2, 0.08);
		}
	}

	if (curStep == 2890 || curStep == 2892 || curStep == 2893 || curStep == 2894 || curStep == 2895)
	{
		addCamZoom(0.3, 0.08);
	}

	switch (curStep)
	{
		case 1312:
			PlayState.addCinematicBars(1);

			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);

			PlayState.isCameraOnForcedPos = true;

			PlayState.followChars = false;

		case 1313:
			PlayState.camFollow.set(600, 120);

			PlayState.cameraStageZoom = false;

			PlayState.defaultCamZoom = 0.6;

		case 1340:
			PlayState.gf.animation.callback = function(name, frameNumber, frameIndex)
			{
				if (name == "spawn" && frameNumber == 6 && PlayState.infernogroundparts["p1"] != null)
				{
					PlayState.remove(PlayState.gf);
					PlayState.insert(PlayState.members.indexOf(PlayState.infernogroundparts["p1"]) - 1, PlayState.gf);
				}
			};

			PlayState.gf.alpha = 1;
			PlayState.gf.playAnim("spawn", false);
			PlayState.gf.specialAnim = true;

			PlayState.isCameraOnForcedPos = false;

			PlayState.followChars = true;
		case 1343:
			PlayState.gf.specialAnim = false;
			PlayState.gf.dance();
		case 1344:
			FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1);
			PlayState.cameraStageZoom = true;
		case 1345:
			PlayState.changeDadIcon(true);
		case 1376:
			PlayState.gf.playAnim("laugh", true);
			PlayState.gf.specialAnim = true;
		case 1392:
			PlayState.gf.specialAnim = false;
			PlayState.gf.dance();
		case 1440:
			PlayState.gf.playAnim("laugh", true);
			PlayState.gf.specialAnim = true;
		case 1456:
			PlayState.gf.specialAnim = false;
			PlayState.gf.dance();
		case 1792:
			PlayState.gf.playAnim("laugh", true);
			PlayState.gf.specialAnim = true;
		case 1808:
			PlayState.gf.specialAnim = false;
			PlayState.gf.dance();
		case 1856:
			PlayState.gf.playAnim("laugh", true);
			PlayState.gf.specialAnim = true;
		case 1867:
			PlayState.gf.specialAnim = false;
			PlayState.gf.dance();
		case 1868:
			PlayState.removeCinematicBars(1);

			PlayState.gf.animation.callback = function(name, frameNumber, frameIndex)
			{
				if (name == "spawn" && frameNumber == 6 && PlayState.infernogroundparts["p1"] != null)
				{
					PlayState.remove(PlayState.gf);
					PlayState.insert(PlayState.members.indexOf(PlayState.infernogroundparts["p1"]) - 1, PlayState.gf);
				}
				if (name == "spawn" && frameNumber == 0)
				{
					PlayState.changeDadIcon(false);
					PlayState.remove(PlayState.gf);

					PlayState.gf.visible = false;
				}
			};

			PlayState.gf.playAnim("spawn", true, true);
			PlayState.gf.specialAnim = true;

			PlayState.isCameraOnForcedPos = true;

			PlayState.followChars = true;

			PlayState.camFollow.set(600, 120);

		case 1876:
			PlayState.isCameraOnForcedPos = false;

			PlayState.followChars = true;

		case 2384:
			PlayState.curCamera.dadPos[1] += 30;
			PlayState.curCamera.bfPos[1] += 30;

			PlayState.addCinematicBars(1.5);

			var arr = [
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				Main.fpsVar
			];

			for (obj in arr)
			{
				FlxTween.tween(obj, {alpha: 0}, 1.5);
			}

			PlayState.curCamera.bfZoom = 1.2;

			PlayState.curCamera.dadZoom = 1.2;

		case 2896:
			PlayState.curCamera.dadPos[1] -= 30;
			PlayState.curCamera.bfPos[1] -= 30;

			PlayState.removeCinematicBars(0.000000000000000000001);

			PlayState.camGame.visible = false;

			PlayState.camHUD.visible = false;

		case 2912:
			PlayState.camGame.visible = true;

			PlayState.camHUD.visible = true;

			var arr = [
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				Main.fpsVar
			];

			for (obj in arr)
			{
				FlxTween.tween(obj, {alpha: 1}, 1);
			}

			PlayState.curCamera.bfZoom = 1.0;

			PlayState.curCamera.dadZoom = 0.8;

		case 3552:
			PlayState.curCamera.dadPos[1] += 30;
			PlayState.curCamera.bfPos[1] += 30;

			PlayState.addCinematicBars(1);

			var arr = [
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
				Main.fpsVar
			];

			for (obj in arr)
			{
				FlxTween.tween(obj, {alpha: 0}, 1);
			}

			PlayState.curCamera.bfZoom = 1.2;

			PlayState.curCamera.dadZoom = 1.2;

		case 3680: // IM GONNA CRY ITS SO SAD 😭 -lunar
			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1.4);
			FlxTween.tween(Main.fpsVar, {alpha: 1}, 2);
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}

function destroy()
{
	if (Main.fpsVar.alpha != 1)
		Main.fpsVar.alpha = 1;
}
