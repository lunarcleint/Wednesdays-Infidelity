package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var warnImage:FlxSprite;
	override function create()
	{
		super.create();

		warnImage = new FlxSprite(-400, -100).loadGraphic(Paths.image('mickeysangre'));
		warnImage.antialiasing = true;
		warnImage.alpha = 0.4;
		warnImage.scrollFactor.set();
		warnImage.screenCenter(X);
		add(warnImage);

		warnText = new FlxText(0, 0, FlxG.width,
			"This mod includes loud effects, flashing lights, and shake effects.\n
			Soon we will make a patch with an option to disable this." + TitleState.updateVersion + "!\n
			\n
			You are warned.\n
			Press ENTER to continue.",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warnText.screenCenter(Y);
		add(warnText);

		new FlxTimer().start(2.5, function (tmrr:FlxTimer)
		{
			FlxTween.tween(warnImage, {alpha: 0}, 2.5, {type:PINGPONG});
		});
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(warnImage, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						warnImage.visible = false;
					}
				});
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						warnImage.visible = false;
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
