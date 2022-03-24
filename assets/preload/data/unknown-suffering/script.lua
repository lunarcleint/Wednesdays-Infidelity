local allowCountdown = false
local allowEnd = false
function onEndSong()
	if not allowEnd and isStoryMode then --Block the next song lol
		startVideo('Portal');
		allowEnd = true;
		return Function_Stop;
	end
	return Function_Continue;
end