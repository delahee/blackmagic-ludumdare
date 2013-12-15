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
		//var s = M.me.data.lib.getAndPlay("goldpirate_run");
		dir = S;
		state = Idle;
		//el = s;
		bsup =  new Sprite();
		bsup.graphics.beginFill(0xFF0000);
		bsup.graphics.drawRect( -8, -24, 16, 16);
		bsup.graphics.endFill();
		
		bsdown =  new Sprite();
		bsdown.graphics.beginFill(0x00FF00);
		bsdown.graphics.drawRect( -8, -8, 16, 16);
		bsdown.graphics.endFill();
		
		bsdown.addChild(bsup);
		
		el = bsdown;
		
		depth = Level.DM_CHAR;
		super();
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