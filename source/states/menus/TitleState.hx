package states.menus;

import data.ClientPrefs;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Alphabet;
import lime.app.Application;
import openfl.Assets;
import openfl.Lib;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import song.Conductor;
import util.Shaders;

using StringTools;

#if desktop
import sys.thread.Thread;
import util.Discord.DiscordClient;
#end

// import flixel.graphics.FlxGraphic;
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var mickey:FlxSprite;

	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var mustUpdate:Bool = false;

	public static var updateVersion:String = '';

	var bloom:BloomEffect;
	var distort:DistortionEffect;
	var chrom:ChromaticAberrationEffect;

	var shaders:Array<ShaderEffect> = [];

	var spiral:SpiralSpin;
	var spiralbg:FlxSprite;

	override public function create():Void
	{
		// DiscordClient.changePresence("In the Menus", null);

		Main.fpsVar.visible = ClientPrefs.showFPS;

		Main.fpsVar.alpha = 0;

		FlxTween.tween(Main.fpsVar, {alpha: 1}, 1);

		Lib.application.window.title = "Wednesday's Infidelity - Title";

		FlxGraphic.defaultPersist = true;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var titleTextx:FlxSprite;
	var titleTextxs:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			if (FlxG.sound.music == null)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxG.sound.music.loopTime = 15920;
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;

		if (ClientPrefs.shaders)
		{
			if (ClientPrefs.intensiveShaders)
			{
				bloom = new BloomEffect(0);

				spiral = new SpiralSpin();
				spiral.speed.value = [4.0];
				spiral.iTime.value = [0];
			}

			distort = new DistortionEffect(0.25, 0.25, false);
			distort.shader.working.value = [false];

			chrom = new ChromaticAberrationEffect();

			addShader(distort);
			addShader(chrom);

			if (bloom != null)
				addShader(bloom);
		}

		if (spiral != null)
		{
			spiralbg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
			spiralbg.updateHitbox();
			spiralbg.screenCenter(X);
			spiralbg.scrollFactor.set(0, 0);
			spiralbg.shader = spiral;
			spiral.iResolution.value = [spiralbg.width, spiralbg.height];
			add(spiralbg);
		}
		else
		{
			spiralbg = new FlxSprite(0, 0).loadGraphic(Paths.image("Spiral Shader Still"));
			spiralbg.updateHitbox();
			spiralbg.screenCenter();
			spiralbg.scrollFactor.set(0, 0);
			add(spiralbg);
		}

		mickey = new FlxSprite(-400, 0).loadGraphic(Paths.image('mickeysangre', 'preload'));
		mickey.antialiasing = ClientPrefs.globalAntialiasing;
		mickey.updateHitbox();
		mickey.screenCenter(X);
		add(mickey);

		titleText = new FlxSprite(-400, -100).loadGraphic(Paths.image('titleEnter'));
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.setGraphicSize(Std.int(titleText.width * 0.55));
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		titleTextx = new FlxSprite(-200, -50).loadGraphic(Paths.image('titleEnter'));
		titleTextx.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleTextx.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleTextx.antialiasing = ClientPrefs.globalAntialiasing;
		titleTextx.setGraphicSize(Std.int(titleText.width * 0.55));
		titleTextx.animation.play('idle');
		titleTextx.updateHitbox();
		add(titleTextx);

		titleTextxs = new FlxSprite(200, 0).loadGraphic(Paths.image('titleEnter'));
		titleTextxs.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleTextxs.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleTextxs.antialiasing = ClientPrefs.globalAntialiasing;
		titleTextxs.setGraphicSize(Std.int(titleTextxs.width * 0.55));
		titleTextxs.animation.play('idle');
		titleTextxs.updateHitbox();
		add(titleTextxs);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	function addShader(effect:ShaderEffect)
	{
		if (!ClientPrefs.shaders)
			return;

		shaders.push(effect);

		var newCamEffects:Array<BitmapFilter> = [];

		for (i in shaders)
		{
			newCamEffects.push(new ShaderFilter(i.shader));
		}

		FlxG.camera.setFilters(newCamEffects);
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (!transitioning && skippedIntro)
		{
			if (pressedEnter)
			{
				if (ClientPrefs.flashing)
				{
					if (bloom != null)
					{
						bloom.setDim(0.1);

						var tween:NumTween = FlxTween.num(0.1, 1.8, 1);
						tween.onUpdate = function(t:FlxTween)
						{
							bloom.setDim(tween.value);
						}
					}
					else
					{
						FlxG.camera.flash();
					}
				}

				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				titleText.visible = false;
				titleTextx.visible = false;
				titleTextxs.visible = false;

				transitioning = true;

				new FlxTimer().start(1.7, function(tmr:FlxTimer)
				{
					Lib.application.window.title = "Wednesday's Infidelity";
					if (mustUpdate)
					{
						MusicBeatState.switchState(new MainMenuState());
					}
					else
					{
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		#if PRIVATE_BUILD
		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}
		#end

		if (distort != null)
			distort.update(elapsed);

		if (bloom != null)
			bloom.update(elapsed);

		if (spiral != null)
		{
			spiral.iTime.value[0] += elapsed;
			spiral.iResolution.value = [spiralbg.width, spiralbg.height];
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0, ?shake:Bool = false)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet;
			if (shake)
			{
				money = new Alphabet(0, 0, textArray[i], true, false, 0.05, 1, true);
			}
			else
			{
				money = new Alphabet(0, 0, textArray[i], true, false);
			}
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?offset:Float = 0, ?shake:Bool = false)
	{
		if (textGroup != null)
		{
			var coolText:Alphabet;
			if (shake)
			{
				coolText = new Alphabet(0, 0, text, true, false, 0.05, 1, true);
			}
			else
			{
				coolText = new Alphabet(0, 0, text, true, false);
			}
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen

	private static var closedState:Bool = false;

	override function stepHit()
	{
		super.stepHit();

		if (!closedState)
		{
			switch (curStep)
			{
				case 4:
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
				// credTextShit.visible = true;
				case 12:
					addMoreText('present');
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 16:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 20:
					createCoolText(['In association', 'with']);
				case 28:
					addMoreText('newgrounds');
					ngSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 32:
					deleteCoolText();
					ngSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 36:
					addMoreText("The wait is over");
				// credTextShit.visible = true;
				case 44:
					addMoreText("Its finally here");
				// credTextShit.text += '\nlmao';
				case 48:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 52:
					addMoreText('Friday');
				// credTextShit.visible = true;
				case 56:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 60:
					deleteCoolText();
				case 63:
					if (ClientPrefs.shake)
					{
						FlxG.camera.shake(0.004, 99999999999);
					}
					if (bloom != null)
						bloom.setSize(18.0);
					if (distort != null)
						distort.shader.working.value = [true];

					if (chrom != null)
						doChrome(null, false);

					createCoolText([curWacky[0]], 0);
				case 74:
					addMoreText(curWacky[1], 0);
				case 97:
					deleteCoolText();
				case 108:
					if (distort != null)
						distort.shader.working.value = [false];

					if (ClientPrefs.flashing)
						flickerMickey(null);

					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.BLACK, 2.3, null, true);
			FlxG.camera.zoom = 1.2;

			FlxTween.tween(FlxG.camera, {zoom: 1}, 1.8, {ease: FlxEase.circOut});

			remove(credGroup);
			skippedIntro = true;
		}
	}

	function flickerMickey(T:FlxTimer)
	{
		if (!ClientPrefs.flashing)
			return;

		if (T != null)
			T.cancel();

		var a:Float = mickey.alpha == 0.95 ? 1 : 0.95;

		mickey.alpha = a;

		new FlxTimer().start(FlxG.random.float(0.08, 0.12), flickerMickey);
	}

	function doChrome(T:FlxTimer, ?setChrom:Bool = true)
	{
		if (!ClientPrefs.shaders)
			return;

		if (T != null)
			T.cancel();

		if (chrom != null && setChrom)
			chrom.setChrome(FlxG.random.float(0.0, 0.002));

		new FlxTimer().start(FlxG.random.float(0.08, 0.12), function(tmr:FlxTimer)
		{
			new FlxTimer().start(FlxG.random.float(0.7, 1.6), function(tmr:FlxTimer)
			{
				doChrome(tmr, true);
			});
		});
	}
}
