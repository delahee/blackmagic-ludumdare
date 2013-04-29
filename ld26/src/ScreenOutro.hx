import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextFieldAutoSize;
import flash.text.TextField;
import flash.text.TextFormat;
import gfx.Intro;
import gfx.Outro;
import mt.deepnight.Key;
import starling.core.Starling;
//import starling.display.Image;
//import starling.display.Sprite;
//import starling.text.TextField;
//import starling.display.DisplayObject;
			
class ScreenOutro extends Screen{
	
	public var outro : Outro;
	//public var shp : Shape;
	//public var txt : flash.text.TextField;
	
	public function new(){
		super();
		outro = new Outro();
		outro.x -= 75;
		outro.y -= 135;
		loadBg = false;
	}
		
	public override function init() {
		super.init();
		outro.play();
		M.core.nativeOverlay.addChild( outro );
	}
	
	public override function kill() {
		var b =  super.kill();
		M.core.nativeOverlay.removeChild( outro );
		return b;
	}
	
	public override function update()
	{
		
	}
}


