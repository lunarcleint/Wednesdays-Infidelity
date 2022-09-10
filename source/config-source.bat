@echo off
cls
title W.I Requirements Auto-Downloader
echo Made by Reycko (btw this is a really good mod)
echo.
echo.
echo Installing HXP...
echo.
haxelib install hxp
echo.
echo Installing FLXAnimate...
echo.
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate
echo.
echo Setting FLXAnimate version to 1.2.0 (the version used by W.I)
echo.
haxelib set flxanimate 1.2.0
echo.
echo Installing HScript... (Haxe script library)
echo.
haxelib install hscript
echo.
echo Installing HXCodec...
echo.
haxelib install hxCodec
echo.
echo Setting HXCodec version to 2.5.1...
echo.
haxelib set hxCodec 2.5.1
echo.
echo.
echo Downloaded! Press any key to close the app!
pause
