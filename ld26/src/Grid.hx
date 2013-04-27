


class Grid
{
	var rep:IntHash<List<Entity>>;
	
	public function new() {
		rep = new IntHash();
	}
	
	public function iterRange( n : Int, proc ) {
		for( y in 0...n )
			for ( x in 0...n )
				if ( rep.exists( (x << 16) | y ))
					for ( e in rep.get( (x << 16) | y ) ) 
						proc( e );
			
	}

	public function remove(e:Entity)
	{
		if ( e.key != null)
		{
			var l : List<Entity> = rep.get( e.key ) ;
			for ( es in l )
				if ( es == e )
					l.remove( e );
		}

	}
	
	public function add(e:Entity)
	{
		var k = (Std.int(e.x) << 16) | Std.int(e.y);
		var l = rep.get(k);
		if ( l == null ) 
			rep.set( k, l = new List() );
			
		l.push( e );
		e.key = k;
	}
}