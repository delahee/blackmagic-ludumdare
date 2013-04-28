import starling.display.Sprite;
import volute.Lib;

class View extends Sprite
{
	public function new()
	{
		super();
		
	}
	
	public function update()
	{
		var p = Player.me;
		if ( p == null) {
			x = 0;
			y = 0;
		}
		else {
			if ( p.pos.x < Lib.h() / 2)
				x = 0;
			else 
				x = - p.pos.x  + Lib.h() / 2;
				
		}
		
	}
	
	
	
}
