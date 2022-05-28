package;

import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import openfl.Lib;

using StringTools;

class FreeplaySelectorState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	override function create()
	{
		Lib.application.window.title = "Wednesday's Infidelity - Freeplay Selector";
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

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBGBlue'));
		bg.scrollFactor.set(0, 0);
		//bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var mickey:FlxSprite = new FlxSprite(250,-100).loadGraphic(Paths.image('menubackgrounds/menu_suicide'));
		mickey.ID = 0;
		menuItems.add(mickey);

		var julian:FlxSprite = new FlxSprite(mickey.x,mickey.y +180).loadGraphic(Paths.image('menubackgrounds/menu_julian'));
		julian.ID = 1;
		menuItems.add(julian);

		var chedder:FlxSprite = new FlxSprite(mickey.x, julian.y +180).loadGraphic(Paths.image('menubackgrounds/menu_cheddar'));
		chedder.ID = 2;
		menuItems.add(chedder);

		var sus:FlxSprite = new FlxSprite(mickey.x, chedder.y +180).loadGraphic(Paths.image('menubackgrounds/menu_sus'));
		sus.ID = 3;
		menuItems.add(sus);

		mickey.setGraphicSize(Std.int(mickey.width * 0.45));
		julian.setGraphicSize(Std.int(julian.width * 0.45));
		chedder.setGraphicSize(Std.int(chedder.width * 0.45));
		sus.setGraphicSize(Std.int(sus.width * 0.45));

		if (ClientPrefs.shake)
			FlxG.camera.shake(0.001, 99999999999);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) {
			if (FlxG.sound.music.volume < 0.8)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			}
		}


		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		//camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT)
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

							if (ClientPrefs.flashing) {
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									MusicBeatState.switchState(new FreeplayState());
								});
							} else {
								new FlxTimer().start(1,function(tmr:FlxTimer) {
									MusicBeatState.switchState(new FreeplayState());
								});
							}

						}
					});
				}
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
			var newShader:ColorSwap = new ColorSwap();
			spr.shader = newShader.shader;
			newShader.brightness = -0.8;
			spr.setGraphicSize(Std.int(spr.width * 0.45));

			if (spr.ID == curSelected)
			{
				spr.shader = null;
				spr.setGraphicSize(Std.int(spr.width * 0.47));
				if (ClientPrefs.flashing) {
					FlxG.camera.flash(FlxColor.BLACK, 0.2, null, true);
				}
				//FlxG.camera.flash(FlxColor.BLACK, 0.2);
				//camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}
