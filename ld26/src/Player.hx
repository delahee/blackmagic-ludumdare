import flash.Lib;
import flash.Vector;
import mt.deepnight.Key;
import starling.display.MovieClip;
import starling.display.Sprite;
import volute.t.Vec2;
import volute.MathEx;

import volute.Types;
enum PlayerState {
	
	SPACED; //player wanders through infinite
	ASTER;
	RUN;
	JUMP;
	LAND;
}

class Player implements haxe.Public{
	var mc : MovieClip;
	
	var pos : Vec2;
	var vel : Vec2;
	
	var state : PlayerState;
	
	var aster : Aster;
	var asterAngle : Float;
	
	public function new() {
		mc = new MovieClip( Data.me.getFramesRectTex( 'perso', 'idle' ));
		pos = new Vec2();
		vel = new Vec2();
		asterAngle = 0;
	}
	
	public function syncPos() {
		mc.x = pos.x;
		mc.y = pos.y;
	}
	
	public function setAsterAngle( aster, angle) {
		this.aster = aster;
		asterAngle = angle;
		
		var c = aster.getCenter();
		var r = aster.sz;
		
		var ca = Math.cos( angle );
		var sa = Math.sin( angle );
		
		pos.x = c.x + ca * r;
		pos.y = c.y + sa * r;
	}
	
	public function update() {
		mc.x = pos.x;
		mc.y = pos.y;
	}
}