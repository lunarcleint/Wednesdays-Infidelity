package states.menus;

import data.*;
import data.WeekData;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.*;
import lime.tools.LaunchStoryboard;
import lime.utils.Assets;
import openfl.Lib;
import openfl.utils.Assets as OpenFlAssets;
import states.editors.ChartingState;
import states.game.CutsceneState;
import states.game.PlayState;
import util.*;

using StringTools;

#if desktop
import util.Discord.DiscordClient;
#end
#if MODS_ALLOWED
import sys.FileSystem;
#end

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	private static var curSelected:Int = 0;

	var curDifficulty:Int = -1;

	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var daStatic:FlxSprite;

	@:isVar
	var keyCombos(default, set):Map<Array<FlxKey>, Void->Void> = [];

	function set_keyCombos(newCombos:Map<Array<FlxKey>, Void->Void>):Map<Array<FlxKey>, Void->Void>
	{
		keyCombos = newCombos;

		combos = Lambda.count(keyCombos);

		return newCombos;
	}

	var combos:Null<Int>;
	var keysPressed:Map<Array<FlxKey>, Array<FlxKey>> = [];

	var dsidesSongs:Array<String> = ["Untold Loneliness"];
	var encoreSongs:Array<String> = ["Too Slow"];

	var selectedSomethin:Bool = false;

	var text:FlxText;

	override function create()
	{
		keyCombos = [
			[FlxKey.SIX, FlxKey.SIX, FlxKey.SIX] => function()
			{
				selectedSomethin = true;

				songs.remove(songs[curSelected]);
				songs.insert(curSelected, new SongMetadata("Hellhole", 0, "icon-hellholemickey", FlxColor.fromRGB(42, 46, 40)));

				grpSongs.remove(grpSongs.members[curSelected]);

				iconArray[curSelected].visible = false;
				iconArray.remove(iconArray[curSelected]);

				var songText:Alphabet = new Alphabet(0, (70 * curSelected) + 30, songs[curSelected].songName, true, false);
				songText.isMenuItem = true;
				songText.instaLerp = true;
				songText.targetY = 0; // yeah idk either
				grpSongs.insert(curSelected, songText);

				for (letter in songText.lettersArray)
				{
					FlxFlicker.flicker(letter, 1.6, 0.06, false);
				}

				if (songText.width > 980)
				{
					var textScale:Float = 980 / songText.width;
					songText.scale.x = textScale;
					for (letter in songText.lettersArray)
					{
						letter.x *= textScale;
						letter.offset.x *= textScale;
					}
				}

				Paths.currentModDirectory = songs[curSelected].folder;
				var icon:HealthIcon = new HealthIcon(songs[curSelected].songCharacter);
				icon.sprTracker = songText;

				iconArray.insert(curSelected, icon);
				add(icon);

				FlxFlicker.flicker(icon, 1.6, 0.06, false);

				// Lib.application.window.title = "66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666";

				FlxG.sound.music.volume = 0;
				stopmusic = true;
				FlxG.camera.flash(FlxColor.BLACK, 1.2);
				FlxG.sound.play(Paths.sound('hellholeSFX'));

				remove(daStatic);
				insert(members.indexOf(icon) + 1, daStatic);

				FlxTween.tween(daStatic, {alpha: 0.5}, 1.4);

				FlxTween.tween(FlxG.camera, {zoom: 1.7}, 1.4, {ease: FlxEase.circIn});

				new FlxTimer().start(1.4, function(tmr:FlxTimer)
				{
					selectSong(true, true);
				});

				destroyFreeplayVocals();
			}
		];

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxGraphic.defaultPersist = false;

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			if (weekIsLocked(WeekData.weeksList[i]))
				continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				switch (song[0])
				{
					case 'Sunsets':
						if (!Progression.goodEnding)
							continue;
						else
							addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));

					case 'Last Day':
						if (!Progression.badEnding)
							continue;
						else
							addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));

					case 'Hellhole':
						if (!Progression.beatHell)
							continue;
						else
							addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));

					default:
						addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
				}
			}
		}
		WeekData.loadTheFirstEnabledMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		genSongs();

		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.color = FlxColor.GRAY;
		add(diffText);

		add(scoreText);

		if (curSelected >= songs.length)
			curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if (lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		text = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		text.screenCenter(X);
		add(text);

		daStatic = new FlxSprite(0, 0);
		daStatic.frames = Paths.getSparrowAtlas('daSTAT', 'shared');
		daStatic.setGraphicSize(FlxG.width, FlxG.height);
		// daStatic.alpha = 0.05;
		daStatic.alpha = 0.00001;
		daStatic.screenCenter();
		daStatic.scrollFactor.set(0, 0);
		daStatic.animation.addByPrefix('static', 'staticFLASH', 24, true);
		add(daStatic);
		daStatic.animation.play('static');

		super.create();
	}

	function genSongs()
	{
		for (i in 0...songs.length)
		{
			if (grpSongs.members[i] != null)
				return;

			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
			}

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
		{
			if (songCharacters == null)
				songCharacters = ['bf'];

			var num:Int = 0;
			for (song in songs)
			{
				addSong(song, weekNum, songCharacters[num]);
				this.songs[this.songs.length-1].color = weekColor;

				if (songCharacters.length != 1)
					num++;
			}
	}*/
	var instPlaying:Int = -1;

	private static var vocals:FlxSound = null;

	var holdTime:Float = 0;

	var stopmusic:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7 && !stopmusic)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2)
		{ // No decimals, add an empty space
			ratingSplit.push('');
		}

		while (ratingSplit[1].length < 2)
		{ // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		if (!selectedSomethin)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			var accepted = controls.ACCEPT;
			var space = FlxG.keys.justPressed.SPACE;
			var ctrl = FlxG.keys.justPressed.CONTROL;

			var shiftMult:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftMult = 3;

			if (songs.length > 1)
			{
				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
						changeDiff();
					}
				}
			}

			if (controls.UI_LEFT_P)
				changeDiff(-1);
			else if (controls.UI_RIGHT_P)
				changeDiff(1);
			else if (upP || downP)
				changeDiff();

			if (controls.BACK)
			{
				persistentUpdate = false;
				if (colorTween != null)
				{
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new FreeplaySelectorState());
				Lib.application.window.title = "Wednesday's Infidelity";
			}

			if (space)
			{
				if (instPlaying != curSelected)
				{
					#if PRELOAD_ALL
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;
					Paths.currentModDirectory = songs[curSelected].folder;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					if (PlayState.SONG.needsVoices)
						vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					else
						vocals = new FlxSound();

					FlxG.sound.list.add(vocals);
					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
					vocals.play();
					vocals.persist = true;
					vocals.looped = true;
					vocals.volume = 0.7;
					instPlaying = curSelected;
					#end
				}
			}
			else if (accepted)
			{
				persistentUpdate = false;

				selectSong();
			}

			if (Progression.beatMainWeek && Progression.badEnding && !Progression.beatHell)
			{
				checkCombos();
			}
		}

		super.update(elapsed);
	}

	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	public function selectSong(?playstate:Bool = true, ?story:Bool = false)
	{
		FlxTween.globalManager.cancelTweensOf(diffText);

		var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
		var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

		PlayState.SONG = Song.loadFromJson(poop, songLowercase);
		PlayState.isStoryMode = story;
		PlayState.storyDifficulty = curDifficulty;

		if (colorTween != null)
		{
			colorTween.cancel();
		}

		Lib.application.window.title = "Wednesday's Infidelity";

		FlxG.sound.music.volume = 0;

		destroyFreeplayVocals();

		if (playstate)
		{
			if (story) // songLowercase
			{
				LoadingState.loadAndSwitchState(new CutsceneState(songLowercase, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				}), true);
			}
			else
			{
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length - 1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;

		var diff:String = CoolUtil.difficultyString();

		if (encoreSongs.contains(songs[curSelected].songName))
			diff = "ENCORE";
		else if (dsidesSongs.contains(songs[curSelected].songName))
			diff = "DSIDE";

		diffText.text = '< ' + diff + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var newColor:Int = songs[curSelected].color;
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		if (encoreSongs.contains(songs[curSelected].songName))
		{
			FlxTween.globalManager.cancelTweensOf(diffText);

			FlxTween.color(diffText, 0.5, diffText.color, FlxColor.YELLOW);
		}
		else if (dsidesSongs.contains(songs[curSelected].songName))
		{
			FlxTween.globalManager.cancelTweensOf(diffText);

			FlxTween.color(diffText, 0.5, diffText.color, FlxColor.PURPLE);
		}
		else if (diffText.color != FlxColor.GRAY)
		{
			FlxTween.globalManager.cancelTweensOf(diffText);

			FlxTween.color(diffText, 0.5, diffText.color, FlxColor.GRAY);
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if (diffStr != null)
			diffStr = diffStr.trim(); // Fuck you HTML5

		if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1)
						diffs.remove(diffs[i]);
				}
				--i;
			}

			if (diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}

		if (CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		// trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}

		Lib.application.window.title = "Wednesday's Infidelity - " + songs[curSelected].songName;
	}

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	public override function destroy()
	{
		super.destroy();

		FlxG.bitmap.clearCache();

		FlxGraphic.defaultPersist = true;

		Paths.clearStoredMemory(true);

		#if cpp
		cpp.NativeGc.run(true);
		#end
	}

	public function checkCombos()
	{
		if (combos <= 0)
			return;

		var lastPressed:FlxKey = FlxG.keys.firstJustPressed();

		for (keys in keyCombos.keys())
		{
			if (!keys.contains(lastPressed))
				continue;

			if (keysPressed[keys] == null)
				keysPressed[keys] = [];

			keysPressed[keys].push(lastPressed);

			FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);

			if (keysPressed[keys].length == keys.length)
			{
				var same:Bool = true;

				for (i in 0...keysPressed[keys].length) // check if keys are the same
				{
					if (keysPressed[keys][i] != keys[i])
					{
						same = false;
						break;
					}
				}

				if (same)
				{
					if (keyCombos[keys] != null)
						keyCombos[keys]();
				}

				keysPressed[keys] = [];
				// Clears keys Pressed
			}
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if (this.folder == null)
			this.folder = '';
	}
}
