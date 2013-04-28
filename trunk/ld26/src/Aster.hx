import flash.display.Bitmap;
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


class Aster extends Entity, implements Public {
	
	var shp : flash.display.Shape; 
	var bmp : Bitmap; 
	
	var img : starling.display.Image;
	var link  : Null<Aster>;
	
	var isFire:Bool;
	var sz:Float;
	
	var grid: Grid;
	var scripted : Bool;
	var script : ScriptedAster;
	
	public var a(default, set_a) : Float;
	
	public function move(ix, iy) {
		x = ix; y = iy;
		syncPos();
	}
	
	public function translate(ix, iy) {
		x += ix; y += iy;
		syncPos();
	}
	
	public function new(isFire = false, sz : Float = 32) {
		super();
		
		this.isFire = isFire;
		this.sz = sz;
		a = 0;
		x = y = 0;
		
		scripted = true;
		compile();
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
		g.beginFill(0x0);
		g.drawCircle( sz / 2.0, sz / 2.0, sz );
		g.endFill();
		
		bmp = Lib.flatten( shp );
		img = Image.fromBitmap( bmp );
		
		img.readjustSize();
	
		img.pivotX = bmp.width * 0.5;
		img.pivotY = bmp.height * 0.5;
		
		return this;
	}
	
	public function setPosXY(x,y) {
		if (grid != null && key != null)
			grid.remove( this );
		
		img.x = x;
		img.y = y;
		
		grid.add( this );
	}
	
	public function update() {
		
	}
	
	public function set_a(f:Float) {
		
		a = f;
		
		return f;
	}
	
	public function syncPos()
	{
		img.x = x; img.y = y;
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















