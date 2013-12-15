import flash.display.DisplayObject;
import flash.display.Sprite;
import mt.deepnight.SpriteLibBitmap;
import mt.deepnight.SpriteLibBitmap.*;

using volute.Ex;

enum CharState {
	Idle;
	Run;
	Shoot;
}

class Char extends Entity{

	var dir : Dir;
	
	var bsup : Sprite;
	var bsdown : Sprite;
	
	var state : CharState;
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
	
	public function createSprites() {
		var anim_up = name + "_shoot_" + Std.string( dir ).toLowerCase(); 
		var anim_down = name + "_" + Std.string( state ) .toLowerCase() + "_" + Std.string( dir ).toLowerCase(); 
		
		bsup = M.me.data.lib.getAndPlay(anim_up);
		bsdown = M.me.data.lib.getAndPlay(anim_down);
	}
	
	static inline var rosaceLim = 0.001;
	public function rosace4() {
		if 				( dx < - 	rosaceLim ) dir = W;
		else if 		( dx > 	 	rosaceLim ) dir = E;
		else if		 	( dy < - 	rosaceLim ) dir = N;
		else if 		( dy > 	 	rosaceLim ) dir = S;
		
		syncDir();
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
	
	public function syncDir() {
		var anim = name + "_" + Std.string( state ) .toLowerCase() + "_" + Std.string( dir ).toLowerCase(); 
		
		//trace(anim);
		/*
		 * 
		 */
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
		}
	}
	
	public override function update() {
		stateLife++;
		super.update();
		if( currentGun!=null)
			currentGun.update();
	}
}