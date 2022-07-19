package openfl.display;

import flixel.math.FlxMath;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	private var memPeak:Float = 0;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 12, color);
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		width = 150;

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = "FPS: " + currentFPS;
		}

		cacheCount = currentCount;

		if (System.totalMemory > memPeak)
			memPeak = System.totalMemory;

		if (visible)
		{
			text = "FPS:"
				+ currentFPS
				+ "\nMEM: "
				+ _getFormattedSize(System.totalMemory, 2)
				+ " \nMEM peak: "
				+ _getFormattedSize(memPeak, 2);
		}
	}

	final sizes:Array<String> = ["Bytes", "KB", "MB", "GB", "TB"];

	@:noCompletion
	/**
		Stolen from https://github.com/adireddy/perf/blob/master/src/Perf.hx#L223 lmao
	**/
	function _getFormattedSize(bytes:Float, ?frac:Int = 0):String
	{
		if (bytes == 0)
			return "0";
		var i = Math.floor(Math.log(bytes) / Math.log(1024));
		var precision = Math.pow(10, i <= 2 ? 0 : frac);
		return Math.round(bytes * precision / Math.pow(1024, i)) / precision + " " + sizes[i];
	}
}
