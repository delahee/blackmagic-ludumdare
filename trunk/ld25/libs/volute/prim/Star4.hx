package volute.prim;

import Types;

/**
 * ...
 * @author de
 */

class Star4 extends Shape
{
	static var vtx = [
	[1,2],	
	[3,3],	
	[1,4], 	
	[0,6],
	[-1,4],
	[-3,3],
	[-1,2],	
	[0, 0],
	];
	
	public function new() 
	{
		super();
		
		var gfx = graphics;
		//	 *
		//  / \
		//*-----*
		//	\ /
		//   *  
		//
		
		var c = 5;
		var dx = 0; var dy = -3;
		
		gfx.beginFill(0xFFffFF);
		for( v in vtx )
			gfx.lineTo(v[0]*c, v[1]*c);
		gfx.endFill();
		
		this.cacheAsBitmap = true;
		//gfx.moveTo( -width / 2, -height / 2);
	}
	
}