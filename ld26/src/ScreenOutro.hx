import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextFieldAutoSize;
import flash.text.TextField;
import flash.text.TextFormat;
import gfx.Intro;
import mt.deepnight.Key;
import starling.core.Starling;
//import starling.display.Image;
//import starling.display.Sprite;
//import starling.text.TextField;
//import starling.display.DisplayObject;
			
class ScreenOutro extends Screen{
	
	public var outro : flash.display.Sprite;
	public var shp : Shape;
	public var txt : flash.text.TextField;
	
	public function new(){
		super();
		outro = new Sprite();
		shp = new Shape();
		txt = new TextField();
		txt.width = 600;
		var fmt = new TextFormat('semibold', 20,0xFFffFF);
		txt.setTextFormat( txt.defaultTextFormat = fmt );
		txt.x = 300;
		txt.y = 300;
		txt.multiline = true;
		txt.wordWrap = true;
		txt.text = "Swimming Fool created by @cardduus(gfx), @gandhirules(design&snd), @blackmagic_mt(code) & @HallouinMathieu(music). Additionnal Music Tütenmuschi by Gourmet.";
	}
		
	public override function init() {
		super.init();
		
		outro.addChild( txt );
		outro.addChild( shp );
		
		var g = outro.graphics;
		g.beginFill( 0xFF0000);
		g.drawCircle( 0, 0, 50);
		g.endFill();

		M.core.nativeOverlay.addChild( txt );
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


