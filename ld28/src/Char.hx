import flash.display.DisplayObject;
import flash.display.Sprite;
import mt.deepnight.SpriteLibBitmap;
import mt.deepnight.SpriteLibBitmap.*;
import volute.MathEx;
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
			case E: rx -= d;
			case W: rx += d;
		}
	}
	
	static inline var rosaceLim = 0.001;
	
	public function rosace4() {
		
		if ( MathEx.is0( dx ) && MathEx.is0( dy ))
			return;
		
		var ndir : Dir = N;
		
		if 				( dx < - 	rosaceLim ) ndir = W;
		else if 		( dx > 	 	rosaceLim ) ndir = E;
		else if		 	( dy < - 	rosaceLim ) ndir = N;
		else if 		( dy > 	 	rosaceLim ) ndir = S;
		
		syncDir(dir,ndir);
	}
	
	public function rosace8() {
		
		if ( MathEx.is0( dx ) && MathEx.is0( dy ))
			return;
		
		var ndir : Dir = null;
		var fl = 0;
		
		if ( dy > rosaceLim) 			{ fl |= (1 << 0);}
		else if ( dy < rosaceLim) 		{ fl |= (1 << 1); }
		
		if ( dx < -rosaceLim) 			{ fl |= (1 << 2);}
		else if ( dx > rosaceLim)		{ fl |= (1 << 3); }
		
		if ( fl != 0 ) {
			ndir = switch(fl) {
				
				case 1 : S;
				case 2 : N;
				
				case 4: E;
				case 5: SW;
				case 6: NW;
				
				case 8: W;
				case 9: SE;
				case 10: NE;
				
				default: 
			}
			
		}
		
		syncDir(dir,ndir);
	}
	
	public override function kill() {
		bsdown.detach();
		bsup.detach();
		
		bsdown = null;
		bsup = null;
	}
	
	public function addMessage(str)
	{
		M.me.ui.addMessage(str, el.x - M.me.level.view.x, el.y - M.me.level.view.y );
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
	}
}