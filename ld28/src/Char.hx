import flash.display.DisplayObject;
import flash.display.Sprite;
import mt.deepnight.SpriteLibBitmap;
import mt.deepnight.SpriteLibBitmap.*;

enum CharState {
	Idle;
	Walk;
	Run;
	Shoot;
}

class Char extends Entity{

	var dir : Dir;
	
	var bsup : Sprite;
	var bsdown : Sprite;
	
	var state : CharState;
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
	
	public function syncDir() {
		var anim = name + "_" + Std.string( state ) .toLowerCase() + "_" + Std.string( dir ).toLowerCase(); 
		
		//trace(anim);
		/*
		 * 
		 */
	}
	
}