package gameObjects;

#if web
import openfl.events.NetStatusEvent;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
#else
import openfl.events.Event;
#end
import flixel.FlxBasic;
import flixel.FlxG;
import input.PlayerSettings;
import vlc.MP4Handler;

class FlxVideo extends FlxBasic
{
	#if VIDEOS_ALLOWED
	public var finishCallback:Void->Void = null;

	#if desktop
	#end
	public var skipable:Bool = false;

	public function new(name:String, ?skip:Bool, ?focus:Bool = true)
	{
		#if PRIVATE_BUILD
		skipable = true;
		#else
		if (skip != null)
			skipable = skip;
		#end

		super();

		#if web
		var player:Video = new Video();
		player.x = 0;
		player.y = 0;
		FlxG.addChildBelowMouse(player);
		var netConnect = new NetConnection();
		netConnect.connect(null);
		var netStream = new NetStream(netConnect);
		netStream.client = {
			onMetaData: function()
			{
				player.attachNetStream(netStream);
				player.width = FlxG.width;
				player.height = FlxG.height;
			}
		};
		netConnect.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent)
		{
			if (event.info.code == "NetStream.Play.Complete")
			{
				netStream.dispose();
				if (FlxG.game.contains(player))
					FlxG.game.removeChild(player);

				if (finishCallback != null)
					finishCallback();
			}
		});
		netStream.play(name);
		#elseif desktop
		var video:MP4Handler = new MP4Handler(focus);
		video.playVideo(name);
		video.finishCallback = onVLCComplete;
		video.onError = onVLCError;
		video.skipable = skipable;
		#end
	}

	#if desktop
	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}

	public function onVLCComplete()
	{
		if (finishCallback != null)
		{
			finishCallback();
		}

		destroy();
	}

	function onVLCError()
	{
		trace("An error has occured while trying to load the video.\nPlease, check if the file you're loading exists.");
		if (finishCallback != null)
		{
			finishCallback();
		}
	}
	#end
	#end
}
