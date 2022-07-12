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
				PlayState.scoreTxt,
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
				PlayState.scoreTxt,
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
				PlayState.scoreTxt,
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
				PlayState.scoreTxt,
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
				PlayState.scoreTxt,
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
				PlayState.scoreTxt,
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
	}
}
