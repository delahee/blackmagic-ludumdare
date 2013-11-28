package volute.algo;

class Pool<T>
{
	var free : List < T >;
	var used : List < T >;
	var new_proc : Void->T;
	
	public function create() : T
	{
		var n = free.pop();
		if ( n == null )
			n = new_proc();
			
		used.add(n);
		return n;
	}
	
	public inline function nbUsed() 		return used.length
	public inline function getUsed() : Iterable<T> return used
	public inline function getFree() : Iterable<T>	return free
	public inline function getAll() : Iterable<T>	return Lambda.concat( used,free)
	
	public inline function destroy( o : T ) : Void{
		var ok = used.remove( o );
		if (ok) free.add(o);
	}
	
	public function new( new_proc ){
		free = new List<T>();
		used = new List<T>();
		this.new_proc = new_proc;
	}
	
	public function reserve( len : Int ){
		for (i in 0...len)
			free.add( new_proc() );
		return this;
	}
	
	public function reset(){
		for (o in used)
			free.add( o );
		used.clear();
		return this;
	}
	
}