#if web
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
#else
import openfl.events.Event;
import vlc.VlcBitmap;
#end
import flixel.FlxBasic;
import flixel.FlxG;
import lime.app.Application;
import PlayerSettings;

class FlxVideo extends FlxBasic {
	#if VIDEOS_ALLOWED
	public var finishCallback:Void->Void = null;
	
	#if desktop
	public static var vlcBitmap:VlcBitmap;
	#end

	public var skipable:Bool = false;

	public function new(name:String, ?skip:Bool) {
		#if PRIVATE_BUILD 
		skipable = true;
		#else 
		if (skip != null) skipable = skip;
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
			onMetaData: function() {
				player.attachNetStream(netStream);
				player.width = FlxG.width;
				player.height = FlxG.height;
			}
		};
		netConnect.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent) {
			if(event.info.code == "NetStream.Play.Complete") {
				netStream.dispose();
				if(FlxG.game.contains(player)) FlxG.game.removeChild(player);

				if(finishCallback != null) finishCallback();
			}
		});
		netStream.play(name);

		#elseif desktop
		// by Polybius, check out PolyEngine! https://github.com/polybiusproxy/PolyEngine

		vlcBitmap = new VlcBitmap();
		vlcBitmap.set_height(FlxG.stage.stageHeight);
		vlcBitmap.set_width(FlxG.stage.stageHeight * (16 / 9));

		vlcBitmap.onComplete = onVLCComplete;
		vlcBitmap.onError = onVLCError;

		FlxG.stage.addEventListener(Event.ENTER_FRAME, fixVolume);
		vlcBitmap.repeat = 0;
		vlcBitmap.inWindow = false;
		vlcBitmap.fullscreen = false;
		fixVolume(null);

		FlxG.addChildBelowMouse(vlcBitmap);
		vlcBitmap.play(checkFile(name));
		#end

		FlxG.stage.addEventListener(Event.ENTER_FRAME, newUpdate);
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

	function fixVolume(e:Event)
	{
		// shitty volume fix
		vlcBitmap.volume = 0;
		if(!FlxG.sound.muted && FlxG.sound.volume > 0.01) { //Kind of fixes the volume being too low when you decrease it
			vlcBitmap.volume = FlxG.sound.volume * 0.5 + 0.5;
		}
	}

	function newUpdate(e:Event) {
		if (PlayerSettings.player1.controls.ACCEPT && skipable) {
			onVLCComplete();

			destroy();
		}
	}

	public function onVLCComplete()
	{
		vlcBitmap.stop();

		// Clean player, just in case!
		vlcBitmap.dispose();

		if (FlxG.game.contains(vlcBitmap))
		{
			FlxG.game.removeChild(vlcBitmap);
		}

		FlxG.stage.removeEventListener(Event.ENTER_FRAME, fixVolume);
		FlxG.stage.removeEventListener(Event.ENTER_FRAME, newUpdate);

		if (finishCallback != null)
		{
			finishCallback();
		}
	}

	
	function onVLCError()
		{
			trace("An error has occured while trying to load the video.\nPlease, check if the file you're loading exists.");
			if (finishCallback != null) {
				finishCallback();
			}
		}
	#end
	#end
}