


class Grid
{
	var rep:IntHash<List<Entity>>;
	
	public function new() {
		rep = new IntHash();
	}
	
	public function iterRange( posx:Int,posy:Int, rpix : Int, proc : Entity->Bool) {
		var n = rpix >> 5;
		var posnx :Int= posx >> 5;
		var posny :Int= posy >> 5;
		var hn = (n >> 1) + 1;
		
		for( y in posny-hn...posny+hn )
			for ( x in posnx-hn...posnx+hn )
				if ( rep.exists( (x << 16) | y ))
					for ( e in rep.get( (x << 16) | y ) ) 
						if ( proc( e ) )
							return;
			
	}

	public function remove(e:Entity){
		if ( e.key != null)
		{
			var l : List<Entity> = rep.get( e.key ) ;
			for ( es in l )
				if ( es == e )
					l.remove( e );
		}

		trace("removing from grid");
	}
	
	public function add(e:Entity)	{
		var k = ((Std.int(e.x)>>5) << 16) | (Std.int(e.y)>>5);
		var l = rep.get(k);
		if ( l == null ) 
			rep.set( k, l = new List() );
			
		l.push( e );
		e.key = k;
		
		trace("adding to grid " + k+" "+e);
	}
}