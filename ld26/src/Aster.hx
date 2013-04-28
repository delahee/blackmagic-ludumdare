import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import haxe.Public;
import starling.display.Image;
import volute.Dice;
import volute.Lib;
import volute.t.Vec2;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

using Lambda;
using volute.LbdEx;
using volute.ArrEx;

enum Side{
	SPlayer;
	SOther;
}

typedef CineLine = {
	line:String,
	side:Side,
}
typedef Cine = 
{
	sprite:String,
	script:List<CineLine>,
	proc:Void->Void,
	ofs:Vec2,
}


class Aster extends Entity, implements Public {
	
	var shp : flash.display.Shape; 
	var bmp : Bitmap; 
	
	var img : starling.display.Image;
	var link  : Null<Aster>;
	
	var isFire:Bool;
	
	var grid: Grid;
	var scripted : Bool;
	var script : ScriptedAster;
	
	var cine(default, setCine) : Null<Cine>;
	
	static var guid : Int = 0;
	
	public var a(default, set_a) : Float;
	public function new(isFire = false, sz : Float = 32) {
		super();
		
		this.isFire = isFire;
		this.sz = sz;
		a = 0;
		x = y = 0;
		
		scripted = true;
		guid++;
		compile();
	}
	
	var cineMc : starling.display.MovieClip;
	
	public function setCine(c:Cine){
		
		if ( c != null) {
			cineMc = Data.me.getMovie(c.sprite, 'idle');
			cineMc.x = x /*- img.width*0.5*/ + c.ofs.x;
			cineMc.y = y - img.height + c.ofs.y;
			img.parent.addChild( cineMc );
		}
		
		return cine = c;
	}
	
	public function move(ix, iy) {
		x = ix; y = iy;
		syncPos();
		return this;
	}
	
	public function translate(ix, iy) {
		x += ix; y += iy;
		syncPos();
		return this;
	}
	
	public function dispose() {
		bmp.bitmapData.dispose();
		bmp.bitmapData = null;
		bmp = null;
	}
	
	public function enableTouch()
	{
		img.touchable = true;
		img.addEventListener( TouchEvent.TOUCH , function (e:TouchEvent)
		{
			var touch: Touch = e.touches[0];
			if(touch!=null){
				if(touch.phase == TouchPhase.BEGAN)
				{
				}
 
				else if(touch.phase == TouchPhase.ENDED)
				{
					var loc = touch.getLocation(img);
					//trace("mup on " + loc );
				}
 
				else if(touch.phase == TouchPhase.MOVED)
				{
				}
			}
			
		}); 
		
	}
			
		
	public function compile() {
		shp = new Shape();
		var g = shp.graphics;
		var col = isFire ? 0xFF0000 : 0x000020;
		g.beginFill( col);
		g.drawCircle( sz / 2.0, sz / 2.0, sz );
		g.endFill();
		
		bmp = Lib.flatten( shp );
		img = Image.fromBitmap( bmp );
		
		img.readjustSize();
	
		img.pivotX = bmp.width * 0.5;
		img.pivotY = bmp.height * 0.5;
		
		return this;
	}
	
	private function setPosXY(x,y) {
		if (grid != null && key != null) grid.remove( this );
		
		img.x = x;
		img.y = y;
		
		if( grid != null ) grid.add( this );
	}
	
	public function update() {
		
		var p = Player.me;
		var cull = volute.MathEx.dist2( p.pos.x, p.pos.y, img.x,img.y) > 1300 * 1300;
		#if debug
			img.alpha = cull ? 0.1 : 1.0;
		#else
			img.visible = cull; 
		#end
	}
	
	public function set_a(f:Float) {
		
		a = f;
		
		return f;
	}
	
	public function syncPos(){
		setPosXY( x, y );
	}
	
	public function getCenter() {
		return new Vec2(x,y);
	}
	
	public function intersects( a: Aster) {
		var ac = a.getCenter();
		var pos = getCenter();
		
		var c = pos.decr( ac );
		
		return a.sz * a.sz + sz * sz >= c.norm2();
	}
	
	public function onBurn()
	{
		
	}
	
}















