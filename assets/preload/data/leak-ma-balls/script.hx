function onCreate()
{
	if (PlayState.leakSatan != null)
	{
		PlayState.leakSatan.animation.callback = function(n, f, i)
		{
			if (n == "idle")
			{
				PlayState.leakSatan.visible = false;
			}
			else
			{
				PlayState.leakSatan.visible = true;
			}
		}
	}
}

function onUpdate()
{
	if (curStep >= 57 && curStep < 192)
	{
		PlayState.defaultCamZoom = .9;
		PlayState.camFollow.set(PlayState.boyfriend.getMidpoint().x + 120, PlayState.boyfriend.getMidpoint().y - 150);
	}
}

function onStepHit()
{
	switch (curStep)
	{
		case 2: //subtitles
			FlxTween.tween(PlayState.cutsceneText, {alpha: 1}, 0.5);
			PlayState.cutsceneText.text = "What is that?";
		case 15:
			PlayState.cutsceneText.text = "Humans. Specifically Leakers, a race far below humanity.";
			PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 32, fromRGB(214, 32, 32), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));

			if (PlayState.leakSatan != null)
			{
				PlayState.leakSatan.playAnim("leakers");
				PlayState.leakSatan.specialAnim = true;
			}
		case 67:
			FlxTween.tween(PlayState.cutsceneText, {alpha: 0}, 0.5);
		case 79:
			FlxTween.tween(PlayState.cutsceneText, {alpha: 1}, 0.5);
			PlayState.cutsceneText.text = "Their only motivation that keeps them alive and still existing in this reality is to be a PEST";
		case 147:
			PlayState.cutsceneText.text = "one of the worst existing plagues of modern society.";
		case 184:
			FlxTween.tween(PlayState.cutsceneText, {alpha: 0}, 0.5);
		case 195:
			FlxTween.tween(PlayState.cutsceneText, {alpha: 1}, 0.5);
			PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 32, fromRGB(255, 255, 255), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));
			PlayState.cutsceneText.text = "Yo Leakers, that's why you straight built like a R/Niceguys-lookin";	
		case 240:
			PlayState.cutsceneText.text = "uUuUh, my waifu is gonna love me even though she looks like a fucking 10 year old";	
		case 284:
			PlayState.cutsceneText.text = "but it's ok beause she's like... 500 years old.";	
		case 317:
			FlxTween.tween(PlayState.cutsceneText, {alpha: 0}, 0.3);
		case 960:
			PlayState.addCinematicBars(0.5);
			var objs = [
				// me lo robe de lunar
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
			];
			PlayState.opponentStrums.forEach(function(spr)
			{
				objs.push(spr);
			});
			PlayState.playerStrums.forEach(function(spr)
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
			FlxTween.tween(PlayState.cutsceneText, {alpha: 1}, 0.3);
			PlayState.cutsceneText.text = "Please, please just send them away from us. Murder them. Fuckin' anything.";	
		case 1025:
			PlayState.cutsceneText.text = "Why am I ranting? I dunno. I should have ended this a long time ago.";	
		case 1075:
			PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 32, fromRGB(255, 227, 49), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));
			PlayState.cutsceneText.text = "Fuck, that rhymed.";	
		case 1086:
			FlxTween.tween(PlayState.cutsceneText, {alpha: 0}, 0.2);
		case 2041:
			FlxTween.tween(PlayState.cutsceneText, {alpha: 1}, 0.5);
			PlayState.cutsceneText.setFormat(Paths.font("vcr.ttf"), 32, fromRGB(105, 105, 105), CENTER, FlxTextBorderStyle.OUTLINE, fromRGB(0, 0, 0));
			PlayState.cutsceneText.text = "FUCK, I MISSED AGAIN!";	
		case 1:
			PlayState.cutsceneText.alpha = 0;
			PlayState.cutsceneText.visible = true;
			PlayState.cutsceneText.size = 32;
			PlayState.cutsceneText.fieldWidth = 1000;
			PlayState.cutsceneText.x = 170;
			PlayState.cutsceneText.y = 550;
			PlayState.addCinematicBars(1.2);
			var objs = [
				// me lo robe de lunar
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
			];
			PlayState.opponentStrums.forEach(function(spr)
			{
				objs.push(spr);
			});
			PlayState.playerStrums.forEach(function(spr)
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

		case 320:
			PlayState.removeCinematicBars(0.000001);
			var objs = [
				// me lo robe de lunar
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
			];
			PlayState.opponentStrums.forEach(function(spr)
			{
				objs.push(spr);
			});
			PlayState.playerStrums.forEach(function(spr)
			{
				objs.push(spr);
			});
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 1}, 0.00001, {
					onComplete: function(twn)
					{
						obj.visible = true;
					}
				});
			}
		case 1088:
			PlayState.removeCinematicBars(0.000001);
			var objs = [
				// me lo robe de lunar
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
			];
			PlayState.opponentStrums.forEach(function(spr)
			{
				objs.push(spr);
			});
			PlayState.playerStrums.forEach(function(spr)
			{
				objs.push(spr);
			});
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 1}, 0.00001, {
					onComplete: function(twn)
					{
						obj.visible = true;
					}
				});
			}
		case 1408:
			PlayState.addCinematicBars(0.2);
			var objs = [
				// me lo robe de lunar
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
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
		case 1472:
			PlayState.removeCinematicBars(0.000001);
			var objs = [
				// me lo robe de lunar
				PlayState.healthBar,
				PlayState.healthBarBG,
				PlayState.iconP1,
				PlayState.iconP2,
				PlayState.scoreGroup,
				PlayState.timeBar,
				PlayState.timeBarBG,
				PlayState.timeTxt,
			];
			PlayState.opponentStrums.forEach(function(spr)
			{
				objs.push(spr);
			});
			for (obj in objs)
			{
				FlxTween.tween(obj, {alpha: 1}, 0.00001, {
					onComplete: function(twn)
					{
						obj.visible = true;
					}
				});
			}
		case 2006:
			PlayState.osbaldo.animation.play('die', true);
			PlayState.osbaldo.setPosition(PlayState.osbaldo.x - 6, PlayState.osbaldo.y - 48); // the offsets doesn't work
		case 2021:
			if (PlayState.gf != null)
				PlayState.gf.visible = false;
	}
}
