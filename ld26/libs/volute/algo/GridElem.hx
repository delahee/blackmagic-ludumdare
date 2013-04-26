package volute.algo;

/**
 * ...
 * @author de
 */

enum GE_FLAGS
{
}

class GridElem implements haxe.Public
{
	var ?gridStore:Int;
	
	var cx:Float;
	var cy:Float;
	
	var ?tx:Float;
	var ?ty:Float;
	
	var ?nx:Float;
	var ?ny:Float;
	
	c:Coll;
	var type:Int;
	var r : Float;//coll sphere radius
	
	var fl : haxe.EnumFlags<GE_FLAGS>;
	
	public function new() 
	{
		
	}
	
	public function stop()
	{
		cx = tx;
		cy = ty;
		
		nx = null; tx = null;
		ny = null; ty = null;
	}
	
	var span : List<Int>;
	public function cacheSpan()
	{
		if ( spanCount == 1 )
			span = null;
		else
		{
			var dgc = Grid.GC;
			span = new List();
			for( y in Std.int((t.cy - t.r)*dgc)...Std.int((t.cy + t.r )*dgc))
				for ( x in Std.int((t.cx - t.r)*dgc)...Std.int((t.cx + t.r )*dgc))
					span.push( (x%Grid.GD) | ((y%Grid.GC)<<8) );
		}
	}
	
	public function spanCount( t )
	{
		var dx = Std.int((t.cx + t.r ) / GC) - Std.int((t.cx - t.r) / GC) + 1;
		var dy = Std.int((t.cy + t.r ) / GC) - Std.int((t.cy - t.r) / GC) + 1;
		
		return dx * dy;
	}
}