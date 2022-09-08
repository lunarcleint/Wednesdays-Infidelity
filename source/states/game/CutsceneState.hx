package states.game;

import data.Progression;
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
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

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
		var focus:Null<Bool> = true;

		if (endingCutscene)
		{
			switch (StringTools.replace(songName.toLowerCase(), '-', ' '))
			{
				case 'last day':
					video = "BadEnding";
					skippable = Progression.badEnding;
			}
		}
		else
		{
			switch (StringTools.replace(songName.toLowerCase(), '-', ' '))
			{
				case 'sunsets':
					video = "Good ending cinematica";
					skippable = Progression.goodEnding;
				case 'hellhole':
					video = "HellholeIntro";
					skippable = Progression.beatHell;
				case 'wistfulness':
					video = "StoryStart";
					skippable = Progression.beatMainWeek;
				case 'last day':
					video = "Portal";
					skippable = Progression.badEnding;
				case 'unknown suffering':
					video = "TransformUN";
					skippable = Progression.beatMainWeek;
				case 'versiculus iratus':
					video = "good ending oh no";
					skippable = Progression.goodEnding;
				case 'dook':
					video = "LIL DROPTOP - DOOK";
					skippable = false;
					focus = false;
				case 'penk':
					video = "PENKARU GRIDDY";
					skippable = false;
					focus = false;
				case 'cole':
					video = "ongfr";
					skippable = false;
					focus = false;
			}
		}

		if (video != null && skippable != null && focus != null)
		{
			playVideo(video, skippable, focus);
		}
		else
		{
			finish();
		}
	}

	public function playVideo(videoName:String, ?skippable:Bool = false, ?focus:Bool = true)
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
			var video = new FlxVideo(fileName, skippable, focus);

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
