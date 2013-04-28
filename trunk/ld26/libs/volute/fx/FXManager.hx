package volute.fx;

using Lambda;

class FXManager
{
	var rep : Hash<List<FX>>;
	
	public static inline var DEFAULT_QUEUE = "__multi";
	
	public static var self : FXManager = new FXManager();
	public function len() 
	{
		var n = 0;
		for ( l in rep)
			n += l.length;
		return n;
	}
	
	public function new()
	{
		rep = new Hash();
		rep.set( null, new List());
	}
	
	public function update()
	{
		for( k in rep.keys() )
		{
			var x = rep.get( k );
			if( k == DEFAULT_QUEUE )
				rep.set( k , x.filter( function(fx) return fx.update() ));
			else
			{
				var p = x.first();
				while(p!=null)
				{
					if (!p.update())
					{
						x.remove( p );
						p = x.first();
						if(p!=null) p.reset();
					}
					else break;
				}
			}
		}
	}
	
	//adding to null queue
	public function add( queue : String = null, x :FX )
	{
		if( queue ==null)
			queue = DEFAULT_QUEUE;
		if ( !rep.exists( queue ))
			rep.set(queue, new List());
		rep.get( queue ).add(x);
	}
}