package pix;
import flash.display.BitmapData;

class Store
{//}

	var lastIndex:Int;
	var ddx:Int;
	var ddy:Int;	
	
	public var timelines:Hash < Array < Int >> ;	
	public var index:Hash<Int>;
	
	public var frames:Array<Frame>;
	public var texture:BitmapData;

	public function new( bmp:BitmapData ) {
		texture = bmp;
		frames = [];
		ddx = 0;
		ddy = 0;
		lastIndex = 0;
		index = new Hash();
		timelines = new Hash();
	}
	
	// TOOLS - REGISTER
	
	public function addFrame( x, y, w, h, flipX=false, flipY=false, ?rot ) {
		var fr = new Frame( texture, x, y, w, h, flipX, flipY, rot );
		fr.ddx = ddx;
		fr.ddy = ddy;
		frames.push(fr);
		return fr;
	}
	
	public function slice( sx, sy, w, h, xmax=1, ymax=1, flipX=false, flipY=false, ?rot ) {
		for ( y in 0...ymax ) {
			for ( x in 0...xmax ) {
				addFrame( sx + x * w, sy + y * h, w, h, flipX, flipY, rot );
			}
		}
	}
	public function slice90( sx, sy, w, h, xmax = 1, ymax = 1) {
		for ( n in 0...4 ) {
			slice(sx, sy, w, h, xmax, ymax, false, false, n * 1.57);
		}
	}
	
	/*
	public function getIndexPos(str:String) {
		return index.get( str );
	}
	
	public function getLastIndexPos() {
		return lastIndex;
	}
	*/
	
	public function addIndex(str:String) {
		index.set(str, frames.length);
		lastIndex = frames.length;
	}
	public function addAnim(str:String, frames:Array<Int>, ?rythm:Array<Int>, multi=1 ) {

		var a = [];
		var id = 0;
		for ( n in frames ) {
			var max = 1;
			if ( rythm != null ) {
				if (id < rythm.length)	max = rythm[id];
				else					max = rythm[rythm.length - 1];
			}
			for( i in 0...max) a.push(n + lastIndex);
			id++;
		}
				
		if ( multi > 1 ) {
			for( k in 0...multi ){
				var b = [];
				var inc =  k*a.length;
				for ( n in a ) b.push(n + inc );
				timelines.set(str + "_" + k, a);
			}
		}else {
			timelines.set(str, a);
		}
		

	}
	
	// OTHER TOOLS
	public function setOffset(dx=0,dy=0) {
		ddx = dx;
		ddy = dy;
	}
	public function swapTexture(bmp) {
		texture = bmp;
		for( fr in frames ) fr.texture = texture;
	}
	public function makeTransp(color) {
		texture.threshold(texture, texture.rect, new flash.geom.Point(0, 0), "==", color, 0);
	}
	
	
	// TOOLS - GET
	public function get(id:Null < Int >= 0, ?str:String) {
		
		if ( str != null ) id += index.get(str);
		return frames[id];
	}
	public function getLength() {
		return frames.length;
	}
	public function getTimeline(str:String) {
		return timelines.get(str);
	}
	public function getIds() {
		var a = [];
		for ( n in index ) a.push(n);
		var f = function(a:Int, b:Int) {return (a < b)?-1:1;}
		a.sort(f);
		return a;
	}

	
//{
}



