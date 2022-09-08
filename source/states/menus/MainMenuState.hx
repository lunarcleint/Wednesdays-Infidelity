package states.menus;

import data.ClientPrefs;
import data.CppAPI;
import data.Highscore;
import data.Progression;
import data.Song;
import data.WindowsData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.IFlxSignal;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.graphics.Image;
import lime.tools.WindowData;
import openfl.Lib;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import states.editors.MasterEditorMenu;
import states.game.CutsceneState;
import states.game.PlayState;
import states.menus.CreditsState;
import states.menus.FreeplaySelectorState.ColorSwap;
import states.options.OptionsState;
import states.substates.ResetScoreSubState;
import util.CoolUtil;
import util.Shaders;

using StringTools;

#if desktop
import util.Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState
{
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if ACHIEVEMENTS_ALLOWED
		'awards',
		#end
		'credits',
		#if !switch
		'discord',
		#end
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var resetText:FlxText;

	@:isVar
	var keyCombos(default, set):Map<Array<FlxKey>, Void->Void> = [];

	var bloom:BloomEffect;
	var chrom:ChromaticAberrationEffect;

	var shaders:Array<ShaderEffect> = [];

	function set_keyCombos(newCombos:Map<Array<FlxKey>, Void->Void>):Map<Array<FlxKey>, Void->Void>
	{
		keyCombos = newCombos;

		combos = Lambda.count(keyCombos);

		return newCombos;
	}

	var combos:Null<Int>;
	var keysPressed:Map<Array<FlxKey>, Array<FlxKey>> = [];

	override function create()
	{
		keyCombos = [
			[FlxKey.D, FlxKey.O, FlxKey.O, FlxKey.K] => function()
			{
				selectedSomethin = true;

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				stopSound();

				Lib.application.window.title = "All this money on me make me wanna poop, Pull up to yo' crib in that Bentley coupe, Hit the studio just to take a dookRun up to the streets with that fruit loop, Pull up to yo' block to yo' fuckin' trap".toUpperCase();
				Lib.application.window.setIcon(Image.fromBitmapData(Paths.image("funni/MONEY").bitmap));

				MusicBeatState.switchState(new CutsceneState("dook", false, function()
				{
					Sys.exit(0);
				}));
			},
			[FlxKey.P, FlxKey.E, FlxKey.N, FlxKey.K] => function()
			{
				selectedSomethin = true;

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				stopSound();

				Lib.application.window.title = [for (_ in 0...100) "GRIDDY"].join(" ");
				Lib.application.window.setIcon(Image.fromBitmapData(Paths.image("funni/penkfunnyicon").bitmap));

				MusicBeatState.switchState(new CutsceneState("penk", false, function()
				{
					Sys.exit(0);
				}));
			},
			[FlxKey.M, FlxKey.E, FlxKey.E, FlxKey.S, FlxKey.K, FlxKey.A] => function()
			{
				selectedSomethin = true;

				FlxTransitionableState.skipNextTransIn = true;

				var songLowercase:String = Paths.formatToSongPath("Clubhouse");
				// var poop:String = Highscore.formatSong(songLowercase, 2);

				PlayState.SONG = Song.loadFromJson('clubhouse-hard', songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 2;
				PlayState.weekMisses = 0;

				FlxG.sound.music.volume = 0;

				LoadingState.loadAndSwitchState(new PlayState());
			},
			[FlxKey.C, FlxKey.O, FlxKey.L, FlxKey.E] => function()
			{
				selectedSomethin = true;

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				stopSound();

				MusicBeatState.switchState(new CutsceneState("cole", false, function()
				{
					Sys.exit(0);
				}));
			},
		];

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		Lib.application.window.title = "Wednesday's Infidelity - Main Menu";
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		if (ClientPrefs.shaders)
		{
			if (ClientPrefs.intensiveShaders)
			{
				bloom = new BloomEffect(5.0);
				addShader(bloom);
			}

			chrom = new ChromaticAberrationEffect();

			addShader(chrom);
		}

		doChrome(null, false);

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		// bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(150 + (30 * i), 50 + (70 * i));
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 2) * 0.135;
			if (optionShit.length < 4)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = true;

			if (optionShit[i] == 'freeplay' && !Progression.beatMainWeek)
			{
				var newShader:ColorSwap = new ColorSwap();
				menuItem.shader = newShader.shader;
				newShader.brightness = -0.8;
			}

			if (optionShit[i] == 'credits')
			{
				menuItem.y -= 10; // god this has been bothering me
			}
		}

		if (ClientPrefs.shake)
			FlxG.camera.shake(0.001, 99999999999);

		resetText = new FlxText(0, FlxG.height - 24, 0, "PRESS DELETE TO RESET PROGRESS", 12);
		resetText.scrollFactor.set();
		resetText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resetText.x = (FlxG.width - resetText.width) - 12;
		resetText.visible = Progression.beatMainWeek;
		resetText.cameras = [camAchievement];
		add(resetText);

		if (Progression.beatMainWeek)
			FlxTween.color(resetText, 1, FlxColor.WHITE, FlxColor.YELLOW, {type: PINGPONG});

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
		{
			if (FlxG.sound.music.volume < 0.8)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			}
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'discord')
				{
					CoolUtil.browserLoad('https://discord.gg/KYGJvPkN8C');
				}
				else if (!Progression.beatMainWeek && optionShit[curSelected] == 'freeplay')
				{
					FlxG.sound.play(Paths.sound('lockedSound'));
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxTween.tween(FlxG.camera, {zoom: 2.1}, 2, {ease: FlxEase.expoInOut});
							if (ClientPrefs.shake)
								FlxG.camera.shake(0.008, 0.08);

							if (ClientPrefs.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									switchState();
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									switchState();
								});
							}
						}
					});
				}
			}
			#if PRIVATE_BUILD
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
			#end
			if (#if PRIVATE_BUILD true #else Progression.beatMainWeek #end && FlxG.keys.justPressed.DELETE)
			{
				selectedSomethin = true;
				openSubState(new ResetScoreSubState(function()
				{
					selectedSomethin = false;
				}, function()
				{
					#if cpp
					CppAPI._setWindowLayered();

					var numTween:NumTween = FlxTween.num(1, 0, 1, {
						onComplete: function(twn:FlxTween)
						{
							Sys.exit(0);
						}
					});

					numTween.onUpdate = function(twn:FlxTween)
					{
						#if windows
						CppAPI.setWindowOppacity(numTween.value);
						#end
					}
					#else
					FlxTween.tween(FlxG.camera, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							Sys.exit(0);
						}
					});
					#end
					FlxTween.tween(FlxG.sound, {volume: 0}, 1);
				}));
			}

			#if PRIVATE_BUILD
			if (FlxG.keys.justPressed.T) // 100% THE GAME
			{
				Progression.badEnding = true;
				Progression.goodEnding = true;
				Progression.beatHell = true;
				Progression.beatMainWeek = true;

				Progression.save();

				Sys.exit(0);
			}
			#end

			checkCombos();
		}
	}

	function switchState()
	{
		Lib.application.window.title = "Wednesday's Infidelity";
		var daChoice:String = optionShit[curSelected];

		FlxTween.globalManager.cancelTweensOf(resetText);

		switch (daChoice)
		{
			case 'story_mode':
				MusicBeatState.switchState(new StoryMenuState());
			case 'freeplay':
				MusicBeatState.switchState(new FreeplaySelectorState());
			case 'credits':
				MusicBeatState.switchState(new CreditsState());
			case 'options':
				MusicBeatState.switchState(new OptionsState());
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		trace(camFollow.x, camFollow.y);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				if (ClientPrefs.flashing)
				{
					FlxG.camera.flash(FlxColor.BLACK, 0.2, null, true);
				}
				// FlxG.camera.flash(FlxColor.BLACK, 0.2);
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}

	public override function destroy()
	{
		super.destroy();
	}

	public function checkCombos()
	{
		if (combos <= 0)
			return;

		var lastPressed:FlxKey = FlxG.keys.firstJustPressed();

		for (keys in keyCombos.keys())
		{
			if (!keys.contains(lastPressed))
				continue;

			if (keysPressed[keys] == null)
				keysPressed[keys] = [];

			keysPressed[keys].push(lastPressed);

			if (keysPressed[keys].length == keys.length)
			{
				var same:Bool = true;

				for (i in 0...keysPressed[keys].length) // check if keys are the same
				{
					if (keysPressed[keys][i] != keys[i])
					{
						same = false;
						break;
					}
				}

				if (same)
				{
					if (keyCombos[keys] != null)
						keyCombos[keys]();
				}

				keysPressed[keys] = [];
				// Clears keys Pressed
			}
		}
	}

	function stopSound()
	{
		FlxG.sound.muteKeys = [];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.volumeUpKeys = [];

		for (sound in FlxG.sound.list)
			sound.stop();

		FlxG.sound.music.stop();

		Main.fpsVar.visible = false;

		FlxG.sound.volume = 1;

		Lib.application.window.title = "Wednesday's Infidelity";
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
