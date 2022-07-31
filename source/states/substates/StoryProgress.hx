package states.substates;

import data.Progression;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Alphabet;
import input.Controls;
import openfl.Lib;
import openfl.sensors.Accelerometer;
import states.substates.MusicBeatSubstate;

using StringTools;

class StoryProgress extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var onYes:Bool = true;
	var yesText:Alphabet;
	var noText:Alphabet;
	var text:Alphabet;
	var selectedsomething:Bool = false;
	var canSelect:Bool = false;

	public var finishedCallback:Void->Void;

	public var accepted:Void->Void;

	public var goback:Void->Void;

	public var startedSelect:Bool = false;

	public function new(?finished:Void->Void, ?yes:Void->Void, ?back:Void->Void)
	{
		super();

		startedSelect = controls.ACCEPT;

		canSelect = !startedSelect;

		if (finished != null)
			finishedCallback = finished;

		if (yes != null)
			accepted = yes;

		if (back != null)
			goback = back;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		text = new Alphabet(0, 280, "Would you like to continue?", true);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);

		yesText = new Alphabet(0, text.y + 150, 'Continue', true);
		yesText.screenCenter(X);
		yesText.x -= 300;
		add(yesText);

		noText = new Alphabet(0, text.y + 150, FlxG.random.bool(1) ? "Fuck You" : "Start Over", true);
		noText.screenCenter(X);
		noText.x += 250;
		add(noText);
		updateOptions();
	}

	override function update(elapsed:Float)
	{
		if (startedSelect && !controls.ACCEPT)
		{
			startedSelect = false;
			canSelect = true;
		}

		bg.alpha += elapsed * 1.5;
		if (bg.alpha > 0.6)
		{
			bg.alpha = 0.6;
		}

		for (i in 0...alphabetArray.length)
		{
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if (!selectedsomething && canSelect)
		{
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 1);
				onYes = !onYes;
				updateOptions();
			}
			if (controls.BACK)
			{
				selectedsomething = true;
				FlxG.sound.play(Paths.sound('cancelMenu'), 1);
				fadeOut(goback != null ? goback : function()
				{
				});
			}
			else if (controls.ACCEPT)
			{
				selectedsomething = true;
				if (onYes)
				{
					fadeOut(accepted);
				}
				else
				{
					fadeOut();
				}
			}
		}

		super.update(elapsed);
	}

	function fadeOut(?callback:Void->Void)
	{
		if (callback == null)
		{
			callback = function()
			{
				if (finishedCallback != null)
				{
					finishedCallback();
				}
			};
		}

		var objs:Array<Dynamic> = [text, yesText, noText, bg];
		for (obj in objs)
		{
			FlxTween.tween(obj, {alpha: 0}, 0.5, {
				onComplete: function(twn:FlxTween)
				{
				}
			});
		}

		(new FlxTimer()).start(0.5, function(tmr:FlxTimer)
		{
			close();
			callback();
		});
	}

	function updateOptions()
	{
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}
}
