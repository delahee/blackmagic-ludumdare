import flash.Lib;
import flash.Vector;
import mt.deepnight.Key;
import starling.display.MovieClip;
import starling.display.Sprite;
import volute.Coll;
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
	
	var checkPoint : Aster;
	var last : Aster;
	
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
		if( aster != null ) last = aster;
	}
	
	public function setAngle(angle){
		var c = aster.getCenter();
		var r = aster.sz - 2;
		
		var ca = Math.cos( angle );
		var sa = Math.sin( angle );
		
		pos.x = c.x + ca * r;
		pos.y = c.y + sa * r;
		
		mc.rotation = MathEx.normAngle(angle + Math.PI * 0.5);
		asterAngle = angle;
		
		if ( aster!=null&& aster.script!=null &&aster.script.isCheckpoint())
			checkPoint = aster;
	}
	
	public function updateKey(df:Float){
		if ( aster != null)
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
			else if ( Key.isDown( K.UP )) {
				if ( movieState != 'jump' )
					setMovieState( 'jump' );
				onFly();
			}
			else
				if ( movieState != 'idle') setMovieState( 'idle' );
		}
		else if (isFlying()){
			//if ( Key.isDown( K.LEFT )) a = - ac * df;
			//else if ( Key.isDown( K.RIGHT )) a = ac * df;			
			//asterAngleSpeed
			
			var ask = 0.05;
			if ( Key.isDown( K.LEFT )) {
				asterAngleSpeed -= ask;
				if ( asterAngleSpeed < -ask) asterAngleSpeed = -ask;
			}
			else if ( Key.isDown( K.RIGHT )) {
				asterAngleSpeed += ask;	
				if ( asterAngleSpeed > ask) asterAngleSpeed = ask;
			}
			
			asterAngleSpeed *= Math.pow( 0.93, df);
			asterAngle += asterAngleSpeed *  df;
			
			var ca = Math.cos( asterAngle );
			var sa = Math.sin( asterAngle );
			var k = 10.0;
			vel.set( ca * k, sa * k);
			
			mc.rotation = MathEx.normAngle(asterAngle + Math.PI / 2);
			
			var asres :Entity= null;
			function testLand( as : Entity){
				if ( 	Coll.testCircleCircle( pos.x + ca * 35, pos.y + sa * 35, 50, as.x, as.y, as.sz ) 
				&&		last != as) 
				{
					//trace("hit");	
					asres = as;
					return true;
				}
				
				return false;
			}
			
			L.me.grid.iterRange( Std.int(pos.x), Std.int(pos.y), 200, testLand );
			var asn : Aster = cast asres;
			
			if ( asres != null) {
				var a = Math.atan2( pos.y - asres.y, pos.x - asres.x);
				onLand( asn );
				setAsterAngle( asn, a);
			}
			else{
				//var expectPlanet = 
			}
		}
		
	}
	
	public function onFly() {
		var ca = Math.cos( asterAngle );
		var sa = Math.sin( asterAngle );
		var k = 10.0;
		vel.set( ca * k, sa * k);
		aster = null;
		//mc.pivotX = mc.width * 0.5;
		//mc.pivotY = mc.height * 0.5;
	}
	
	public function onLand(as:Aster) {
		//mc.pivotX = mc.width * 0.5;
		//mc.pivotY = mc.height;
		if ( as.isFire ) {
			kill();
		}
	}
	
	public function isFlying(){
		return aster == null;
	}
	
	public function tryKill()
	{
		if ( mc.x < 100)						kill();
		else if ( mc.y < 100)					kill();
		else if ( mc.y > volute.Lib.h()+  100)	kill();
	}
	
	
	public function kill() {
		if( checkPoint!=null)
			setAsterAngle( checkPoint, Math.PI * 0.5);
	}
	
	public function update() {
		
		var df = M.timer.df;
		
		updateKey(df);
		
		if (isFlying()){
			pos.x += vel.x * df;
			pos.y += vel.y * df;
		}
		
		mc.x = pos.x;
		mc.y = pos.y;
		
		
	}
}