package volute;

class Bits{
	public static inline function set( _v : Int , _i : Int) : Int 						
		return _v | _i;
	public static inline function has( _v : Int , _i : Int) : Bool					
		return  (_v & _i) == _i;
	public static inline function clear( _v : Int, _i : Int) : Int 				
		return (_v & ~_i);
	public static inline function neg(  _i : Int) : Int								
		return ~_i;
	public static inline function toggle( _v : Int , _onoff : Bool, _i : Int) : Int 
		return 	_onoff ? bitSet(_v,  _i) : bitClear(_v, _i);
	
}