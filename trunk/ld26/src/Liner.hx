package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import mt.gx.math.Vec2;
import starling.display.Image;
import starling.textures.RenderTexture;
import starling.textures.Texture;
import volute.Lib;

/**
 * ...
 * @author de
 */
class Liner
{
	var shp : flash.display.Shape;
	var bmp : Bitmap;
	var lines : Array<{inv:Vec2,outv:Vec2,col:Int}>;
	var tex : starling.textures.RenderTexture;
	public var img : Image;
	
	public function new() {
		lines = [];
		tex = new RenderTexture( Lib.w(), Lib.h(), true);
		bmp = new Bitmap( new BitmapData( Lib.w(), Lib.h(), true, 0x0 ));
		img = new Image(tex);
	}
	
	public function dispose() {
		bmp.bitmapData = null;
		bmp = null;
	}
	public function clear() {
		tex.clear();
	}
	
	public function compile(){
		var shp = new flash.display.Shape();
		var g = shp.graphics;
		
		for (l in lines) {
			g.lineStyle( 3.0, l.col);
			g.moveTo(l.inv.x, l.inv.y);
			g.lineTo(l.outv.x,l.outv.y);
		}
		
		bmp.bitmapData.draw( shp);
		tex.draw( Image.fromBitmap( bmp ));
		img.readjustSize();
	}
	
	public function addLine(x,y, xx,yy,col=0xFF0000) {
		lines.push({inv:new Vec2(x, y), outv:new Vec2(xx, yy),col:col});
	}
	
	public function addPoint(x:Float, y:Float, col = 0xFF0000, sz = 2.) {
		sz*=0.5;
		lines.push({inv:new Vec2(x-sz, y-sz), outv:new Vec2(x+sz, y+sz),col:col});
		lines.push({inv:new Vec2(x+sz, y-sz), outv:new Vec2(x-sz, y+sz),col:col});
	}
}