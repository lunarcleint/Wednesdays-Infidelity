package states.options;

#if desktop
import util.Discord.DiscordClient;
#end
import flash.text.TextField;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import gameObjects.*;
import haxe.Json;
import input.Controls;
import lime.utils.Assets;

using StringTools;

class AccessibilitySubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Accessibility Settings';
		rpcTitle = 'Accessibility Settings Menu'; // for Discord Rich Presence

		var option:Option = new Option('Flashing Lights', "Uncheck this if you're sensitive to flashing lights!", 'flashing', 'bool', true);
		addOption(option);

		var option:Option = new Option('Screen Shake', "Uncheck this if you're sensitive to Screen Shaking!", 'shake', 'bool', true);
		addOption(option);

		var option:Option = new Option('Show Warning', "Show the warning menu", 'doNotShowWarnings', 'bool', false);
		option.opposite = true;
		addOption(option);

		super();
	}
}
