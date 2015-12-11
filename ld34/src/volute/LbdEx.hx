package volute;

using Lambda;

import haxe.ds.StringMap;
import haxe.ds.IntMap;

class LbdEx
{
	public static function sum<Elem>( it : Iterable<Elem>, valFunc : Elem -> Int ) : Int
	{
		var v = 0;
		for ( x in it ) v += valFunc( x );
		return v;
	}
	
	public static function nth<Elem>( it : Iterable<Elem>, n : Int , ?dflt) : Elem
	{
		var i = 0;
		for ( x in it )
		{
			if( i == n )
				return x;
			i++;
		}
		return dflt;
	}
	
	public static function first<Elem>( it : Iterable<Elem>, ?dflt) : Elem
	{
		return nth(it,0,dflt);
	}
	
	public static function nullStrip<A>( it : Iterable<A>) : List<A>
	{
		return Lambda.filter(it, function(x:A) { return (x != null); } );
	}
	
	public static function reverse<A>( it : Iterable<A>) : List<A>
	{
		var l = new List();
		for(x in it)
			l.push( x);
		return l;
	}
	
	public static function head<A>( it : Iterable<A>, n : Int ) : List<A>
	{
		var i = 0;
		var l = new List();
		for ( e in it )
		{
			if ( i >= n ) return l;
			l.add( e );
			i++;
		}
		
		return l;
	}
	
	public static function tail<A>( it : Iterable<A>, n : Int ) : List<A>
	{
		var i = 0;
		var len = Lambda.count( it );
		return Lambda.filter( it, function(x) return( i++ >= (len - n ) ) );
	}
	
	
	public static function random<A>( it : Iterable<A> ) : A
	{
		var i : Null<Int> = Std.random( Lambda.count(it) );
		return  nth( it, i );
	}
	
}