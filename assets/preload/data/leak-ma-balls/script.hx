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

function onStepHit()
{
	switch (curStep)
	{
		case 1:
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
		case 15:
			if (PlayState.leakSatan != null)
			{
				PlayState.leakSatan.playAnim("leakers");
				PlayState.leakSatan.specialAnim = true;
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
			PlayState.osbaldo.offset.set(0.6, 4.8);
		case 2021:
			if (PlayState.gf != null)
				PlayState.gf.visible = false;
	}
}
