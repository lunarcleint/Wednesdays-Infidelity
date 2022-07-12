package states.menus;

import data.ClientPrefs;
import data.Progression;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Lib;
import states.editors.MasterEditorMenu;
import states.menus.CreditsState;
import states.menus.FreeplaySelectorState.ColorSwap;
import states.options.OptionsState;
import states.substates.ResetScoreSubState;
import util.CoolUtil;

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

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxGraphic.defaultPersist = false;

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
					CoolUtil.browserLoad('https://discord.gg/U4SbwdNHpX');
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
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
			if (#if PRIVATE_BUILD true #else Progression.beatMainWeek #end && FlxG.keys.justPressed.DELETE)
			{
				selectedSomethin = true;
				openSubState(new ResetScoreSubState(function()
				{
					selectedSomethin = false;
				}, function()
				{
					FlxTween.tween(FlxG.camera, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							Sys.exit(0);
						}
					});
					FlxTween.tween(FlxG.sound, {volume: 0}, 1);
				}));
			}

			#if PRIVATE_BUILD
			if (FlxG.keys.justPressed.T)
			{
				Progression.badEnding = true;
				Progression.goodEnding = true;
				Progression.beatHell = true;
				Progression.beatMainWeek = true;

				Progression.save();

				Sys.exit(0);
			}
			#end
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

		FlxG.bitmap.clearCache();

		FlxGraphic.defaultPersist = true;

		Paths.clearStoredMemory(true);

		#if cpp
		cpp.NativeGc.run(true);
		#end
	}
}
