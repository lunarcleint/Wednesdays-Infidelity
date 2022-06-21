package data;

import data.Song;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef StageFile =
{
	var directory:String;
	var defaultZoom:Float;
	var isPixelStage:Bool;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
	var hide_girlfriend:Bool;
	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;
}

class StageData
{
	public static var forceNextDirectory:String = null;

	public static function loadDirectory(SONG:SwagSong)
	{
		var stage:String = '';
		if (SONG.stage != null)
		{
			stage = SONG.stage;
		}
		else if (SONG.song != null)
		{
			switch (SONG.song.toLowerCase().replace(' ', '-'))
			{
				case 'spookeez' | 'south' | 'monster':
					stage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					stage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					stage = 'limo';
				case 'cocoa' | 'eggnog':
					stage = 'mall';
				case 'winter-horrorland':
					stage = 'mallEvil';
				case 'senpai' | 'roses':
					stage = 'school';
				case 'thorns':
					stage = 'schoolEvil';
				default:
					stage = 'stage';
			}
		}
		else
		{
			stage = 'stage';
		}

		var stageFile:StageFile = getStageFile(stage);
		if (stageFile == null)
		{ // preventing crashes
			forceNextDirectory = '';
		}
		else
		{
			forceNextDirectory = stageFile.directory;
		}
	}

	public static function getStageFile(stage:String):StageFile
	{
		var rawJson:String = null;
		var path:String = Paths.getPreloadPath('stages/' + stage + '.json');

		if (Assets.exists(path))
		{
			rawJson = Assets.getText(path);
		}
		else
		{
			return null;
		}
		return cast Json.parse(rawJson);
	}
}
