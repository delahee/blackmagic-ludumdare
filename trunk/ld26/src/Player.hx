import flash.Lib;
import flash.Vector;
import fx.SpeechDelay;
import mt.deepnight.Sfx;
import mt.fx.Fx;

import fx.Blink;
import fx.Delay;
import fx.Vanish;

import mt.deepnight.KDTree;
import mt.deepnight.Key;
import starling.display.MovieClip;
import starling.display.Sprite;
import volute.Coll;
import volute.Dice;
import volute.t.Vec2;
import volute.MathEx;

import volute.Types;
import volute.Lib;

import Aster;
import Data;

using volute.Ex;

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
	var mute = false;
	
	static var me : Player;
	
	public function new() {
		mc = Data.me.getMovie( 'perso', movieState='idle' );
		mc.pivotX = mc.width * 0.5;			
		mc.pivotY = mc.height;			
		mc.name = "player";	
		pos = new Vec2();
		vel = new Vec2();
		asterAngle = 0;
		me = this;
	}
	
	public function setMovieState(str){
		movieState = str;
		
		Data.me.fillMc(mc, Data.me.getFramesRectTex( 'perso', str));
		
		//if ( str == 'idle') trace(str);
	}
	
	public function setAsterAngle( ias, angle) {
		if ( aster == null) {
			Data.sndBank.stomp().play();
		}
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
			else
			if ( Key.isDown( K.UP ) || Key.isDown( K.SPACE ) ) {
				if ( movieState != 'jump' ) setMovieState( 'jump' );
				onFly();
			}
			else
				if ( movieState != 'idle') setMovieState( 'idle' );
			
		}
		else if (isFlying()){
			//if ( Key.isDown( K.LEFT )) a = - ac * df;
			//else if ( Key.isDown( K.RIGHT )) a = ac * df;			
			//asterAngleSpeed
			
			var ask = 0.04;
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
			
			vel.y += 0.42 * df;
			
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
		Data.sndBank.jump().play();
		var ca = Math.cos( asterAngle );
		var sa = Math.sin( asterAngle );
		var k = 10.0;
		vel.set( ca * k, sa * k);
		aster = null;
		stateLife = 0;
		mc.loop = true;
	}
	
	public function onLand() {
		if ( aster.isFire ) {
			Data.sndBank.burn().play();
			kill();
			setAnim( 'blown' );
			mc.loop = false;
			mc.rotation = mc.rotation + Math.PI;
		}
		else {
			last = aster;
			/*
			if ( aster.cine != null) {
				
				input = false;
				makeCine( aster.cine );
				aster.cine = null;
			}*/
		}
	}
	
	public function setAnim(anm)
	{
		if ( movieState != anm ) 
			setMovieState( anm );
	}
	
	public function makeCine(c:Cine){
		function p(d,f) new fx.SpeechDelay( d,f );
		
		setAngle( -Math.PI / 2 - 0.3);
		setAnim('idle');
		
		c.proc();
		
		mc.scaleX = 1;
		
		var delay:Float = 0.0;
		for ( q in c.script) {
			var d = speachDur( q.line);
			
			switch(q.side) {
				case SPlayer:	
						p( delay, function() speach( mc.x -50, mc.y - 100, q.line ));
						Data.sndBank.speak1().play();
						
				case SOther:
				{
					{
						var col = 0xFFcdcdcd;
						switch(c.type) {
							case BEN :col = [0xDD555, 0x55DD55, 0xDDDD55, 0x55DDDD, 0xDD55DD].random();
							case YODA: col = 0xbcffbc; 
							case DEEPNIGHT: col = 0xffbcbc; 
							case ELVIS: col = 0xfff9bc; 
							case PRINCE: col = 0xfff832; 
							
						}
						
						p( delay, function()
						{
							speach( mc.x + 100 + c.ofsSpeech.x, mc.y - 100 + c.ofsSpeech.y, q.line, col);
							Data.sndBank.speak2().play();
						});
					}
				}
			}
			
			delay += d;
		}
		
		if ( c.type != ELVIS )
		{
			new fx.SpeechDelay( delay += 1.0, function()
			{
				input = true;
			});
		}
		else
		{
			new SpeechDelay( delay+=2.0, function() {
				M.me.setScreen( M.me.scursor + 1);
			});
		}
		
		//del += 10.0;
		//p( del, M.me.unmakeBlackStrip);
	}
	
	public function isFlying(){
		return aster == null;
	}
	
	public function tryKill()
	{
		if ( killed ) return;
		
		if ( pos.x < -100)						kill();
		else if ( pos.y < -100)					kill();
		else if ( pos.y > volute.Lib.h()+  100)	kill();
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
				
		var fx = new fx.Blink(mc);
		fx.onKill =  oe;
		killed = true;
	}
	
	public function update() {
		
		if ( killed ) return;
		var df = M.timer.df;
		stateLife += df;
		asterAngle = MathEx.normAngle(asterAngle);
		
		if( input )
			updateKey(df);
		else 
			if ( Key.isToggled(K.SPACE) ) {
				for ( f in volute.fx.FXManager.self.rep )
					if ( Std.is( f, fx.SpeechDelay ) )
						f.duration -= 0.25;
			}
		
		if (isFlying()){
			pos.x += vel.x * df;
			pos.y += vel.y * df;
			
			if ( stateLife > 10)
				last = null;
		}
		
		tryKill();
		handleCine();
		
		if ( aster != null && !killed)
			setAngle( asterAngle );
		
		
		mc.x = pos.x;
		mc.y = pos.y;
		
		
	}
	
	public function handleCine() {
		
		asterAngle = MathEx.normAngle(asterAngle);
		
		var isNear = 	asterAngle > (3 * Math.PI / 2)
		&&				asterAngle < (2 * Math.PI ) - Math.PI / 3;
		
		if( aster!=null)
		if( aster.cine != null && isNear  ) {
			input = false;
			makeCine( aster.cine );
			aster.cine = null;
		}
	}
	
	public function speachDur(lbl) return 0.75 + lbl.length * 0.07
	public function say( lbl:String ) {
		if ( !mute ) 
			speach( mc.x + 40, mc.y - 100,lbl ); 
	}
	
	public function speach( x, y, lbl:String,  col = 0xFFFFffFF ) {
		var t = Data.me.texts.get( lbl );
		var tf = M.getTf( t == null?lbl : t, x, y, 24, col );
		tf.blendMode = starling.display.BlendMode.ADD;
		tf.alpha = 0.5;
		mc.parent.addChild( tf ); 
		Ex.toFront( tf );
		
		var d = speachDur(lbl);
		var v = new Vanish(tf, d);
		v.sy = 1.0;
		//trace('saying ' + lbl);
	}
	
	
	
}