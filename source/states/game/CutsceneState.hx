package states.game;

import flixel.FlxG;
import gameObjects.FlxVideo;

using StringTools;

#if sys
import sys.FileSystem;
#end

class CutsceneState extends MusicBeatState // PlayState is alreadly laggy enough
{
	public var finishCallback:Void->Void;
	public var songName:String;
	public var endingCutscene:Bool = false;

	public var video:FlxVideo;

	public function new(songName:String, isEnd:Bool, ?finishCallback:Void->Void)
	{
		super();

		if (finishCallback != null)
			this.finishCallback = finishCallback;

		this.songName = songName;
		endingCutscene = isEnd;
	}

	override public function create()
	{
		if (songName != null)
		{
			chooseVideo();
		}
		else
		{
			finish();
		}
	}

	function chooseVideo()
	{
		var video:String = null;
		var skippable:Null<Bool> = null;

		if (endingCutscene)
		{
			switch (StringTools.replace(songName.toLowerCase(), '-', ' '))
			{
				case 'last day':
					video = "BadEnding";
					skippable = FlxG.save.data.gotbadending;
			}
		}
		else
		{
			switch (StringTools.replace(songName.toLowerCase(), '-', ' '))
			{
				case 'hellhole':
					video = "HellholeIntro";
					skippable = FlxG.save.data.beathell;
				case 'wistfulness':
					video = "StoryStart";
					skippable = FlxG.save.data.beatmainweek;
				case 'last day':
					video = "Portal";
					skippable = FlxG.save.data.gotbadending;
				case 'unknown suffering':
					video = "TransformUN";
					skippable = FlxG.save.data.beatmainweek;
			}
		}

		if (video != null && skippable != null)
		{
			playVideo(video, skippable);
		}
		else
		{
			finish();
		}
	}

	public function playVideo(videoName:String, ?skippable:Bool = false)
	{
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = Paths.video(videoName);

		if (FileSystem.exists(fileName))
		{
			foundFile = true;
		}

		if (foundFile)
		{
			var video = new FlxVideo(fileName, skippable);

			video.finishCallback = function()
			{
				finish();
			}
			return;
		}
		else
		{
			FlxG.log.warn('Couldnt find video file: ' + fileName);
			finish();
		}
		#else
		finish();
		#end
	}

	public function finish()
	{
		if (video != null)
		{
			video.destroy();
		}
		if (finishCallback != null)
			finishCallback();
	}
}
