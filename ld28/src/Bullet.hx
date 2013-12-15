import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import mt.deepnight.Lib;

using volute.Ex;

@:publicFields
class Bullet
{
	@:isVar
	var x(get, set) : Float;
	
	@:isVar
	var y(get,set) : Float;
	
	var dx : Float = 0.0;
	var dy : Float = 0.0;
	
	var fx : Float = 1.0;
	var fy : Float = 1.0;
	
	var el : Sprite;
	
	var spr:Sprite;
	var bmp : Bitmap;
	
	var remove : Bool;
	
	public var tick : Void->Void;
	public var coll : Entity->Void;
	
	var cy:Int = 0;
	var harm : Int = 0;
	
	var life = 200;
	
	public function new(?sp=null) {
		tick = id;
		coll = ide;
		remove = false;
		spr = sp;
		if ( spr == null ) {
			spr = new flash.display.Sprite();
			spr.graphics.beginFill(0xFFF052);
			spr.graphics.drawCircle( -1, -1, 2);
			spr.graphics.endFill();
			
			bmp = Lib.flatten( spr , true);
			spr.addChild(bmp);
			spr.graphics.clear();
			
			spr.filters = [new GlowFilter(0,1,2,2,8)];
		}
	}
	
	public inline function headX() {
		return x-2;
	}
	
	public inline function headY() {
		return y-2;
	}
	
	public inline function headRadius() {
		return 2;
	}
	
	public inline function get_x() {
		return x;
	}
	
	public inline function get_y() {
		return y;
	}
	
	public inline function set_x(v:Float) {
		x = v;
		spr.x = Std.int(v);
		return v;
	}
	
	public inline function set_y(v:Float) {
		y = v;
		cy = Std.int(v) >> 4;
		spr.y = Std.int(v);
		return v;
	}
	
	
	public function kill() {
		dx = 0; 
		dy = 0;
		
		M.me.timer.delay( function(){
		spr.detach();
		if ( bmp != null){
			bmp.bitmapData.dispose();
			bmp.bitmapData = null;
			bmp = null;
		}
		}, 8);
		trace("bullet killed");
		
	}
	
	public static function id() {
		
	}
	
	public static function ide(_) {
		
	}
	
	
	public function begin(?tick, ?coll ) {
		this.tick = tick;
		this.coll = coll;
	}
	
	public function update() {
		tick();
		life--;
		if ( life <= 0 ) {
			remove = true;
		}
		//trace('bl update $x $y $dx $dy');
	}
	
}