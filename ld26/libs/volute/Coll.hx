package volute;

class Coll{
	
	public static function testCircleCircle( x : Float, y : Float, r : Float, xx  : Float, yy : Float, rr : Float) {
		var cx = xx - x;
		var cy = yy - y;
		var r3 = r + rr;
		return cx*cx + cy*cy< r3*r3;
	}
}