package volute.com;

/**
 * ...
 * @author de
 */

class ArrEx
{
	public static inline function scramble<A>( arr : Array<A>)
	{
		for(x in 0...arr.length + Std.random( arr.length ) )
		{
			var b =  Std.random( arr.length );
			var a =  Std.random( arr.length );
			var temp = arr[a];
			arr[ a ] = arr[ b ];
			arr[ b ] = temp;
		}
	}
	
	public static inline function first<A>( arr : Array<A> )	return arr[0]
	public static inline function last<A>( arr : Array<A> )		return arr[arr.length-1]
	public static inline function rd<A>( arr : Array<A> ) : A
		return (arr.length != 0)? arr[ Std.random(arr.length) ] : null
	
	public static inline function reserve<A>( n : Int ) : Array<A>
	{
		var r = new Array();
		r[n] = null;
		return r;
	}
	
	public static inline function clear<A>(  arr : Array<A> ) arr.splice( 0, arr.length )
	public static inline function removeByIndex<A>(  arr : Array<A>,i : Int ) arr.splice( i, 1 )
	
	//append iterable at end of array and returns this array
	public static function enqueue<A>( a : Array<A>, b : Iterable<A>) : Array<A>
	{
		for(x in b )
			a.push( x );
		return a;
	}
	
	//in place filtering for arrays
	public static inline function strip<A>( a : Array<A>, f:  A -> Bool ) : Array<A>
	{
		var top = a.length -1;
		while( top >= 0 )
		{
			if ( f(a[top])) a.splice( top , 1 );
			top--;
		}
		return a;
	}
	
	/**
	 * add x shallow copy of e in the array
	 * @param	e
	 * @param	nb
	 */
	public static function splat<S>( arr:Array<S>, nb, e)
	{
		for(i in 0...nb) arr.push( Reflect.copy(e) );
		return arr;
	}

	public static function bsearch<K,S>( a : Array<S>, key : K, f : K -> S -> Int ) : S
	{
		var st = 0;
		var max = a.length;
		
		var index = - 1;
		while(st < max)
		{
			index = ( st + max ) >> 1;
			var val = a[index];
			
			var cmp = f( key, val);
			if( cmp < 0  )
				max = index;
			else if ( cmp > 0)
				st = index + 1;
			else return val;
		}
		return null;
	}
	
	public static inline function pushBack<T>( l : Array<T>, e : T )
	{	l.push(e); return e; }
		
	public static inline function pushFront<T>( l : Array<T>, e : T )
	{	l.unshift(e); return e; }
		
	public static function partition<Elem>( it : Array<Elem>, predicate )
	{
		var p = { first:[],second:[] }
		for ( x in it )
			if(  predicate( x ) )
				p.first.push( x);
			else
				p.second.push( x);
		return p;
	}
	
}


