package volute.postfx;

/**
 * ...
 * @author de
 */

class Greyscale
{
	var cmf : flash.filters.ColorMatrixFilter;
	static var grayMatrix :Array<Float> = [
	  0.3, 0.59, 0.11, 0, 0,
	  0.3, 0.59, 0.11, 0, 0,
	  0.3, 0.59, 0.11, 0, 0,
	  0,    0,    0,    1, 0];
	  
	public function new() 
	{
		cmf = new flash.filters.ColorMatrixFilter(grayMatrix);
	}
	
	public function get()
	{
		return cmf;
	}
}