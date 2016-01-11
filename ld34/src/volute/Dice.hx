package volute;

class Dice
{
	public static inline function roll( min :Int,max:Int, ?mr:volute.Rand ) : Int
	{
		return
		mr == null? Std.random( max - min +1 ) + min
		: mr.random( max - min +1 ) + min
		;
	}
	
	public static inline function percent( thresh : Float) : Bool
	{
		if ( thresh <= 0.5 - 0.001)
			return false;
		else
			return( roll( 1, 100) <= thresh);
	}
	
	public static inline function oneChance( qty : Int ) : Bool
		return roll( 1, qty) == qty;
		
	public static inline function D100( )
		return roll(  1, 100);
	
	public static inline function toss(?mr:volute.Rand)
		return Dice.roll(0, 1, mr) == 0;
	
	public static inline function rollF( min : Float, max:Float ) : Float{
		if ( max < min ) {
			var o = max;
			max = min; min = max;
		}
		return  Math.random() * (max - min) + min;
	}
	
	public static inline function randAngle() : Float {
		return rollF(0, Math.PI * 2);
	}
}	