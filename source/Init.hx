package;

import data.*;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import input.PlayerSettings;
import lime.app.Application;
import openfl.Lib;
import states.menus.StoryMenuState;
import states.menus.TitleState;
import util.Discord.DiscordClient;

class Init extends FlxState
{
	public override function new()
	{
		super();
	}

	public override function create()
	{
		super.create();

		FlxGraphic.defaultPersist = true;

		#if cpp
		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);
		#end

		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;

		FlxG.autoPause = false;

		PlayerSettings.reset();

		PlayerSettings.init();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		if (FlxG.save.data.beatmainweek == null) // W.I SAVES
		{
			FlxG.save.data.beatmainweek = false;
		}
		if (FlxG.save.data.gotbadending == null)
		{
			FlxG.save.data.gotbadending = false;
		}
		if (FlxG.save.data.gotgoodending == null)
		{
			FlxG.save.data.gotgoodending = false;
		}
		if (FlxG.save.data.beathell == null)
		{
			FlxG.save.data.beathell = false;
		}

		FlxG.mouse.visible = false;

		#if desktop
		DiscordClient.initialize();
		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end

		Lib.application.window.focus();

		ClientPrefs.loadDefaultKeys();

		Paths.excludeAsset('assets/preload/images/kevin_normal.png');

		FlxG.switchState(Type.createInstance(Main.initialState, []));
	}
}
