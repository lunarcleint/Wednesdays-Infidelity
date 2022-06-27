package states.game;

import cpp.Random;
import data.*;
import data.ClientPrefs;
import data.Highscore;
import data.Section.SwagSection;
import data.Song.SwagSong;
import data.StageData;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flxanimate.*;
import flxanimate.FlxAnimate;
import gameObjects.*;
import gameObjects.AttachedSprite;
import gameObjects.BGSprite;
import gameObjects.Boyfriend;
import gameObjects.Character;
import gameObjects.HealthIcon;
import gameObjects.Note.EventNote;
import gameObjects.Note;
import gameObjects.NoteSplash;
import gameObjects.StrumNote;
import haxe.Json;
import lime.tools.Asset;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.Shader;
import openfl.display.StageQuality;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import song.Conductor;
import song.Script;
import states.*;
import states.editors.CharacterEditorState;
import states.editors.ChartingState;
import states.menus.*;
import states.substates.GameOverSubstate;
import states.substates.PauseSubState;
import util.*;
import util.CoolUtil;
import util.Shaders;

using StringTools;

#if desktop
import util.Discord.DiscordClient;
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end

typedef StageCamera =
{
	@:optional var bfZoom:Float;
	@:optional var dadZoom:Float;
	@:optional var dadPos:Array<Float>;
	@:optional var bfPos:Array<Float>;
	@:optional var gfZoom:Float;
	@:optional var gfPos:Array<Float>;
}

class PlayState extends MusicBeatState
{
	private var STRUM_X = 42;
	private var STRUM_X_MIDDLESCROLL = -278;

	private var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], // From 0% to 19%
		['Shit', 0.4], // From 20% to 39%
		['Bad', 0.5], // From 40% to 49%
		['Bruh', 0.6], // From 50% to 59%
		['Meh', 0.69], // From 60% to 68%
		['Nice', 0.7], // 69%
		['Good', 0.8], // From 70% to 79%
		['Great', 0.9], // From 80% to 89%
		['Sick!', 1], // From 90% to 99%
		['Perfect!!', 1] // The value on this one isn't used actually, since Perfect is always "1"
	];

	// event variables
	public var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var noteKillOffset:Float = 350;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	var curDifficulty:Int = 0;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	// Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = true; // why is it false if tutorial isnt a thing anymore

	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;

	public var healthBar:FlxBar;

	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;

	public var timeBar:FlxBar;

	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;

	public var endingSong:Bool = false;
	public var startingSong:Bool = false;

	private var updateTime:Bool = true;

	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	// Gameplay settings
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var heyTimer:Float;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;

	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var camZoomingDecay:Float = 1;

	public static var instance:PlayState;

	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	// WENSDAY INF
	var devil:FlxAnimate;
	var jumps:FlxSprite;
	var grain:FlxSprite;

	var cutsceneText:FlxText;

	var chedderguybg:BGSprite;

	var stageWhite:FlxSprite;

	// GF Amongus / Sus
	var gfSus:BGSprite;

	// Inferno / Satán
	var satanAparicion:FlxSprite;
	var satanJijijija:FlxSprite;

	var basedSkeletons:FlxSprite;

	var infernogroundparts:Map<String, FlxSprite> = ["p1" => null, "p2" => null];

	// Black / Kriman't
	var blackFuck:FlxSprite;

	// Week Misses / Endings
	public static var weekMisses:Int = 0;

	public var weekMissesTxt:FlxText;

	var weekMissesBar:FlxSprite;

	// DODGE
	private var dodgeKeys:Array<FlxKey> = [];

	var spaceBar:FlxSprite;

	var dodgeTimers = new FlxTimerManager();

	final dodgingInfo:Map<String, Float> = [
		"time" => 0.9, // time given to dodge
		"cooldown" => 0.2, // cool down
		"lasting" => 0.4, // how much time hitting space lasts
	];

	var _onCoolDown:Bool = false;
	var dodging:Bool = false;
	var doingDodge:Bool = false;
	var canDodge:Bool = true;

	// EFFECTS
	var noteXYTweens:Array<FlxTween> = [];

	var noteAngleTweens:Array<FlxTween> = [];

	var camTween:FlxTween = null;

	var cinematicBars:Map<String, FlxSprite> = ["top" => null, "bottom" => null,];

	var camBars:FlxCamera;

	// BLAMMED LIGHTS OMG!!11
	var blackBack:FlxSprite;
	var blackTween:FlxTween;

	var stageCameras:Map<String, StageCamera> = [
		"bobux" => {
			dadPos: [420.95, 513], // xx
			bfPos: [952.9, 550], // xx2
			gfPos: [952.9, 200], // xx3
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.8, // mushitsection == false
			gfZoom: 0.65 // gfsection == true
		},
		"fence" => {
			dadPos: [420.95, 513], // xx
			bfPos: [952.9, 550], // xx2
			gfPos: [952.9, 200], // xx3
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.8, // mushitsection == false
			gfZoom: 0.65 // gfsection == true
		},
		"hell" => {
			dadPos: [420.95, 283], // xx
			bfPos: [952.9, 370], // xx2
			gfPos: [952.9, 200], // xx3
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.8, // mushitsection == false
			gfZoom: 0.65 // gfsection == true
		},
		"vecindariocover" => {
			dadPos: [420.95, 513], // xx
			bfPos: [952.9, 550], // xx2
			gfPos: [952.9, 200], // xx3
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.8, // mushitsection == false
			gfZoom: 0.65 // gfsection == true
		},
		"chedder" => {
			dadPos: [410.95, 363], // xx
			bfPos: [952.9, 550], // xx2
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.7, // mushitsection == false
		},
		"inferno" => {
			dadPos: [220.95, 513], // xx
			bfPos: [952.9, 650], // xx2
			gfPos: [600, 100], // xx3
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.8, // mushitsection == false
			gfZoom: 0.5 // gfsection == true
		},
		"reefer" => {
			dadPos: [410.95, 363], // xx
			bfPos: [952.9, 550], // xx2
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.8, // mushitsection == false
		},
		"susNightmare" => {
			dadPos: [420.95, 513], // xx
			bfPos: [952.9, 550], // xx2
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.8, // mushitsection == false
		},
		"toyland" => {
			dadPos: [450.95, 520], // xx
			bfPos: [852.9, 530], // xx2
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.8, // mushitsection == false
		},
		"vecindario" => {
			dadPos: [420.95, 513], // xx
			bfPos: [952.9, 550], // xx2
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.8, // mushitsection == false
		},
		"stageMokey" => {
			dadPos: [420.95, 513], // xx
			bfPos: [952.9, 550], // xx2
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.8, // mushitsection == false
		},
		"stageLeakers" => {
			dadPos: [420.95, 513], // xx
			bfPos: [952.9, 550], // xx2
			bfZoom: 1, // mushitsection == true
			dadZoom: 0.8, // mushitsection == false
			gfZoom: 0.8 // gfsection == true
		},
	];

	var curCamera:StageCamera = {
		dadPos: null, // xx
		bfPos: null, // xx2
		gfPos: null, // xx3
		bfZoom: null, // mushitsection == true
		dadZoom: null, // mushitsection == false
		gfZoom: null // gfsection == true
	};
	var ofs:Float = 60;

	var bfsection:Bool = false; // IK MUST HIT SECTION EXIST BUT ITS DELAYED

	var singingTurnsOnCamZoom:Bool = true;

	var followChars:Bool = true;
	var cameraStageZoom:Bool = true;

	// Shaders
	public var chrom:ChromaticAberrationEffect;

	public var defaultChrome:Array<Array<Float>> = [[0, 0], [0, 0], [0, 0]]; // r/g/b

	public var vhs:VHSEffect;
	public var distort:DistortionEffect;

	public var shaderUpdates:Array<Float->Void> = [];

	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUDShaders:Array<ShaderEffect> = [];
	public var camOtherShaders:Array<ShaderEffect> = [];

	// Hscript
	public var script:Script;

	override public function create()
	{
		Paths.clearStoredMemory();

		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));

		// Mechanics

		dodgeKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('dodge'));

		PauseSubState.songName = null; // Reset to default

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		cpuControlled = ClientPrefs.botPlay;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camBars = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();

		camBars.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camBars);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		// FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			#if PRIVATE_BUILD
			detailsText = "Story Mode: " + 'CLASSIFIED'; // how did we forget this noooooo
			#else
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
			#end
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = PlayState.SONG.stage;
		if (PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1)
		{
			switch (songName)
			{
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if (stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if (boyfriendCameraOffset == null) // Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if (opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if (girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		if (stageCameras.exists(curStage))
			curCamera = stageCameras.get(curStage);

		// Week Misses
		weekMissesBar = new FlxSprite(800, ClientPrefs.downScroll ? 130 : 550).loadGraphic(Paths.image('weekMissesBar', 'shared'));
		weekMissesBar.antialiasing = ClientPrefs.globalAntialiasing;
		weekMissesBar.scale.set(0.7, 0.7);
		weekMissesBar.alpha = 0.8;
		weekMissesBar.visible = !ClientPrefs.hideHud;
		add(weekMissesBar);

		switch (curStage)
		{
			case 'stage': // Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);

				var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
				stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
				stageLight.updateHitbox();
				add(stageLight);

				var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
				stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
				stageLight.updateHitbox();
				stageLight.flipX = true;
				add(stageLight);

				var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				add(stageCurtains);

			case 'vecindario': // Week Suicide
				var sexi:BGSprite = new BGSprite('backgrounds/VecindarioBG', -600, -200);
				sexi.antialiasing = ClientPrefs.globalAntialiasing;
				sexi.updateHitbox();
				add(sexi);
			case 'vecindariocover': // Too Slow Encore Song
				var bg:BGSprite = new BGSprite('backgrounds/BG_MIKICOVER', -600, -200);
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.updateHitbox();
				add(bg);
			case 'fence': // Oswald Song
				var bg:BGSprite = new BGSprite('backgrounds/BG_OSWALD', -600, -300);
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.updateHitbox();
				add(bg);
			case 'chedder': // Week Chedder
				chedderguybg = new BGSprite('backgrounds/BG_CHEDDER', -658, -280);
				add(chedderguybg);

			case 'reefer': // Song Reefer Madness
				var stupig:FlxSprite = new FlxSprite(-650, -100).loadGraphic(Paths.image('backgrounds/Snoop-Dog-Approved-BG'), 'shared');
				add(stupig);

				blackFuck = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
				blackFuck.cameras = [camOther];
				blackFuck.alpha = 0;
				blackFuck.screenCenter(X);
				add(blackFuck);

			case 'stageMokey': // Song Kriman't
				stageWhite = new FlxSprite(-650, -100).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
				stageWhite.scale.set(5, 5);
				stageWhite.updateHitbox();
				add(stageWhite);

				blackFuck = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
				blackFuck.cameras = [camOther];
				blackFuck.alpha = 0;
				blackFuck.screenCenter(X);
				add(blackFuck);

			case 'stageLeakers': // Song Leak ma balls
				stageWhite = new FlxSprite(-650, -100).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
				stageWhite.scale.set(5, 5);
				stageWhite.updateHitbox();
				add(stageWhite);

			case 'bobux': // Week Suicide
				var nosexi:BGSprite = new BGSprite('backgrounds/Destruido', -600, -200);
				nosexi.antialiasing = ClientPrefs.globalAntialiasing;
				nosexi.updateHitbox();
				add(nosexi);

			case 'inferno': // Week Final
				var infernosky:BGSprite = new BGSprite('backgrounds/SKY', -920, -800);
				infernosky.scale.set(0.9, 0.9);
				infernosky.antialiasing = ClientPrefs.globalAntialiasing;
				infernosky.updateHitbox();
				infernosky.scrollFactor.set(0.8, 0.8);
				add(infernosky);

				satanAparicion = new FlxSprite(-280, -370);
				satanAparicion.frames = Paths.getSparrowAtlas('backgrounds/SATAN_APARITION');
				satanAparicion.animation.addByPrefix('aparicion', 'SATAN APARICION', 24, false);
				satanAparicion.antialiasing = ClientPrefs.globalAntialiasing;
				satanAparicion.alpha = 0.00001; // preloading purposes
				satanAparicion.updateHitbox();
				add(satanAparicion);

				satanAparicion.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
				{
					if (name == "aparicion" && frameNumber == 6 && infernogroundparts["p2"] != null)
					{
						remove(satanAparicion);
						insert(members.indexOf(infernogroundparts["p2"]), satanAparicion);
					}
				};

				var infernogroundp1:BGSprite = new BGSprite('backgrounds/infernogroundp1', -920, -110);
				infernogroundp1.antialiasing = ClientPrefs.globalAntialiasing;
				infernogroundp1.updateHitbox();
				infernogroundp1.scrollFactor.set(1, 1);
				add(infernogroundp1);
				infernogroundparts.set("p1", infernogroundp1);

				satanJijijija = new FlxSprite(-250, -325);
				satanJijijija.frames = Paths.getSparrowAtlas('backgrounds/JUJUJUJA');
				satanJijijija.animation.addByPrefix('jijijija', 'JUJUJUJA', 24, true);
				satanJijijija.antialiasing = ClientPrefs.globalAntialiasing;
				// satanJijijija.visible = false;
				satanJijijija.alpha = 0.00001; // preloading purposes
				satanJijijija.updateHitbox();
				add(satanJijijija);

				var infernogroundp2:BGSprite = new BGSprite('backgrounds/infernogroundp2', -920, -110);
				infernogroundp2.antialiasing = ClientPrefs.globalAntialiasing;
				infernogroundp2.updateHitbox();
				infernogroundp2.scrollFactor.set(1, 1);
				add(infernogroundp2);
				infernogroundparts.set("p2", infernogroundp2);
			case 'hell': // versiculus iratus
				var sky:BGSprite = new BGSprite('backgrounds/INFERNO_SKY', -608, -482);
				sky.antialiasing = ClientPrefs.globalAntialiasing;
				sky.scrollFactor.set(0.5, 0.5);
				add(sky);

				basedSkeletons = new FlxSprite(-506, 164);
				basedSkeletons.frames = Paths.getSparrowAtlas('backgrounds/SKULLS');
				basedSkeletons.animation.addByPrefix('idle', 'SKULLS', 24, false);
				basedSkeletons.antialiasing = ClientPrefs.globalAntialiasing;
				basedSkeletons.scrollFactor.set(0.85, 0.9);
				add(basedSkeletons);

				FlxTween.tween(basedSkeletons, {y: basedSkeletons.y + 60}, 6, {ease: FlxEase.sineInOut, type: PINGPONG});
				FlxTween.tween(sky, {y: sky.y + 15}, 6, {ease: FlxEase.sineInOut, type: PINGPONG});

				var ground:BGSprite = new BGSprite('backgrounds/ROCK_BG', -608, 324);
				ground.antialiasing = ClientPrefs.globalAntialiasing;
				add(ground);
			case 'susNightmare': // Week SUS
				var nightmare:BGSprite = new BGSprite('backgrounds/BG_SUS', -600, -200);
				nightmare.antialiasing = ClientPrefs.globalAntialiasing;
				nightmare.updateHitbox();
				add(nightmare);

				gfSus = new BGSprite('backgrounds/gf-amogus', 1300, 400, ['amongus-gf']);
				gfSus.antialiasing = ClientPrefs.globalAntialiasing;
				add(gfSus);
			case 'toyland':
				var toyland:BGSprite = new BGSprite('backgrounds/BG_JULIAN', -600, 0);
				toyland.scrollFactor.set(1, 1);
				add(toyland);
		}
		switch (curStage)
		{ // did another switch for stages here just to make sure it layers properly and it looks clean!! :P
			case 'vecindario' | 'chedder' | 'reefer' | 'bobux' | 'toyland' | 'inferno' | 'susNightmare' | 'vecindariocover' | 'hell' | 'fence': // add stage name here to give it the cool static effect
				var daStatic:FlxSprite = new FlxSprite(0, 0);
				daStatic.frames = Paths.getSparrowAtlas('daSTAT', 'shared');
				daStatic.setGraphicSize(FlxG.width, FlxG.height);
				daStatic.alpha = 0.05;
				daStatic.screenCenter();
				daStatic.cameras = [camOther];
				daStatic.animation.addByPrefix('static', 'staticFLASH', 24, true);
				add(daStatic);
				daStatic.animation.play('static');
		}

		if (isPixelStage)
		{
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);

		if (curStage == 'inferno')
		{
			remove(gfGroup);
			insert(members.indexOf(infernogroundparts["p2"]), gfGroup);
		}

		add(dadGroup);
		add(boyfriendGroup);

		devil = new FlxAnimate(0, 0,
			PlayState.SONG.stage == "susNightmare" ? "shared:assets/shared/images/SATAN AMONGUS" : "shared:assets/shared/images/SATAN");
		devil.anim.addBySymbol("scape", "SATANN", 24, false);
		devil.antialiasing = true;
		devil.cameras = [camOther];
		devil.alpha = 0.0001;
		add(devil);

		blackBack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5);
		blackBack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		var position:Int = members.indexOf(gfGroup);
		if (members.indexOf(boyfriendGroup) < position)
		{
			position = members.indexOf(boyfriendGroup);
		}
		else if (members.indexOf(dadGroup) < position)
		{
			position = members.indexOf(dadGroup);
		}
		insert(position, blackBack);

		blackBack.alpha = 0.0;

		var gfVersion:String = SONG.gfVersion;
		if (gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				default:
					gfVersion = 'gf';
			}
			SONG.gfVersion = gfVersion; // Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			if (curStage == 'inferno')
				gf.alpha = 0.00001; // preloading purposes
		}
		if (curStage == 'inferno')
			satanAparicion.setPosition(gf.x - 80, gf.y - 320); // positions him jumping out

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if (gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if (dad.curCharacter.startsWith('gf'))
		{
			dad.setPosition(GF_X, GF_Y);
			if (gf != null)
				gf.visible = false;
		}

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (ClientPrefs.downScroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if (ClientPrefs.downScroll)
			timeTxt.y = FlxG.height - 44;

		if (ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFF7D808E);
		timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if (ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		startScript();

		if (noteTypeMap.get("Jump Note") && jumps == null)
		{
			jumps = new FlxSprite(0, 0);
			jumps.frames = Paths.getSparrowAtlas('SCREAMER', 'shared');
			CoolUtil.exactSetGraphicSize(jumps, FlxG.width + 4, FlxG.height);
			jumps.x += 4;
			jumps.screenCenter();
			jumps.cameras = [camOther];
			jumps.animation.addByPrefix('scape', 'SCREAMER instancia ', 24, false);
			jumps.alpha = 0.00001;
			jumps.animation.play('scape');
			jumps.screenCenter();
			add(jumps);
		}

		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		grain = new FlxSprite();
		grain.frames = Paths.getSparrowAtlas('pantalla');
		grain.animation.addByPrefix('idle', 'pantalla', 24, true);
		CoolUtil.exactSetGraphicSize(grain, FlxG.width + 6 /*idk*/, FlxG.height + 6);
		grain.screenCenter();
		grain.x += 3;
		grain.y += 3;
		grain.antialiasing = false;
		grain.cameras = [camOther];
		grain.alpha = 0.0001;
		add(grain);

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if (ClientPrefs.downScroll)
			healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		cutsceneText = new FlxText(0, 0, 400, "", 32);
		cutsceneText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		cutsceneText.visible = false;
		add(cutsceneText);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		weekMissesTxt = new FlxText(-75, weekMissesBar.y + 18, FlxG.width, "", 20);
		weekMissesTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		weekMissesTxt.scrollFactor.set();
		weekMissesTxt.borderSize = 1.25;
		weekMissesTxt.visible = weekMissesBar.visible; // smh
		add(weekMissesTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll)
		{
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		weekMissesBar.cameras = [camHUD];
		weekMissesTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		cutsceneText.cameras = [camOther];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		var daSong:String = Paths.formatToSongPath(curSong);

		if (!seenCutscene)
		{
			if (isStoryMode)
			{
				switch (daSong)
				{
					case 'wistfulness':
						fadeIn(1);

					case 'hellhole':
						fadeIn(0.6);

					default:
						startCountdown();
				}
				seenCutscene = true;
			}
			else
			{
				switch (daSong) // FREE PLAY SONGS
				{
					default:
						startCountdown();
				}
				seenCutscene = true;
			}
		}
		else
		{
			startCountdown();
		}

		RecalculateRating();

		if (ClientPrefs.shaders)
		{
			switch (daSong) // shaders
			{
				case 'last-day':
					vhs = new util.Shaders.VHSEffect();

					addShaderToCamera('camGame', vhs);
				case 'unknown-suffering':
					chrom = new util.Shaders.ChromaticAberrationEffect();

					addShaderToCamera("camHUD", chrom);
					addShaderToCamera("camGame", chrom);
				case 'wistfulness':
					distort = new util.Shaders.DistortionEffect(1, 1);

					distort.shader.working.value = [false];

					addShaderToCamera('camGame', distort);
				case 'dejection':
					distort = new util.Shaders.DistortionEffect(1, 1);

					distort.shader.working.value = [false];

					addShaderToCamera('camGame', distort);
			}
		}

		// PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if (ClientPrefs.hitsoundVolume > 0)
			CoolUtil.precacheSound('hitsound');
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');

		if (PauseSubState.songName != null)
		{
			CoolUtil.precacheMusic(PauseSubState.songName);
		}
		else if (ClientPrefs.pauseMusic != 'None')
		{
			CoolUtil.precacheMusic(Paths.formatToSongPath(ClientPrefs.pauseMusic));
		}

		#if desktop
		// Updating Discord Rich Presence.
		#if PRIVATE_BUILD
		DiscordClient.changePresence(detailsText, "CLASSIFIED" + " (" + storyDifficultyText + ")", 'face'); // make sure to remove for public build
		#else
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
		#end

		if (!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;

		super.create();

		Paths.clearUnusedMemory();
		CustomFadeTransition.nextCamera = camOther;

		if (script != null)
		{
			script.executeFunc("onCreate");
		}
	}

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic)
		{
			var ratio:Float = value / songSpeed; // funny word huh
			for (note in notes)
			{
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function reloadHealthBarColors(?dadisgf:Bool = false)
	{
		if (dadisgf)
		{
			healthBar.createFilledBar(FlxColor.fromRGB(gf.healthColorArray[0], gf.healthColorArray[1], gf.healthColorArray[2]),
				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		}
		else
		{
			healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		}

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
				}

			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
				}

			case 2:
				if (gf != null && !gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
				}
		}
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	function startAndEnd():Void
	{
		if (endingSong)
			endSong();
		else
			startCountdown();
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;

	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		if (startedCountdown)
		{
			return;
		}

		inCutscene = false;

		if (skipCountdown || startOnTime > 0)
			skipArrowStartTween = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		if (script != null)
		{
			script.executeFunc("onStartCountdown");
		}

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		if (skipCountdown || startOnTime > 0)
		{
			clearNotesBefore(startOnTime);
			setSongTime(startOnTime - 500);
			return;
		}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (gf != null
				&& tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
				&& !gf.stunned
				&& gf.animation.curAnim.name != null
				&& !gf.animation.curAnim.name.startsWith("sing")
				&& !gf.stunned)
			{
				gf.dance();
			}
			if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0
				&& boyfriend.animation.curAnim != null
				&& !boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.stunned)
			{
				boyfriend.dance();
			}
			if (tmr.loopsLeft % dad.danceEveryNumBeats == 0
				&& dad.animation.curAnim != null
				&& !dad.animation.curAnim.name.startsWith('sing')
				&& !dad.stunned)
			{
				dad.dance();
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', 'set', 'go']);
			introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var antialias:Bool = ClientPrefs.globalAntialiasing;
			if (isPixelStage)
			{
				introAlts = introAssets.get('pixel');
				antialias = false;
			}

			// head bopping for bg characters on Mall
			switch (curStage)
			{
				case 'vecindario' | 'bobux' | 'reefer' | 'inferno' | 'toyland' | 'chedder' | 'vecindariocover' | 'hell' | 'fence': // make sure to also add the stage name here too
					grain.alpha = 1;
					grain.animation.play('idle');
				case 'susNightmare':
					if (curBeat % 1 == 0)
					{
						gfSus.dance(true);
					}
					grain.alpha = 1;
					grain.animation.play('idle');
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
				case 1:
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom + 0.15}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
					countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					countdownReady.scrollFactor.set();
					countdownReady.updateHitbox();

					if (PlayState.isPixelStage)
						countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

					countdownReady.screenCenter();
					countdownReady.antialiasing = true;
					add(countdownReady);
					FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownReady);
							countdownReady.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
				case 2:
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom + 0.25}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
					countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					countdownSet.scrollFactor.set();

					if (PlayState.isPixelStage)
						countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

					countdownSet.screenCenter();
					countdownSet.antialiasing = true;
					add(countdownSet);
					FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownSet);
							countdownSet.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
				case 3:
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom + 0.35}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
					countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					countdownGo.scrollFactor.set();

					if (PlayState.isPixelStage)
						countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

					countdownGo.updateHitbox();

					countdownGo.screenCenter();
					countdownGo.antialiasing = true;
					add(countdownGo);
					FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownGo);
							countdownGo.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);

				case 4:
			}

			notes.forEachAlive(function(note:Note)
			{
				note.copyAlpha = false;
				note.alpha = note.multAlpha;
				if (ClientPrefs.middleScroll && !note.mustPress)
				{
					note.alpha *= 0.5;
				}
			});

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = unspawnNotes[i];
			if (daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = notes.members[i];
			if (daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if (time < 0)
			time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		vocals.time = time;
		vocals.play();
		Conductor.songPosition = time;
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function changeDadIcon(gf:Bool = false) // mostly used just so i can update satans icon in
	{
		if (gf)
		{
			iconP2.changeIcon(this.gf.healthIcon);
			reloadHealthBarColors(true);
		}
		else
		{
			iconP2.changeIcon(dad.healthIcon);
			reloadHealthBarColors();
		}
	}

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if (startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if (paused)
		{
			// trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		if (curSong != "Kriman't")
		{
			songLength = FlxG.sound.music.length;
		}
		else
		{
			songLength = 130 * 1000;
		}

		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		if (script != null)
		{
			script.executeFunc("onSongStart");
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		#if PRIVATE_BUILD
		DiscordClient.changePresence(detailsText, "CLASSIFIED"
			+ " ("
			+ storyDifficultyText
			+ ")", 'face', true,
			songLength
			- Conductor.songPosition
			- ClientPrefs.noteOffset);
		#else
		DiscordClient.changePresence(detailsText, SONG.song
			+ " ("
			+ storyDifficultyText
			+ ")", iconP2.getCharacter(), true,
			songLength
			- Conductor.songPosition
			- ClientPrefs.noteOffset);
		#end
		#end
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		songSpeed = SONG.speed;

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		Lib.application.window.title = "Wednesday's Infidelity - " + curSong + " [" + storyDifficultyText + "]";

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(file))
		{
		#else
		if (OpenFlAssets.exists(file))
		{
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) // Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}
				var oldNote:Note;

				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);

				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1] < 4));
				swagNote.noteType = songNotes[3];
				if (!Std.isOfType(songNotes[3], String))
					swagNote.noteType = ChartingState.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts
				swagNote.scrollFactor.set();
				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				var floorSus:Int = Math.floor(susLength);

				if (floorSus > 0)
				{
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sustainNote:Note = new Note(daStrumTime
							+ (Conductor.stepCrochet * susNote)
							+ (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote,
							true);

						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1] < 4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if (ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if (daNoteData > 1) // Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}
				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if (ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if (daNoteData > 1) // Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if (!noteTypeMap.exists(swagNote.noteType))
				{
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) // Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}
		// trace(unspawnNotes.length);
		// playerCounter += 1;
		unspawnNotes.sort(sortByShit);
		if (eventNotes.length > 1)
		{ // No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote)
	{
		switch (event.event)
		{
			case 'Change Character':
				var charType:Int = 0;
				switch (event.value1.toLowerCase())
				{
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
			case 'Do Syringe':
				if (spaceBar == null)
				{
					spaceBar = new FlxSprite(0, 0);
					spaceBar.frames = Paths.getSparrowAtlas('mechanics/warning');
					spaceBar.antialiasing = ClientPrefs.globalAntialiasing;
					spaceBar.cameras = [camOther];
					spaceBar.animation.addByPrefix('alert', 'Advertencia', 24, true);
					spaceBar.scale.set(1.05, 1.05);
					spaceBar.updateHitbox();
					spaceBar.antialiasing = true;
					spaceBar.screenCenter();
					spaceBar.alpha = 0.0001;
					add(spaceBar);
				}
		}

		if (!eventPushedMap.exists(event.event))
		{
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float
	{
		switch (event.event)
		{
			case 'Kill Henchmen': // Better timing so that the kill sound matches the beat intended
				return 280; // Plays 280ms before the actual position
			case 'Do Syringe':
				return dodgingInfo["time"] * 1000;
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false;

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1 && ClientPrefs.middleScroll)
				targetAlpha = 0.35;

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				// babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if (ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if (i > 1)
					{ // Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (health > 0)
				Lib.application.window.title = "Wednesday's Infidelity - " + curSong + " [" + storyDifficultyText + "] - PAUSED";

			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
			{
				if (char != null && char.colorTween != null)
				{
					char.colorTween.active = false;
				}
			}

			for (tween in noteXYTweens)
			{
				if (tween != null)
					tween.active = false;
			}

			for (tween in noteAngleTweens)
			{
				if (tween != null)
					tween.active = false;
			}

			if (camTween != null)
				camTween.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (health > 0)
				Lib.application.window.title = "Wednesday's Infidelity - " + curSong + " [" + storyDifficultyText + "]";

			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
			{
				if (char != null && char.colorTween != null)
				{
					char.colorTween.active = true;
				}
			}

			for (tween in noteXYTweens)
			{
				if (tween != null)
					tween.active = true;
			}

			for (tween in noteAngleTweens)
			{
				if (tween != null)
					tween.active = true;
			}

			if (camTween != null)
				camTween.active = true;

			paused = false;

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				#if PRIVATE_BUILD
				DiscordClient.changePresence(detailsText, "CLASSIFIED"
					+ " ("
					+ storyDifficultyText
					+ ")", 'face', true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
				#else
				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
				#end
			}
			else
			{
				#if PRIVATE_BUILD
				DiscordClient.changePresence(detailsText, "CLASSIFIED" + " (" + storyDifficultyText + ")", 'face');
				#else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				#if PRIVATE_BUILD
				DiscordClient.changePresence(detailsText, "CLASSIFIED"
					+ " ("
					+ storyDifficultyText
					+ ")", 'face', true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
				#else
				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
				#end
			}
			else
			{
				#if PRIVATE_BUILD
				DiscordClient.changePresence(detailsText, "CLASSIFIED" + " (" + storyDifficultyText + ")", 'face');
				#else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			// DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null)
			return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		if (generatedMusic && (isCameraOnForcedPos && followChars))
		{
			if (bfsection
				&& (boyfriend.animation.curAnim.name == null
					|| (StringTools.contains(boyfriend.animation.curAnim.name, "idle")
						|| StringTools.contains(boyfriend.animation.curAnim.name, "miss"))))
			{
				isCameraOnForcedPos = false;
				moveCameraSection(Std.int(curStep / 16));
			}

			if (!bfsection
				&& ((dad.animation.curAnim.name == null || StringTools.contains(dad.animation.curAnim.name, "idle"))
					&& !SONG.notes[Math.floor(curStep / 16)].gfSection))
			{
				isCameraOnForcedPos = false;
				moveCameraSection(Std.int(curStep / 16));
			}

			if (!bfsection
				&& ((dad.animation.curAnim.name == null || StringTools.contains(dad.animation.curAnim.name, "idle"))
					&& !SONG.notes[Math.floor(curStep / 16)].gfSection))
			{
				isCameraOnForcedPos = false;
				moveCameraSection(Std.int(curStep / 16));
			}
		}

		if (chrom != null)
		{
			var objToLerp:Array<Dynamic> = [chrom.shader.rOffset.value, chrom.shader.bOffset.value, chrom.shader.gOffset.value];
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4, 0, 1);
			for (duh in 0...objToLerp.length)
			{
				objToLerp[duh][0] = FlxMath.lerp(objToLerp[duh][0], defaultChrome[duh][0], lerpVal);
				objToLerp[duh][1] = FlxMath.lerp(objToLerp[duh][0], defaultChrome[duh][1], lerpVal);
			}
		}

		if (doingDodge && canDodge && FlxG.keys.anyJustPressed(dodgeKeys) && !_onCoolDown && !cpuControlled && !dodging && !paused)
		{
			_onCoolDown = true;
			dodging = true;
			new FlxTimer(dodgeTimers).start(dodgingInfo["lasting"], function(timer:FlxTimer)
			{
				dodging = false;
				boyfriend.dance();
				new FlxTimer(dodgeTimers).start(dodgingInfo["cooldown"], function(timer:FlxTimer)
				{
					_onCoolDown = false;
				});
			});
		}

		if (isStoryMode
			&& WeekData.getWeekFileName() == 'Week Suicide'
			&& !ClientPrefs.hideHud
			&& Paths.formatToSongPath(SONG.song) != 'hellhole')
		{
			weekMissesBar.visible = true;
			weekMissesTxt.visible = true;
		}
		else
		{
			weekMissesBar.visible = false;
			weekMissesTxt.visible = false;
		}

		if (boyfriend.animation.curAnim.name == "dodge" && !dodging)
		{ // forces anim
			boyfriend.dance();
		}
		else if (boyfriend.animation.curAnim.name != "dodge" && dodging)
		{
			boyfriend.playAnim("dodge", true);
			boyfriend.specialAnim = true;
		}

		if (!paused)
		{
			if (dodgeTimers != null)
				dodgeTimers.update(elapsed);
		}

		switch (boyfriend.curCharacter)
		{
			case "bf-sus":
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
				GameOverSubstate.loopSoundName = 'gameOver';
				GameOverSubstate.endSoundName = 'gameOverEnd';
				GameOverSubstate.characterName = 'bf-sus';
			case "bf-suicide":
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
				GameOverSubstate.loopSoundName = 'gameOver';
				GameOverSubstate.endSoundName = 'gameOverEnd';
				GameOverSubstate.characterName = 'bf-suicide';
			case "bf-retro":
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
				GameOverSubstate.loopSoundName = 'gameOver';
				GameOverSubstate.endSoundName = 'gameOverEnd';
				GameOverSubstate.characterName = 'bf-suicide';
			case "bf-satan":
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
				GameOverSubstate.loopSoundName = 'gameOver';
				GameOverSubstate.endSoundName = 'gameOverEnd';
				GameOverSubstate.characterName = 'bf-satan';
			case "bf-portal":
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
				GameOverSubstate.loopSoundName = 'gameOver';
				GameOverSubstate.endSoundName = 'gameOverEnd';
				GameOverSubstate.characterName = 'bf-portal';
			case "bf":
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
				GameOverSubstate.loopSoundName = 'gameOver';
				GameOverSubstate.endSoundName = 'gameOverEnd';
				GameOverSubstate.characterName = 'bf';
			default:
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
				GameOverSubstate.loopSoundName = 'gameOver';
				GameOverSubstate.endSoundName = 'gameOverEnd';
				GameOverSubstate.characterName = 'bf';
		}

		if (!inCutscene)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		super.update(elapsed);

		if (ratingName == '?')
		{
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName;
		}
		else
		{
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%' + ' | '
				+ ratingName + ' [' + ratingFC + ']'; // peeps wanted no integer rating
		}

		if (isStoryMode && WeekData.getWeekFileName() == 'Week Suicide' && Paths.formatToSongPath(SONG.song) != 'hellhole')
		{
			weekMissesTxt.text = 'Week Misses: ' + (weekMisses + songMisses);
		}

		if (botplayTxt.visible)
		{
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		#if PRIVATE_BUILD
		if (FlxG.keys.justPressed.THREE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			/*if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				cancelMusicFadeTween();
				MusicBeatState.switchState(new GitarooPause());
			}
			else { */
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			// }

			#if desktop
			#if PRIVATE_BUILD
			DiscordClient.changePresence(detailsPausedText, "CLASSIFIED" + " (" + storyDifficultyText + ")", 'face'); // make sure to remove for public build
			#else
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			#end
			#end
		}
		#end

		if (FlxG.keys.justPressed.ENTER && canPause && startedCountdown && !inCutscene)
		{
			diablo();
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
			Lib.application.window.title = "Wednesday's Infidelity";
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			+ (150 * iconP1.scale.x - 150) / 2
			- iconOffset;
		iconP2.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (150 * iconP2.scale.x) / 2
			- iconOffset * 2;

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene)
		{
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
			Lib.application.window.title = "Wednesday's Infidelity";
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if (updateTime)
				{
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if (curTime < 0)
						curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if (ClientPrefs.timeBarType == 'Time Elapsed')
						songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if (secondsTotal < 0)
						secondsTotal = 0;

					if (ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000; // shit be werid on 4:3
			if (songSpeed < 1)
				time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene)
			{
				if (!cpuControlled)
				{
					keyShit();
				}
				else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
					&& boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.dance();
					// boyfriend.animation.curAnim.finish();
				}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if (!daNote.mustPress)
					strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) // Downscroll
				{
					// daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}
				else // Upscroll
				{
					// daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if (daNote.copyAlpha)
					daNote.alpha = strumAlpha;

				if (daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if (daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					// Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if (strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end'))
						{
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							if (PlayState.isPixelStage)
							{
								daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
							}
							else
							{
								daNote.y -= 19;
							}
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if (daNote.mustPress && cpuControlled)
				{
					if (daNote.isSustainNote)
					{
						if (daNote.canBeHit)
						{
							goodNoteHit(daNote);
						}
					}
					else if (daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress))
					{
						goodNoteHit(daNote);
					}
				}

				var center:Float = strumY + Note.swagWidth / 2;
				if (strumGroup.members[daNote.noteData].sustainReduce
					&& daNote.isSustainNote
					&& (daNote.mustPress || !daNote.ignoreNote)
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
					{
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		#if debug
		if (!endingSong && !startingSong)
		{
			if (FlxG.keys.justPressed.ONE)
			{
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if (FlxG.keys.justPressed.TWO)
			{ // Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		for (i in shaderUpdates)
		{
			i(elapsed);
		}

		if (script != null)
		{
			script.executeFunc("onUpdate");
		}
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public function addShaderToCamera(cam:String, effect:ShaderEffect)
	{ // STOLE FROM ANDROMEDA

		if (!ClientPrefs.shaders)
			return;

		switch (cam.toLowerCase())
		{
			case 'camhud' | 'hud':
				camHUDShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = []; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for (i in camHUDShaders)
				{
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
				camOtherShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = []; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for (i in camOtherShaders)
				{
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camOther.setFilters(newCamEffects);
			case 'camgame' | 'game':
				camGameShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = []; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for (i in camGameShaders)
				{
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camGame.setFilters(newCamEffects);
			default:
				var OBJ = Reflect.getProperty(PlayState.instance, cam);
				Reflect.setProperty(OBJ, "shader", effect.shader);
		}
	}

	public var isDead:Bool = false;

	function doDeathCheck(?skipHealthCheck:Bool = false)
	{
		if (((skipHealthCheck && false) || health <= 0) && !practiceMode && !isDead)
		{
			boyfriend.stunned = true;
			deathCounter++;

			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			persistentUpdate = false;
			persistentDraw = false;

			clearShaders();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0],
				boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

			// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			#if PRIVATE_BUILD
			DiscordClient.changePresence("Game Over - " + detailsText, "CLASSIFIED" + " (" + storyDifficultyText + ")", 'face');
			#else
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			#end
			#end
			isDead = true;
			return true;
		}
		return false;
	}

	public function checkEventNote()
	{
		while (eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0].strumTime;
			if (Conductor.songPosition < leStrumTime)
			{
				break;
			}

			var value1:String = '';
			if (eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if (eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String)
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		// trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String)
	{
		switch (eventName)
		{
			case 'Hey!':
				var value:Int = 2;
				switch (value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if (Math.isNaN(time) || time <= 0)
					time = 0.6;

				if (value != 0)
				{
					if (dad.curCharacter.startsWith('gf'))
					{ // Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					}
					else if (gf != null)
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if (value != 1)
				{
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value) || value < 1)
					value = 1;
				gfSpeed = value;

			case 'Blammed Lights':
				if (!ClientPrefs.flashing)
					return;

				var lightId:Int = Std.parseInt(value1);
				if (Math.isNaN(lightId))
					lightId = 0;

				var chars:Array<Character> = [];
				if (lightId > 0 && curLightEvent != lightId)
				{
					if (lightId > 5)
						lightId = FlxG.random.int(1, 5, [curLightEvent]);

					var color:Int = 0xffffffff;
					switch (lightId)
					{
						case 1: // Blue
							color = 0xff31a2fd;
						case 2: // Green
							color = 0xff31fd8c;
						case 3: // Pink
							color = 0xfff794f7;
						case 4: // Red
							color = 0xfff96d63;
						case 5: // Orange
							color = 0xfffba633;
					}
					curLightEvent = lightId;

					if (blackBack.alpha == 0)
					{
						if (blackTween != null)
						{
							blackTween.cancel();
						}
						blackTween = FlxTween.tween(blackBack, {alpha: 1}, 1, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								blackTween = null;
							}
						});

						for (char in chars)
						{
							if (char.colorTween != null)
							{
								char.colorTween.cancel();
							}
							char.colorTween = FlxTween.color(char, 1, FlxColor.WHITE, color, {
								onComplete: function(twn:FlxTween)
								{
									char.colorTween = null;
								},
								ease: FlxEase.quadInOut
							});
						}
					}
					else
					{
						if (blackTween != null)
						{
							blackTween.cancel();
						}
						blackTween = null;
						blackBack.alpha = 1;

						for (char in chars)
						{
							if (char.colorTween != null)
							{
								char.colorTween.cancel();
							}
							char.colorTween = null;
						}
					}
				}
				else
				{
					if (blackBack.alpha != 0)
					{
						if (blackTween != null)
						{
							blackTween.cancel();
						}
						blackTween = FlxTween.tween(blackBack, {alpha: 0}, 1, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								blackTween = null;
							}
						});
					}

					for (char in chars)
					{
						if (char.colorTween != null)
						{
							char.colorTween.cancel();
						}
						char.colorTween = FlxTween.color(char, 1, char.color, FlxColor.WHITE, {
							onComplete: function(twn:FlxTween)
							{
								char.colorTween = null;
							},
							ease: FlxEase.quadInOut
						});
					}

					curLight = 0;
					curLightEvent = 0;
				}

			case 'Add Camera Zoom':
				if (ClientPrefs.camZooms && FlxG.camera.zoom < 1.35)
				{
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				// trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch (value2.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if (Math.isNaN(val2))
							val2 = 0;

						switch (val2)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 0;
				if (Math.isNaN(val2))
					val2 = 0;

				isCameraOnForcedPos = false;
				if (!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2)))
				{
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch (value1.toLowerCase())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if (Math.isNaN(val))
							val = 0;

						switch (val)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				if (!ClientPrefs.shake)
					return;

				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if (split[0] != null)
						duration = Std.parseFloat(split[0].trim());
					if (split[1] != null)
						intensity = Std.parseFloat(split[1].trim());
					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;

					if (duration > 0 && intensity != 0)
					{
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = 0;
				switch (value1)
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				switch (charType)
				{
					case 0:
						if (boyfriend.curCharacter != value2)
						{
							if (!boyfriendMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}

					case 1:
						if (dad.curCharacter != value2)
						{
							if (!dadMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if (!dad.curCharacter.startsWith('gf'))
							{
								if (wasGf && gf != null)
								{
									gf.visible = true;
								}
							}
							else if (gf != null)
							{
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}

					case 2:
						if (gf != null)
						{
							if (gf.curCharacter != value2)
							{
								if (!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 1;
				if (Math.isNaN(val2))
					val2 = 0;

				var newValue:Float = SONG.speed * val1;

				if (val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
			case 'Flash White':
				if (!ClientPrefs.flashing)
					return;
				camOther.flash(FlxColor.fromString('0xFFFFFFFF'), 1, null, true);

			case 'Flash Black':
				if (!ClientPrefs.flashing)
					return;
				camOther.flash(FlxColor.fromString('0xFF000000'), 1, null, true);

			case 'camHud & camera Off':
				camHUD.visible = false;
				camGame.visible = false;

			case 'Fade Cameras':
				var val1:Float = Std.parseFloat(value1); // alpha
				var val2:Float = Std.parseFloat(value2); // duration
				if (val2 == 0)
				{
					camHUD.alpha = val1;
					camGame.alpha = val1;
					camOther.alpha = val1;
				}
				else
				{
					FlxTween.tween(camHUD, {alpha: val1}, val2);
					FlxTween.tween(camGame, {alpha: val1}, val2);
					FlxTween.tween(camOther, {alpha: val1}, val2);
				}

			case 'camHud & camera On':
				camHUD.visible = true;
				camGame.visible = true;

			case 'Do Syringe':
				startDodge();

			case 'camGame Off':
				camGame.visible = false;
		}
	}

	function moveCameraSection(?id:Int = 0):Void
	{
		if (SONG.notes[id] == null)
			return;

		if (gf != null && SONG.notes[id].gfSection)
		{
			if (curCamera != null && curCamera.gfPos != null)
			{
				camFollow.set(curCamera.gfPos[0], curCamera.gfPos[1]);
			}
			else
			{
				camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
				camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
				camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
				tweenCamIn();
			}

			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
		}
		else
		{
			moveCamera(false);
		}
	}

	var cameraTwn:FlxTween;

	public function moveCamera(isDad:Bool)
	{
		if (isDad)
		{
			if (curCamera != null && curCamera.dadPos != null)
			{
				camFollow.set(curCamera.dadPos[0], curCamera.dadPos[1]);
			}
			else
			{
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
				camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
				tweenCamIn();
			}
		}
		else
		{
			if (curCamera != null && curCamera.bfPos != null)
			{
				camFollow.set(curCamera.bfPos[0], curCamera.bfPos[1]);
			}
			else
			{
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
				camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
				camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
			}
		}
	}

	function tweenCamIn()
	{
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	// Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		if (isStoryMode)
		{
			weekMisses += songMisses;

			weekMissesBar.visible = false;
			weekMissesTxt.visible = false;

			switch (SONG.song)
			{
				case 'Unknown Suffering':
					{
						finishCallback = function()
						{
							if (weekMisses >= 30)
								sendToSong('last-day');
							else
								sendToSong('sunsets');
						};
					}
				default:
					{endSong();}
			}
		}

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if (ClientPrefs.noteOffset <= 0 || ignoreNoteOffset)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	public function endSong():Void
	{
		// Should kill you if you tried to cheat
		if (!startingSong)
		{
			notes.forEach(function(daNote:Note)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05;
				}
			});
			for (daNote in unspawnNotes)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05;
				}
			}

			if (doDeathCheck())
			{
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		if (!transitioning)
		{
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if (Math.isNaN(percent))
					percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			Lib.application.window.title = "Wednesday's Infidelity";

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;
				campaignMisses += weekMisses;

				var lastSong:String = storyPlaylist[0];

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					cancelMusicFadeTween();
					if (FlxTransitionableState.skipNextTransIn)
					{
						CustomFadeTransition.nextCamera = null;
					}
					LoadingState.loadAndSwitchState(new CutsceneState(SONG.song, true, function()
					{
						MusicBeatState.switchState(new StoryMenuState());

						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						FlxG.sound.music.loopTime = 15920;
						FlxG.sound.music.time = 15920;
					}));

					if (WeekData.getWeekFileName() == 'Week Suicide')
					{
						if (Paths.formatToSongPath(SONG.song) == 'sunsets')
							FlxG.save.data.gotgoodending = true;
						if (Paths.formatToSongPath(SONG.song) == 'last-day')
							FlxG.save.data.gotbadending = true;
						if (!FlxG.save.data.beatmainweek)
							FlxG.save.data.beatmainweek = true;
						if (Paths.formatToSongPath(SONG.song) == 'hellhole')
							FlxG.save.data.beathell = true;
						FlxG.save.flush();
					}
					// if ()
					if (!practiceMode && !cpuControlled)
					{
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					cancelMusicFadeTween();
					LoadingState.loadAndSwitchState(new CutsceneState(lastSong, true, function()
					{
						LoadingState.loadAndSwitchState(new CutsceneState(PlayState.storyPlaylist[0], false, function()
						{
							LoadingState.loadAndSwitchState(new PlayState());
						}), true);
					}), true);
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				if (FlxTransitionableState.skipNextTransIn)
				{
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.sound.music.loopTime = 15920;
				FlxG.sound.music.time = 15920;
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	public var showCombo:Bool = true;
	public var showRating:Bool = true;

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		// trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		rating.alpha = scoreTxt.alpha;
		var score:Int = 350;

		// tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(note, noteDiff);

		switch (daRating)
		{
			case "shit": // shit
				totalNotesHit += 0;
				note.ratingMod = 0;
				score = 50;
				if (!note.ratingDisabled)
					shits++;
			case "bad": // bad
				totalNotesHit += 0.5;
				note.ratingMod = 0.5;
				score = 100;
				if (!note.ratingDisabled)
					bads++;
			case "good": // good
				totalNotesHit += 0.75;
				note.ratingMod = 0.75;
				score = 200;
				if (!note.ratingDisabled)
					goods++;
			case "sick": // sick
				totalNotesHit += 1;
				note.ratingMod = 1;
				if (!note.ratingDisabled)
					sicks++;
		}
		note.rating = daRating;

		if (daRating == 'sick' && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if (!practiceMode && !cpuControlled)
		{
			songScore += score;
			if (!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating();
			}

			if (ClientPrefs.scoreZoom)
			{
				if (scoreTxtTween != null)
				{
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						scoreTxtTween = null;
					}
				});
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.alpha = scoreTxt.alpha;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		insert(members.indexOf(strumLineNotes), rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if (combo >= 1000)
		{
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;
			numScore.alpha = scoreTxt.alpha;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			// if (combo >= 10 || combo == 0)
			insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore = null;
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
		trace(combo);
		trace(seperatedScore);
	 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		// trace('Pressed: ' + eventKey);

		if (!cpuControlled && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if (!boyfriend.stunned && generatedMusic && !endingSong)
			{
				// more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				// var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if (daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							// notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0)
				{
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes)
						{
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1)
							{
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							}
							else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped)
						{
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				}
				else if (canMiss)
				{
					noteMissPress(key);
				}

				// more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if (spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
		}
		// trace('pressed: ' + controlArray);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if (!cpuControlled && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if (spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		}
		// trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [
				controls.NOTE_LEFT_P,
				controls.NOTE_DOWN_P,
				controls.NOTE_UP_P,
				controls.NOTE_RIGHT_P
			];
			if (controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if (controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong)
			{
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				// boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [
				controls.NOTE_LEFT_R,
				controls.NOTE_DOWN_R,
				controls.NOTE_UP_R,
				controls.NOTE_RIGHT_R
			];
			if (controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if (controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void
	{ // You didn't hit the key and let it go offscreen, also used by Hurt Notes
		// Dupe note remove
		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note
				&& daNote.mustPress
				&& daNote.noteData == note.noteData
				&& daNote.isSustainNote == note.isSustainNote
				&& Math.abs(daNote.strumTime - note.strumTime) < 1)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;

		health -= daNote.missHealth;

		// For testing purposes
		// trace(daNote.missHealth);
		songMisses++;

		vocals.volume = 0;
		if (!practiceMode)
			songScore -= 10;

		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if (daNote.gfNote)
		{
			char = gf;
		}

		if (char != null && char.hasMissAnimations)
		{
			if (daNote.noteType == 'Jeringe Note')
			{
				if (char.animOffsets.exists('at') && char.curCharacter.startsWith('jank'))
				{
					doEffect();
					char.playAnim('at', true);
					char.specialAnim = true;
				}
			}

			var daAlt = '';
			if (daNote.noteType == 'Alt Animation')
				daAlt = '-alt';

			if (daNote.noteType == 'Jeringe Note')
				daAlt = '-shoot';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			if (!char.specialAnim)
				char.playAnim(animToPlay, true);
		}
	}

	function noteMissPress(direction:Int = 1):Void // You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.05;

			if (ClientPrefs.ghostTapping)
				return;

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (!practiceMode)
				songScore -= 10;
			if (!endingSong)
			{
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
		});*/

			if (boyfriend.hasMissAnimations)
			{
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial' && !note.noAnimation && singingTurnsOnCamZoom)
			camZooming = true;

		if (note.noteType == 'Hey!' && dad.animOffsets.exists('hey'))
		{
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		}
		else if (note.noteType == 'Jeringe Note')
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + '-shoot';
			dad.playAnim(animToPlay);
			dad.holdTimer = 0;
		}
		else if (!note.noAnimation)
		{
			var altAnim:String = "";

			var curSection:Int = Math.floor(curStep / 16);
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation')
				{
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if (note.gfNote)
			{
				char = gf;
			}

			switch (dad.curCharacter)
			{
				case 'mutant-mouse' | 'satan-mouse' | 'tiny-mouse-mad' | 'mouse-inferno' | 'mokey-sad-suicide' | 'jank' | 'satan' | 'smileeeeer' | 'suicide' |
					'satan-chad':
					triggerEventNote("Screen Shake", "0.2,0.008", "0.2,0.008");
			}

			var notehealthdmg:Float = 0.00;

			switch (dad.curCharacter)
			{
				case 'mutant-mouse' | 'satan-mouse' | 'tiny-mouse-mad' | 'mouse-inferno' | 'mokey-sad-suicide' | 'jank' | 'satan' | 'smileeeeer' | 'suicide' |
					'mouse-phase2' | 'mouse-smile' | 'mouse-happy' | 'satan-chad':
					notehealthdmg = 0.025;

					if (health > 0.1)
						if (note.isSustainNote)
						{
							health -= notehealthdmg / 2;
						}
						else
						{
							health -= notehealthdmg;
						}
			}

			if (char != null)
			{
				if (!char.specialAnim)
				{
					char.playAnim(animToPlay, true);

					if (!bfsection && followChars)
					{
						var yy:Float = 0.0;
						var xx:Float = 0.0;

						if (curCamera != null)
						{
							if (char == gf && curCamera.gfPos != null)
							{
								xx = curCamera.gfPos[0];
								yy = curCamera.gfPos[1];
							}
							else if (curCamera.dadPos != null)
							{
								xx = curCamera.dadPos[0];
								yy = curCamera.dadPos[1];
							}
						}
						else
						{
							var camerashit:Array<Int> = [150, -100];

							if (SONG.notes[curSection].gfSection)
							{
								camerashit = [0, 0];
							}

							xx = (char.getMidpoint().x + camerashit[0]) + char.cameraPosition[0];
							yy = (char.getMidpoint().y + camerashit[1]) + char.cameraPosition[1];
						}

						var singAnimationsPostions:Array<Float> = getSingPos([xx, yy], Std.int(Math.abs(note.noteData)));

						camFollow.set(singAnimationsPostions[0], singAnimationsPostions[1]);
						isCameraOnForcedPos = true;
					}

					char.holdTimer = 0;
				}
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
		{
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function diablo()
	{
		devil.anim.play('scape', true);
		devil.alpha = 1;

		devil.anim.onComplete = function()
		{
			devil.alpha = 0.0001;
		}
	}

	function jump()
	{
		if (jumps == null)
			return;

		jumps.animation.play('scape');
		jumps.alpha = 1;
		jumps.screenCenter();

		FlxG.sound.play(Paths.sound('static'));

		jumps.animation.finishCallback = function(name:String)
		{
			jumps.alpha = 0;
		}
	}

	function startDodge()
	{
		if (doingDodge || spaceBar == null)
			return;

		FlxG.sound.play(Paths.sound('mechanics/Warning', 'shared'), 2);
		spaceBar.animation.play('alert', true);
		spaceBar.alpha = 1;

		doingDodge = true;

		new FlxTimer(dodgeTimers).start(dodgingInfo["time"] - 0.41, function(timer:FlxTimer)
		{
			if (dad.animation.exists("dodge"))
			{
				dad.playAnim("dodge");
				dad.specialAnim = true;
			}
		});

		new FlxTimer(dodgeTimers).start(dodgingInfo["time"], function(timer:FlxTimer)
		{
			if (!dodging && !cpuControlled)
			{
				boyfriend.playAnim("at");
				boyfriend.specialAnim = true;
				doEffect();

				// FlxG.sound.play(Paths.sound('mechanics/damage', 'shared'), 2);
			}
			else if (cpuControlled)
			{
				boyfriend.playAnim('dodge', true);
				boyfriend.specialAnim = true;
				boyfriend.animation.finishCallback = function(name:String)
				{
					if (name == 'dodge')
						boyfriend.dance();
				}
			}

			dodgeTimers.forEach(function(tmr:FlxTimer)
			{
				tmr.cancel();
			});
			doingDodge = false;
			_onCoolDown = false;
			dodging = false;
			spaceBar.alpha = 0.0001;
		});
	}

	function addCinematicBars(speed:Float, ?thickness:Float = 7)
	{
		if (cinematicBars["top"] == null)
		{
			cinematicBars["top"] = new FlxSprite(0, 0).makeGraphic(FlxG.width, Std.int(FlxG.height / thickness), FlxColor.BLACK);
			cinematicBars["top"].screenCenter(X);
			cinematicBars["top"].cameras = [camBars];
			cinematicBars["top"].y = 0 - cinematicBars["top"].height; // offscreen
			add(cinematicBars["top"]);
		}

		if (cinematicBars["bottom"] == null)
		{
			cinematicBars["bottom"] = new FlxSprite(0, 0).makeGraphic(FlxG.width, Std.int(FlxG.height / thickness), FlxColor.BLACK);
			cinematicBars["bottom"].screenCenter(X);
			cinematicBars["bottom"].cameras = [camBars];
			cinematicBars["bottom"].y = FlxG.height; // offscreen
			add(cinematicBars["bottom"]);
		}

		FlxTween.tween(cinematicBars["top"], {y: 0}, speed, {ease: FlxEase.circInOut});
		FlxTween.tween(cinematicBars["bottom"], {y: FlxG.height - cinematicBars["bottom"].height}, speed, {ease: FlxEase.circInOut});
	}

	function removeCinematicBars(speed:Float)
	{
		if (cinematicBars["top"] != null)
		{
			FlxTween.tween(cinematicBars["top"], {y: 0 - cinematicBars["top"].height}, speed, {ease: FlxEase.circInOut});
		}

		if (cinematicBars["bottom"] != null)
		{
			FlxTween.tween(cinematicBars["bottom"], {y: FlxG.height}, speed, {ease: FlxEase.circInOut});
		}
	}

	function doEffect()
	{
		if (chrom != null)
		{
			if (defaultChrome[1][0] < 0.0005)
			{
				defaultChrome[1][0] -= 0.0005;
				defaultChrome[2][0] += 0.0005;
			}

			chrom.shader.gOffset.value = [defaultChrome[1][0] + -0.002, 0];
			chrom.shader.bOffset.value = [defaultChrome[2][0] + 0.002, 0];
		}

		var random:Int = FlxG.random.int(0, 2);

		songSpeed += 0.1;

		switch (random)
		{
			case 0:
				for (tween in noteAngleTweens)
				{
					tween.cancel();
					noteAngleTweens.remove(tween);
				}

				strumLineNotes.forEach(function(note:StrumNote)
				{
					noteAngleTweens.push(FlxTween.tween(note, {angle: note.angle + FlxG.random.float(-40, 40)}, FlxG.random.float(15, 20)));
				});
			case 1:
				for (tween in noteXYTweens)
				{
					tween.cancel();
					noteXYTweens.remove(tween);
				}

				strumLineNotes.forEach(function(note:StrumNote)
				{
					noteXYTweens.push(FlxTween.tween(note, {x: note.x + FlxG.random.float(-30, 30), y: note.y + FlxG.random.float(-35, 35)},
						FlxG.random.float(15, 20)));
				});
			case 2:
				if (camTween != null)
				{
					camTween.cancel();
					camTween = null;
				}

				var cam:FlxCamera = FlxG.random.bool() ? camGame : camHUD;

				camTween = FlxTween.tween(cam, {angle: (FlxG.random.bool() ? FlxG.random.float(2, 7) : FlxG.random.float(-2, -7))}, FlxG.random.float(20, 25), {
					onComplete: function tween(tween:FlxTween)
					{
						camTween = FlxTween.tween(cam, {angle: FlxG.random.float(-1, 1)}, FlxG.random.float(10, 15), {
							onComplete: function tween(tween:FlxTween)
							{
								camTween = null;
							}
						});
					}
				});
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if (cpuControlled && (note.ignoreNote || note.hitCausesMiss))
				return;

			if (note.hitCausesMiss)
			{
				noteMiss(note);
				if (!note.noteSplashDisabled && !note.isSustainNote)
				{
					spawnNoteSplashOnNote(note);
				}

				switch (note.noteType)
				{
					case 'Hurt Note': // Hurt note
						if (boyfriend.animation.getByName('hurt') != null)
						{
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (note.noteType == 'Jump Note')
			{
				jump();
			}

			if (note.noteType == 'Jeringe Note')
			{
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + '-shoot';
				dad.playAnim(animToPlay);
				dad.holdTimer = 0;
				boyfriend.playAnim('dodge', true);
				boyfriend.specialAnim = true;
			}

			if (note.noteType == 'Speed Note')
			{
				doEffect();
				boyfriend.playAnim('at', true);
				boyfriend.specialAnim = true;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
				if (combo > 9999)
					combo = 9999;
			}
			health += note.hitHealth;

			if (!note.noAnimation && note.noteType != 'Jeringe Note')
			{
				var daAlt = '';
				if (note.noteType == 'Alt Animation')
					daAlt = '-alt';

				if (note.noteType == 'Jeringe Note')
					daAlt = '-shoot';

				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if (note.gfNote)
				{
					if (gf != null)
					{
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					if (!boyfriend.specialAnim)
					{
						boyfriend.playAnim(animToPlay + daAlt, true);

						if (bfsection && followChars)
						{
							var xx:Float = 0.0;
							var yy:Float = 0.0;

							if (curCamera != null && curCamera.bfPos != null)
							{
								xx = curCamera.bfPos[0];
								yy = curCamera.bfPos[1];
							}
							else
							{
								xx = (boyfriend.getMidpoint().x - 100) - boyfriend.cameraPosition[0];
								yy = (boyfriend.getMidpoint().y - 100) + boyfriend.cameraPosition[1];
							}

							var singAnimationsPostions:Array<Float> = getSingPos([xx, yy], Std.int(Math.abs(note.noteData)));

							camFollow.set(singAnimationsPostions[0], singAnimationsPostions[1]);
							isCameraOnForcedPos = true;
						}

						boyfriend.holdTimer = 0;
					}
				}

				if (note.noteType == 'Hey!')
				{
					if (boyfriend.animOffsets.exists('hey'))
					{
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if (gf != null && gf.animOffsets.exists('cheer'))
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if (cpuControlled)
			{
				var time:Float = 0.15;
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			}
			else
			{
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; // GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note)
	{
		if (ClientPrefs.noteSplashes && note != null)
		{
			var strum:StrumNote = playerStrums.members[note.noteData];
			if (strum != null)
			{
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	private final notesplashOffsets:Array<Array<Float>> = [[4, 4], [24, 8], [30, 10], [5, 8]];

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null)
	{
		var skin:String = 'noteSplashes';
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if (note != null)
		{
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x + notesplashOffsets[data][0], y + notesplashOffsets[data][1], data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	override function destroy()
	{
		if (!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		if (script != null)
		{
			script.destroy();
		}

		instance = null;

		super.destroy();
	}

	public static function cancelMusicFadeTween()
	{
		if (FlxG.sound.music.fadeTween != null)
		{
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		super.stepHit();

		if (script != null)
		{
			script.setVariable("curStep", curStep);
			script.executeFunc("onStepHit");
		}

		if (followChars && cameraStageZoom)
		{
			if (!SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				if (curCamera != null && curCamera.gfZoom != null && SONG.notes[Math.floor(curStep / 16)].gfSection)
				{
					defaultCamZoom = curCamera.gfZoom;
				}

				if (curCamera != null && curCamera.dadZoom != null && !SONG.notes[Math.floor(curStep / 16)].gfSection)
				{
					defaultCamZoom = curCamera.dadZoom;
				}
			}
			else
			{
				if (curCamera != null && curCamera.bfZoom != null)
				{
					defaultCamZoom = curCamera.bfZoom;
				}
			}
		}

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if (curSong == 'Battered')
		{
			switch (curStep)
			{
				case 1060:
					var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
					introAssets.set('default', ['ready', 'set', 'go']);
					introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

					var introAlts:Array<String> = introAssets.get('default');

					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom + 0.15}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
					countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					countdownReady.scrollFactor.set();
					countdownReady.updateHitbox();

					if (PlayState.isPixelStage)
						countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

					countdownReady.screenCenter();
					countdownReady.antialiasing = true;
					add(countdownReady);
					FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownReady);
							countdownReady.destroy();
						}
					});
				case 1064:
					var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
					introAssets.set('default', ['ready', 'set', 'go']);
					introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

					var introAlts:Array<String> = introAssets.get('default');

					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom + 0.25}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
					countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					countdownSet.scrollFactor.set();

					if (PlayState.isPixelStage)
						countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

					countdownSet.screenCenter();
					countdownSet.antialiasing = true;
					add(countdownSet);
					FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownSet);
							countdownSet.destroy();
						}
					});
				case 1068:
					var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
					introAssets.set('default', ['ready', 'set', 'go']);
					introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

					var introAlts:Array<String> = introAssets.get('default');

					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom + 0.35}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
					countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					countdownGo.scrollFactor.set();

					if (PlayState.isPixelStage)
						countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

					countdownGo.updateHitbox();

					countdownGo.screenCenter();
					countdownGo.antialiasing = true;
					add(countdownGo);
					FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownGo);
							countdownGo.destroy();
						}
					});
			}
		}

		if (curSong == 'Dejection')
		{
			switch (curStep)
			{
				case 642:
					FlxTween.tween(camHUD, {alpha: 0}, 0.5);

				case 651:
					FlxTween.tween(camHUD, {alpha: 1}, 0.5);

				case 1552:
					FlxTween.tween(camHUD, {alpha: 0}, 3.5);
					FlxTween.tween(camGame, {alpha: 0}, 3.5);
					FlxTween.tween(camOther, {alpha: 0}, 3.5);
			}
		}

		if (curSong == "Wistfulness" && ClientPrefs.shaders)
		{
			switch (curStep)
			{
				case 536:
					distort.shader.glitchModifier.value = [9];
					// distort.shader.fullglitch.value = [2];

					distort.shader.working.value = [true];

				case 544:
					distort.shader.glitchModifier.value = [1];
					distort.shader.fullglitch.value = [1];

				case 670:
					camGame.setFilters([]); // Remove shader

					camGameShaders = [];

					distort = null;
			}
		}

		if (curStep == lastStepHit)
		{
			return;
		}

		lastStepHit = curStep;
	}

	private var lastBeatHit:Int;

	override function beatHit()
	{
		super.beatHit();

		if (lastBeatHit >= curBeat)
		{
			// trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		// I SWEAR ITS OFF BY 1
		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			bfsection = SONG.notes[Math.floor(curStep / 16)].mustHitSection;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				// FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null
			&& curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
			&& !gf.stunned
			&& gf.animation.curAnim.name != null
			&& !gf.animation.curAnim.name.startsWith("sing")
			&& !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0
			&& boyfriend.animation.curAnim != null
			&& !boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0
			&& dad.animation.curAnim != null
			&& !dad.animation.curAnim.name.startsWith('sing')
			&& !dad.stunned)
		{
			dad.dance();
		}

		switch (curStage)
		{
			case 'vecindario':
				grain.animation.play('idle');

			case 'bobux' | 'reefer' | 'inferno' | 'toyland' | 'vecindariocover': // add stage names here to make the grain appear

			case 'susNightmare':
				if (gfSus != null)
					if (curBeat % 1 == 0)
					{
						gfSus.dance(true);
					}

				grain.alpha = 1;
				grain.animation.play('idle');
			case 'hell':
				grain.alpha = 1;
				grain.animation.play('idle');
				if (curBeat % 1 == 0)
					basedSkeletons.animation.play('idle', true);
		}
		lastBeatHit = curBeat;
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		var spr:StrumNote = null;
		if (isDad)
		{
			spr = strumLineNotes.members[id];
		}
		else
		{
			spr = playerStrums.members[id];
		}

		if (spr != null)
		{
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;

	public function RecalculateRating()
	{
		if (totalPlayed < 1) // Prevent divide by 0
			ratingName = '?';
		else
		{
			// Rating Percent
			ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
			// trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

			// Rating Name
			if (ratingPercent >= 1)
			{
				ratingName = ratingStuff[ratingStuff.length - 1][0]; // Uses last string
			}
			else
			{
				for (i in 0...ratingStuff.length - 1)
				{
					if (ratingPercent < ratingStuff[i][1])
					{
						ratingName = ratingStuff[i][0];
						break;
					}
				}
			}
		}

		// Rating FC
		ratingFC = "";
		if (sicks > 0)
			ratingFC = "MFC";
		if (goods > 0)
			ratingFC = "GFC";
		if (bads > 0 || shits > 0)
			ratingFC = "FC";
		if (songMisses > 0 && songMisses < 10)
			ratingFC = "SDCB";
		else if (songMisses >= 10)
			ratingFC = "Clear";
	}

	var curLight:Int = 0;
	var curLightEvent:Int = 0;

	function sendToSong(name:String)
	{
		if (name == null)
			return;

		persistentUpdate = false;

		var songLowercase:String = Paths.formatToSongPath(name);
		var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

		prevCamFollow = camFollow;
		prevCamFollowPos = camFollowPos;

		PlayState.SONG = Song.loadFromJson(poop, songLowercase);
		PlayState.isStoryMode = true;
		PlayState.storyDifficulty = curDifficulty;

		Lib.application.window.title = "Wednesday's Infidelity";

		FlxG.sound.music.stop();
		cancelMusicFadeTween();

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		LoadingState.loadAndSwitchState(new CutsceneState(PlayState.storyPlaylist[0], true, function()
		{
			LoadingState.loadAndSwitchState(new CutsceneState(songLowercase, false, function()
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				LoadingState.loadAndSwitchState(new PlayState());
			}), true);
		}), true);
	}

	public function startScript()
	{
		var formattedFolder:String = Paths.formatToSongPath(SONG.song);

		var path:String = Paths.hscript(formattedFolder + '/script');

		var hxdata:String = "";

		if (FileSystem.exists(path))
			hxdata = File.getContent(path);

		if (hxdata != "")
		{
			trace("Loading Script: " + path);

			script = new Script();

			script.setVariable("onSongStart", function()
			{
			});

			script.setVariable("onCreate", function()
			{
			});

			script.setVariable("onStartCountdown", function()
			{
			});

			script.setVariable("onStepHit", function()
			{
			});

			script.setVariable("onUpdate", function()
			{
			});

			script.setVariable("import", function(lib:String, ?as:Null<String>) // Does this even work?
			{
				if (lib != null && Type.resolveClass(lib) != null)
				{
					script.setVariable(as != null ? as : lib, Type.resolveClass(lib));
				}
			});

			script.setVariable("fromRGB", function(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255)
			{
				return FlxColor.fromRGB(Red, Green, Blue, Alpha);
			});

			script.setVariable("curStep", curStep);
			script.setVariable("bpm", SONG.bpm);

			// PRESET CLASSES
			script.setVariable("PlayState", instance);
			script.setVariable("FlxTween", FlxTween);
			script.setVariable("FlxEase", FlxEase);
			script.setVariable("FlxSprite", FlxSprite);
			script.setVariable("Math", Math);
			script.setVariable("FlxG", FlxG);
			script.setVariable("ClientPrefs", ClientPrefs);
			script.setVariable("FlxTimer", FlxTimer);
			script.setVariable("Main", Main);
			script.setVariable("Event", Event);
			script.setVariable("Conductor", Conductor);
			script.setVariable("Std", Std);
			script.setVariable("FlxTextBorderStyle", FlxTextBorderStyle);
			script.setVariable("Paths", Paths);
			script.setVariable("CENTER", FlxTextAlign.CENTER);
			script.setVariable("FlxTextFormat", FlxTextFormat);
			script.setVariable("InputFormatter", InputFormatter);
			script.setVariable("FlxTextFormatMarkerPair", FlxTextFormatMarkerPair);

			script.runScript(hxdata);
		}
	}

	function getSingPos(pos:Array<Float>, noteData:Int):Array<Float>
	{
		// [[xx - ofs, yy], [xx, yy + ofs], [xx, yy - ofs], [xx + ofs, yy]]
		switch (noteData)
		{
			case 0:
				return [pos[0] - ofs, pos[1]];
			case 1:
				return [pos[0], pos[1] + ofs];
			case 2:
				return [pos[0], pos[1] - ofs];
			case 3:
				return [pos[0] + ofs, pos[1]];
		}
		return [];
	}

	function fadeIn(speed:Float = 1)
	{
		grain.alpha = 1;
		grain.animation.play('idle');

		var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		black.cameras = [camOther];
		add(black);

		FlxTween.tween(black, {alpha: 0}, speed, {
			onComplete: function(twn:FlxTween)
			{
				remove(black);
				black.destroy();

				startAndEnd();
			}
		});
	}

	function clearShaders()
	{
		camGame.setFilters([]);

		camGameShaders = [];

		camHUD.setFilters([]);

		camHUDShaders = [];
	}
}
