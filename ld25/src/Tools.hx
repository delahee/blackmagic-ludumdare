using volute.com.Ex;

class Tools 
{
	public static function mkStatic(d:flash.display.Sprite)
	{
		d.mouseEnabled  = false;
		return d;
	}

	public static function w() return Std.int(flash.Lib.current.stage.stageWidth)
	public static function h() return Std.int(flash.Lib.current.stage.stageHeight)
	
	public static function gw() return w()>>1
	public static function gh() return h()>>1
	
	public static function lw() return gw()<< 2 
	public static function lh() return gh()
	
	public static function cw() return gw()>>4
	public static function ch() return gh()>>4
	
	public static inline function rangeMinMax(min:Int,max:Int)
	{
		var a = [];
		for ( i in min...max)
			a.pushBack(i);
		return a;
	}
	
	public static inline function intRange(nb:Int,st=0)
	{
		var a = [];
		for ( i in 0...nb)
			a.pushBack(i+st);
		return a;
	}
	
	public static function assert( v:  Null<Dynamic>,?msg )
	{
		if ( v == null || v == false )
			throw "assert "+msg==null?"":msg;
	}
	
	public static function splat( v:  Int,n:Int)
	{
		var a = [];
		for ( i in 0...n)
			a.push( v );
		return a;
	}
}