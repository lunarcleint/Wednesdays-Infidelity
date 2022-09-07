package states.menus;

import data.ClientPrefs;
import data.Highscore;
import data.Progression;
import data.Song;
import data.WeekData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flxanimate.frames.FlxAnimateFrames.PropertyList;
import gameObjects.MenuCharacter;
import gameObjects.MenuItem;
import lime.net.curl.CURLCode;
import openfl.Lib;
import states.game.CutsceneState;
import states.game.PlayState;
import states.menus.FreeplayState;
import util.CoolUtil;

using StringTools;

#if desktop
import util.Discord.DiscordClient;
#end

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';

	var curDifficulty:Int = 1;

	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var loadedWeeks:Array<WeekData> = [];

	var lockedIcon:FlxSprite;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	final weekDescs:Map<String, String> = [
		"Week Suicide" => "Description",
		"Week Cheddar" => "Description_Cheddar",
		"Week Julian" => "Description_Julian"
	];

	final weekTitles:Map<String, String> = [
		"Week Suicide" => "Save the depressed mouse",
		"Week Cheddar" => "Father_i_crave_cheddar",
		"Week Julian" => "Brick_of_friendship"
	];

	var description:FlxSprite;
	var weekTitle:FlxSprite;

	override function create()
	{
		Lib.application.window.title = "Wednesday's Infidelity - Story Menu";

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('storymenu/StoryBG', 'preload'));
		bg.screenCenter();
		add(bg);

		scoreText = new FlxText(0, 0, 0, "SCORE: 49324858", 36);
		scoreText.setFormat(Paths.font("waltographUI.ttf"), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
		scoreText.x = FlxG.width - 300;
		scoreText.y = FlxG.height - 200;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("waltographUI.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		bgSprite = new FlxSprite(0, -56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var num:Int = 0;

		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if (!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if (lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		add(bgSprite);
		add(grpWeekCharacters);
		// add(rankText);
		add(scoreText);

		lockedIcon = new FlxSprite(0, 0).loadGraphic(Paths.image('storymenu/Locked', 'preload'));
		lockedIcon.screenCenter();
		lockedIcon.antialiasing = ClientPrefs.globalAntialiasing;
		lockedIcon.alpha = 0.00001;
		lockedIcon.y -= 70;
		add(lockedIcon);

		leftArrow = new FlxSprite(FlxG.width * 0.05).loadGraphic(Paths.image('storymenu/Arrow', 'preload'));
		leftArrow.screenCenter(Y);
		leftArrow.alpha = 0.5;
		leftArrow.y -= 70;
		add(leftArrow);

		rightArrow = new FlxSprite(FlxG.width * 0.87).loadGraphic(Paths.image('storymenu/Arrow', 'preload'));
		rightArrow.screenCenter(Y);
		rightArrow.alpha = 0.5;
		rightArrow.angle = 180;
		rightArrow.y -= 70;
		add(leftArrow);
		add(rightArrow);

		description = new FlxSprite();
		add(description);

		weekTitle = new FlxSprite();
		add(weekTitle);

		// Cache Images

		for (map in [weekTitles, weekDescs])
		{
			for (week => image in map)
			{
				Paths.image('storymenu/$image', 'preload');
			}
		}

		changeWeek();

		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if (Math.abs(intendedScore - lerpScore) < 10)
			lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;
		scoreText.updateHitbox();
		scoreText.x = FlxG.width - scoreText.width - 10;
		scoreText.y = FlxG.height - scoreText.height - 10;

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var leftP = controls.UI_LEFT_P;
			var rightP = controls.UI_RIGHT_P;

			if (controls.UI_LEFT)
			{
				leftArrow.alpha = 1;
			}
			if (controls.UI_LEFT_R)
			{
				leftArrow.alpha = 0.5;
			}

			if (controls.UI_RIGHT)
			{
				rightArrow.alpha = 1;
			}
			if (controls.UI_RIGHT_R)
			{
				rightArrow.alpha = 0.5;
			}

			if (leftP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('storySelect'));
			}

			if (rightP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('storySelect'));
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			Lib.application.window.title = "Wednesday's Infidelity";
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			selectedWeek = true;
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length)
			{
				songArray.push(leWeek[i][0]);
			}

			if (Progression.weekProgress.exists(WeekData.weeksList[curWeek]))
			{
				openSubState(new states.substates.StoryProgress(function()
				{
					PlayState.weekMisses = 0;
					playGame(songArray);
				}, function()
				{
					var resumeInfo = Progression.weekProgress.get(WeekData.weeksList[curWeek]);

					if (!songArray.contains(resumeInfo.song))
						songArray[songArray.length] = resumeInfo.song;

					songArray = songArray.slice(songArray.indexOf(resumeInfo.song));
					PlayState.weekMisses = resumeInfo.weekMisees;

					playGame(songArray);
				}, function()
				{
					selectedWeek = false;
				}));
			}
			else
			{
				PlayState.weekMisses = 0;
				playGame(songArray);
			}
		}
		else
		{
			if (ClientPrefs.shake)
				FlxG.camera.shake(0.008, 0.08);
			FlxG.sound.play(Paths.sound('lockedSound'));
		}
	}

	var tweenDifficulty:FlxTween;

	function playGame(songs:Array<String>)
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		FlxTween.tween(FlxG.camera, {zoom: 2.1}, 2, {ease: FlxEase.expoInOut});
		if (ClientPrefs.shake)
			FlxG.camera.shake(0.008, 0.08);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			PlayState.storyPlaylist = songs;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if (diffic == null)
				diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;

			LoadingState.loadAndSwitchState(new CutsceneState(PlayState.storyPlaylist[0].toLowerCase(), false, function()
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			}), true);

			Lib.application.window.title = "Wednesday's Infidelity";
			FreeplayState.destroyFreeplayVocals();
		});
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var menuTween:FlxTween;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);
		var unlocked:Bool = !weekIsLocked(leWeek.fileName);

		var leName:String = leWeek.storyName;

		var bullShit:Int = 0;

		var originalY:Float = 0;

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if (assetName == null || assetName.length < 1 || !unlocked)
		{
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
			CoolUtil.exactSetGraphicSize(bgSprite, bgSprite.width * 0.7, bgSprite.height * 0.7);
			bgSprite.screenCenter();
			bgSprite.y -= 70;
			bgSprite.alpha = 0.5;
			originalY = bgSprite.y;
			bgSprite.y = bgSprite.y + 50;
			if (lockedIcon != null)
				lockedIcon.alpha = 1;
		}
		else
		{
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
			CoolUtil.exactSetGraphicSize(bgSprite, bgSprite.width * 0.7, bgSprite.height * 0.7);
			bgSprite.screenCenter();
			bgSprite.alpha = 0;
			bgSprite.y -= 70;
			originalY = bgSprite.y;
			bgSprite.y = bgSprite.y + 50;
			if (lockedIcon != null)
				lockedIcon.alpha = 0;
		}

		if (weekDescs.exists(leWeek.fileName))
		{
			description.loadGraphic(Paths.image('storymenu/${weekDescs[leWeek.fileName]}', 'preload'));
			description.screenCenter();
			description.y -= 10;
			description.x += 55;
			description.visible = true;
		}
		else
			description.visible = false;

		if (weekTitles.exists(leWeek.fileName))
		{
			weekTitle.loadGraphic(Paths.image('storymenu/${weekTitles[leWeek.fileName]}', 'preload'));
			weekTitle.screenCenter();
			weekTitle.y -= 300;
			weekTitle.visible = true;
		}
		else
			weekTitle.visible = false;

		PlayState.storyWeek = curWeek;

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
		updateText();
		if (menuTween != null)
		{
			menuTween.cancel();
		}
		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		if (unlocked)
		{
			menuTween = FlxTween.tween(bgSprite, {alpha: 1, y: originalY}, 0.15, {ease: FlxEase.circOut});
		}
		else
		{
			menuTween = FlxTween.tween(bgSprite, {alpha: 0.5, y: originalY}, 0.15, {ease: FlxEase.circOut});
		}

		Lib.application.window.title = "Wednesday's Infidelity - Story Menu - " + leWeek.weekName;
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		if (leWeek.fileName != 'Week Suicide' && !Progression.beatMainWeek)
		{
			return (true
				&& leWeek.weekBefore.length > 0
				&& (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
		}
		else
		{
			return (!leWeek.startUnlocked
				&& leWeek.weekBefore.length > 0
				&& (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
		}
	}

	function updateText()
	{
		var leWeek:WeekData = loadedWeeks[curWeek];
		var unlocked:Bool = !weekIsLocked(leWeek.fileName);

		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length)
		{
			stringThing.push(leWeek.songs[i][0]);
		}

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
