var curSection = 0;
var stepDev = 0;

function onCreate()
{
	PlayState.camZooming = false;
	PlayState.singingTurnsOnCamZoom = false;

	PlayState.blackFuck = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, fromRGB(0, 0, 0));
	PlayState.blackFuck.cameras = [PlayState.camOther];
	PlayState.add(PlayState.blackFuck);

	PlayState.addCinematicBars(0.0000001, 7);
}

function onSongStart()
{
	PlayState.songLength = 104.5 * 1000;
}

function onStepHit()
{
	if (curStep % 16 == 0)
	{
		curSection = Math.floor(curStep / 16);
	}

	stepDev = Math.floor(curStep % 16) + 1;

	if (curSection >= 16 && curSection <= 23)
	{
		if (curStep % 16 == 0)
			addCamZoom(0.25, 0.082);
	}

	if (curSection >= 24 && curSection <= 47 || curSection >= 111 && curSection <= 124)
	{
		if (curStep % 4 == 0)
			addCamZoom(0.2, 0.07);
	}

	if (curSection >= 53 && curSection <= 67 || curSection >= 78 && curSection <= 84 || curSection >= 87 && curSection <= 94)
	{
		if (curStep % 4 == 0)
			addCamZoom(0.12, 0.05);
	}

	if (curStep == 840 || curStep == 844)
		addCamZoom(0.2, 0.07);

	if (curStep == 1088 || curStep == 1092 || curStep == 1240 || curStep == 1244 || curStep == 1360 || curStep == 1364)
		addCamZoom(0.12, 0.05);

	if (curStep == 776 || curStep == 1096)
		addCamZoom(0.15, 0.06);

	if (curSection >= 49 && curSection <= 51 || curSection >= 95 && curSection <= 110)
	{
		if (curStep % 8 == 0)
			addCamZoom(0.15, 0.06);
	}

	switch (curStep)
	{
		case 1:
			PlayState.remove(PlayState.blackFuck);

			PlayState.cutsceneText.alpha = 0;
			PlayState.cutsceneText.visible = true;
			PlayState.cutsceneText.size = 32;
			PlayState.cutsceneText.fieldWidth = 1000;
			PlayState.cutsceneText.x = 170;
			PlayState.cutsceneText.y = 560;

			var dodgeKeys = ClientPrefs.keyBinds.get('dodge');

			var keysText = getKey(dodgeKeys[0]).toUpperCase()
				+ (!checkKey(getKey(dodgeKeys[0])) && !checkKey(getKey(dodgeKeys[1])) ? " " : "")
				+ getKey(dodgeKeys[1]).toUpperCase();

			PlayState.cutsceneText.text = "Your dodge keybinds are: %" + keysText + "%";

			PlayState.cutsceneText.applyMarkup("Your dodge keybinds are: $" + keysText + "$",
				[new FlxTextFormatMarkerPair(new FlxTextFormat(fromRGB(255, 255, 0)), "$")]);

			FlxTween.tween(PlayState.cutsceneText, {alpha: 1}, 1);
		case 64:
			FlxTween.tween(PlayState.cutsceneText, {alpha: 0}, 1);

		case 224:
			PlayState.followChars = false;
			PlayState.isCameraOnForcedPos = true;
			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x, PlayState.dad.getGraphicMidpoint().y - 70);

			var objs = [
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
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
				FlxTween.tween(obj, {alpha: 0}, 0.2);
			}

			FlxTween.tween(FlxG.camera, {zoom: 1.2}, 2);
		case 256:
			var objs = [
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
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
				FlxTween.tween(obj, {alpha: 1}, 0.2);
			}

			PlayState.singingTurnsOnCamZoom = true;

			PlayState.isCameraOnForcedPos = false;

			PlayState.followChars = true;
		case 272:
			PlayState.curCamera.dadZoom = 1.1;
		case 288:
			PlayState.curCamera.dadZoom = 0.8;
		case 336:
			PlayState.curCamera.bfZoom = 1.2;
		case 352:
			PlayState.curCamera.bfZoom = 1;
		case 776:
			PlayState.curCamera.bfZoom -= 0.2;
			PlayState.curCamera.dadZoom -= 0.15;
		case 968:
			PlayState.curCamera.bfZoom += 0.2 / 2;
			PlayState.curCamera.dadZoom += 0.15 / 2;
		case 1032:
			PlayState.curCamera.bfZoom += 0.2 / 2;
			PlayState.curCamera.dadZoom += 0.15 / 2;

		case 1112:
			PlayState.isCameraOnForcedPos = true;
			PlayState.followChars = false;

			PlayState.cameraStageZoom = false;

			PlayState.defaultCamZoom = PlayState.curCamera.dadZoom -= 0.15;

			FlxTween.tween(PlayState, {defaultCamZoom: PlayState.curCamera.dadZoom + 0.4}, 9.58);

			PlayState.camFollow.set(PlayState.dad.getGraphicMidpoint().x + 305, PlayState.dad.getGraphicMidpoint().y - 100);

		case 1240:
			PlayState.followChars = true;

			PlayState.cameraStageZoom = true;
		case 1376:
			PlayState.isCameraOnForcedPos = true;
			PlayState.followChars = false;

			PlayState.cameraStageZoom = false;

			FlxTween.tween(PlayState, {defaultCamZoom: PlayState.curCamera.dadZoom + 0.7}, 1, {ease: FlxEase.circOut});

			FlxTween.tween(PlayState.camGame, {alpha: 0}, 1, {ease: FlxEase.circOut});

		case 1392:
			FlxTween.tween(PlayState, {songLength: FlxG.sound.music.length}, 10, {ease: FlxEase.circInOut});

			var objs = [
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.botplayTxt
			];
			PlayState.strumLineNotes.forEach(function(spr)
			{
				objs.push(spr);
			});
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 0}, 1);
			}
		case 1512:
			PlayState.cameraStageZoom = false;

			FlxTween.tween(PlayState, {defaultCamZoom: 0.8}, 1, {
				ease: FlxEase.circIn,
				onComplete: function(t)
				{
					PlayState.cameraStageZoom = true;
					PlayState.followChars = true;

					PlayState.curCamera.dadZoom = 0.8;
					PlayState.curCamera.bfZoom = 1;
				}
			});

			FlxTween.tween(PlayState.camGame, {alpha: 1}, 1, {ease: FlxEase.circIn});

		case 1520:
			var objs = [
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.botplayTxt,
			];

			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 1}, 0.2);
			}

			fadeDadStrum(1, 0.2);
		case 1634:
			fadeBfStrum(1, 1);
		case 1648:
			fadeDadStrum(0, 1);
		case 1699:
			fadeDadStrum(1, 1);
		case 2000:
			PlayState.curCamera.dadZoom += 0.1;
			PlayState.curCamera.bfZoom += 0.1;
		case 2016:
			PlayState.curCamera.dadZoom += 0.1;
			PlayState.curCamera.bfZoom += 0.1;
		case 2032:
			PlayState.curCamera.dadZoom += 0.1;
			PlayState.curCamera.bfZoom += 0.1;
		case 2032:
			fadeDadStrum(0, 1);
			fadeBfStrum(0, 1);

			FlxTween.tween(PlayState.camGame, {alpha: 0}, 1);

			FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1);
	}
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
}

function fadeDadStrum(alph, time)
{
	PlayState.opponentStrums.forEach(function(spr)
	{
		FlxTween.tween(spr, {alpha: alph}, time);
	});
}

function fadeBfStrum(alph, time)
{
	PlayState.playerStrums.forEach(function(spr)
	{
		FlxTween.tween(spr, {alpha: alph}, time);
	});
}

function checkKey(s)
{
	return !(s != null && s != '---');
}

function getKey(t)
{
	var s = InputFormatter.getKeyName(t);

	return checkKey(s) ? '' : s;
}
