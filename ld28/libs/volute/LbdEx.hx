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
	
	public static function avg<Elem>( it : Iterable<Elem>, valFunc : Elem -> Int ) : Float
	{
		var len = Lambda.count( it );
		if ( len == 0 ) return 0;
		
		var v = 0;
		for ( x in it ) v += valFunc( x );
		return v / len;
	}
	
	public static function test<Elem>( it : Iterable<Elem>, predicate : Elem -> Bool ) : Bool
	{
		for ( x in it )
			if(  predicate( x ) )
				return true;
		return false;
	}
	
	//first in pair is the valid predicate set, second is the wrong
	public static function partition<Elem>( it : Iterable<Elem>, predicate )
	{
		var p = {first:new List(),second:new List()};
		for ( x in it )
			if(  predicate( x ) )
				p.first.add( x);
			else
				p.second.add( x);
		return p;
	}
	
	/**
	 *
	 **/
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
	
	public static function sortAbsOrder<A>( it : Iterable<A> , order : A -> A -> Bool ) : List<A>
	{
		var arr = Lambda.array( it );
		var f =
		function(x, y)
		{
			if( order(x,y) )
			{
				return -1;
			}
			else
			{
				return 1;
			}
		}
		
		arr.sort(f);
		
		return Lambda.list(arr);
	}
	
	
	public static function random<A>( it : Iterable<A> ) : A
	{
		var i : Null<Int> = Std.random( Lambda.count(it) );
		return  nth( it, i );
	}
	
}