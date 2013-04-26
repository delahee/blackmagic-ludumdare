package volute.t;


//does not work because of uint handling
class Rgba
{
	public var v : UInt; 
	
	public var r(get, set):UInt;
	public var g(get, set):UInt;
	public var b(get, set):UInt;
	public var a(get, set):UInt;
	
	public var rf(get, set):Float;
	public var gf(get, set):Float;
	public var bf(get, set):Float;
	public var af(get, set):Float;

	static inline var D = 1.0 / 255.0;
	
	public inline function new(v : UInt = 0xFFFFFFFF)
	{
		this.v = v;
		trace( get_r() );
	}

	public inline function toArgb() return ((v & 0xFF) << 24) | (v >> 8)
	
	public inline function get_r() return (v&0xFF000000)>>24
	public inline function get_g() return (v & 0x00FF0000) >> 16 
	public inline function get_b() return (v & 0x0000FF00) >> 8
	public inline function get_a() return v&0xFF
	
	public inline function set_r(i)			return v = (v & 0x00FFFFFF) | (i << 24)
	public inline function set_g(i)			return v = (v & 0xFF00FFFF) | (i << 16)
	public inline function set_b(i)			return v = (v & 0xFFFF00FF) | (i << 8)
	public inline function set_a(i)			return v = (v & 0xFFFFFF00) | i
	
	public inline function get_rf() return get_r() * D
	public inline function get_gf() return get_g() * D
	public inline function get_bf() return get_b() * D
	public inline function get_af() return get_a() * D
	
	public inline function set_rf(i:Float)			return set_r( Std.int(i * 255 ))
	public inline function set_gf(i:Float)			return set_g( Std.int(i * 255 ))
	public inline function set_bf(i:Float)			return set_b( Std.int(i * 255 ))
	public inline function set_af(i:Float)			return set_a( Std.int(i * 255 ))
	
	public function ofFloats(r=1.,g=1.,b=1.,a=1.){
		this.r = Std.int(r * 255);
		this.g = Std.int(g * 255);
		this.b = Std.int(b * 255);
		this.a = Std.int(a * 255);
	}
	
	public function OfInts(r=255,g=255,b=255,a=255){
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}
}