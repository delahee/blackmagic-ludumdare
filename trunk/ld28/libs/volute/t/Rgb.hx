package volute.t;

class Rgb
{
	public var v : UInt; 
	
	public var r(get, set):UInt;
	public var g(get, set):UInt;
	public var b(get, set):UInt;
	
	public var rf(get, set):Float;
	public var gf(get, set):Float;
	public var bf(get, set):Float;

	static inline var D = 1.0 / 255.0;
	
	public inline function new(v : UInt = 0xFFFFFF)
		this.v = v
	
	public inline function get_r() return (v & 0xFF0000) >> 16
	public inline function get_g() return (v & 0x00FF00) >> 8 
	public inline function get_b() return v & 0xFF
	
	public inline function set_r(i)			return v = (v & 0x00FFFF) | (i << 16)
	public inline function set_g(i)			return v = (v & 0xFF00FF) | (i << 8)
	public inline function set_b(i)			return v = (v & 0xFFFF00) 
	
	public inline function get_rf() return get_r() * D
	public inline function get_gf() return get_g() * D
	public inline function get_bf() return get_b() * D
	
	public inline function set_rf(i:Float)			return set_r( Std.int(i * 255 ))
	public inline function set_gf(i:Float)			return set_g( Std.int(i * 255 ))
	public inline function set_bf(i:Float)			return set_b( Std.int(i * 255 ))
	
	public function ofFloats(r=1.,g=1.,b=1.){
		this.r = Std.int(r * 255);
		this.g = Std.int(g * 255);
		this.b = Std.int(b * 255);
	}
	
	public function OfInts(r=255,g=255,b=255){
		this.r = r;
		this.g = g;
		this.b = b;
	}
}