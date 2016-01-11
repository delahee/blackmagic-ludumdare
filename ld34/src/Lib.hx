
class Lib{

	public static inline function normAngle( f:  Float){
		while (f >= Math.PI * 2)
			f -= Math.PI * 2;
		while (f <= -Math.PI * 2)
			f += Math.PI * 2;
		return f;
	}
	
	public static inline function dt2Frame( dt:  Float ) : Float{
		if ( dt == 0)
			dt = 1.0 / C.FPS;
		var t = 1.0 / dt;
		var frame = t / C.FPS;
		return frame;
	}
	
}