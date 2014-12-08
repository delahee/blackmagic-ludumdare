package ;

/**
 * ...
 * @author 
 */
class C {
	public static inline var W = 800;
	public static inline var H = 800;
	public static inline var BAND_H = 100;
	
	public static inline var CHAR_W = 200;
	
	public static inline var CW = W - (BAND_H << 1);
	public static inline var CH = H - (BAND_H<<1);
	
	public static inline var CHAR_Y = H - (BAND_H << 1) - 64;
	public static inline var NMY_Y = 300;
	
	public static inline var CHANGE_LIGHT_DUR = 2.0;
	public static inline var FPS = 30.0;
	public static inline var SWAP_DUR = 300;
}