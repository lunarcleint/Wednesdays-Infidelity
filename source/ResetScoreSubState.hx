import openfl.sensors.Accelerometer;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Lib;

using StringTools;

class ResetScoreSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;
	var text:Alphabet;
	var selectedsomething:Bool = false;

	public var finishedCallback:Void->Void;

	public var accepted:Void->Void;

	public function new(?finished:Void->Void, ?yes:Void->Void)
	{
		super();

		if (finished != null)
			finishedCallback = finished;

		if (yes != null) 
			accepted = yes;
		

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		text = new Alphabet(0, 180, "Reset Story Progress?", true);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);

		yesText = new Alphabet(0, text.y + 150, 'Yes', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);
		noText = new Alphabet(0, text.y + 150, 'No', true);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);
		updateOptions();
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.6) bg.alpha = 0.6;

		for (i in 0...alphabetArray.length) {
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if (!selectedsomething) {
			if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'), 1);
				onYes = !onYes;
				updateOptions();
			}
			if(controls.BACK) {
				selectedsomething = true;
				FlxG.sound.play(Paths.sound('cancelMenu'), 1);
				fadeOut();
			} else if(controls.ACCEPT) {
				selectedsomething = true;
				if(onYes) {
					// Wow thats alot of data 

					FlxG.save.data.gotgoodending = null;
					FlxG.save.data.gotbadending = null;
					FlxG.save.data.beatmainweek = null;
					FlxG.save.data.beathell = null;

					FlxG.save.data.weekCompleted = null;

					// WIPE OUT ALL HIGH SCORES

					FlxG.save.data.weekScores = null;
					FlxG.save.data.songScores = null;
					FlxG.save.data.songRating = null;

					FlxG.save.flush();
					
					fadeOut(accepted);
					
				}else {
					FlxG.sound.play(Paths.sound('cancelMenu'), 1);
					fadeOut();
				}

			}
		}
		
		super.update(elapsed);
	}

	function fadeOut(?callback:Void->Void) {

		if (callback == null) {
			callback = function () {
				if (finishedCallback != null) {
					finishedCallback();
				}
			};
		}

		var objs:Array<Dynamic> = [text, yesText, noText, bg];
		for (obj in objs) {
			FlxTween.tween(obj, {alpha: 0}, 0.5, {onComplete: function (twn:FlxTween) {}});
		}
		
		(new FlxTimer()).start(0.5, function (tmr:FlxTimer) {
			close();
			callback();
		});
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}
}