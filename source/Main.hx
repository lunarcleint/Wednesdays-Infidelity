package;

import data.ClientPrefs;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import haxe.CallStack;
import input.Controls;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import states.menus.*;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).

	public static var initialState:Class<FlxState> = WarningState; // The FlxState the game starts with.

	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var canToggleFullScreen:Bool = false; // Will be set true in Init to make sure everything is ready

	public static var fullscreenKeys:Array<Null<FlxKey>>;

	public static var fpsVar:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();

		addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(error:Dynamic)
		{
			@:using(haxe.CallStack)
			var callStack:Array<Dynamic> = CallStack.callStack();

			for (call in callStack)
			{
				trace(call);
			}

			trace(error.message);
		});

		addEventListener(Event.ENTER_FRAME, update);
	}

	public function update(e:Event)
	{
		if (FlxG.keys == null)
			return;

		if (canToggleFullScreen && fullscreenKeys != null)
		{
			var lastPressed:FlxKey = FlxG.keys.firstJustPressed();

			if (!fullscreenKeys.contains(lastPressed))
				return;

			for (key in fullscreenKeys)
			{
				if (key == null || key == FlxKey.NONE)
					continue;

				if (key == lastPressed)
				{
					FlxG.fullscreen = !FlxG.fullscreen;
					break;
				}
			}
		}
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = WarningState;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, Init, zoom, framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		fpsVar = new FPS(10, 5, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if (fpsVar != null)
		{
			fpsVar.visible = false;
		}
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	}
}
