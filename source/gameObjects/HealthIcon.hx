package gameObjects;

import data.ClientPrefs;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon()
	{
		if (isOldIcon = !isOldIcon)
			changeIcon('bf-old');
		else
			changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(char:String)
	{
		if (this.char != char)
		{
			switch (char)
			{
				default:
					var name:String = 'icons/' + char;
					if (!Paths.fileExists('images/' + name + '.png', IMAGE))
						name = 'icons/icon-' + char; // Older versions of psych engine's support
					if (!Paths.fileExists('images/' + name + '.png', IMAGE))
						name = 'icons/icon-face'; // Prevents crash from missing icon
					var file:Dynamic = Paths.image(name);

					loadGraphic(file); // Load stupidly first for getting the file size
					loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); // Then load it fr
					iconOffsets[0] = (width - 150) / 2;
					iconOffsets[1] = (width - 150) / 2; // NOTE FOR MY DUMBASS + IS HIGHER -lunar
					switch (char)
					{
						case "gf":
							iconOffsets[1] -= 10;
						case "badend bf" | "hellholebf":
							iconOffsets[0] += 8;
							iconOffsets[1] -= 10;
						case "satan":
							iconOffsets[1] += 20;
						case "crazy-mokey" | "mokey":
							iconOffsets[1] += 10;
						case "Oswald":
							iconOffsets[1] += 12.5;
						case "rabiesOswald":
							iconOffsets[1] += 15;
					}
					updateHitbox();

					animation.add("losing", [1], 0, false, isPlayer);
					animation.add("idle", [0], 0, false, isPlayer);
					animation.play("idle");
					this.char = char;

					antialiasing = ClientPrefs.globalAntialiasing;
					if (char.endsWith('-pixel'))
					{
						antialiasing = false;
					}
				case 'oswald-suicide':
					frames = Paths.getJSONAtlas('icons/$char');

					animation.addByPrefix("losing", "angryish", 24, true, isPlayer);
					animation.addByPrefix("idle", "idle", 24, true, isPlayer);
					animation.play("losing");
					this.char = char;

					updateHitbox();

					antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();

		switch (char)
		{
			case 'oswald-suicide':
				switch (animation.name)
				{
					case "losing":
						offset.x = -5;
						offset.y = 10;
				}
			default:
				offset.x = iconOffsets[0];
				offset.y = iconOffsets[1];
		}
	}

	public function getCharacter():String
	{
		return char;
	}
}
