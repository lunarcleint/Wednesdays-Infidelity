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
	PlayState.songLength = 121 * 1000;
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

	if (curSection >= 24 && curSection <= 47 || curSection >= 69 && curSection <= 99)
	{
		if (curStep % 4 == 0)
			addCamZoom(0.2, 0.07);
	}

	if (curStep == 1096 || curStep == 1100)
		addCamZoom(0.2, 0.07);

	if (curStep == 776 || curStep == 1096)
		addCamZoom(0.15, 0.06);

	if (curSection >= 49 && curSection <= 67 || curSection >= 109 && curSection <= 138)
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
			PlayState.curCamera.dadZoom = 1;
		case 288:
			PlayState.curCamera.dadZoom = 0.8;
		case 336:
			PlayState.curCamera.bfZoom = 1.1;
		case 352:
			PlayState.curCamera.bfZoom = 1;
		case 768:
			PlayState.curCamera.bfZoom = 1.1;
		case 776:
			PlayState.curCamera.bfZoom = 0.9;
		case 836:
			PlayState.curCamera.bfZoom = 1;
		case 856:
			PlayState.curCamera.dadZoom = 1;
		case 872:
			PlayState.curCamera.dadZoom = 0.8;
		case 1606:
			PlayState.camGame.visible = false;
		case 1616:
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
		case 1744:
			PlayState.camGame.visible = true;

			PlayState.camGame.alpha = 0;

			var objs = [
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.botplayTxt,
				PlayState.camGame
			];

			fadeDadStrum(1, 0.2);

			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 1}, 0.2);
			}
		case 1858:
			fadeBfStrum(1, 1);
		case 1878:
			fadeDadStrum(0, 1);
		case 1922:
			fadeDadStrum(1, 1);
		case 2256:
			fadeDadStrum(0, 1);
			fadeBfStrum(0, 1);

			PlayState.camGame.visible = false;
		case 2259:
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
