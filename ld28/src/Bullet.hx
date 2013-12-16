import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import mt.deepnight.Lib;
import mt.deepnight.SpriteLibBitmap.BSprite;
import volute.*;
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
	
	var spr:BSprite;
	var bmp : Bitmap;
	
	var remove : Bool;
	
	public var tick : Void->Void;
	public var coll : Entity->Void;
	
	var cy:Int = 0;
	var harm : Int = 0;
	
	var life = 14;
	
	public function new(?sp) {
		tick = id;
		coll = ide;
		remove = false;
		
		if(sp==null)
			spr = M.me.data.lib.getAndPlay( "props_bullet_a" );
		else 
			spr = sp;
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
		spr.destroy();
		}, 8);
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
		spr.rotation = MathEx.RAD2DEG * (Math.PI*0.5 + Math.atan2(dy,dx));
		if ( life <= 0 ) {
			remove = true;
			spr.destroy();
		}
	}
	
}