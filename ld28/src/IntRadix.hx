import haxe.ds.Vector;


class IntRadix {
	var work : Vector<Int>;
	var hi : Vector<Int>;
	var lo : Vector<Int>;
	
	var maxSize:Int;
	public var NBITS:Int;
	
	public function new(maxSize:Int,nbits=16) {
		this.maxSize = maxSize;
		work = new Vector(maxSize);
		hi = new Vector(maxSize);
		lo = new Vector(maxSize);
		
		NBITS = nbits;
	}
	
	/** returns a vector of the sorted infos, the vector is not for subsequent use*/ 
	public function sortArray( arr:Array<Int>) {
		if ( arr.length > maxSize ) throw "insufficient radix size";
		
		for( i in 0...arr.length )
			work[i] = arr[i];
		
		sortBuckets(arr.length);
		
		for ( i in 0...arr.length)
			arr[i] = work[i];
		return arr;
	}
	
	/** returns a vector of the sorted infos, the vector is not for subsequent use*/ 
	public function sortVector( vec:Vector< Int >, len:Int ) {
		if ( len > maxSize ) throw "insufficient radix size";
		
		for( i in 0...len )
			work[i] = vec[i];
		
		sortBuckets(len);
		
		for ( i in 0...len)
			vec[i] = work[i];
		return vec;
	}
	
	function sortBuckets(sz) {
		var hiCur = 0;
		var loCur = 0;
		var sb = 0;
		var wi = 0;
		for ( b in 0...NBITS) {
			sb = 1 << b;
			hiCur = 0;
			loCur = 0;
			for ( i in 0...sz ) {
				wi = work[i];
				if ( (wi & sb) != sb)
					lo[loCur++] = wi;
				else 
					hi[hiCur++] = wi;
			}			
			hi.blit(0, lo, loCur, hiCur);
			var owork = work;
			work = lo;
			lo = work;
		}
	}
}


