﻿/*
 * FROM POLYGONAL - A HAXE LIBRARY FOR GAME DEVELOPERS
 * Copyright (c) 2009-2010 Michael Baczynski, http://www.polygonal.de
 */
package mt;

import haxe.macro.Expr;

class MLib
{
	/**
	 * Min value, signed byte.
	 */
	inline public static var INT8_MIN =-0x80;

	/**
	 * Max value, signed byte.
	 */
	inline public static var INT8_MAX = 0x7F;

	/**
	 * Max value, unsigned byte.
	 */
	inline public static var UINT8_MAX = 0xFF;

	/**
	 * Min value, signed short.
	 */
	inline public static var INT16_MIN =-0x8000;

	/**
	 * Max value, signed short.
	 */
	inline public static var INT16_MAX = 0x7FFF;

	/**
	 * Max value, unsigned short.
	 */
	inline public static var UINT16_MAX = 0xFFFF;

	/**
	 * Min value, signed integer.
	 */
	inline public static var INT32_MIN =
	#if cpp
	//warning: this decimal constant is unsigned only in ISO C90
	-0x7fffffff;
	#elseif(neko && !neko_v2)
	0xc0000000;
	#else
	0x80000000;
	#end

	/**
	 * Max value, signed integer.
	 */
	inline public static var INT32_MAX = #if(neko && !neko_v2) 0x3fffffff #else 0x7fffffff#end;

	/**
	 * Max value, unsigned integer.
	 */
	inline public static var UINT32_MAX =  #if(neko && !neko_v2) 0x3fffffff #else 0xffffffff#end;

	/**
	 * Number of bits using for representing integers.
	 */
	inline public static var INT_BITS =	#if (neko && neko_v2)
											32;
										#elseif(neko)
											31;
										#else
											32;
										#end

	/**
	 * The largest representable number (single-precision IEEE-754).
	 */
	inline public static var FLOAT_MAX = 3.4028234663852886e+38;

	/**
	 * The smallest representable number (single-precision IEEE-754).
	 */
	inline public static var FLOAT_MIN = -3.4028234663852886e+38;

	/**
	 * The largest representable number (double-precision IEEE-754).
	 */
	inline public static var DOUBLE_MAX = 1.7976931348623157e+308;

	/**
	 * The smallest representable number (double-precision IEEE-754).
	 */
	inline public static var DOUBLE_MIN = -1.7976931348623157e+308;
	
	/**
	 * IEEE 754 NAN.
	 */
	#if !flash
	inline public static function NaN() { return Math.NaN; }
	#else
	inline public static function NaN() { return .0 / .0; }
	#end
	/**
	 * IEEE 754 positive infinity.
	 */
	#if !flash
	inline public static function POSITIVE_INFINITY() { return Math.POSITIVE_INFINITY; }
	#else
	inline public static function POSITIVE_INFINITY() { return  1. / .0; }
	#end
	/**
	 * IEEE 754 negative infinity.
	 */
	#if !flash
	inline public static function NEGATIVE_INFINITY() { return Math.NEGATIVE_INFINITY; }
	#else
	inline public static function NEGATIVE_INFINITY() { return -1. / .0; }
	#end
	
	/**
	 * Multiply value by this constant to convert from radians to degrees.
	 */
	inline public static var RAD_DEG = 180 / PI;
	
	/**
	 * Multiply value by this constant to convert from degrees to radians.
	 */
	inline public static var DEG_RAD = PI / 180;
	
	/**
	 * The natural logarithm of 2.
	 */
	inline public static var LN2 = 0.6931471805599453;
	
	/**
	 * Math.PI / 2.
	 */
	inline public static var PIHALF = 1.5707963267948966;
	
	/**
	 * Math.PI.
	 */
	inline public static var PI = 3.141592653589793;
	
	/**
	 * 2 * Math.PI.
	 */
	inline public static var PI2 = 6.283185307179586;
	
	/**
	 * Default system epsilon.
	 */
	inline public static var EPS = 1e-6;
	
	/**
	 * The square root of 2.
	 */
	inline public static var SQRT2 = 1.414213562373095;
	
	/**
	 * Converts deg to radians.
	 */
	inline public static function toRad(deg:Float):Float
	{
		return deg * MLib.DEG_RAD;
	}
	
	/**
	 * Converts rad to degrees.
	 */
	inline public static function toDeg(rad:Float):Float
	{
		return rad * MLib.RAD_DEG;
	}
	
	/**
	 * Returns min(x, y).
	 */
	inline public static function min(x:Int, y:Int):Int
	{
		return x < y ? x : y;
	}
	
	/**
	 * Returns max(x, y).
	 */
	inline public static function max(x:Int, y:Int):Int
	{
		return x > y ? x : y;
	}
	
	/**
	 * Returns the absolute value of x.
	 */
	inline public static function iabs(x:Int):Int
	{
		return x < 0 ? -x : x;
	}
	
	/**
	 * Returns the sign of x.
	 * sgn(0) = 0.
	 */
	inline public static function sgn(x:Int):Int
	{
		return (x > 0) ? 1 : (x < 0 ? -1 : 0);
	}
	
	/**
	 * Clamps x to the interval so min <= x <= max.
	 */
	inline public static function clamp(x:Int, min:Int, max:Int):Int
	{
		return (x < min) ? min : (x > max) ? max : x;
	}
	
	/**
	 * Clamps x to the interval so -i <= x <= i.
	 */
	inline public static function clampSym(x:Int, i:Int):Int
	{
		return (x < -i) ? -i : (x > i) ? i : x;
	}
	
	/**
	 * Wraps x to the interval so min <= x <= max.
	 */
	inline public static function wrap(x:Int, min:Int, max:Int):Int
	{
		return x < min ? (x - min) + max + 1: ((x > max) ? (x - max) + min - 1: x);
	}
	
	/**
	 * Fast replacement for Math.min(x, y).
	 */
	inline public static function fmin(x:Float, y:Float):Float
	{
		return x < y ? x : y;
	}
	
	/**
	 * Fast replacement for Math.max(x, y).
	 */
	inline public static function fmax(x:Float, y:Float):Float
	{
		return x > y ? x : y;
	}
	
	/**
	 * Fast replacement for Math.abs(x).
	 */
	inline public static function fabs(x:Float):Float
	{
		return x < 0 ? -x : x;
	}
	
	/**
	 * Extracts the sign of x.
	 * fsgn(0) = 0.
	 */
	inline public static function fsgn(x:Float):Int
	{
		return (x > 0.) ? 1 : (x < 0. ? -1 : 0);
	}
	
	/**
	 * Clamps x to the interval so min <= x <= max.
	 */
	inline public static function fclamp(x:Float, min:Float, max:Float):Float
	{
		return (x < min) ? min : (x > max) ? max : x;
	}
	
	/**
	 * Clamps x to the interval so -i <= x <= i.
	 */
	inline public static function fclampSym(x:Float, i:Float):Float
	{
		return (x < -i) ? -i : (x > i) ? i : x;
	}
	
	/**
	 * Wraps x to the interval so min <= x <= max.
	 */
	inline public static function fwrap(value:Float, lower:Float, upper:Float):Float
	{
		return value - (Std.int((value - lower) / (upper - lower)) * (upper - lower));
	}

	/**
	 * Returns true if the sign of x and y is equal.
	 */
	inline public static function eqSgn(x:Int, y:Int):Bool
	{
		return (x ^ y) >= 0;
	}
	
	/**
	 * Returns true if the sign of x and y is equal.
	 */
	inline public static function feqSgn(x:Float, y:Float):Bool
	{
		return x*y >= 0;
	}
	
	/**
	 * Returns true if x is even.
	 */
	inline public static function isEven(x:Int):Bool
	{
		return (x & 1) == 0;
	}
	
	/**
	 * Returns true if x is a power of two.
	 */
	inline public static function isPow2(x:Int):Bool
	{
		return x > 0 && (x & (x - 1)) == 0;
	}
	
	/**
	 * Returns the nearest power of two value
	 */
	inline public static function nearestPow2( x:Int )
	{
		return Math.pow( 2, Math.round( Math.log( x ) / Math.log( 2 ) ) );
	}

	/**
	 * Linear interpolation over interval a...b with t = 0...1
	 */
	inline public static function lerp(a:Float, b:Float, t:Float):Float
	{
		return a + (b - a) * t;
	}
	
	/**
	 * Spherically interpolates between two angles.
	 * See <a href="http://www.paradeofrain.com/2009/07/interpolating-2d-rotations/" target="_blank">http://www.paradeofrain.com/2009/07/interpolating-2d-rotations/</a>.
	 */
	inline public static function slerp(a:Float, b:Float, t:Float)
	{
		var m = Math;
		
        var c1 = m.sin(a * .5);
        var r1 = m.cos(a * .5);
		var c2 = m.sin(b * .5);
        var r2 = m.cos(b * .5);

       var c = r1 * r2 + c1 * c2;

        if( c < 0.)
		{
			if( (1. + c) > MLib.EPS)
			{
				var o = m.acos(-c);
				var s = m.sin(o);
				var s0 = m.sin((1 - t) * o) / s;
				var s1 = m.sin(t * o) / s;
				return m.atan2(s0 * c1 - s1 * c2, s0 * r1 - s1 * r2) * 2.;
			}
			else
			{
				var s0 = 1 - t;
				var s1 = t;
				return m.atan2(s0 * c1 - s1 * c2, s0 * r1 - s1 * r2) * 2;
			}
		}
		else
		{
			if( (1 - c) > MLib.EPS)
			{
				var o = m.acos(c);
				var s = m.sin(o);
				var s0 = m.sin((1 - t) * o) / s;
				var s1 = m.sin(t * o) / s;
				return m.atan2(s0 * c1 + s1 * c2, s0 * r1 + s1 * r2) * 2.;
			}
			else
			{
				var s0 = 1 - t;
				var s1 = t;
				return m.atan2(s0 * c1 + s1 * c2, s0 * r1 + s1 * r2) * 2;
			}
		}
	}
	
	/**
	 * Calculates the next highest power of 2 of x.
	 */
	inline public static function nextPow2(x:Int):Int
	{
		var t = x;
		t |= (t >> 0x01);
		t |= (t >> 0x02);
		t |= (t >> 0x03);
		t |= (t >> 0x04);
		t |= (t >> 0x05);
		return t + 1;
	}
	
	/**
	 * Fast integer exponentiation for base a and exponent n.
	 */
	inline public static function exp(a:Int, n:Int):Int
	{
		var t = 1;
		var r = 0;
		while (true)
		{
			if( n & 1 != 0) t = a * t;
			n >>= 1;
			if( n == 0)
			{
				r = t;
				break;
			}
			else
				a *= a;
		}
		return r;
	}
	
	/**
	 * Rounds x to the iterval y.
	 */
	inline public static function roundTo(x:Float, y:Float):Float
	{
		return round(x / y) * y;
	}
	
	/**
	 * Fast replacement for Math.round(x).
	 */
	inline public static function round(x:Float):Int
	{
		return Std.int(x > 0 ? x + .5 : x < 0 ? x - .5 : 0);
	}
	
	/**
	 * Fast replacement for Math.ceil(x).
	 */
	inline public static function ceil(x:Float):Int
	{
		if( x > .0)
		{
			var t = Std.int(x + .5);
			return (t < x) ? t + 1 : t;
		}
		else if( x < .0)
		{
			var t = Std.int(x - .5);
			return (t < x) ? t + 1 : t;
		}
		else
			return 0;
	}
	
	/**
	 * Fast replacement for Math.floor(x).
	 */
	inline public static function floor(x:Float) : Int {
		return
			if( x>=0 )
				Std.int(x);
			else {
				var i = Std.int(x);
				if( x==i )
					i;
				else
					i - 1;
			}
	}
	
	/**
	 * Computes the 'quake-style' fast inverse square root of x.
	 */
	inline public static function invSqrt(x:Float):Float
	{
		/*
		#if( flash10 && !no_alchemy)
		var xt = x;
		var half = .5 * xt;
		var i = floatToInt(xt);
		i = 0x5f3759df - (i >> 1);
		var xt = intToFloat(i);
		return xt * (1.5 - half * xt * xt);
		#else
		return 1 / Math.sqrt(x);
		#end
		*/
		return 1 / Math.sqrt(x);
	}
	
	/**
	 * Compares x and y using an absolute tolerance of eps.
	 */
	inline public static function cmpAbs(x:Float, y:Float, eps:Float):Bool
	{
		var d = x - y;
		return d > 0 ? d < eps : -d < eps;
	}
	
	/**
	 * Compares x to zero using an absolute tolerance of eps.
	 */
	inline public static function cmpZero(x:Float, eps:Float):Bool
	{
		return x > 0 ? x < eps : -x < eps;
	}
	
	/**
	 * Snaps x to the grid y.
	 */
	inline public static function snap(x:Float, y:Float):Float
	{
		return floor((x + y * .5) / y);
	}
	
	/**
	 * Returns true if min <= x <= max.
	 */
	inline public static function inRange(x:Float, min:Float, max:Float):Bool
	{
		return x >= min && x <= max;
	}
	
	/**
	 * Returns a pseudo-random integral value x, where 0 <= x < 0x7fffffff  0 <= x < 0x3FFFFFFF on Neko1
	 */
	inline public static function rand(?max:Int=#if neko 0x3FFFFFFF #else 0x7fffffff #end, ?rnd:Void->Float):Int
	{
		return Std.int(frand(rnd) * max);
	}
	
	/**
	 * Returns a pseudo-random integral value x, where min <= x <= max.
	 */
	inline public static function randRange(min:Int, max:Int, ?rnd:Void->Float):Int
	{
		var l = min - .4999;
		var h = max + .4999;
		return MLib.round(l + (h - l) * frand(rnd));
	}
	
	/**
	 * Returns a pseudo-random double value x, where -range <= x <= range.
	 */
	inline public static function randRangeSym(range:Int, ?rnd:Void->Float):Int
	{
		return randRange(-range, range, rnd);
	}
	
	/**
	 * Returns a pseudo-random double value x, where 0 <= x < 1.
	 */
	inline public static function frand(?rnd:Void->Float):Float
	{
		return
			if ( rnd == null )
				Math.random();
			else
				rnd();
	}
	
	/**
	 * Returns a pseudo-random double value x, where min <= x < max.
	 */
	inline public static function frandRange(min:Float, max:Float, ?rnd:Void->Float):Float
	{
		return min + (max - min) * frand(rnd);
	}
	
	/**
	 * Returns a pseudo-random double value x, where -range <= x < range.
	 */
	inline public static function frandRangeSym(range:Float, ?rnd:Void->Float):Float
	{
		return frandRange(-range, range, rnd);
	}
	
	/**
	 * Wraps an angle x to the range -PI...PI by adding the correct multiple of 2 PI.
	 */
	inline public static function wrapToPi(x:Float):Float
	{
		var t = round(x / PI2);
		return (x < -PI) ? (x - t * PI2) : (x > PI ? x - t * PI2 : x);
	}
	
	/**
	 * Wraps a number to the range -mod...mod
	 * Donne des résultats différents de budum9.Num.hMod mais devrait fonctionner en gros de la meme façon.
	 */
	inline public static function wrapTo(n:Float, mod:Float)
	{
		var t = round(n / mod);
		return (n < -2*mod) ? (n - t * mod) : (n > 2*mod ? n - t * mod : n);
	}
	
	/**
	 * Modulo simple
	 */
	inline static public function sMod(n:Float, mod:Float)
	{
		if ( mod != 0.0  )
		{
			while(n >= mod) n -= mod;
			while (n < 0) n += mod;
		}
		return n;
	}
	
	/**
	 * Module avec partie négative
	 */
	inline static public function hMod(n:Float, mod:Float)
	{
		while(n > mod) n -= mod*2;
		while(n < -mod) n += mod*2;
		return n;
	}
	
	/**
	 * Computes the greatest common divisor of x and y.
	 * See <a href="http://www.merriampark.com/gcd.htm" target="_blank">http://www.merriampark.com/gcd.htm</a>.
	 */
	inline public static function gcd(x:Int, y:Int):Int
	{
		var d = 0;
		var r = 0;
		x = MLib.iabs(x);
		y = MLib.iabs(y);
		while (true)
		{
			if( y == 0)
			{
				d = x;
				break;
			}
			else
			{
				r = x % y;
				x = y;
				y = r;
			}
		}
		return d;
	}
	
	/**
	 * Removes excess floating point decimal precision from x.
	 */
	inline public static function maxPrecision(x:Float, precision:Int):Float
	{
		if( x == 0)
			return x;
		else
		{
			var correction = 10;
			for (i in 0...precision - 1) correction *= 10;
			return round(correction * x) / correction;
		}
	}
	
	/**
	 * Converts the boolean expression x to an integer.
	 * @return 1 if x is true and zero if x is false.
	 */
	inline public static function ofBool(x:Bool):Int
	{
		return x ? 1 : 0;
	}
	
	/*
	 * Normalize the angle back to [-2PI,2PI]
	 * */
	public static inline function normAngle( f:  Float) {
		var pi = std.Math.PI;
		while (f >= pi * 2)
			f -= pi * 2;
		while (f <= -pi * 2)
			f += pi * 2;
			
		return f;
	}
	
	/**
	 * mod that allways returns a positive value ( neg % k -> neg )
	 */
	public static inline function posMod( i :Int,m:Int ){
		var mod = i % m;
		return (mod >= 0)
		? mod
		: mod + m;
	}
	

	/**
	 * Replaces pow(v, 3) by v*v*v at compilation time (macro), 17x faster results
	 * Limitations: "pow" must be a constant Int [0-256], no variable allowed
	 */
	macro public static function pow(v:Expr, power:Expr) {
		var pos = haxe.macro.Context.currentPos();
		var v = { expr:EParenthesis(v), pos:pos }
		
		var ipow = switch( power.expr ) {
			case EConst(CInt(v)) : Std.parseInt(v);
			default : haxe.macro.Context.error("You can only use a constant Int here", power.pos);
		}
		
		if( ipow<=0 || ipow>256 )
			haxe.macro.Context.error("Only values between [0-256] are supported", power.pos);
		
		function recur(n:Int) : Expr {
			if( n>1 )
				return {expr:EBinop(OpMult, v, recur(n-1)), pos:pos}
			else
				return v;
		}
		return recur(ipow);
	}
	
	public static inline function dist3Sq(x:Float, y:Float, z:Float) :Float
		return x * x + y * y + z * z;
		
	public static inline function dist3(x:Float, y:Float, z:Float):Float
		return Math.sqrt(dist3Sq(x, y, z));
	
	public static inline function dist2Sq(x:Float, y:Float ):Float
		return x * x + y * y;
		
	public static inline function dist2(x:Float, y:Float):Float
		return Math.sqrt(dist2Sq(x, y));
}