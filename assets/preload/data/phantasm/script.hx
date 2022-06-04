function onCreate()
{
    for (sus in PlayState.opponentStrums)
    {
        FlxTween.tween(sus,{x: sus.x -560},0.4,{ease: FlxEase.elasticOut});
    }
    for (sus in PlayState.playerStrums)
    {
        FlxTween.tween(sus,{x: sus.x -325},0.4,{ease: FlxEase.elasticOut});
    }
    PlayState.iconP2.alpha = 0;
}