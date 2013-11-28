package volute.algo;

using Ex;
/**
 * ...
 * @author de
 */
//cyclic seed ? 
//generic, simple and efficient coll class...or so i hope
class Grid 
{
	public static inline var NB_GC = 32;
	public static inline var GC = 32;
	
	var repo : Array<List<GridElem>>; 
	var tVsT : Array<Int>;
	
	public function enable(t0,t1)
	{
		if (tVsT[t0] == null)		tVsT[t0] = 0;
		tVsT[t0] |= (1 << t1);
	}
	
	public function disable(t0, t1)
	{
		if (tVsT[t0] == null)		tVsT[t0] = 0;
		tVsT[t0] &= ~(1 << t1);
	}
	
	//set me to handle collisions
	dynamic function onColl(t0,t1)
	{
		trace(t0 + " collided " + t1);
	}
	
	public function new() 
	{
		repo = [];
	}
	
	inline function mK( t )
	{
		var cx = (t.cx / GC) % NB_GC;
		var cy = (t.cy / GC) % NB_GC;
		
		return cx | (cy << 8);
	}
	
	public inline function circTest(t0,t1)
	{
		var difx = t1.x - t0.x;
		var dify = t1.y - t0.y;
		var ldif2 = difx * difx + dify * dify;
		return ldify <= t0.r * t0.r + t1.r * t1.r;
	}
	
	public function remElem( t ) : Bool
	{
		if (t.store == null)
			return false;
		else
		{
			var k = mK(t);
			var c = repo[k];
			if (c == null) return false;
			
			var rid = repo[k].remove(t);
			if ( rid != null)
				t.store = null;
			return rid;
		}
	}
	
	public function moveElem( t,x,y)
	{
		t.nx = y;
		t.ny = y;
	}
	
	public function setElem( t ) : Bool
	{
		if (t.store != null)
			return false;
			
		var k = mK(t);
		
		if ( repo[k] == null)
			repo[k] = new List();
			
		#if debug
			if ( repo[k].has( t ) )
				throw "assert";
		#end
		
		repo[k].push( t );
		t.store = k;
		return true;
	}
	
	public function spanList( t )
	{
		
	}
	
	
	
	public function clear()
		repo.splice(0,repo.length);
	
	public function update()
	{
		var nbIter = 4;
		
		function iterLists( f )
		{
			for ( o in repo )
				if ( o != null)
					f(o);
		}
		
		function iterSoup( f )
		{
			for ( o in repo )
				if ( o != null)
					for ( e in o )
						f(e);
		}
		
		function testElemVsList(a,l)
		{
			for ( b in l)
			{
				if ( a != b )
				{
					var coll = circTest( a,b );
					if ( (tVsT[a.type] & (1 << b.type)) != 0)//a can trigger b 
						onColl( a,b );
					if ( (tVsT[b.type] & (1 << a.type)) != 0)//a can trigger b 
						onColl( b,a );
				}
			}
		}
		
		iterSoup(function(t) 
		{
			t.tx = t.cx;
			t.ty = t.cy;
		});
		
		for ( n in 0...nbIter+1)
		{
			//manage out of box elements ?
			iterLists( 	function( l )
						{
							for ( a in o)
								testElemVsList( o );
						}
				});
				
			iterSoup( function( t ) 
			{
				if ( t.nx != null && t.ny != null)
				{
					t.tx = t.cx + t.nx * n / nbIter;
					t.ty = t.cy + t.ny * n / nbIter;
				}
			}
		}
	}
}