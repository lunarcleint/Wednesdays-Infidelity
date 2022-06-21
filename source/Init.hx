package;

import flixel.FlxG;
import flixel.FlxState;
import input.PlayerSettings;
import states.menus.TitleState;

class Init extends FlxState
{
	public override function new()
	{
		super();
	}

	public override function create()
	{
		super.create();

		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;

		FlxG.autoPause = false;

		PlayerSettings.reset();

		PlayerSettings.init();

		FlxG.switchState(Type.createInstance(Main.initialState, []));
	}
}
