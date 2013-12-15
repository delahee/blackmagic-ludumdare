package volute;
import haxe.PosInfos;
import volute.Types;

class Lib 
{
	public static inline function w() return 320;
	public static inline function h() return 320;
	
	
	/**
	 * return a iota between two value
	 * @param	max exclusive hi bound
	 */
	public static inline function rangeMinMax(min:Int,max:Int){
		var a = [];
		for ( i in min...max)
			a.push(i);
		return a;
	}
	
	public static function splat( v:  Int,n:Int){
		var a = [];
		for ( i in 0...n) a.push( v );
		return a;
	}
	
	//courtesy of deepnight
	public static inline function rad(a:Float) : Float {
		return a*3.1416/180;
	}
	
	public static inline function deg(a:Float) : Float {
		return a*180/3.1416;
	}
	
}