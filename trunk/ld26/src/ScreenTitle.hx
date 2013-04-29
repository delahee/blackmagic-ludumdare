import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.Lib;
import fx.SndFadeOut;
import gfx.Intro;
import mt.deepnight.Key;
import flash.media.SoundChannel;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.text.TextField;
import starling.display.DisplayObject;
import Data;


class ScreenTitle extends Screen{
	
	public var info : starling.text.TextField;
	var intro : gfx.Intro;
	var spaced = false;
	var exiting = false;
	var bgm : SoundChannel;
	public function new(){
		super();
		intro = new gfx.Intro();
		loadBg = false;
		
		bgm = new IntroBGM().play(0,1000);
	}
		
	public override function init() {
		super.init();
		intro.x += intro.width * 0.5 - 24;
		intro.y += 360;
		M.core.nativeOverlay.addChild( intro );
	}
	
	public override function kill() {
		var b =  super.kill();
		if ( intro != null) {
			M.core.nativeOverlay.removeChild( intro );
			intro = null;
			
		}
		return b;
	}
	
	public override function update()
	{
		if ( exiting ) return;
		super.update();
		if ( intro.currentFrameLabel == "pressSpace" && Key.isToggled( flash.ui.Keyboard.SPACE) && !exiting&&!spaced) {
			intro.play(); 
			spaced = true;
			//bgm.soundTransform.volume = 128;
			new SndFadeOut( bgm, 12 );
		}
		else
			if ( !exiting && intro.currentFrame == intro.totalFrames) {
				var shp = new Shape();
				var g = shp.graphics;
				g.beginFill( 0xFFFFFF);
				g.drawRect( 0,0, volute.Lib.w(),volute.Lib.h());
				g.endFill();
				M.me.transition = Image.fromBitmap( mt.deepnight.Lib.flatten( shp, "transition"));
				mt.deepnight.Lib.disposeFlattened("transition");
				M.me.addChild( M.me.transition );
				M.me.setScreen( M.me.scursor + 1 );
				exiting = true;
				
				bgm.stop();
			}
	}
}


