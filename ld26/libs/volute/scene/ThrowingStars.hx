package volute.scene;

class ThrowingStars extends Scene
{
	var gr :  algo.Grid;
	var stars : algo.Pool < prim.Star4 >;
	
	public function new()
	{
		stars = new algo.Pool( function() return new prim.Star4() );
	}
}