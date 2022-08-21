package states.menus;

#if desktop
import util.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.Alphabet;
import gameObjects.AttachedSprite;
import lime.utils.Assets;
import openfl.Lib;
import sys.FileSystem;
import sys.io.File;
import util.CoolUtil;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		Lib.application.window.title = "Wednesday's Infidelity - Credits";
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		var pisspoop:Array<Array<String>> = [
			// Name - Icon name - Description - Link - BG Color
			["Wednesday's Infidelity Team"],
			[
				'Jhaix',
				'Jhaix',
				'Director & Creator, Main Musician',
				'https://twitter.com/Jhaix3',
				'e2d4ce'
			],
			[
				'Nugget',
				'Nugget',
				'Co Director, Artist',
				'https://twitter.com/NuggetNightmare',
				'6e034b'
			],
			[
				'Cape',
				'Cape',
				'Main Charter & Extra Coder',
				'https://twitter.com/c4peletini',
				'242846'
			],
			['Zero', 'Zero', 'Art Director', 'https://twitter.com/zero_artist02', '003333'],
			[
				'Kyz',
				'Kyz',
				'Main Background Artist',
				'https://twitter.com/as_cookie',
				'362526'
			],
			[
				'Kass8tto',
				'Kass8tto',
				'Background Artist',
				'https://twitter.com/Kass8tto',
				'cccccc'
			],
			['Lunar', 'Lunar', 'Main Programmer', 'https://twitter.com/lunarcleint', '6757f3'],
			['Jloor', 'Jloor', 'Programmer', 'https://twitter.com/GamerJloor', 'fdc4ad'],
			["Sandi", "Sandi", "Musician", "https://www.twitter.com/Sandi334_", "eaeaea"],
			["GoddessAwe", 'Awe', 'Musician', 'https://twitter.com/GoddessAwe', "3e2c6b"],
			[
				"Lean",
				'Lean',
				'Musician, Programmer, and some Sound Effects',
				'https://twitter.com/NewLeandapper',
				"816954"
			],
			["Flaconadir", 'Flaco', 'Musician', 'https://youtube.com/c/Flaconadir', "9b2526"],
			[
				"Tok",
				'Tok',
				'Charter and Mokey Icon Artist',
				'https://twitter.com/ThatOne_Kid39',
				"725980"
			],
			['KINGF0X', 'Kingfox_', 'Voice actor', 'https://twitter.com/VOKINGF0X', '8f040b'],
			[''],
			["Specail Thanks"],
			[
				"Prob someone here",
				'Awe',
				'Musician',
				'https://twitter.com/GoddessAwe',
				"3e2c6b"
			],
			["Coder Specail Thanks"],
			[
				"Shader Toy",
				"none",
				"I stole alot of shaders:\nhttps://www.shadertoy.com/view/ldjGzV\nhttps://www.shadertoy.com/view/Ms3XWH\nhttps://www.shadertoy.com/view/XtK3W3",
				"https://www.shadertoy.com/\nhttps://www.shadertoy.com/view/lds3WB",
				"ffffff"
			],
			[
				"Vs RetroSpector",
				"none",
				"I stole your chromatic abberation",
				"https://gamebanana.com/mods/317366",
				"16d7e3"
			],
			[
				"Yoshi Engine",
				"none",
				"I stole most of HScript.hx (and a little of GameStats.hx) lmao",
				"https://twitter.com/FNFYoshiEngine",
				"6bd04b"
			],
			["47rooks", "none", "Literal Shader God", "https://github.com/47rooks", "e37b05"],
			[
				"BBPanzu",
				"none",
				"Stole Bloom Shader",
				"https://www.youtube.com/c/bbpanzuRulesSoSubscribeplz123",
				"238a07"
			],
		];

		for (i in pisspoop)
		{
			creditsStuff.push(i);
		}

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.yAdd -= 70;
			if (isSelectable)
			{
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			// optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (isSelectable)
			{
				if (creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				if (creditsStuff[i][1] != "none")
				{
					var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
					icon.xAdd = optionText.width + 10;
					icon.sprTracker = optionText;

					// using a FlxGroup is too much fuss!
					iconArray.push(icon);
					add(icon);
				}

				Paths.currentModDirectory = '';

				if (curSelected == -1)
					curSelected = i;
			}
		}

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER /*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		// descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!quitting)
		{
			if (creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-1 * shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(1 * shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if (controls.ACCEPT)
			{
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				if (colorTween != null)
				{
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				Lib.application.window.title = "Wednesday's Infidelity";
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}

		for (item in grpOptions.members)
		{
			if (!item.isBold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if (item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
					item.forceX = item.x;
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
					item.forceX = item.x;
				}
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var newColor:Int = getCurrentBGColor();
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if (moveTween != null)
			moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y: descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	function getCurrentBGColor()
	{
		var bgColor:String = creditsStuff[curSelected][4];
		if (!bgColor.startsWith('0x'))
		{
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool
	{
		return creditsStuff[num].length <= 1;
	}
}
