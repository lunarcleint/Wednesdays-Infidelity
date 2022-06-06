package;

// STOLEN FROM HAXEFLIXEL DEMO LOL
import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.display.ShaderInput;
import openfl.utils.Assets;

using StringTools;

typedef ShaderEffect =
{
	var shader:Dynamic;
}

class ChromaticAberrationEffect extends Effect
{
	public var shader:ChromaticAberrationShader;

	public function new(offset:Float = 0.00)
	{
		shader = new ChromaticAberrationShader();
		shader.rOffset.value = [offset];
		shader.gOffset.value = [0.0];
		shader.bOffset.value = [-offset];
	}

	public function setChrome(chromeOffset:Float):Void
	{
		shader.rOffset.value = [chromeOffset];
		shader.gOffset.value = [0.0];
		shader.bOffset.value = [chromeOffset * -1];
	}
}

class ChromaticAberrationShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		
        uniform vec2 rOffset;
        uniform vec2 gOffset;
        uniform vec2 bOffset;

		vec4 offsetColor(vec2 offset)
        {
            return texture2D(bitmap, openfl_TextureCoordv.st - offset);
        }

		void main()
		{
			vec4 base = texture2D(bitmap, openfl_TextureCoordv);
            base.r = offsetColor(rOffset).r;
            base.g = offsetColor(gOffset).g;
            base.b = offsetColor(bOffset).b;

			gl_FragColor = base;
		}
	')
	public function new()
	{
		super();
	}
}

class DistortionEffect extends Effect // I need to learn glsl -lunar
{
	public var shader:DistortionShader = new DistortionShader();

	public function new(glitchFactor:Float)
	{
		shader.iTime.value = [0];
		shader.glitchModifier.value = [glitchFactor];
		shader.iResolution.value = [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight];
		PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed:Float)
	{
		shader.iTime.value[0] += elapsed;
		shader.iResolution.value = [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight];
	}

	public function setGlitchModifier(modifier:Float)
	{
		shader.glitchModifier.value[0] = modifier;
	}
}

class DistortionShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header

        uniform float iTime;
        uniform float glitchModifier;
        uniform vec3 iResolution;
    
        float onOff(float a, float b, float c)
        {
          return step(c, sin(iTime + a*cos(iTime*b)));
        }
    
        float ramp(float y, float start, float end)
        {
          float inside = step(start,y) - step(end,y);
          float fact = (y-start)/(end-start)*inside;
          return (1.-fact) * inside;
    
        }
    
        vec4 getVideo(vec2 uv)
          {
            vec2 look = uv;
              float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
              look.x = look.x + (sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window)*(glitchModifier*2);
              float vShift = 0.4*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) +
                                 (0.5 + 0.1*sin(iTime*200.)*cos(iTime)));
              look.y = mod(look.y + vShift*glitchModifier, 1.);
            vec4 video = flixel_texture2D(bitmap,look);
    
            return video;
          }
    
        vec2 screenDistort(vec2 uv)
        {
          return uv;
        }
		
        float random(vec2 uv)
        {
           return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
        }

        float noise(vec2 uv)
        {
           vec2 i = floor(uv);
            vec2 f = fract(uv);
    
            float a = random(i);
            float b = random(i + vec2(1.,0.));
          float c = random(i + vec2(0., 1.));
            float d = random(i + vec2(1.));
    
            vec2 u = smoothstep(0., 1., f);
    
            return mix(a,b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;
        }
    
    
        vec2 scandistort(vec2 uv) {
          float scan1 = clamp(cos(uv.y * 2.0 + iTime), 0.0, 1.0);
          float scan2 = clamp(cos(uv.y * 2.0 + iTime + 4.0) * 10.0, 0.0, 1.0) ;
          float amount = scan1 * scan2 * uv.x;
    
          return uv;
        }

        void main()
        {
          vec2 uv = openfl_TextureCoordv;
          vec2 curUV = screenDistort(uv);
          uv = scandistort(curUV);
          vec4 video = getVideo(uv);
          float vigAmt = 1.0;
          float x =  0.;
          
          gl_FragColor = video;
    
        }
  	')
	public function new()
	{
		super();
	}
}

class VHSEffect extends Effect
{
	public var shader:VHSShader = new VHSShader();

	public function new()
	{
		shader.iTime.value = [0];
		shader.noisePercent.value = [0.0];
		shader.range.value = [0.05];
		shader.offsetIntensity.value = [0.02];
		shader.iResolution.value = [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight];
		PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed:Float)
	{
		shader.iTime.value[0] += elapsed;
		shader.iResolution.value = [Lib.current.stage.stageWidth, Lib.current.stage.stageHeight];
	}

	public function setNoise(amount:Float)
	{
		shader.noisePercent.value[0] = amount;
	}
}

class VHSShader extends FlxShader // i HATE shaders xd -lunar https://www.shadertoy.com/view/ldjGzV https://www.shadertoy.com/view/Ms3XWH https://www.shadertoy.com/view/XtK3W3
{
	@:glFragmentSource('
		#pragma header

		uniform float range;
		uniform float iTime;
		uniform sampler2D noiseTexture;
		uniform float noisePercent;
		uniform vec3 iResolution; // have this var anyway to stop crashes lmao xd
		uniform float offsetIntensity;
		
		float rand(vec2 co)
		{
			float a = 12.9898;
			float b = 78.233;
			float c = 43758.5453;
			float dt= dot(co.xy ,vec2(a,b));
			float sn= mod(dt,3.14);
			return fract(sin(sn) * c);
		}

		vec3 mod289(vec3 x) {
			return x - floor(x * (1.0 / 289.0)) * 289.0;
		}

		vec2 mod289(vec2 x) {
			return x - floor(x * (1.0 / 289.0)) * 289.0;
		}

		vec3 permute(vec3 x) {
			return mod289(((x*34.0)+1.0)*x);
		}

		float snoise(vec2 v)
		{
			 const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
			// First corner
			vec2 i  = floor(v + dot(v, C.yy) );
			vec2 x0 = v -   i + dot(i, C.xx);

			// Other corners
			vec2 i1;
			//i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
			//i1.y = 1.0 - i1.x;
			i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
			// x0 = x0 - 0.0 + 0.0 * C.xx ;
			// x1 = x0 - i1 + 1.0 * C.xx ;
			// x2 = x0 - 1.0 + 2.0 * C.xx ;
			vec4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;

			// Permutations
			i = mod289(i); // Avoid truncation effects in permutation
			vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
					+ i.x + vec3(0.0, i1.x, 1.0 ));

			vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
			m = m*m ;
			m = m*m ;

			// Gradients: 41 points uniformly over a line, mapped onto a diamond.
			// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

			vec3 x = 2.0 * fract(p * C.www) - 1.0;
			vec3 h = abs(x) - 0.5;
			vec3 ox = floor(x + 0.5);
			vec3 a0 = x - ox;

			// Normalise gradients implicitly by scaling m
			// Approximation of: m *= inversesqrt( a0*a0 + h*h );
			m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

			// Compute final noise value at P
			vec3 g;
			g.x  = a0.x  * x0.x  + h.x  * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 90.0 * dot(m, g);
		}
			
		float noise(vec2 p)
		{
			return rand(p) * noisePercent;
		}
		
		float onOff(float a, float b, float c)
		{
			return step(c, sin(iTime + a*cos(iTime*b)));
		}

		float ramp(float y, float start, float end)
		{
			float inside = step(start,y) - step(end,y);
			float fact = (y-start)/(end-start)*inside;
			return (1.-fact) * inside;
		}

		float stripes(vec2 uv)
		{
			float noi = noise(uv*vec2(0.5,1.) + vec2(1.,3.));
			return ramp(mod(uv.y*4. + iTime/2.+sin(iTime + sin(iTime*0.63)),1.),0.5,0.6)*noi;
		}

		vec4 getVideo(vec2 uv)
		{

			float time = iTime * 2.0;
			
			// Create large, incidental noise waves
			float noise2 = max(0.0, snoise(vec2(time, uv.y * 0.3)) - 0.3) * (1.0 / 0.7);
			
			// Offset by smaller, constant noise waves
			noise2 = noise2 + (snoise(vec2(time*10.0, uv.y * 2.4)) - 0.5) * 0.15;
			
			// Apply the noise as x displacement for every line
			float xpos = uv.x - noise2 * noise2 * 0.25;

			vec2 look = vec2(xpos, uv.y);

			float window = 1./(2.+20.*(look.y-mod(iTime ,1.))*(look.y-mod(iTime ,1.)));
			float vShift = 0.2*onOff(2.,3.,.9) * (sin(iTime)*sin(iTime*200.) + (0.2 + 0.1*sin(iTime*200.)*cos(iTime/10)));
			look.y = mod(look.y + vShift, 1.);
			vec4 video = vec4(flixel_texture2D(bitmap,look));
			return video;
		}

		vec2 screenDistort(vec2 uv)
		{
			uv -= vec2(.5,.5);
			uv = uv*1.2*(1./1.2+2.*uv.x*uv.x*uv.y*uv.y);
			uv += vec2(.5,.5);
			return uv;
		}

		float verticalBar(float pos, float uvY, float offset)
		{
			float edge0 = (pos - range);
			float edge1 = (pos + range);

			float x = smoothstep(edge0, pos, uvY) * offset;
			x -= smoothstep(pos, edge1, uvY) * offset;
			return x;
		}

		void main()
        {
			vec2 uv = openfl_TextureCoordv.xy;   

			for (float i = 0.0; i < 0.71; i += 0.1313)
			{
				float d = mod(iTime * i, 1.7);
				float o = sin(1.0 - tan(iTime * 0.24 * i));
				o *= offsetIntensity;
				uv.x += verticalBar(d, uv.y, o);
			}

			uv = screenDistort(uv);
			vec4 video = getVideo(uv);
			float x =  0.;

			video.r = getVideo(vec2(x+uv.x+0.001,uv.y+0.001));
          	video.g = getVideo(vec2(x+uv.x+0.000,uv.y-0.002));
          	video.b = getVideo(vec2(x+uv.x-0.002,uv.y+0.000));
			
			float vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));
			float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));
			
			video += stripes(uv);
			video += noise(uv*2.)/2.;
			video *= vignette;
			video *= (12.+mod(uv.y*30.+iTime,1.))/13.;
			
			gl_FragColor = vec4(video);
		}
	')
	public function new()
	{
		super();
	}
}

class Effect
{
	public function setValue(shader:FlxShader, variable:String, value:Float)
	{
		Reflect.setProperty(Reflect.getProperty(shader, 'variable'), 'value', [value]);
	}
}
