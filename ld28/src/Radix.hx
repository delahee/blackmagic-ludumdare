//author bm
import haxe.ds.Vector;

//you can inline this interface with patterns like key = objectid<<16 | x<<8| y for example
//the important thing it to pad what is sorted on an int
interface Sortable {
	public function getKey():Int;
}

/**
 * This is a specialized sort to sort bit field keys
 * by sorting one bit at a time
 */
@:generic
class Radix<T:Sortable> {
	var work : Vector<T>;
	var hi : Vector<T>;
	var lo : Vector<T>;
	
	var maxSize:Int;
	
	//determine the number of bit to sort
	//the algorithm will sort all numbers by the first bit order then go next
	public var NBITS:Int;
	
	public function new(maxSize:Int,nbits=16) {
		this.maxSize = maxSize;
		work = new Vector<T>(maxSize);
		hi = new Vector<T>(maxSize);
		work = lo = new Vector<T>(maxSize);
		
		NBITS = nbits;
	}
	
	/** returns an array of the sorted infos, the vector is not for subsequent use*/ 
	public function sortArray( arr:Array<T>) {
		if ( arr.length > maxSize ) throw "insufficient radix size";
		
		for( i in 0...arr.length )
			work[i] = arr[i];
		
		sortBuckets(arr.length);
		
		for ( i in 0...arr.length)
			arr[i] = work[i];
		return arr;
	}
	
	/** returns a vector of the sorted infos, the vector is not for subsequent use*/ 
	public function sortVector( vec:Vector< T >, len:Int ) {
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
				wi = work[i].getKey();
				if ( (wi & sb) != sb)
					lo[loCur++] = work[i];
				else 
					hi[hiCur++] = work[i];
			}			
			haxe.ds.Vector.blit(hi, 0, lo, loCur, hiCur);
			work = lo;			
		}

		
	}
	
	/**
	 * test
	 * class Elem implements Radix.Sortable {
		var x = 0;
		
		public function new(v) {
			x = v;
		}
		
		public function getKey() return x;
		public function toString() return "" + x;
	}
		var radix = new Radix<Elem>(2048, 16);
		var a = [];
		for ( i in 0...512 ) {
			a.push( new Elem(Std.random(1 << 15) ));
		}
		radix.sortArray(a);
		trace(a);
		
		a = [9, 8, 7, 6, 5, 5, 5, 4, 3, 2, 1].map( function(e) return new Elem(e ));
		radix.sortArray(a);
		trace( a );
		a = [9,  1].map( function(e) return new Elem(e ));
		radix.sortArray(a);
		trace( a );
		
		a = [4, 8, 1, 10].map( function(e) return new Elem(e ));
		radix.sortArray(a);
		trace( a );
		
		var radix = new Radix<Elem>(2048, 2);
		var a = [4, 8, 1, 10].map( function(e) return new Elem(e ));
		radix.sortArray(a);
		trace( a );
		
		Demo.hx:33: [8,71,115,125,195,249,264,307,471,479,583,657,972,978,1031,1068,1083,1158,1192,1391,1413,1416,1420,1589,1756,1927,2010,2095,2126,2195,2199,2206,2303,2366,2367,2387,2416,2444,2476,2486,2498,2562,2595,2635,2639,2653,2675,2721,2724,2769,2840,3000,3099,3192,3204,3250,3274,3302,3319,3355,3377,3406,3414,3524,3534,3584,3658,3675,3841,3842,3879,4010,4014,4115,4132,4376,4400,4432,4464,4606,4636,4673,4674,4689,4899,4921,4942,4942,4952,5057,5127,5158,5223,5367,5405,5515,5567,5606,5607,5623,5806,5853,5871,5911,5990,6003,6087,6091,6113,6146,6175,6195,6197,6277,6421,6454,6491,6532,6744,6819,6822,6841,6933,6947,6967,7045,7120,7127,7163,7432,7453,7469,7522,7564,7583,7641,7684,7764,7841,7883,7891,7909,8027,8128,8140,8152,8220,8237,8249,8258,8306,8311,8314,8436,8548,8615,8642,8740,8763,8803,8846,9005,9022,9100,9326,9372,9445,9537,9557,9585,9632,9656,9667,9721,9810,9865,9921,10014,10192,10228,10231,10266,10299,10432,10490,10492,10630,10648,10803,10818,10861,10890,11023,11367,11385,11443,11465,11569,11638,11717,11760,11778,11789,11927,11955,11998,12039,12078,12365,12393,12420,12422,12548,12555,12661,12764,12919,12978,12988,13017,13020,13047,13184,13266,13289,13307,13426,13518,13521,13540,13593,13638,13683,13711,13778,13861,13954,13979,14060,14335,14378,14609,14639,14743,14788,14922,14934,15074,15209,15236,15278,15310,15353,15357,15441,15459,15517,15559,15561,15775,15834,15846,15867,15886,15941,15945,16097,16097,16343,16354,16446,16473,16510,16589,16627,16629,16721,16754,16826,16834,17041,17122,17126,17134,17146,17258,17268,17321,17340,17377,17497,17599,17752,17792,17839,18063,18101,18116,18149,18174,18198,18257,18467,18619,18704,18764,18805,18808,18858,18869,18882,18920,19038,19121,19129,19143,19151,19156,19213,19373,19416,19527,19619,19648,19676,19727,19814,20089,20134,20219,20277,20338,20374,20427,20602,20737,20853,20853,20885,20934,20984,21013,21112,21115,21133,21137,21187,21202,21302,21812,21823,21892,21914,22040,22143,22175,22230,22337,22384,22525,22529,22530,22772,22788,22899,22965,23113,23138,23286,23314,23333,23347,23380,23393,23428,23432,23511,23729,23742,24047,24103,24140,24146,24320,24321,24358,24488,24514,24560,24640,24649,24669,24832,24865,24903,24953,25019,25050,25116,25133,25216,25534,25682,25693,25904,25917,25924,25961,26036,26157,26187,26300,26378,26634,26685,26800,26836,26841,26890,26911,26917,27049,27246,27274,27305,27336,27343,27349,27397,27418,27573,27598,27644,27667,27710,27727,27753,27760,27781,28045,28080,28154,28304,28329,28394,28423,28477,28517,28764,28778,28795,28814,28948,28957,28987,29082,29087,29107,29185,29207,29408,29448,29454,29496,29538,29555,29591,29772,29872,29890,30030,30054,30081,30280,30298,30416,30531,30571,30748,30765,30794,30885,30970,30982,31060,31373,31397,31414,31416,31424,31526,31658,31665,31670,31688,31773,31917,31928,31998,32004,32102,32160,32204,32315,32370,32376,32391,32487,32513,32609,32729,32744]
		Demo.hx:37: [1,2,3,4,5,5,5,6,7,8,9]
		Demo.hx:40: [1,9]
		Demo.hx:44: [1,4,8,10]
		Demo.hx:49: [4,8,10,1]
	 */
}


