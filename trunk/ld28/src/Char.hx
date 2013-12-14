import flash.display.DisplayObject;
import flash.display.Sprite;

class Char extends Entity{

	public function new() 
	{
		var s = M.me.data.lib.getAndPlay("goldpirate_run");
		
		el = s;
		depth = Level.DM_CHAR;
		super();
	}
	
}