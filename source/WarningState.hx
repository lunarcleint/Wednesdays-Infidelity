package;

import flixel.addons.editors.tiled.TiledTile;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import options.Option;
import CheckboxThingie;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.Lib;

class WarningState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var warnImage:FlxSprite;

	private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Option>;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedText>;
	
	override function create()
	{
		FlxG.autoPause = false;
		#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end
		
		#if CHECK_FOR_UPDATES
		if(!closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");
			
			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}
			
			http.onError = function (error) {
				trace('error: $error');
			}
			
			http.request();
		}
		#end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;

		PlayerSettings.init();

		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;

		Lib.application.window.title = "Wednesday's Infidelity - WARNING";

		warnImage = new FlxSprite(-400, 0).loadGraphic(Paths.image('mickeysangre','preload'));
		warnImage.antialiasing = ClientPrefs.globalAntialiasing;
		warnImage.updateHitbox();
		warnImage.screenCenter(X);
		warnImage.alpha = 0.5;
		add(warnImage);

		var warnTitle = new Alphabet(0, 40, "Warning!", true, false, 0, 1.25);
		warnTitle.screenCenter(X);
		add(warnTitle);

		warnText = new FlxText(0, 0, FlxG.width,
			"This mod contains Flashing Lights, Loud Effects, and Screen Shake.\n
			 Press Select Your Options \n
			(*These can be changed later*)" + "\n
			\n\n
			You have been warned.\n
			Press SPACE to continue.",
			21);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warnText.screenCenter(XY);
		warnText.y += 40;
		add(warnText);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		var option:Option = new Option(
			'Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true
		);
		addOption(option);

		var option:Option = new Option('Screen Shake',
			"Uncheck this if you're sensitive to Screen Shaking!",
			'shake',
			'bool',
			true
		);
		addOption(option);

		genOptions();
	}

	public function addOption(option:Option) {
		if(optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
	}

	function genOptions() {
		for (i in 0...optionsArray.length)
			{
				var optionText:Alphabet = new Alphabet(0, 0, optionsArray[i].name, true, false, 0, 0.6);
				optionText.isMenuItem = false;
				optionText.x += 225 + (600*i);
				/*optionText.forceX = 300;
				optionText.yMult = 90;*/
				optionText.xAdd = 200;
				//optionText.yAdd = 100;
				optionText.targetY = i;
				optionText.screenCenter(Y);
				optionText.y += 80;
				grpOptions.add(optionText);
	
				if(optionsArray[i].type == 'bool') {
					var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, optionsArray[i].getValue() == true);
					checkbox.sprTracker = optionText;
					checkbox.offsetY = -60;
					checkbox.ID = i;
					checkboxGroup.add(checkbox);
				} else {
					optionText.x -= 80;
					optionText.xAdd -= 80;
					var valueText:AttachedText = new AttachedText('' + optionsArray[i].getValue(), optionText.width + 80);
					valueText.sprTracker = optionText;
					valueText.copyAlpha = true;
					valueText.ID = i;
					grpTexts.add(valueText);
					optionsArray[i].setChild(valueText);
				}
			}
	
			changeSelection();
			reloadCheckboxes();
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
		for (text in grpTexts) {
			text.alpha = 0.6;
			if(text.ID == curSelected) {
				text.alpha = 1;
			}
		}

		curOption = optionsArray[curSelected]; 

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes() {
		for (checkbox in checkboxGroup) {
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var usesCheckbox = true;
			if(curOption.type != 'bool')
			{
				usesCheckbox = false;
			}

			if(usesCheckbox)
			{
				if(FlxG.keys.justPressed.ENTER)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					curOption.setValue((curOption.getValue() == true) ? false : true);
					curOption.change();
					reloadCheckboxes();
				}
			}

			if (FlxG.keys.justPressed.LEFT) {
				changeSelection(1);
			}

			if (FlxG.keys.justPressed.RIGHT) {
				changeSelection(-1);
			}

			if (FlxG.keys.justPressed.SPACE) {
				leftState = true;
				ClientPrefs.saveSettings();
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(warnImage, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						warnImage.visible = false;
					}
				});
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						warnImage.visible = false;
						Lib.application.window.title = "Wednesday's Infidelity";
						MusicBeatState.switchState(new TitleState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
