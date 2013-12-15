import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Vector3D;
import mt.deepnight.SpriteLibBitmap;
import mt.deepnight.SpriteLibBitmap.*;
import volute.MathEx;
import volute.t.Vec2i;
import Dir;
using volute.Ex;

enum CharState {
	Idle;
	Run;
	Shoot;
	Watch;
}

class Char extends Entity{

	var dir : Dir;
	
	var bsup : BSprite;
	var bsdown : BSprite;
	
	var state(default,set) : CharState;
	var stateLife:Int = 0;
	var currentGun : Gun;
	
	var isShooting : Int;
	var isRunning : Bool;
	
	static inline var shootCooldown = 5;
	
	public function new() 
	{
		dir = S;
		state = Idle;
		createSprites();
		bsdown.addChild(bsup);
		el = bsdown;
		depth = Level.DM_CHAR;
		super();
	}
	
	public function set_state(s) {
		onStateChange( state, s);
		if( state != s )
			stateLife = 0;
		state = s;
		return s;
	}
	
	static var v2id: Vec2i = new Vec2i(0, 0);
	
	public function getFireOfset(){
		return v2id;
	}
	
	public function onStateChange(os, ns) {
		
	}
	
	public function createSprites() {
		var anim_up = name + "_shoot_" + Std.string( dir ).toLowerCase(); 
		var anim_down = name + "_" + Std.string( state ) .toLowerCase() + "_" + Std.string( dir ).toLowerCase(); 
		
		trace("loading " + anim_up);
		trace("loading " + anim_down);
		bsup = M.me.data.lib.getAndPlay(anim_up);
		bsdown = M.me.data.lib.getAndPlay(anim_down);
	}
	
	public inline function addToMajorDir(dir:Dir,d:Float){
		switch(dir) {
			default:
			case N: ry -= d;
			
			case NE: addToMajorDir(N, d * 0.7); addToMajorDir(E, d * 0.7);
			case SE: addToMajorDir(S, d * 0.7); addToMajorDir(E, d * 0.7);
			case SW: addToMajorDir(S, d * 0.7); addToMajorDir(W, d * 0.7);
			case NW: addToMajorDir(N, d * 0.7); addToMajorDir(W, d * 0.7);
			 
			case S: ry += d;
			case E: rx += d;
			case W: rx -= d;
		}
	}
	
	static inline var rosaceLim = 0.02;
	
	public function rosace4() {
		
		if ( MathEx.is0( dx ) && MathEx.is0( dy ))
			return;
		
		var ndir : Dir = N;
		
		if 				( dx < - 	rosaceLim ) ndir = W;
		else if 		( dx > 	 	rosaceLim ) ndir = E;
		else if		 	( dy < - 	rosaceLim ) ndir = N;
		else if 		( dy > 	 	rosaceLim ) ndir = S;
		else 
			isRunning = false;
			
		syncDir(dir,ndir);
	}
	
	public function addScore(d)
	{
		var s = M.me.ui.addScore(d, 
		el.x - M.me.level.view.x - el.width * 0.5,
		el.y - M.me.level.view.y - el.height  );
	
		s.x -= s.textWidth * 0.5;
	}
	
	public function rosace8() {
		if ( Math.abs(dx) <= 0.01 ) dx = 0;
		if ( Math.abs(dy) <= 0.01 ) dy = 0;
		
		var ndir : Dir = null;
		var fl = 0;
		
		if ( dy > rosaceLim) 			{ fl |= (1 << 0);}
		else if ( dy < -rosaceLim) 		{ fl |= (1 << 1); }
		
		if ( dx < -rosaceLim) 			{ fl |= (1 << 2);}
		else if ( dx > rosaceLim)		{ fl |= (1 << 3); }
		
		isRunning = true;
	
		if ( fl != 0 ) {
			ndir = switch(fl) {
				case 0 : isRunning = false; null;
				case 1 : S;
				case 2 : N;
				
				case 4: W;
				case 5: SW;
				case 6: NW;
				
				case 8: E;
				case 9: SE;
				case 10: NE;
				default:
			}
			
		}
		trace(dir+" "+ndir+" "+dx+" "+dy);
		syncDir(dir,ndir);
	}
	
	public function angleToDir(a:Float) {
		while (a <= 0) a += 2 * Math.PI;
		while (a >= 2 * Math.PI) a -= 2 * Math.PI;
		
		return 
		if 		( a <= 0*Math.PI * 0.25 && a <= 1*Math.PI * 0.25) 	E;
		else if	( a <= 1*Math.PI * 0.25 && a <= 2*Math.PI * 0.25) 	NE;
		else if	( a <= 2*Math.PI * 0.25 && a <= 3*Math.PI * 0.25) 	N;
		else if	( a <= 3*Math.PI * 0.25 && a <= 4*Math.PI * 0.25) 	NW;
		else if	( a <= 4*Math.PI * 0.25 && a <= 5*Math.PI * 0.25) 	W;
		else if	( a <= 5*Math.PI * 0.25 && a <= 6*Math.PI * 0.25) 	SW;
		else if	( a <= 6*Math.PI * 0.25 && a <= 7*Math.PI * 0.25) 	S;
		else 	SE;
	}
	
	public override function kill() {
		bsdown.detach();
		bsup.detach();
		
		bsdown = null;
		bsup = null;
	}
	
	public function addMessage(str)
	{
		M.me.ui.addMessage(str, el.x - M.me.level.view.x, el.y - M.me.level.view.y - el.height*0.5 );
	}
	
	public function syncDir(odir,ndir) {
		
		dir = ndir;
	}
	
	public override  function tryCollideBullet(b:Bullet) {
		var t = volute.Coll.testCircleRectAA(	b.headX(), b.headY(), b.headRadius(),
												el.x - el.width * 0.5, el.y - el.height, el.width, el.height);
		if ( t ) {
			hp--;
			if ( hp == 0 ) {
				onKill();
			}
			else onHurt();
			b.remove = true;
			dx = 0;
			dy = 0;
		}
	}
	
	public override function update() {
		stateLife++;
		super.update();
		if( currentGun!=null)
			currentGun.update();
		isShooting--;
	}
}