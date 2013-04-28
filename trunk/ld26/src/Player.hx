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
	var asterAngleSpeed : Float;
	
	var movieState:String;
	
	public function new() {
		mc = Data.me.getMovie( 'perso', movieState='idle' );
		mc.pivotX = mc.width * 0.5;			
		mc.pivotY = mc.height;			
		pos = new Vec2();
		vel = new Vec2();
		asterAngle = 0;
	}
	
	public function setMovieState(str){
		movieState = str;
		
		Data.me.fillMc(mc, Data.me.getFramesRectTex( 'perso', str));
		
		if ( str == 'idle')
			trace(str);
	}
	
	public function setAsterAngle( aster, angle) {
		this.aster = aster;
		setAngle( angle );
		asterAngleSpeed = 0;
	}
	
	public function setAngle(angle)
	{
		var c = aster.getCenter();
		var r = aster.sz - 2;
		
		var ca = Math.cos( angle );
		var sa = Math.sin( angle );
		
		pos.x = c.x + ca * r;
		pos.y = c.y + sa * r;
		
		mc.rotation = MathEx.normAngle(angle + Math.PI / 2);
		asterAngle = angle;
	}
	
	public function updateKey(df)
	{
		var aspeed = 0.2;
		if ( Key.isDown( K.LEFT )) {
			setAsterAngle( aster, asterAngle - aspeed * M.timer.df);
			mc.scaleX = -1;	
			if ( movieState != 'run' ) setMovieState( 'run' );
		}
		
		else if ( Key.isDown( K.RIGHT )) {
			setAsterAngle( aster, asterAngle + aspeed * M.timer.df);
			mc.scaleX = 1;	
			if ( movieState != 'run' ) setMovieState( 'run' );
		}
		else 
			if ( movieState != 'idle') setMovieState( 'idle' );
	}
	
	public function update() {
		
		var df = M.timer.df;
		
		updateKey(df);
		
		mc.x = pos.x;
		mc.y = pos.y;
		
		
	}
}