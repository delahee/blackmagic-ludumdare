package volute;

class Coll{
	
	public static inline function testCircleCircle( x : Float, y : Float, r : Float, xx  : Float, yy : Float, rr : Float) {
		var cx = xx - x;
		var cy = yy - y;
		var r3 = r + rr;
		return cx*cx + cy*cy< r3*r3;
	}
	
	public static inline function testCircleRectAA(cx,cy, cr, rx,ry, rw,rh)
	{
		var closestx = MathEx.clamp(cx, rx, rx + rw);
		var closesty = MathEx.clamp(cy, ry, ry + rh);
		
		var dx = cx - closestx;
		var dy = cy - closesty;
		
		return dx * dx + dy * dy < cr * cr;
	}
	
	public static inline function testPointRectAA(px,py,rx,ry,rw,rh)
	{
		return px >= rx && py >= ry && px <= rx + rw && py <= ry + rh;
	}
}