package volute.t;

class Vec2{
	public var x		: Float;
	public var y		: Float;
	
	public function new (x=0.0, y=0.0){
		this.x = x;
		this.y = y;
	}
	
	public function set( x , y ) {
		this.x = x;
		this.y = y;
		return this;
	}
	
	public inline function copy( xy : Vec2 ) {
		x = xy.x;
		y = xy.y;
		return this;
	}
	
	public inline function clone(  ) : Vec2{
		return new Vec2( x, y );
	}
	
	public inline function norm2() : Float{
		return x * x + y * y;
	}
	
	public inline function norm() : Float{
		return Math.sqrt( norm2() );
	}
	
	public static inline function scale2(vOut : Vec2, xy: Vec2) : Vec2
	{
		vOut.x *= xy.x;
		vOut.y *= xy.y;
		return vOut;
	}
	
	public static inline function cross(v0: Vec2, v1:Vec2) : Float
	{
		return v0.x * v1.y - v0.y * v1.y;
	}
	
	//v0     v2
	//    v1 
	// 
	public static inline function signedArea( v0, v1, v2 ) {
		return cross( Vec2.sub( v0, v1 ), Vec2.sub( v2, v1 ));
	}
	
	
	public inline function incr( V1 :  Vec2 ) 				{ x += V1.x; y += V1.y; return this; }
	public inline function incrXY(ix:Float,iy:Float)		{ x += ix; y += iy; return this; }
	
	public inline function decr( V1 :  Vec2 )
	{
		x -= V1.x;
		y -= V1.y;
		return this;
	}
	
	public static inline function scale(vOut : Vec2,f:Float,?vIn:Vec2) : Vec2
	{
		if( vIn == null)
			vIn = vOut;
		vOut.x = vIn.x * f;
		vOut.y = vIn.y * f;
		return vOut;
	}
	
	public static inline function add( VOut : Vec2, V0 : Vec2, V1 :  Vec2 ) :  Vec2
	{
		VOut.x = V0.x + V1.x;
		VOut.y = V0.y + V1.y;
		return VOut;
	}
	
	public static inline function sub(  V0 : Vec2, V1 :  Vec2, ?vOut : Vec2 ) : Vec2
	{
		if ( vOut == null) vOut = new Vec2();
		vOut.x = V0.x - V1.x;
		vOut.y = V0.y - V1.y;
		return vOut;
	}
	
	
	public inline function normalize( inOut : Vec2 ) : Vec2{
		var invLen = 1.0 / norm();
		x *= invLen;
		y *= invLen;
		return inOut;
	}
	
	public inline function safeNormalize( dflt : Vec2 ) : Vec2{
		var norm = norm();
		if( norm > MathEx.EPSILON )
		{
			var invLen = 1.0 / norm;
			
			x *= invLen;
			y *= invLen;
		}
		else
		{
			copy( dflt);
		}
		
		return this;
	}

	public function toString()
	{
		return "Vec2(" + MathEx.trunk(x, 1) + "," + MathEx.trunk(y, 1);
	}
	
	public static inline function dist2( v0 : Vec2, v1 :  Vec2 ) : Float
	{
		return ( (v1.x - v0.x) * (v1.x - v0.x) ) + ( (v1.y - v0.y) * (v1.y - v0.y) );
	}
	
	public inline function isNear( v0 : Vec2, r : Float = 10e-3 )
	{
		return dist( this, v0 ) <= r;
	}
	
	public static inline function dist( v0 : Vec2, v1 :  Vec2 ) : Float
	{
		return Math.sqrt( dist2( v0 , v1 ) );
	}
	
	public static inline function unit( angle :Float )
	{
		return new Vec2( Math.cos( angle ), Math.sin( angle ) );
	}
	
	public inline function rotation(a:Float) {
		var ca = Math.cos(a);
		var sa = Math.sin(a);
		return new Vec2( x * ca - y * sa, x * sa + y *ca );
	}
	
	public inline function rotate(a:Float) {
		var ca = Math.cos(a);
		var sa = Math.sin(a);
		var ox = x;
		var oy = y;
		
		x = ca * ox - sa * oy;
		y = sa * ox + ca * oy;
		return this;
	}
	
	public inline function rotationPoint(p:Vec2,a:Float) {
		return rotationPointXY(p.x,p.y,a);
	}
	
	public inline function rotationPointXY(px:Float,py:Float,a:Float) {
		var t = new Vec2();
		t.x = x - px;
		t.y = y - py;
		t.rotate( a );
		return t.incrXY( px, py );
	}
	
	public static inline function lerp(v0:Vec2, v1:Vec2, r:Float) {
		return new Vec2( v0.x * r + (1 - r) * v1.x, v0.y * r + (1 - r) * v1.y);
	}
	
	public static var ZERO 		: Vec2 = new Vec2(0, 0);
	public static var ONE 		: Vec2 = new Vec2(1, 1);
	public static var HALF 		: Vec2 = new Vec2(0.5, 0.5);
}
