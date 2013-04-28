import flash.Lib;
import flash.Vector;
import fx.Blink;
import mt.deepnight.Key;
import starling.display.MovieClip;
import starling.display.Sprite;
import volute.Coll;
import volute.Dice;
import volute.fx.FX;
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
	var stateLife = 0.0;
	var input = true;
	var killed = false;
	
	static var me : Player;
	
	public function new() {
		mc = Data.me.getMovie( 'perso', movieState='idle' );
		mc.pivotX = mc.width * 0.5;			
		mc.pivotY = mc.height;			
		pos = new Vec2();
		vel = new Vec2();
		asterAngle = 0;
		me = this;
	}
	
	public function setMovieState(str){
		movieState = str;
		
		Data.me.fillMc(mc, Data.me.getFramesRectTex( 'perso', str));
		
		if ( str == 'idle')
			trace(str);
	}
	
	public function setAsterAngle( ias, angle) {
		aster = ias;
		
		asterAngleSpeed = 0;
		
		if ( aster != null ) {
			onLand();
			if ( killed ) return;
			
			setAngle( angle );
		}
		
		if ( aster != null 
		&& ( aster.script == null || aster.script.isCheckpoint())
		&&	!aster.isFire )
			checkPoint = aster;
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
			
			var ask = 0.004;
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
			
			vel.y += 0.3333;
			
			asterAngle = Math.atan2( vel.y, vel.x );
			
			var down = new Vec2(0, 1);
			var k = 3; down.mulScalar( k );
			
			mc.rotation = MathEx.normAngle(asterAngle + Math.PI / 2);
			
			var asres :Entity= null;
			function testLand( as : Entity){
				if ( 	Coll.testCircleCircle( pos.x + ca * 35, pos.y + sa * 35, 20, as.x, as.y, as.sz ) 
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
		stateLife = 0;
	}
	
	public function onLand() {
		if ( aster.isFire ) {
			kill();
		}
		else {
			last = aster;
		}
	}
	
	public function isFlying(){
		return aster == null;
	}
	
	public function tryKill()
	{
		if ( mc.x < -100)						kill();
		else if ( mc.y < -100)					kill();
		else if ( mc.y > volute.Lib.h()+  100)	kill();
	}
	
	//public function gameOver(){
		//trace('gameOver');
	//}
	
	public function kill() {
		input = false;
		
		function oe() 
			{
				killed = false;
				input = true;
				setAsterAngle( checkPoint, Dice.rollF( - Math.PI * 0.5, Math.PI ) );
			}
				
		var fx : FX = new fx.Blink(mc);
		fx.onKill =  oe;
		killed = true;
	}
	
	public function update() {
		
		if ( killed ) return;
		var df = M.timer.df;
		stateLife += df;
		
		if( input )
			updateKey(df);
		
		if (isFlying()){
			pos.x += vel.x * df;
			pos.y += vel.y * df;
			
			if ( stateLife > 10)
				last = null;
		}
		
		tryKill();
		
		mc.x = pos.x;
		mc.y = pos.y;
	}
}