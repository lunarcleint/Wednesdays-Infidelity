var curSection = 0;
var stepDev = 0;

//function onCreate()
//{
//}

function onStepHit()
{
	switch (curStep)
	{
		case 512:
			PlayState.oscuro.visible = false;
			PlayState.basedSkeletons.visible = true;
			PlayState.sky.visible = true;
			PlayState.ground.visible = true;
	}
}