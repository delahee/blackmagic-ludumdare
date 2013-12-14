package volute.scene;
import com.Dice;
import flash.display.Sprite;
import postfx.Bloom;

using com.Ex;

/**
 * ...
 * @author de
 */

class FallingStar extends Scene
{
	public var stars : algo.Pool<prim.Star4>;
	
	public function new() 
	{
		super();
		stars = new algo.Pool( function() return new prim.Star4() );
		mkStars();
	}
	
	function mkStars()
	{
		function c( i )
			return new t.Rgb(i);
			
		var r = [ 0xFFFFFF,0xFFCCAA].map(c).array();
		for ( i in 0...10)
		{
			var s = stars.create();
			s.x += i * Lib.w() / 10;
					
			var c = r.rd();
			var ctr = new flash.geom.ColorTransform();
			ctr.redMultiplier = c.rf;
			ctr.greenMultiplier = c.gf;
			ctr.blueMultiplier = c.bf;
			s.transform.colorTransform = ctr;
			
			addChild( s );
		}
		
		//filters = [ new postfx.Greyscale().get() ];
	}
	
	override function update(_)
	{
		for ( s in stars.getUsed() )
		{
			s.y+=0.2;
			s.rotationZ++;
		}
	}
	
}