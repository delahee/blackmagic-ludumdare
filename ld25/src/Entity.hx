import flash.display.Sprite;

using volute.com.Ex;

enum ENT_TYPE
{
	ET_PLAYER;
	ET_PEON;//tired
}

class Entity  implements haxe.Public
{
	var el : flash.display.DisplayObject;
	
	var cx : Int = 0;
	var cy : Int = 0;
	
	var rx : Float = 0.0;
	var ry : Float = 1.0;
	
	var dx : Float = 0.0;
	var dy : Float = 0.0;
	
	var ofsX : Float = 0.0;
	var ofsY : Float = 0.0;
	var gravity = true;
	var falling = false;
	var type:ENT_TYPE;
	
	var l : Level;
	
	public function new() 
	{
	}
	
	public function enterLevel(l:Level)
	{
		this.l = l;
		l.add(this);
	}
	
	public function detach()
	{
		el.detach();
		if(l!=null)l.remove2(this);
		l = null;
	}
	
	
	public function test(cx, cy)
	{
		return M.level.staticTest(cx, cy);
	}
	
	public function bump(cx, cy)
	{
		return M.level.staticBump(cx, cy);
	}
	
	public function updateX()
	{
		var moved = false;
		function m() moved = true;
		
		while (rx > 1)
		{
			if (!test(cx + 1, cy))
			{
				rx--;
				cx++;
				m();
			}
			else
			{
				bump(cx + 1, cy);
				rx -= 0.05;
				dx = 0;
				m();
			}
		}
		
		while (rx < 0)
		{
			if (!test(cx -1, cy))
			{
				rx++;
				cx--;
				m();
			}
			else
			{
				bump(cx - 1, cy);
				rx += 0.05;
				dx = 0;
				m();
			}
		}
		
		return moved;
	}
	
	public function onLand()
	{
		
	}
	
	public function onFall()
	{
		
	}
	
	
	public function updateY()
	{
		var moved = false;
		function m() moved = true;
		
		while (ry > 1.2)
		{
			if ( test(cx, cy + 1) )
			{
				bump(cx, cy + 1);
				cy++;
				ry = 1.0;
				dy = 0;
				if(falling)
					onLand();
				falling = false;
				m();
			}
			else
			{
				ry--;
				cy++;
				m();
			}
		}
		while (ry < 0.0)
		{
			cy--;
			ry++;
			m();
		}
		
		
		return moved;
	}
	
	public function update()
	{
		rx += dx;
		ry += dy;
					
		if (  Math.abs( dx ) < 1e-3 )
			dx = 0;
			
		if (  Math.abs( dy ) < 1e-3 )
			dy = 0;
			
		
		#if debug
		if (Std.is(this, Char))
		{
			//var i = 0;
			//trace("cx:"+cx+" cy:"+cy+" dx:"+dx+" dy:"+dy+" rx:"+rx+" ry:"+ry);
		}
		#end
		
		var uy = updateY();
		var ux = updateX();
		while(ux||uy)
		{
			uy = updateY();
			ux = updateX();
		}
		
		var hasFoot = test(cx, cy+1 );
		if ( hasFoot )
		{
			if (falling
			//
			&& dy > 0.0005
			&& ry > 0.9
			)
			{
				dy = 0;
				ry = 1.0;
				falling = false;
				onLand();
			}
			//else nothing
			//trace()
		}
		else
		{
			dy += 0.005; 
			if ( dy > 0.125)
				dy = 0.125;
			falling = true; 
			onFall();
		}
		
		syncPos();
		
		if(dx!=0)
			el.scaleX = dx < 0 ? -1 : 1;
		
	}
	
	public inline function syncPos()
	{
		el.x = Std.int((cx << 4) + rx * 16.0);
		el.y = Std.int((cy << 4) + ry * 16.0);
	}
		
		
	public function kill()
	{
		
	}
}