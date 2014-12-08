
class Lib{

	public static inline function normAngle( f:  Float){
		while (f >= Math.PI * 2)
			f -= Math.PI * 2;
		while (f <= -Math.PI * 2)
			f += Math.PI * 2;
		return f;
	}
	
}